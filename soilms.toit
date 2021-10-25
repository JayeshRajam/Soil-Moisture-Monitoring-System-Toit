
import gpio
import gpio.adc
import serial.protocols.i2c as i2c
import i2c

import font show *
import font.x11_100dpi.sans.sans_24_bold as sans_24_bold
import pixel_display show *
import pixel_display.texture show *
import pixel_display.two_color show *

import ssd1306 show *

MS ::= 32

main:
  //Set up I2C bus for OLED display
  scl := gpio.Pin 22
  sda := gpio.Pin 21
  bus := i2c.Bus
    --sda=sda
    --scl=scl

  devices := bus.scan
  if not devices.contains 0x3c: throw "No SSD1306 display found"
  
  oled :=
    TwoColorPixelDisplay
      SSD1306 (bus.device 0x3c)

  oled.background = BLACK
  sans := Font.get "sans10"
  sans24b := Font [sans_24_bold.ASCII]
  sans_context := oled.context --landscape --font=sans --color=WHITE //--color=BLACK
  sans24b_context := sans_context.with --font=sans24b --alignment=TEXT_TEXTURE_ALIGN_RIGHT
  oled_text := (oled as any).text sans24b_context 130 55 "0.0" //"oled as any" is a hack

  val := 0.0000
  per := 0.00
  pin := gpio.Pin MS
  sensor := adc.Adc pin

  while true:    
    val=sensor.get
    oled.text sans_context 10 20 "Moisture Reading"
    print "Moisture: $(%.2f per) %"
    per = (-41.66666667*val) + 145.833333334 //linear conversion to percentage
    oled_text.text = "$(%.2f per)%"
    oled.draw
    sleep --ms=500
    