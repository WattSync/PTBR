#include <WiFi.h>
#include <WiFiManager.h>
#include <WebServer.h>
#include <ArduinoJson.h>
#include <ESPmDNS.h>
#include <Adafruit_GFX.h>
#include <Adafruit_ST7735.h>
#include <EEPROM.h>
#include "screens.h"
#include "HardwareSerial.h"


#define BUZZER_PIN  17
#define TFT_CS      10
#define TFT_RST     5
#define TFT_DC      6
#define TX_PIN      40
#define RX_PIN      47

// Definições para o wear leveling da EEPROM
const int EEPROM_SIZE = 512;  // Tamanho da EEPROM a ser usado
const int MAX_WRITES = 10; // Número máximo de escritas
int startAddress = 0;         // Endereço inicial para o wear leveling
int writeCounts = 0;          // Contador de escritas

// Endereços de memória para as variáveis
const int enderecoTema = 0;   // Endereço para a variável 'tema'
const int enderecoBrilho = 4; // Endereço para a variável 'brilho'

Adafruit_ST7735 tft = Adafruit_ST7735(TFT_CS, TFT_DC, TFT_RST);

WebServer server(80); // 80 é a porta padrão para HTTP
HardwareSerial mySerial(1); // UART1

float Voltage, Current, ValueInReal, Frequency, ValuePowerLimit = 0;
float Power = Voltage * Current;
float ValueTotal = Power /1000 * ValueInReal;
bool PowerLimitDisplay, Wire_1, Wire_2, ON = 0;
int error = 0;
bool tema = false;
uint16_t Color;

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
  mySerial.begin(115200, SERIAL_8N1, RX_PIN, TX_PIN);
  pinMode(BUZZER_PIN, OUTPUT);

  WiFiManager wifiManager;
  wifiManager.setTitle("Conecte-se ao dispositivo");
  wifiManager.setHostname("WattSync");

  // Remover "Info" e "Update" do menu
  std::vector<const char *> customMenu = {"wifi", "exit"}; // Apenas mostrar Wi-Fi e Sair
  wifiManager.setMenu(customMenu);

  wifiManager.setCustomHeadElement(
    "<style>"
    "button {"
    "  border-radius: 15px;"  // Arredondar botões
    "  padding: 10px 20px;"
    "  background-color: #800080;"  // Cor de fundo roxa
    "  color: white;"
    "  border: none;"
    "}"
    "</style>"
  );

  wifiManager.autoConnect("WattSync");

  wifiManager.autoConnect("WattSync");
  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("Conectado ao Wi-Fi.");
    Serial.println(WiFi.localIP());

    if (!MDNS.begin("WattSync")) {
      Serial.println("Erro ao iniciar o serviço mDNS.");
    } else {
      Serial.println("Serviço mDNS iniciado.");
    }

    server.on("/receber-dados", HTTP_POST, handleReceberDados);
    server.on("/enviar-dados", HTTP_GET, handleEnviarDados); 
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

  tft.initR(INITR_BLACKTAB);
  tft.setRotation(2);
  delay(500);
  tft.fillScreen(ST7735_BLACK);

  inicializaDisplay();

}

void loop() {
  server.handleClient();
  ReciverData();
  if (error == 0){
    digitalWrite(BUZZER_PIN, LOW);
    FillScreen();
    delay(20000000);
    
  }
  if (error ==1){
    VoltageAlert();
    tone(BUZZER_PIN, 900);
    delay(1000);
  }
  if (error ==2){
    CurrentAlert();
    tone(BUZZER_PIN, 700);
    delay(1000);
  }
}

void VoltageAlert() {
  uint16_t ColorText;
  int h = 160, w = 128, row, col, buffidx = 0;
  for (row = 0; row < h; row++) {
    for (col = 0; col < w; col++) {
      if (tema == true) {
          ColorText = ST7735_WHITE;
          tft.drawPixel(col, row, pgm_read_word(alert_black + buffidx));
         
        } else {
          ColorText = ST7735_BLACK;
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
  uint16_t ColorText;
  int h = 160, w = 128, row, col, buffidx = 0;
  for (row = 0; row < h; row++) {
    for (col = 0; col < w; col++) {
      if (tema == true) {
         tft.drawPixel(col, row, pgm_read_word(alert_black + buffidx));
         ColorText = ST7735_WHITE;
        } else {
          tft.drawPixel(col, row, pgm_read_word(alert_white + buffidx));
          ColorText = ST7735_BLACK;
        }
        buffidx++;
    }
  tft.setTextColor(ColorText);
	tft.setCursor(15,115);
  tft.println("Corrente excedida");
  tft.setCursor(20,135);
  tft.println("Saida desligada");
  }
}


void inicializaDisplay() {
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
  } else {
    Color = ST7735_WHITE;
  }
  tft.fillScreen(Color);

}





void gravarValores(bool novoTema) {
  // Grava o novo valor do tema se for diferente do atual
  if (novoTema != tema) {
    EEPROM.write(startAddress + enderecoTema, novoTema);
    tema = novoTema;
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
    error = doc["errorJSON"];
    PowerLimitDisplay = doc["LimiteJSON"];
    if (novoTema != tema ) {
      gravarValores(novoTema);
      inicializaDisplay();
    }

    server.send(200, "application/json", "{\"status\":\"dados recebidos\"}");
  } else {
    server.send(400, "application/json", "{\"status\":\"erro ao receber dados\"}");
  }
}

void handleEnviarDados() {
  // Criar um objeto JSON para enviar os dados
  DynamicJsonDocument doc(1024);
  doc["tensao"] = Voltage;
  doc["corrente"] = Current;
  doc["frequencia"] = Frequency;
  doc["ligado"] = ON;
  doc["Fio1"] = Wire_1;
  doc["Fio2"] = Wire_2;
  String response;
  serializeJson(doc, response);
  
  server.send(200, "application/json", response);
}

void FillScreen() {
  tft.fillScreen(Color);
  for (int i = 0; i < 8; i++) {
    delay(250);
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

void ReciverData() {
  pinMode(48, OUTPUT);
  digitalWrite(48, HIGH);
  while (!mySerial.available()) {
    delay(10);
  }
  String receivedMessage = mySerial.readStringUntil('\n');
  digitalWrite(48, LOW);
  int index = 0;
  char* token = strtok(const_cast<char*>(receivedMessage.c_str()), ",");
  while (token != nullptr) {
    if (index == 0) {
      Voltage = atof(token); // Converter para float
    } else if (index == 1) {
      Current = atof(token);
    } else if (index == 2) {
      Frequency = atof(token);
    } else if (index == 3) {
      ON = atoi(token);
    } else if (index == 4) {
      Wire_1 = atoi(token);
    } else if (index == 5) {
      Wire_2 = atoi(token);
    } else if (index == 6) {
      error = atoi(token);
    }
    token = strtok(nullptr, ",");
    index++;
  }
}

