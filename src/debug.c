#ifdef __DEBUG
#include <avr/io.h>
#include <avr/interrupt.h>
#include <stdio.h>

#include "debug.h"

#define DEBUG_STR_LEN 100

#define F_CLK_PRIPH     8000000
#define USART0_BAUD_RATE(BAUD_RATE) \
    ((float)(F_CLK_PRIPH * 64 / (16 * (float)BAUD_RATE)) + 0.5)

static char debug_str[DEBUG_STR_LEN];

static void usart_send_byte(const char c) {
    while (!(USART0.STATUS & USART_DREIF_bm)) {
        
    }
    USART0.TXDATAL = c;
}

static void usart_send_str(const char *str, unsigned char str_len) {
    for(unsigned char i = 0; i < str_len; i++) {
        usart_send_byte(str[i]);
    }
}

static void usart_init(void) {
    cli();
    PORTB.DIRSET = PIN2_bm;
    PORTB.OUTSET = PIN2_bm;
    USART0.BAUD = (unsigned short) USART0_BAUD_RATE(450000);
    USART0.CTRLB |= USART_TXEN_bm;
    sei();
}

void TRACE(char *msg, ...) {
    unsigned char debug_str_len = 0;
    va_list args;
    va_start(args, msg);
    debug_str_len = vsnprintf(debug_str, sizeof(debug_str), msg, args);
    va_end(args);
    usart_send_str(debug_str, debug_str_len);
}

void TRACE_INIT() {
    usart_init();
}
#endif // __DEBUG
