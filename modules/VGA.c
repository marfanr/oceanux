#include <nux/ctype.h>
#define VGA_MEMORY (unsigned char*)0xB8000

extern void __outb(unsigned short port, unsigned char val);
extern void __inb(unsigned short port, unsigned char val);

unsigned short CursorPosition;

void setCursorPosition(unsigned short position) {
    __outb(0x3D4, 0x0F);
    __outb(0x3D5, (unsigned char)(position & 0xFF));
    __outb(0x3D4, 0x0E);
    __outb(0x3D5, (unsigned char)(position >> 8) & 0xFF);

    CursorPosition = position;
}
