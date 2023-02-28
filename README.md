# Attiny816 example project

## Requirements
AVR-GCC 12 is requiered to build project. UPDIPROG utility is used to flash device via USB/UART.

## Building
To build debug version run command:
> make debug

To build release version run command:
> make release

To clean outputs of the project run:
> make clean

## Running
To run project UPDIPROG utility must be in PATH env. Specify your programming COM-port in Makefile or set it in "flash" command using CPORT=[PORT].

Run command:
> make flash

Or:
> make CPORT=[PORT] flash

## Debugging
To run COM port monitor specify your COM utility path in Makefile and run command:
> make trace

