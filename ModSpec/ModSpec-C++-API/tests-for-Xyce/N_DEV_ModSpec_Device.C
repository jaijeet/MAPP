#include <Xyce_config.h>

#include <N_DEV_ModSpec_Device.h>

#include <N_DEV_DeviceOptions.h>
#include <N_DEV_ExternData.h>
#include <N_DEV_Message.h>
#include <N_DEV_SolverState.h>
#include <N_ERH_ErrorMgr.h>

#include <N_LAS_Matrix.h>
#include <N_LAS_Vector.h>

namespace Xyce {
namespace Device {

template<>
ParametricData<ModSpecParamData>::ParametricData()
{
    addPar("NAME", "UNDEFINED", &ModSpecParamData::name);
    addPar("VALUE", 0.0, &ModSpecParamData::value);
}

ParametricData<ModSpecParamData> &ModSpecParamData::getParametricData()
{
    static ParametricData<ModSpecParamData> parMap;
    return parMap;
}

ModSpecParamData::ModSpecParamData()
    : CompositeParam(getParametricData()),
        name(""),
        value(0.0)
{}

void ModSpecParamData::processParams ()
{
}

std::ostream & operator<<(std::ostream & os, const ModSpecParamData & mpd)
{
    os << " ModSpecParamData: name = " << mpd.getName() <<
        " value=" << mpd.getValue() <<
        std::endl;
    return os;
}

namespace ModSpec_Device {

vector<vector<int> > Instance::jacStamp;

void Traits::loadInstanceParameters(ParametricData<ModSpec_Device::Instance> &p)
{
    p.addComposite("PARAM", ModSpecParamData::getParametricData(), &ModSpec_Device::Instance::ModSpecParamDataMap);
}

void Traits::loadModelParameters(ParametricData<ModSpec_Device::Model> &p)
{
    p.addPar("SONAME", "", &ModSpec_Device::Model::SONAME)
        .setUnit(U_NONE)
        .setDescription("Name of the ModSpec .so library");
}

Instance::Instance(
    const Configuration & configuration,
    const InstanceBlock & instance_block,
    Model &                             model,
    const FactoryBlock &    factory_block)
    : DeviceInstance(instance_block, configuration.getInstanceParameters(), factory_block),
        model_(model),
        temp(0.0)
{
    char const* dirname = std::getenv("MODSPEC_SO_DIR"); 
    std::string soPath = dirname == NULL? std::string() : std::string(dirname);
    if (!soPath.empty())
        soPath += "/";
    else
        soPath = "./";
    soPath += model_.SONAME;

    XMIp = new Xyce_ModSpec_Interface(soPath); 
    ModSpecElPtr = XMIp->ModSpecElPtr;

    numExtVars = XMIp->numExtVars;
    numIntVars = XMIp->numIntVars;

    numStateVars = 0; // Tianshi: ModSpec doesn't have this information right now.

    setNumStoreVars(XMIp->nl);

    numLeadCurrentStoreVars = 0; // Tianshi: ModSpec doesn't have this information right now.
    setNumBranchDataVars(0); // Tianshi: ModSpec doesn't have this information right now.
    numBranchDataVarsIfAllocated = 0;

    if (jacStamp.empty())
    {
        jacStamp = XMIp->jacStamp_Xyce_fq;
    }

    // Set params to constant default values from parameter definition
    setDefaultParams();

    // Set params according to instance line and constant defaults from metadata
    setParams(instance_block.params);

    // ModSpec parameters are handled here:
    vector<untyped> parms = ModSpecElPtr->getparms();
    for (int i = 0; i < ModSpecParamDataVec.size(); i++) {
        ModSpecParamData *mpd = ModSpecParamDataVec[i];
        // cout << "Tianshi: " << *mpd << endl;
        std::string pname = mpd->getName();
        untyped pval = mpd->getValue();
        ModSpecElPtr->setparm(pname, pval);
    }

    updateDependentParameters();

    processParams();
}

bool Instance::processParams(string param)
{
    return updateTemperature(temp);
}

void Instance::registerLIDs(
    const vector<int> & intLIDVecRef,
    const vector<int> & extLIDVecRef)
{
    string msg;

#ifdef Xyce_DEBUG_DEVICE
    const string dashedline =
        "-----------------------------------------------------------------------------";
    if (getDeviceOptions().debugLevel > 0)
    {
        cout << endl << dashedline << endl;
        cout << "    ModSpec_DeviceInstance::registerLIDs" << endl;
        cout << "    name = " << getName() << endl;
    }
#endif

    // Check if the size of the ID lists corresponds to the
    // proper number of internal and external variables.
    int numInt = intLIDVecRef.size();
    int numExt = extLIDVecRef.size();

    if (numInt != numIntVars)
    {
        msg = "ModSpec_Device::Instance::registerLIDs:";
        msg += "numInt != numIntVars";
        N_ERH_ErrorMgr::report(N_ERH_ErrorMgr::DEV_FATAL,msg);
    }

    if (numExt != numExtVars)
    {
        msg = "ModSpec_DeviceInstance::registerLIDs:";
        msg += "numExt != numExtVars";
        N_ERH_ErrorMgr::report(N_ERH_ErrorMgr::DEV_FATAL,msg);
    }

    // Copy the local ID lists.
    intLIDVec = intLIDVecRef;
    extLIDVec = extLIDVecRef;

    XMIp->setup_eqnunkidx_to_LID_maps(this->extLIDVec, this->intLIDVec);
}

void Instance::registerStateLIDs(const vector<int> & staLIDVecRef)
{
    AssertLIDs(staLIDVecRef.size() == getNumStateVars());
}

void Instance::registerStoreLIDs(const vector<int> & stoLIDVecRef)
{
    AssertLIDs(stoLIDVecRef.size() == getNumStoreVars());
    stoLIDVec = stoLIDVecRef;
}

void Instance::registerJacLIDs(const vector< vector<int> > & jacLIDVec)
{
    // Let DeviceInstance do its work.
    DeviceInstance::registerJacLIDs(jacLIDVec);
}

void Instance::registerBranchDataLIDs(const std::vector<int> & branchLIDVecRef)
{
    AssertLIDs(branchLIDVecRef.size() == getNumBranchDataVars());
}

void Instance::setupPointers ()
{
    N_LAS_Matrix * dFdxMatPtr = extData.dFdxMatrixPtr;
    N_LAS_Matrix * dQdxMatPtr = extData.dQdxMatrixPtr;

    // define a local class specializing XMI_local::_rREPclassGeneric to access dFdxMatPtr->returnRawEntryPointer()
    class _rREPclass: public XMI_local::_rREPclassGeneric {
        private:
            N_LAS_Matrix* _matPtr;
        public:
            _rREPclass(N_LAS_Matrix* matPtr): _matPtr(matPtr){};
            ~_rREPclass() {}
            double* returnRawEntryPointer(int i, int j) {return _matPtr->returnRawEntryPointer(i,j);} // specializes 
                    // XMI_local::_rREPclassGeneric's pure virtual function
    };

    // instantiate class instances for dFdxMatPtr and dQdxMatPtr
    _rREPclass oofF(dFdxMatPtr);
    _rREPclass oofQ(dQdxMatPtr);

    // pass the above to setup_dFQdxMat_ptrs to up dFdxMat_ptrs and dqdxMat_ptrs within XMIp
    XMIp->setup_dFQdxMat_ptrs(oofF, oofQ);
}

void Instance::loadNodeSymbols(Util::SymbolTable &symbol_table) const
{
    std::vector<std::string> InternalUnkNames = ModSpecElPtr->InternalUnkNames();

    for (int i=0; i< InternalUnkNames.size(); i++) {
        addInternalNode(symbol_table, this->intLIDVec[i], getName(), InternalUnkNames[i]);
        // Tianshi: TODO: this is a hack, since ModSpec doesn't have
        //   information about internal nodes, internal unk names are used here
    }
}

bool Instance::updateIntermediateVars()
{
    bool bsuccess = true;

    double * solVec = extData.nextSolVectorRawPtr; // direct access to the unknown vector, using LIDs

    vector<double> vecE, vecI, vecY;
    XMIp->vecEIY_from_solVec(/* outputs */ vecE, vecI, vecY, /* inputs */ solVec);

    bool do_init = false;
    bool do_limiting = false;
    double * stoVec;
    vector<double> vecLimOld;
    vector<double> vecLimInit;

    bool OFF = false; // Tianshi: always not OFF for ModSpec devices right now.
    bool IC_GIVEN = false; // Tianshi: always not IC_GIVEN for ModSpec devices right now.

    if (getSolverState().initJctFlag && !OFF && getDeviceOptions().voltageLimiterFlag) {
        if (IC_GIVEN) {
        }
        else {
            if (getSolverState().inputOPFlag) {
                // Tianshi:
                // if one or more of *flagSolVectorPtr)[li_xxx] == 0, we should do
                //    do_init = true;
                //    vector<double> vecU;
                //    vecLimInit = XMIp->ModSpecElPtr->initGuess(vecU);
                // This is skipped for the moment.
            } else {
                do_init = true;
                vector<double> vecU;
                vecLimInit = XMIp->ModSpecElPtr->initGuess(vecU);
            }
        }
    }
    else if ((getSolverState().initFixFlag || getSolverState().initJctFlag) && OFF) {
        // Tianshi: should evaluate everything at 0 because of OFF; won't happen
        //   with ModSpec devices at this moment.
        do_init = true;
        for (int i=0; i < XMIp->nl; i++) vecLimInit.push_back(0);
    }

    if (getSolverState().newtonIter == 0)
    {
        if (!getSolverState().dcopFlag || (getSolverState().locaEnabledFlag && getSolverState().dcopFlag)) {
        // ie, first newton step of a transient time step or DCOP continuation step.
            stoVec = extData.currStoVectorRawPtr;
            for (int i=0; i < XMIp->nl; i++) vecLimOld.push_back(stoVec[this->stoLIDVec[i]]);
        }
        else {
            // no history
            vector<double> vecX; 
            vecX = add( prod(XMIp->A_E, vecE) , prod(XMIp->A_I, vecI) );
            // vecY is already set up above
            vecLimOld = XMIp->ModSpecElPtr->vecXYtoLimitedVars(vecX, vecY); 
        }
    } else {
        stoVec = extData.nextStoVectorRawPtr;
        for (int i=0; i < XMIp->nl; i++) vecLimOld.push_back(stoVec[this->stoLIDVec[i]]);
    }

    if (getDeviceOptions().voltageLimiterFlag && !(getSolverState().initFixFlag && OFF)) {
        if (getSolverState().newtonIter >= 0 && !(getSolverState().initJctFlag)) {
            do_limiting = true;
        }
    }

    if (do_init) {
        vecLimOld = vecLimInit;
    }

    XMIp->compute_fq(vecE, vecI, vecY, vecLimOld, do_init, do_limiting);
    XMIp->compute_jac_fq(vecE, vecI, vecY, vecLimOld, do_init, do_limiting);

    if (do_init || do_limiting) {
        double * stoVec = extData.nextStoVectorRawPtr;
        for (int i=0; i < XMIp->nl; i++) stoVec[this->stoLIDVec[i]] = XMIp->vecLimNew[i];
    }

    return bsuccess;
}

bool Instance::updatePrimaryState()
{
    return updateIntermediateVars();
}

bool Instance::loadDAEFVector()
{
    double * fVec = extData.daeFVectorRawPtr;

    int numXyceVars = XMIp->n +1 +XMIp->n - XMIp->l + XMIp->l_v + XMIp->m;
    for (int i=0; i < numXyceVars; i++)
            fVec[XMIp->eqnidx_to_LID_map[i]] += XMIp->f[i];
    
    return true;
}

bool Instance::loadDAEdFdx()
{

    double* ptr;
    for (int i=0; i < XMIp->jac_f.size1(); i++) {
        const spVector& the_row = row(XMIp->jac_f, i);
        int nnzs = the_row.nnz();
        if (nnzs > 0) {
            for (spVector::const_iterator it2 = the_row.begin(); it2 != the_row.end(); it2++) {
                int j = it2.index();
                ptr = XMIp->dFdxMat_ptrs(i,j);
                if (NULL != ptr) 
                        *ptr += XMIp->jac_f(i,j);
                else {
                        fprintf(stderr, "ERROR: jac_f has a nonzero entry at (%d,%d) but dFdxMat_ptrs(%d,%d)=NULL\n", i,j,i,j);
                }
             }
        }
    }
    return true;
}

bool Instance::loadDAEQVector() 
{
    double * qVec = extData.daeQVectorRawPtr;

    int numXyceVars = XMIp->n +1 +XMIp->n - XMIp->l + XMIp->l_v + XMIp->m;
    for (int i=0; i < numXyceVars; i++)
            qVec[XMIp->eqnidx_to_LID_map[i]] += XMIp->q[i];
    
    return true;
}

bool Instance::loadDAEdQdx() // 
{
    double* ptr;
    for (int i=0; i < XMIp->jac_q.size1(); i++) {
        const spVector& the_row = row(XMIp->jac_q, i);
        int nnzs = the_row.nnz();
        if (nnzs > 0) {
            for (spVector::const_iterator it2 = the_row.begin(); it2 != the_row.end(); it2++) {
                int j = it2.index();
                ptr = XMIp->dQdxMat_ptrs(i,j);
                if (NULL != ptr) 
                    *ptr += XMIp->jac_q(i,j);
                else {
                    fprintf(stderr, "ERROR: jac_q has a nonzero entry at (%d,%d) but dQdxMat_ptrs(%d,%d)=NULL\n", i,j,i,j);
                }
            }
        }
    }
    return true;
}

bool Instance::updateTemperature(const double & temp_tmp)
{
    return true;
}

CompositeParam * Instance::constructComposite(const std::string & cName, const std::string & pName)
{
    if (cName == "PARAM")
    {
        ModSpecParamData *mpd = new ModSpecParamData();
        ModSpecParamDataVec.push_back(mpd);
        return (static_cast<CompositeParam *> (mpd));
    }
    else
    {
        std::string msg =
            "Instance::constructComposite: unrecognized composite name: ";
        msg += cName;
        N_ERH_ErrorMgr::report ( N_ERH_ErrorMgr::DEV_FATAL,msg);
    }
    // never reached
    return NULL;
}

bool Model::processParams()
{
    return true;
}

bool Model::processInstanceParams()
{
    for (InstanceVector::const_iterator it = instanceContainer.begin(); it != instanceContainer.end(); ++it)
    {
        (*it)->processParams();
    }

    return true;
}

Model::Model(
    const Configuration & configuration,
    const ModelBlock &        model_block,
    const FactoryBlock &    factory_block)
    : DeviceModel(model_block, configuration.getModelParameters(), factory_block),
        SONAME("")
{

    // the constructor above sets up a good bit of stuff - Jacobian Stamps
    // and the like.
    // Set params to constant default values.
    setDefaultParams();

    // Set params according to .model line and constant defaults from metadata.
    setModParams(model_block.params);

    // Calculate any parameters specified as expressions.
    updateDependentParameters();

    // calculate dependent (ie computed) params and check for errors.
    processParams();
}

Model::~Model()
{
    // Destory all owned instances
    for (InstanceVector::const_iterator it = instanceContainer.begin(); it != instanceContainer.end(); ++it)
    {
        delete (*it);
    }
}

std::ostream &Model::printOutInstances(std::ostream &os) const
{
    os << std::endl;
    os << "Number of ModSpec_Device Instances: " << instanceContainer.size() << std::endl;
    os << "        name         model name    Parameters" << std::endl;

    int i = 0;
    for (InstanceVector::const_iterator it = instanceContainer.begin(); it != instanceContainer.end(); ++it)
    {
        os << "    " << i << ": " << (*it)->getName() << "\t";
        os << getName();
        os << std::endl;
        ++i;
    }

    os << std::endl;

    return os;
}

void Model::forEachInstance(DeviceInstanceOp &op) const /* override */ 
{
    for (std::vector<Instance *>::const_iterator it = instanceContainer.begin(); it != instanceContainer.end(); ++it)
        op(*it);
}

Device *
Traits::factory(const Configuration &configuration, const FactoryBlock &factory_block)
{
    return new Master(configuration, factory_block, factory_block.solverState_, factory_block.deviceOptions_);
}

void
registerDevice()
{
    Config<Traits>::addConfiguration()
        .registerDevice("ModSpec_Device", 1)
        .registerModelType("ModSpec_Device", 1);
}

} // namespace ModSpec_Device
} // namespace Device
} // namespace Xyce
