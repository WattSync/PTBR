#include <Adafruit_GFX.h>    // Core graphics library
#include <Adafruit_ST7735.h> // Hardware-specific library

//#include "bitmaps.h"
#include "screens.h"

// For the breakout, you can use any 2 or 3 pins
// These pins will also work for the 1.8" TFT shield
#define TFT_CS    10  // Chip select control pin
#define TFT_RST   7  // Reset pin (could connect to RST pin)
#define TFT_DC    6
#define LED_PIN   15 

Adafruit_ST7735 tft = Adafruit_ST7735(TFT_CS, TFT_DC, TFT_RST);

void setup() {
    tft.initR(INITR_BLACKTAB);  // Inicializa o display
    tft.setRotation(2);
    tft.fillScreen(ST7735_BLACK);

    pinMode(LED_PIN, OUTPUT);
    analogWrite(LED_PIN, 255);  // Define o valor PWM do LED como 255 (brilho máximo)

    // Case 2: Multi Colored Images/Icons
    int h = 160, w = 128, row, col, buffidx = 0;
    for (row = 0; row < h; row++) { // Para cada linha...
        for (col = 0; col < w; col++) { // Para cada pixel...
            // Para ler da memória Flash, é necessário usar pgm_read_XXX.
            // Como a imagem é armazenada como uint16_t, usa-se pgm_read_word para endereçamento de 16 bits
            tft.drawPixel(col, row, pgm_read_word(splash_screen_black + buffidx));
            buffidx++;
        } // fim do pixel
    }
    delay(1500);

    // Exibir tela branca com a palavra "teste"
    tft.fillScreen(ST7735_WHITE); // Preencher a tela com branco
    tft.setTextColor(ST7735_BLACK); // Definir a cor do texto como preto
    tft.setTextSize(2); // Definir o tamanho do texto
    tft.setCursor(30, 70); // Definir a posição do cursor
    tft.print("teste"); // Exibir o texto "teste"
}

void loop() {
    // Nenhuma ação no loop
}
