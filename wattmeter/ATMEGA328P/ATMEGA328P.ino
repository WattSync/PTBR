#include <SoftwareSerial.h>

int dataTransmitter = A1;
int powerOff = A5;
const int analogPin2 = A2;
const int analogPin3 = A3;
const int currentSensorPin = A0;
const int numSamples = 500;
float voltageRMS2 = 0;
float voltageRMS3 = 0;
float voltageInput2 = 0;
float voltageInput3 = 0;
bool wire1 = false;
bool wire2 = false;
int error = 0;
bool ON = false;

unsigned long lastUpdate = 0;
unsigned long lastCrossingTime = 0;
unsigned long currentTime = 0;
float frequency = 0;
bool crossingDetected = false;

float correnteRms;
float potencia;
float sensibilidade = 0.066;

float calculaCorrente(int sinalSensor);
int filtroDaMedia();

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
  float dataTransmitterVoltage = analogRead(dataTransmitter) * (5.0 / 1023.0);
  float powerOffVoltage = analogRead(powerOff) * (5.0 / 1023.0);

  if (powerOffVoltage >= 3.0) {
    digitalWrite(relayPin, HIGH);  // Mantém o relé desligado se houver 3V no powerOff
    ON = false;
  } else {
    ON = true;
  }
  correnteRms = calculaCorrente(filtroDaMedia());

  currentTime = millis();
  uint32_t sumOfSquares2 = 0;
  uint32_t sumOfSquares3 = 0;
  uint16_t adcValue2 = 0;
  uint16_t adcValue3 = 0;
  float avgSquare2 = 0;
  float avgSquare3 = 0;
  

  if (currentTime - lastUpdate >= 1000) {
    for (int i = 0; i < numSamples; i++) {
      adcValue2 = analogRead(analogPin2);
      sumOfSquares2 += (uint32_t)adcValue2 * adcValue2;

      adcValue3 = analogRead(analogPin3);
      sumOfSquares3 += (uint32_t)adcValue3 * adcValue3;

      if ((adcValue2 > 514 || adcValue3 > 514) && !crossingDetected) { 
        unsigned long crossingTime = micros();
        if (lastCrossingTime != 0) {
          frequency = 1000000.0 / (crossingTime - lastCrossingTime);
        }
        lastCrossingTime = crossingTime;
        crossingDetected = true;
      } else if (adcValue2 < 510 && adcValue3 < 510) {
        crossingDetected = false;
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
    float RMSVoltage = realVoltageRMS3 + realVoltageRMS2;

    if (realVoltageRMS2 > 15){
      wire1 = true;
    } else {
      wire1 = false;
    }
    if (realVoltageRMS3 > 15){
      wire2 = true;
    } else {
      wire2 = false;
    }

    if (!(RMSVoltage >= 106 && RMSVoltage <= 129) && !(RMSVoltage >= 211 && RMSVoltage <= 234)) {
      error = 1;
      digitalWrite(relayPin, HIGH);
    } else if (correnteRms > 16) {
      digitalWrite(relayPin, HIGH);
      error = 2;
    } else {
      error = 0;
      if (!ON) {
        digitalWrite(relayPin, HIGH);
      }
    }

    
    Serial.print("Tensão RMS Real: ");
    Serial.print(RMSVoltage, 3);
    Serial.println(" V");

    Serial.print(" fio 1,Fase? ");
    Serial.println(wire1);

    Serial.print(" fio 2,Fase? ");
    Serial.println(wire2);

    Serial.print("o relé está ligado? ");
    Serial.println(ON);

    Serial.print("Erro? ");
    Serial.println(error);

    Serial.print("Frequência da Rede AC: ");
    Serial.print(frequency, 2);  
    Serial.println(" Hz");

    Serial.print("Corrente:  ");
    Serial.print(correnteRms, 3);
    Serial.println(" A");

    Serial.print("Potência:  ");
    Serial.print(RMSVoltage * correnteRms, 3);
    Serial.println(" W");
    if (dataTransmitterVoltage >= 3.0) {
      String message = String(RMSVoltage) + "," + String(correnteRms) + "," + String(frequency) + "," + String(ON) + "," + String(wire1) + "," + String(wire2) + "," + String(error);
      mySerial.println(message);
    }

    lastUpdate = currentTime;
  }
}

float calculaCorrente(int sinalSensor) {
  return (float)(sinalSensor) * (5.000) / (1023.000 * sensibilidade);
}

int filtroDaMedia() {
  long somaDasCorrentes = 0, mediaDasCorrentes;
  for (int i = 0; i < 1000; i++) {
    somaDasCorrentes += pow((analogRead(currentSensorPin) - 509), 2);
  }
  mediaDasCorrentes = sqrt(somaDasCorrentes / 1000);
  if (mediaDasCorrentes == 1) return 0;
  return mediaDasCorrentes;
}
