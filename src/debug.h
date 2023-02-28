#ifndef DEBUG_H
#define DEBUG_H

#if (__DEBUG == 1)
void TRACE(char *msg, ...);
void TRACE_INIT(void);
#else
#define TRACE(o, ...) ((void)0)
#define TRACE_INIT() ((void)0)
#endif // __DEBUG 

#endif	/* DEBUG_H */

