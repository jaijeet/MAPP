#ifndef MVS_9_STAGE_RING_OSCILLATOR_CKT_H
#define MVS_9_STAGE_RING_OSCILLATOR_CKT_H

#include "cktnetlist.h"

#include "vsrcModSpec.h"
#include "resModSpec.h"
#include "capModSpec.h"
#include "MVS_1_0_1_ModSpec.h"

using namespace std; // needed to disambiguate std::vector from boost::numeric::ublas::vector

class MVS_9_stage_ring_oscillator_ckt : public cktnetlist {
	public:
		MVS_9_stage_ring_oscillator_ckt();
		~MVS_9_stage_ring_oscillator_ckt();
};

#endif // MVS_9_STAGE_RING_OSCILLATOR_CKT_H
