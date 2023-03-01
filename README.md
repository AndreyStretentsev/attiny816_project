# Attiny816 example project

## Requirements
- avr-gcc 12 is requiered to build project; 
- [updiprog](https://github.com/Polarisru/updiprog) utility is used to flash device via USB/UART;
- clang-format 11.0 or newer is required to use static code analyzer.

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

