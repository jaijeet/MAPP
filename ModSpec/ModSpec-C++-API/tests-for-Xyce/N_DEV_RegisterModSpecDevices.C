#include <Xyce_config.h>

#include <N_DEV_RegisterDevices.h>

#include <N_DEV_ModSpec_Device.h>

namespace Xyce {
namespace Device {

void
registerModSpecDevices()
{
    ModSpec_Device::registerDevice();
}

} // namespace Device
} // namespace Xyce
