
#include <StandardCplusplus.h>
#include <Eigen30.h>

#ifdef NOT_IN_ARDUINO_IDE
# include <Arduino.h>
#endif

using namespace Eigen;
Vector3f v1(1.5, 2.0, -.3);


void setup() {
  pinMode(LED_BUILTIN, OUTPUT);

  delay(2000);

}

void loop() {
  /// Print the norm (length) of vector v1
  float length = v1.norm();
  if (length < 1) {
    digitalWrite(LED_BUILTIN, HIGH);
  }
}
