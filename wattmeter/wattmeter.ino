/*#include <WiFi.h>
#include <WiFiManager.h>
#include <WebServer.h>
#include <ArduinoJson.h>
#include <ESPmDNS.h>*/
#include <Adafruit_GFX.h>
#include <Adafruit_ST7735.h>
#include <EEPROM.h>
#include "screens.h"
#include <Adafruit_ADS1X15.h> // lib para converter os dados do ADS1115
#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>

#define RELAY_PIN 13
#define BUZZER_PIN 7
#define TFT_CS    10
#define TFT_RST   5
#define TFT_DC    6
#define LED_PIN   15

// UUIDs para o serviço e características
#define SERVICE_UUID           "91bad492-b950-4226-aa2b-4ede9fa42f59"
#define CHARACTERISTIC_UUID_1  "cba1d466-344c-4be3-ab3f-189f80dd7518"
#define CHARACTERISTIC_UUID_2  "cba1d466-344c-4be3-ab3f-189f80dd7519"
#define CHARACTERISTIC_UUID_3  "cba1d466-344c-4be3-ab3f-189f80dd7520"


// Definições para o wear leveling da EEPROM
const int EEPROM_SIZE = 512;  // Tamanho da EEPROM a ser usado
const int MAX_WRITES = 10; // Número máximo de escritas
int startAddress = 0;         // Endereço inicial para o wear leveling
int writeCounts = 0;          // Contador de escritas

// Endereços de memória para as variáveis
const int enderecoTema = 0;   // Endereço para a variável 'tema'
const int enderecoBrilho = 4; // Endereço para a variável 'brilho'

Adafruit_ST7735 tft = Adafruit_ST7735(TFT_CS, TFT_DC, TFT_RST);
Adafruit_ADS1115 ads; 
//WebServer server(80);

bool tema;
int brilho;
float Voltage = 127.5;
float Current = 9.65;
float Power = Voltage * Current;
float ValueInReal = 0.85;
float ValueTotal = Power /1000 * ValueInReal;
float Frequency = 60;
bool PowerLimitDisplay = 0;
float ValuePowerLimit = false;
uint16_t Color;
float SomaCorrente = 0;
int estado = 0;
uint16_t DarkColors [8] = {
  ST7735_WHITE,
  ST7735_MAGENTA,
  ST7735_RED,
  ST7735_YELLOW,
  ST7735_GREEN,
  ST7735_WHITE,
  ST7735_WHITE,
  ST7735_GREEN
};

uint16_t LightColors [8] = {
  ST7735_BLACK,
  ST7735_BLUE,
  ST7735_RED,
  ST7735_ORANGE,
  ST7735_GREEN,
  ST7735_BLACK,
  ST7735_BLACK,
  ST7735_GREEN
};

int FontSize [8] = {1, 1, 1, 1, 1, 2, 1, 1};

int X [8] = {17, 5, 78, 5, 78, 10, 17, 97};
int Y [8] = {1, 26, 26, 53, 53, 80, 115, 115};

