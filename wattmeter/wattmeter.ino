
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
	tft.initR(INITR_BLACKTAB);
	tft.setRotation(2);
	tft.fillScreen(ST7735_BLACK);

  pinMode(LED_PIN, OUTPUT);

    // Define o valor PWM do LED como 255 (brilho máximo)
    analogWrite(LED_PIN, 255);

//Case 2: Multi Colored Images/Icons
  int h = 160,w = 128, row, col, buffidx=0;
  for (row=0; row<h; row++) { // For each scanline...
    for (col=0; col<w; col++) { // For each pixel...
      //To read from Flash Memory, pgm_read_XXX is required.
      //Since image is stored as uint16_t, pgm_read_word is used as it uses 16bit address
      tft.drawPixel(col, row, pgm_read_word(splash_screen_white + buffidx));
      buffidx++;
    } // end pixel
  }
}

void loop() {
}
