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
const int MAX_WRITES = 10000; // Número máximo de escritas
int startAddress = 0;         // Endereço inicial para o wear leveling
int writeCounts = 0;          // Contador de escritas

// Endereços de memória para as variáveis
const int enderecoTema = 0;   // Endereço para a variável 'tema'
const int enderecoBrilho = 4; // Endereço para a variável 'brilho'

Adafruit_ST7735 tft = Adafruit_ST7735(TFT_CS, TFT_DC, TFT_RST);
WebServer server(80);

bool tema;
int brilho;

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

  tft.setTextSize(2);
  tft.setCursor(30, 70);
  tft.print("teste");
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

    // Verifica se os valores recebidos são diferentes dos valores atuais
    if (novoTema != tema || novoBrilho != brilho) {
      gravarValores(novoTema, novoBrilho);
      inicializaDisplay();
    }

    server.send(200, "application/json", "{\"status\":\"dados recebidos\"}");
  } else {
    server.send(400, "application/json", "{\"status\":\"erro ao receber dados\"}");
  }
}