class MyCallbacks : public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic *pCharacteristic) {
    std::string value = pCharacteristic->getValue();
    if (value.length() > 0) {
      // Converte a string recebida para o tipo correspondente e armazena nas variáveis
      if (pCharacteristic->getUUID().equals(BLEUUID(CHARACTERISTIC_UUID_1))) {
        tema = (value == "1");
      } else if (pCharacteristic->getUUID().equals(BLEUUID(CHARACTERISTIC_UUID_2))) {
        brilho = atoi(value.c_str());
      } else if (pCharacteristic->getUUID().equals(BLEUUID(CHARACTERISTIC_UUID_3))) {
        estado = atoi(value.c_str());
      }
    }
  }
};
void setup() {
  Serial.begin(115200);
  pinMode(BUZZER_PIN, OUTPUT);
  pinMode(RELAY_PIN, OUTPUT);

  // Inicialmente desativa o relé
  digitalWrite(RELAY_PIN, LOW);
  /*WiFiManager wifiManager;
  wifiManager.autoConnect("LedPwm");

  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("Conectado ao Wi-Fi.");
    Serial.println(WiFi.localIP());

    if (!MDNS.begin("ledpwm")) {
      Serial.println("Erro ao iniciar o serviço mDNS.");
    } else {
      Serial.println("Serviço mDNS iniciado.");
    }

    server.on("/receber-dados", HTTP_POST, handleReceberDados);
    server.begin();
  } else {
    Serial.println("Não foi possível conectar ao Wi-Fi.");
  }
*/
  EEPROM.begin(EEPROM_SIZE);

  // Lê o contador de escritas e o endereço inicial da última posição da EEPROM
  startAddress = EEPROM.read(EEPROM_SIZE - 4);
  writeCounts = EEPROM.read(EEPROM_SIZE - 2);

  // Se o contador de escritas atingiu o máximo, reinicie-o e mude o endereço inicial
  if (writeCounts >= MAX_WRITES) {
    startAddress += 6; // Mova para o próximo conjunto de endereços
    if (startAddress >= EEPROM_SIZE - 4) {
      startAddress = 0; // Volte para o início se atingir o fim da EEPROM
    }
    writeCounts = 0;
  }

  // Lê os valores da EEPROM
  tema = EEPROM.read(startAddress + enderecoTema);
  brilho = EEPROM.read(startAddress + enderecoBrilho);

  tft.initR(INITR_BLACKTAB);
  tft.setRotation(2);
  delay(500);
  tft.fillScreen(ST7735_BLACK);

  pinMode(LED_PIN, OUTPUT);
  inicializaDisplay();

  //ads.setGain(GAIN_TWOTHIRDS);
  /*if (!ads.begin())
  {
    Serial.println("Failed to initialize ADS.");
    while (1);
 }*/
  BLEDevice::init("ESP32_BLE_Server");
  BLEServer *pServer = BLEDevice::createServer();
  BLEService *pService = pServer->createService(SERVICE_UUID);

  BLECharacteristic *pCharacteristic1 = pService->createCharacteristic(
                                         CHARACTERISTIC_UUID_1,
                                         BLECharacteristic::PROPERTY_WRITE
                                       );
  pCharacteristic1->setCallbacks(new MyCallbacks());

  BLECharacteristic *pCharacteristic2 = pService->createCharacteristic(
                                         CHARACTERISTIC_UUID_2,
                                         BLECharacteristic::PROPERTY_WRITE
                                       );
  pCharacteristic2->setCallbacks(new MyCallbacks());

  BLECharacteristic *pCharacteristic3 = pService->createCharacteristic(
                                         CHARACTERISTIC_UUID_3,
                                         BLECharacteristic::PROPERTY_WRITE
                                       );
  pCharacteristic3->setCallbacks(new MyCallbacks());

  pService->start();
  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(true);
  pAdvertising->setMinPreferred(0x06);  // funções opcionais, mas recomendadas
  pAdvertising->setMinPreferred(0x12);
  BLEDevice::startAdvertising();
  Serial.println("Characteristic defined! Now you can read it in your phone!");
}


}

void loop() {
  //server.handleClient();
  if (estado == 0){
  FillScreen();
  delay(5000);
  //ReadCurrent();
  digitalWrite(RELAY_PIN, HIGH);
  }
  if (estado ==1){
    VoltageAlert();
    digitalWrite(RELAY_PIN, LOW);
    tone(BUZZER_PIN, 700);
    delay(10000);
  }
  if (estado ==2){
    CurrentAlert();
    digitalWrite(RELAY_PIN, LOW);
    tone(BUZZER_PIN, 700);
    delay(10000);
  }
}

void VoltageAlert() {
  analogWrite(LED_PIN, brilho);
  int h = 160, w = 128, row, col, buffidx = 0;
  for (row = 0; row < h; row++) {
    for (col = 0; col < w; col++) {
      if (tema == true) {
         tft.drawPixel(col, row, pgm_read_word(alert_black + buffidx));
        } else {
          tft.drawPixel(col, row, pgm_read_word(alert_white + buffidx));
        }
        buffidx++;
    }
	tft.setCursor(22,115);
  tft.println("Tensao anormal");
  tft.setCursor(20,135);
  tft.println("Saida desligada");
  }
}
void CurrentAlert() {
  analogWrite(LED_PIN, brilho);
  int h = 160, w = 128, row, col, buffidx = 0;
  for (row = 0; row < h; row++) {
    for (col = 0; col < w; col++) {
      if (tema == true) {
         tft.drawPixel(col, row, pgm_read_word(alert_black + buffidx));
        } else {
          tft.drawPixel(col, row, pgm_read_word(alert_white + buffidx));
        }
        buffidx++;
    }
	tft.setCursor(15,115);
  tft.println("Corrente excedida");
  tft.setCursor(20,135);
  tft.println("Saida desligada");
  }
}

