/*
 * File:   main.c
 * Author: ADMIN
 *
 * Created on 25 ?????? 2023 ?., 12:40
 */


#include <avr/io.h>
#include <avr/interrupt.h>
#include <avr/sleep.h>
#include <avr/cpufunc.h>
#include <stdbool.h>

#include "debug.h"

#define MUX_PORT    PORTC
#define MUX0_PIN    PIN0
#define MUX1_PIN    PIN1
#define MUX2_PIN    PIN2

#define MUX_MUTE    (0x07)
#define MUX_UNMUTE  (0x00)

typedef enum {
    CMD_UNKNOWN = 0,
    CMD_MUTE = 0x10,
    CMD_UNMUTE = 0x2F,
    CMD_MAX 
} cmd_t;

struct {
    cmd_t command;
    bool is_data_received;
    bool is_error;
} spi;

void mute() {
    MUX_PORT.OUT = MUX_MUTE;
    TRACE("mute\n");
}

void unmute() {
    MUX_PORT.OUT = MUX_UNMUTE;
    TRACE("unmute\n");
}

void unknown_command() {
}

void exec_cmd(cmd_t cmd) {
    TRACE("cmd = 0x%02X\n", (unsigned char)cmd);
    switch (cmd) {
        case CMD_MUTE:
            mute();
            break;
        case CMD_UNMUTE:
            unmute();
            break;
        default:
            unknown_command();
            break;
    }
}

ISR(SPI0_INT_vect) {
    if (SPI0.INTFLAGS & SPI_RXCIF_bm) {
        spi.command = (cmd_t)SPI0.DATA;
    }
    if (SPI0.INTFLAGS & SPI_BUFOVF_bm) {
        spi.is_error = true;
    }
    SPI0.INTFLAGS |= SPI_RXCIF_bm | SPI_IF_bm;
}

ISR(PORTA_PORT_vect) {
    if (PORTA.INTFLAGS & PIN5_bm) {
        spi.is_data_received = true;
        PORTA.INTFLAGS |= PIN5_bm;
    }
}

void spi_init() {
    PORTA.DIRCLR = PIN1_bm | PIN3_bm | PIN4_bm;
    PORTA.DIRSET = PIN2_bm;
    SPI0.CTRLA &= ~SPI_MASTER_bm;
    SPI0.CTRLA |= SPI_ENABLE_bm;
    SPI0.INTCTRL |= SPI_RXCIE_bm | SPI_IE_bm;
}

void clk_init() {
    ccp_write_io(
        (void *)&(CLKCTRL.MCLKCTRLB), 
        (CLKCTRL_PDIV_2X_gc | CLKCTRL_PEN_bm)
    );
}

void gpio_init() {
    // MUX gpio init
    MUX_PORT.DIRSET = (1 << MUX0_PIN) | (1 << MUX1_PIN) | (1 << MUX2_PIN);
    MUX_PORT.OUTCLR = 0xFF;
    // SS_INT gpio init
    PORTA.DIRCLR |= PIN5_bm;
    PORTA.PIN5CTRL = PORT_ISC1_bm;
}

void init() {
    cli();
    clk_init();
    gpio_init();
    TRACE_INIT();
    spi_init();
    sei();
}

int main(void) {
    init();
    TRACE("init complete\n");
    bool inf_loop = true;
    while (inf_loop) {
        if (spi.is_data_received) {
            exec_cmd(spi.command);
            spi.is_data_received = false;
        }
        if (spi.is_error) {
            TRACE("spi error\n");
            spi.is_error = false;
        }
    }
    return 0;
}


