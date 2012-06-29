
// Force disabling alignment - perhaps not necessary
#define EIGEN_DONT_ALIGN

// Add an error define it expects
#define ENOMEM 12

// Not sure why just the forward declarations in uClibc++ are insufficient.
#include <sstream>

// Include Eigen's Core
#include <Eigen/Core>
