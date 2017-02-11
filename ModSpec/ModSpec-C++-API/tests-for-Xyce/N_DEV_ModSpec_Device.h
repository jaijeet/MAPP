#ifndef Xyce_N_DEV_ModSpec_Device_h
#define Xyce_N_DEV_ModSpec_Device_h

#include <N_DEV_fwd.h>
#include <N_DEV_Configuration.h>
#include <N_DEV_DeviceInstance.h>
#include <N_DEV_DeviceModel.h>
#include <N_DEV_DeviceMaster.h>
#include <N_DEV_CompositeParam.h>

#include "Xyce_ModSpec_Interface.h"

namespace Xyce {
namespace Device {

class ModSpecParamData : public CompositeParam
{
    friend class ParametricData<ModSpecParamData>;

public:
    static ParametricData<ModSpecParamData> &getParametricData();

    ModSpecParamData();

    void processParams();
    friend std::ostream & operator<<(std::ostream & os, const ModSpecParamData & xcd);

private:
    std::string name;
    double value;

public:
    std::string getName() const { return name;};
    double getValue() const { return value;};
};


namespace ModSpec_Device {

class Model;
class Instance;

struct Traits : public DeviceTraits<Model, Instance>
{
    static const char *name() {return "ModSpec_Device";}
    static const char *deviceTypeName() {return "ModSpec Device";}
    static int numNodes() {return 2;}
    static int numOptionalNodes() {return 1000;} // Tianshi: hard-coded, from N_DEV_Xygra.h
    static const char *primaryParameter() {return "PARAM";}
    static const char *instanceDefaultParameter() {return "PARAM";}
    static bool isLinearDevice() {return false;}

    static Device *factory(const Configuration &configuration, const FactoryBlock &factory_block);
    static void loadModelParameters(ParametricData<Model> &p);
    static void loadInstanceParameters(ParametricData<Instance> &p);
};

/**
 * ModSpec_Device device instance.
 *
 * An instance is created for each occurance of the device in the netlist.
 *
 */
class Instance : public DeviceInstance
{
    friend class ParametricData<Instance>;
    friend class Model;
    friend class Traits;
    friend class Master;

public:
    Instance(
         const Configuration &         configuration,
         const InstanceBlock &         instance_block,
         Model &                                     model,
         const FactoryBlock &            factory_block);

    ~Instance() {}

private:
    Instance(const Instance &);
    Instance &operator=(const Instance &);

public:
    Model &getModel() {
        return model_;
    }

    virtual void registerLIDs(const std::vector<int> & intLIDVecRef, const std::vector<int> & extLIDVecRef) /* override */;
    virtual void registerStateLIDs(const std::vector<int> & staLIDVecRef) /* override */;
    virtual void registerStoreLIDs(const std::vector<int> & stoLIDVecRef) /* override */;
    virtual void registerJacLIDs(const std::vector< std::vector<int> > & jacLIDVec) /* override */;

    virtual void registerBranchDataLIDs(const std::vector<int> & branchLIDVecRef) /* override */;
    virtual void loadNodeSymbols(Util::SymbolTable &symbol_table) const; // override

    virtual bool processParams(string param = "") /* override */;
    virtual bool updateTemperature(const double & temp_tmp) /* override */;
    virtual bool updateIntermediateVars() /* override */;
    virtual bool updatePrimaryState() /* override */;

    virtual const std::vector< std::vector<int> > &jacobianStamp() const    /* override */ {
        return jacStamp;
    }

    virtual bool loadDAEFVector() /* override */;
    virtual bool loadDAEdFdx() /* override */;
    virtual bool loadDAEQVector() /* override */;
    virtual bool loadDAEdQdx() /* override */;

    virtual void setupPointers() /* override */;

    CompositeParam * constructComposite (const std::string &, const std::string &);

protected:
    Xyce_ModSpec_Interface* XMIp;
    ModSpec_Element* ModSpecElPtr; //

private:
    static std::vector< std::vector<int> >  jacStamp; ///< All ModSpec_Device have a common Jacobian Stamp

    Model &         model_;  ///< Owning model

    // For vector composite:
    std::vector<ModSpecParamData*> ModSpecParamDataVec;
    std::map<std::string, ModSpecParamData *> ModSpecParamDataMap;

    double temp;        //    Temperature (K)
};


/**
 * ModSpec_Device model
 *
 */
class Model : public DeviceModel
{
    friend class ParametricData<Model>;  ///< Allow ParametricData to changes member values
    friend class Instance;               ///< Don't force a lot of pointless getters
    friend class Traits;
    friend class Master;                 ///< Don't force a lot of pointless getters

public:
    typedef std::vector<Instance *> InstanceVector;

    Model(
         const Configuration &      configuration,
         const ModelBlock &         model_block,
         const FactoryBlock &       factory_block);
    ~Model();

private:
    Model();
    Model(const Model &);
    Model &operator=(const Model &);

public:
    void addInstance(Instance *instance) 
    {
        instanceContainer.push_back(instance);
    }

    virtual void forEachInstance(DeviceInstanceOp &op) const /* override */;

    virtual std::ostream &printOutInstances(std::ostream &os) const;

    virtual bool processParams() /* override */;
    virtual bool processInstanceParams() /* override */;

private:
    InstanceVector            instanceContainer;  ///< List of owned intances

protected:
    Xyce_ModSpec_Interface* XMIp;
    ModSpec_Element* ModSpecElPtr; //

private:
    // Model parameter
    std::string SONAME;
};

/**
 * ModSpec_Device master
 *
 */
class Master : public DeviceMaster<Traits>
{
    friend class Instance;  ///< Don't force a lot of pointless getters
    friend class Model;     ///< Don't force a lot of pointless getters

public:
    Master(
       const Configuration &     configuration,
       const FactoryBlock &      factory_block,
       const SolverState &       solver_state,
       const DeviceOptions &     device_options)
      : DeviceMaster<Traits>(configuration, factory_block, solver_state, device_options)
    {}
};

void registerDevice();

} // namespace @{model_name}
} // namespace Device
} // namespace Xyce

#endif
