# Board settings

# Normal Arduino UNO
#
# Has atmega328p, runs at 16MHz
board-arduino_uno/lib/libavrada.a : MCU = atmega328p
board-arduino_uno/lib/libavrada.a : BOARD = arduino_uno
board-arduino_uno/avr-mcu.ads     : MCU = atmega328p
board-arduino_uno/avr-mcu.ads     : BOARD = arduino_uno

# Atomic IMU 6 Degrees of Freedom
# http://www.sparkfun.com/products/9812
# 
# Has atmega328p, runs at 8MHz
board-xbeeimu/lib/libavrada.a : MCU = atmega328p
board-xbeeimu/lib/libavrada.a : BOARD = xbeeimu
board-xbeeimu/avr-mcu.ads     : MCU = atmega328p
board-xbeeimu/avr-mcu.ads     : BOARD = xbeeimu

# ATmega8u2 breakout board, Sparkfun
# http://www.sparkfun.com/products/10277
# 
# Has atmega8u2, runs at 16MHz
board-sparkfun8u2/lib/libavrada.a : MCU = atmega8u2
board-sparkfun8u2/lib/libavrada.a : BOARD = sparkfun8u2
board-sparkfun8u2/avr-mcu.ads     : MCU = atmega8u2
board-sparkfun8u2/avr-mcu.ads     : BOARD = sparkfun8u2
