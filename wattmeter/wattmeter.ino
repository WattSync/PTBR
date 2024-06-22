#include <WiFi.h>
#include <WiFiManager.h>
#include <WebServer.h>
#include <ArduinoJson.h>
#include <ESPmDNS.h>
#include <Adafruit_GFX.h>
#include <Adafruit_ST7735.h>
#include <EEPROM.h>
#include "screens.h"


#define TFT_CS    10
#define TFT_RST   5
#define TFT_DC    6
#define LED_PIN   15

// Definições para o wear leveling da EEPROM
const int EEPROM_SIZE = 512;  // Tamanho da EEPROM a ser usado
const int MAX_WRITES = 10; // Número máximo de escritas
int startAddress = 0;         // Endereço inicial para o wear leveling
int writeCounts = 0;          // Contador de escritas

// Endereços de memória para as variáveis
const int enderecoTema = 0;   // Endereço para a variável 'tema'
const int enderecoBrilho = 4; // Endereço para a variável 'brilho'

Adafruit_ST7735 tft = Adafruit_ST7735(TFT_CS, TFT_DC, TFT_RST);
WebServer server(80);

bool tema;
int brilho;
float Voltage = 227;
float Current = 9;
float Power = Voltage * Current;
float ValueInReal = 0.85;
float ValueTotal = Power /1000 * ValueInReal;
float Frequency = 0;
bool PowerLimitDisplay = 0;
float ValuePowerLimit = false;

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

void setup() {
  Serial.begin(115200);
  WiFiManager wifiManager;
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
}

void loop() {
  server.handleClient();
  FillScreen();

}





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
    tft.fillScreen(ST7735_BLACK);
    tft.setTextColor(ST7735_WHITE);
  } else {
    tft.fillScreen(ST7735_WHITE);
    tft.setTextColor(ST7735_BLACK);
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
        tft.println(String(Voltage, 1) + "V");
        break;
      case 2:
        if (Current < 11) {
          tft.println(String(Current, 3) + "A");
        } else if ( Current > 10){
          tft.println(String(Current, 2) + "A");
        }
        break;
     case 3:
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
        tft.println(String(Frequency, 1) + "Hz");
        break;
     case 5:
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

