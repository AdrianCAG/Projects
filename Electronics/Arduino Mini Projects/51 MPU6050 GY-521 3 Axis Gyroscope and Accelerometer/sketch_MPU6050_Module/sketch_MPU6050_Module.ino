#define ACCELE_RANGE 4    // Accelerometer range in g (adjust as needed)
#define GYROSC_RANGE 500  // Gyroscope range in degrees per second

#include <Wire.h>
const int MPU_addr = 0x68; // I2C address of the MPU-6050

// Variables to store sensor data
float AcX, AcY, AcZ, Tmp, GyX, GyY, GyZ;

void setup() {
  Wire.begin(); // Initialize I2C communication
  Wire.beginTransmission(MPU_addr);
  Wire.write(0x6B);  // Access PWR_MGMT_1 register
  Wire.write(0);     // Set to zero to wake up the MPU-6050
  Wire.endTransmission(true);
  
  Serial.begin(9600); // Initialize serial communication
  Serial.println("MPU-6050 Initialized. Reading data...");
}

void loop() {
  // Request accelerometer, temperature, and gyroscope data from MPU-6050
  Wire.beginTransmission(MPU_addr);
  Wire.write(0x3B);  // Start reading from register 0x3B (ACCEL_XOUT_H)
  Wire.endTransmission(false);
  Wire.requestFrom(MPU_addr, 14, true); // Request 14 bytes of data

  // Read accelerometer values (each is 16 bits, stored in two registers)
  AcX = Wire.read() << 8 | Wire.read(); // ACCEL_XOUT_H & ACCEL_XOUT_L
  AcY = Wire.read() << 8 | Wire.read(); // ACCEL_YOUT_H & ACCEL_YOUT_L
  AcZ = Wire.read() << 8 | Wire.read(); // ACCEL_ZOUT_H & ACCEL_ZOUT_L

  // Read temperature value
  Tmp = Wire.read() << 8 | Wire.read(); // TEMP_OUT_H & TEMP_OUT_L

  // Read gyroscope values (each is 16 bits, stored in two registers)
  GyX = Wire.read() << 8 | Wire.read(); // GYRO_XOUT_H & GYRO_XOUT_L
  GyY = Wire.read() << 8 | Wire.read(); // GYRO_YOUT_H & GYRO_YOUT_L
  GyZ = Wire.read() << 8 | Wire.read(); // GYRO_ZOUT_H & GYRO_ZOUT_L

  // Print formatted accelerometer data in g
  Serial.print("Acceleration (g): ");
  Serial.print(" X: "); Serial.print(AcX / 65536 * ACCELE_RANGE - 0.01); 
  Serial.print(" | Y: "); Serial.print(AcY / 65536 * ACCELE_RANGE); 
  Serial.print(" | Z: "); Serial.print(AcZ / 65536 * ACCELE_RANGE + 0.02); 
  Serial.println();

  // Uncomment to display temperature data in degrees Celsius
  // Serial.print("Temperature: "); Serial.print(Tmp / 340.00 + 36.53); Serial.println(" °C");

  // Print formatted gyroscope data in degrees per second
  Serial.print("Gyroscope (d/s): ");
  Serial.print(" X: "); Serial.print(GyX / 65536 * GYROSC_RANGE + 1.7); 
  Serial.print(" | Y: "); Serial.print(GyY / 65536 * GYROSC_RANGE - 1.7); 
  Serial.print(" | Z: "); Serial.print(GyZ / 65536 * GYROSC_RANGE + 0.25); 
  Serial.println("\n");

  delay(500); // Wait for 500ms before next reading
}
