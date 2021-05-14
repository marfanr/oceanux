#include <nux/ctype.h>
#include <nux/printf.h>
void putc(char c);
void set(int fg, int bg);

struct vga_t {
        unsigned short *video;
	    unsigned short attribute;
};

struct vga_t v;

void kern_main() {
	v.video = (unsigned short*)0xB8000;
	set(12, 15);
	putc('O');
    putc('C');
    putc('E');
    putc('A');
    putc('N');
    putc('U');
    putc('X');
    putc(' ');
    putc('O');
    putc('S');
}

void putc(char c)
{
    *v.video++ = v.attribute | c;
}

void set(int fg, int bg)
{
    v.attribute = ((bg << 4) | (fg & 0x0F)) << 8;
}
