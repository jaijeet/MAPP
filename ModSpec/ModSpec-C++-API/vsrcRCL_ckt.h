#ifndef VSRCRCL_CKT_H
#define VSRCRCL_CKT_H

#include "cktnetlist.h"

#include "vsrcModSpec.h"
#include "resModSpec.h"
#include "capModSpec.h"
#include "indModSpec.h"

using namespace std; // needed to disambiguate std::vector from boost::numeric::ublas::vector

/*
>> ckt = vsrcRCL_ckt
ckt = 
              cktname: 'gnd-vsrc-n1-R-n2-C-n3-L-gnd'
            nodenames: {'1'  '2'  '3'}
       groundnodename: 'gnd'
    all_element_names: {'vsrc1'  'r1'  'c1'  'l1'}
             elements: {[1x1 struct]  [1x1 struct]  [1x1 struct]  [1x1 struct]}
              outputs: {{1x3 cell}  {1x3 cell}  {1x3 cell}}
>> celldisp(ckt.elements)
ans{1} =
     name: 'vsrc1'
    model: [1x1 struct]
    nodes: {'1'  'gnd'}
    parms: {}
    udata: {[1x1 struct]}
ans{2} =
     name: 'r1'
    model: [1x1 struct]
    nodes: {'1'  '2'}
    parms: {[1000]}
    udata: {}
ans{3} =
     name: 'c1'
    model: [1x1 struct]
    nodes: {'3'  '2'}
    parms: {[1.0000e-08]}
    udata: {}
ans{4} =
     name: 'l1'
    model: [1x1 struct]
    nodes: {'3'  'gnd'}
    parms: {[0.0300]}
*/

class vsrcRCL_ckt : public cktnetlist {
	public:
		vsrcRCL_ckt();
		~vsrcRCL_ckt();
};

#endif // VSRCRCL_CKT_H
