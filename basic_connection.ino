#include <Adafruit_MPU6050.h>
#include <Adafruit_Sensor.h>
#include <Wire.h>


Adafruit_MPU6050 mpu;


unsigned int ADCValue;
void setup(){
    Serial.begin(9600);
    while (!Serial) {
      delay(10); // will pause Zero, Leonardo, etc until serial console opens
    }  
    
    // Try to initialize!
    if (!mpu.begin()) {
      Serial.println("Failed to find MPU6050 chip");
      while (1) {
        delay(10);
      }
    }
  
    mpu.setAccelerometerRange(MPU6050_RANGE_16_G);
    mpu.setGyroRange(MPU6050_RANGE_250_DEG);
    mpu.setFilterBandwidth(MPU6050_BAND_21_HZ);
    Serial.println("");
    delay(100);
  }

void loop(){


    /* Get new sensor events with the readings */
    sensors_event_t a, g, temp; 
    mpu.getEvent(&a, &g, &temp);
  
    /* Print out the values */
    int x = a.acceleration.x;
    int y = a.acceleration.y;


    Serial.print(g.gyro.x);
    Serial.print(",");
    Serial.print(g.gyro.y);
    Serial.print(",");
    //Serial.print(g.gyro.z);
    //Serial.print(", ");
    Serial.print(a.acceleration.x);
    Serial.print(",");
    Serial.print(a.acceleration.y);
    Serial.print(",");
    Serial.print(a.acceleration.z);
    Serial.println("");
    
//   val = map(val, 0, 300, 0, 255);

//   delay(10);
}
