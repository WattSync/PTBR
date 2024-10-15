#include <SoftwareSerial.h>

int dataTransmitterPin = A1;
int powerOffPin = A5;
const int analogPin2 = A2;
const int analogPin3 = A3;
const int currentSensorPin = A0;
const int numSamples = 500;
float voltageRMS2 = 0;
float voltageRMS3 = 0;
float voltageInput2 = 0;
float voltageInput3 = 0;
bool phaseWire1 = false;
bool phaseWire2 = false;
int errorCode = 0;
bool systemON = false;

unsigned long lastUpdateTime = 0;
unsigned long lastZeroCrossingTime = 0;
unsigned long currentTime = 0;
float acFrequency = 0;
bool zeroCrossingDetected = false;

float currentRMS;
float power;
float sensitivity = 0.066;

float calculateCurrent(int sensorSignal);
int currentFilter();

#define TX_PIN 3
#define RX_PIN 7
#define relayPin 4
SoftwareSerial mySerial(RX_PIN, TX_PIN);

void setup() {
  Serial.begin(115200);
  mySerial.begin(115200);
  pinMode(relayPin, OUTPUT);
}

void loop() {
  float dataTransmitterVoltage = analogRead(dataTransmitterPin) * (5.0 / 1023.0);
  float powerOffVoltage = analogRead(powerOffPin) * (5.0 / 1023.0);

  if (powerOffVoltage >= 3.0) {
    digitalWrite(relayPin, HIGH);  // Keeps the relay off if there is 3V on powerOffPin
    systemON = false;
  } else {
    systemON = true;
  }
  
  currentRMS = calculateCurrent(currentFilter());

  currentTime = millis();
  uint32_t sumOfSquares2 = 0;
  uint32_t sumOfSquares3 = 0;
  uint16_t adcValue2 = 0;
  uint16_t adcValue3 = 0;
  float avgSquare2 = 0;
  float avgSquare3 = 0;

  if (currentTime - lastUpdateTime >= 1000) {
    for (int i = 0; i < numSamples; i++) {
      adcValue2 = analogRead(analogPin2);
      sumOfSquares2 += (uint32_t)adcValue2 * adcValue2;

      adcValue3 = analogRead(analogPin3);
      sumOfSquares3 += (uint32_t)adcValue3 * adcValue3;

      if ((adcValue2 > 514 || adcValue3 > 514) && !zeroCrossingDetected) {
        unsigned long zeroCrossingTime = micros();
        if (lastZeroCrossingTime != 0) {
          acFrequency = 1000000.0 / (zeroCrossingTime - lastZeroCrossingTime);
        }
        lastZeroCrossingTime = zeroCrossingTime;
        zeroCrossingDetected = true;
      } else if (adcValue2 < 510 && adcValue3 < 510) {
        zeroCrossingDetected = false;
      }

      delayMicroseconds(500);
    }

    avgSquare2 = sumOfSquares2 / (float)numSamples;
    avgSquare3 = sumOfSquares3 / (float)numSamples;

    float rmsADC2 = sqrt(avgSquare2);
    float rmsADC3 = sqrt(avgSquare3);

    voltageInput2 = (rmsADC2 * 5.0) / 1023.0;
    voltageInput3 = (rmsADC3 * 5.0) / 1023.0;
    float realVoltageRMS2 = voltageInput2 * 64.8;
    float realVoltageRMS3 = voltageInput3 * 64.8;
    float totalVoltageRMS = realVoltageRMS3 + realVoltageRMS2;

    if (realVoltageRMS2 > 15) {
      phaseWire1 = true;
    } else {
      phaseWire1 = false;
    }
    if (realVoltageRMS3 > 15) {
      phaseWire2 = true;
    } else {
      phaseWire2 = false;
    }

    if (!(totalVoltageRMS >= 106 && totalVoltageRMS <= 129) && !(totalVoltageRMS >= 211 && totalVoltageRMS <= 234)) {
      errorCode = 1;
      digitalWrite(relayPin, HIGH);
    } else if (currentRMS > 16) {
      digitalWrite(relayPin, HIGH);
      errorCode = 2;
    } else {
      errorCode = 0;
      if (!systemON) {
        digitalWrite(relayPin, HIGH);
      }
    }

    // Serial prints
    /*Serial.print("Real RMS Voltage: ");
    Serial.print(totalVoltageRMS, 3);
    Serial.println(" V");

    Serial.print(" Wire 1, Phase? ");
    Serial.println(phaseWire1);

    Serial.print(" Wire 2, Phase? ");
    Serial.println(phaseWire2);

    Serial.print("Is the relay ON? ");
    Serial.println(systemON);

    Serial.print("Error code? ");
    Serial.println(errorCode);

    Serial.print("AC Frequency: ");
    Serial.print(acFrequency, 2);  
    Serial.println(" Hz");

    Serial.print("Current: ");
    Serial.print(currentRMS, 3);
    Serial.println(" A");

    Serial.print("Power: ");
    Serial.print(totalVoltageRMS * currentRMS, 3);
    Serial.println(" W");*/

    if (dataTransmitterVoltage >= 3.0) {
      String message = String(totalVoltageRMS) + "," + String(currentRMS) + "," + String(acFrequency) + "," + String(systemON) + "," + String(phaseWire1) + "," + String(phaseWire2) + "," + String(errorCode);
      mySerial.println(message);
      //Serial.println("Message sent to ESP32");
    }

    lastUpdateTime = currentTime;
  }
}

float calculateCurrent(int sensorSignal) {
  return (float)(sensorSignal) * (5.000) / (1023.000 * sensitivity);
}

int currentFilter() {
  long currentSum = 0, currentAvg;
  for (int i = 0; i < 1000; i++) {
    currentSum += pow((analogRead(currentSensorPin) - 509), 2);
  }
  currentAvg = sqrt(currentSum / 1000);
  if (currentAvg == 1) return 0;
  return currentAvg;
}
