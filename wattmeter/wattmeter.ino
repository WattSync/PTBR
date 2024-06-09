#include <WiFi.h>
#include <WiFiManager.h>
#include <WebServer.h>
#include <ArduinoJson.h>
#include <ESPmDNS.h>
#include <Adafruit_GFX.h>
#include <Adafruit_ST7735.h>
#include "screens.h"  // Certifique-se de que este arquivo está corretamente configurado

#define TFT_CS    10
#define TFT_RST   7
#define TFT_DC    6
#define LED_PIN   15

Adafruit_ST7735 tft = Adafruit_ST7735(TFT_CS, TFT_DC, TFT_RST);

WebServer server(80);
bool tema = true;
int brilho = 255; // Inicializa com brilho máximo


void handleReceberDados() {
  if (server.hasArg("plain")) {
    String dados = server.arg("plain");
    Serial.println(dados);

    DynamicJsonDocument doc(1024);
    deserializeJson(doc, dados);
    tema = doc["temaJSON"];
    brilho = doc["brilhoJSON"];

    
    server.send(200, "application/json", "{\"status\":\"dados recebidos\"}");
    
  
  } else {
    server.send(400, "application/json", "{\"status\":\"erro ao receber dados\"}");
  }
}

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

  tft.initR(INITR_BLACKTAB);
  tft.setRotation(2);
  delay(1500);
  tft.fillScreen(ST7735_BLACK);

  pinMode(LED_PIN, OUTPUT);
  analogWrite(LED_PIN, brilho);

  // Desenha a imagem de fundo
  int h = 160, w = 128, row, col, buffidx = 0;
  for (row = 0; row < h; row++) {
    for (col = 0; col < w; col++) {
      if (tema == true) {
        tft.drawPixel(col, row, pgm_read_word(splash_screen_black + buffidx));
        buffidx++;
      } else {
        tft.drawPixel(col, row, pgm_read_word(splash_screen_white + buffidx));
        buffidx++;

      }
    }
  }
  delay(2000);

  // Exibir tela branca com a palavra "teste"
  tft.fillScreen(ST7735_WHITE);
  
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

void loop() {
  server.handleClient();
}