/*void ReadCurrent() {
  int16_t tensao_serial, corrente_serial;  // Retorna o valor em serial
  float tensao_volts, corrente_volts;  // Retorna o valor em Volts

  SomaCorrente = 0;  // Limpa a soma das correntes antes de cada medição

  for (int i = 0; i < 60; i++) {
    corrente_serial = ads.readADC_SingleEnded(1);
    corrente_volts = (corrente_serial - 13670)* 0.1875/1000; // Leia o valor do canal 1 do ADS1115
    SomaCorrente += pow(corrente_volts, 2);  // Ajusta o valor (offset de 0 para 16 bits) e eleva ao quadrado
    delay(10);  // Atraso de 10ms entre as leituras // Atraso de 250ms entre as leituras
    Serial.println(corrente_volts);
    Serial.println(corrente_serial);
  }

  tensao_serial = ads.readADC_SingleEnded(3);  // Leia o valor do canal 3 do ADS1115
  tensao_volts = ads.computeVolts(tensao_serial);  // Converte o valor lido em volts
 
  Current = sqrt(SomaCorrente / 60)/0,1;  // Calcula a média quadrática
  SomaCorrente = 0;
  Serial.println(Current);
  delay(100);  // Atraso adicional de 250ms antes de reiniciar a soma das correntes
}

*/
void inicializaDisplay() {
  analogWrite(LED_PIN, brilho);
  int h = 160, w = 128, row, col, buffidx = 0;
  for (row = 0; row < h; row++) {
    for (col = 0; col < w; col++) {
      if (tema == true) {
        tft.drawPixel(col, row, pgm_read_word(splash_screen_black + buffidx));
      } else {
        tft.drawPixel(col, row, pgm_read_word(splash_screen_white + buffidx));
      }
      buffidx++;
    }
  }
  delay(2000);

  if (tema == true) {
    Color = ST7735_BLACK;
    tft.fillScreen(ST7735_BLACK);
  } else {
    Color = ST7735_WHITE;
    tft.fillScreen(ST7735_WHITE);
  }

}





void gravarValores(bool novoTema, int novoBrilho) {
  // Grava o novo valor do tema se for diferente do atual
  if (novoTema != tema) {
    EEPROM.write(startAddress + enderecoTema, novoTema);
    tema = novoTema;
  }

  // Grava o novo valor do brilho se for diferente do atual
  if (novoBrilho != brilho) {
    EEPROM.write(startAddress + enderecoBrilho, novoBrilho);
    brilho = novoBrilho;
  
  }

  // Incrementa o contador de escritas
  writeCounts++;

  // Atualiza o contador de escritas e o endereço inicial na EEPROM
  EEPROM.write(EEPROM_SIZE - 4, startAddress);
  EEPROM.write(EEPROM_SIZE - 2, writeCounts);

  // Salva as alterações na EEPROM
  EEPROM.commit();
}




/*
void handleReceberDados() {
  if (server.hasArg("plain")) {
    String dados = server.arg("plain");
    Serial.println(dados);

    DynamicJsonDocument doc(1024);
    deserializeJson(doc, dados);
    bool novoTema = doc["temaJSON"];
    int novoBrilho = doc["brilhoJSON"];

    
    if (novoTema != tema || novoBrilho != brilho) {
      gravarValores(novoTema, novoBrilho);
      inicializaDisplay();
    }

    server.send(200, "application/json", "{\"status\":\"dados recebidos\"}");
  } else {
    server.send(400, "application/json", "{\"status\":\"erro ao receber dados\"}");
  }
}


*/
void FillScreen() {
  for (int i = 0; i < 8; i++) {
    
    if (tema == true) {
      tft.setTextColor(DarkColors[i]);
    } else {
      tft.setTextColor(LightColors[i]);
    }
    tft.setTextSize(FontSize[i]);
    tft.setCursor(X[i], Y[i]);
    switch (i) {
      case 0:
        tft.println("Versao de testes");
        break;
      case 1:
        tft.fillRect(X[i], Y[i], 30, 10, Color);
        tft.println(String(Voltage, 1) + "V");
        break;
      case 2:
        tft.fillRect(X[i], Y[i], 30, 10, Color);
        if (Current < 11) {
          tft.println(String(Current, 3) + "A");
        } else if ( Current > 10){
          tft.println(String(Current, 2) + "A");
        }
        break;
      case 3:
        tft.fillRect(X[i], Y[i], 30, 10, Color);
        if (Power < 11) {
          tft.println(String(Power, 2) + "W");
        } else if ( Power > 10){
          tft.println(String(Power, 1) + "W");
        } else if (Power > 100){
          tft.println(String(Power, 0) + "W");
        } else if (Power > 1000){
          tft.println(String(Power / 1000, 2) + "Kw");
        }
        break;
      case 4:
        tft.fillRect(X[i], Y[i], 30, 10, Color);
        tft.println(String(Frequency, 1) + "Hz");
        break;
      case 5:
        tft.fillRect(X[i], Y[i], 80, 20, Color);
         if (ValueTotal < 11) {
          tft.println(String(ValueTotal, 2) + "R$/h");
        } else if ( Power > 10){
          tft.println(String(ValueTotal, 1) + "R$/h");
        } 
        break;
      case 6:
        tft.println("Limite de C.");
        break;
      case 7:
        tft.fillRect(X[i], Y[i], 30, 10, Color);
        if (PowerLimitDisplay == true)
          tft.println("ON");
        else {
          tft.setTextColor(ST7735_RED);
          tft.println("OFF");
        }
        break;
    }
    
  }
}

