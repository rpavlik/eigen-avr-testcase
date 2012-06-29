
#include <StandardCplusplus.h>
#include <Eigen30.h>

#ifdef NOT_IN_ARDUINO_IDE
# include <Arduino.h>
#endif

using namespace Eigen;
Vector3f v1(1.5, 2.0, -.3);


void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);

  delay(2000);

}

void loop() {
  
  Serial.println("Starting some math output");

  /// Print the norm (length) of vector v1
  float length = v1.norm();
  Serial.println(length);
}
