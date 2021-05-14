#include <nux/ctype.h>
#include <nux/printf.h>
#include <nux/vesa.h>
#include <nux/vga.h>
#include <nux/ctype.h>

static void putpixel(unsigned char* screen, int x,int y, int color);

void kern_main(vbe_info_t* vbe) {
    putpixel((unsigned char*)&vbe->video_memory, 230, 320, 0x7800);
}

static void putpixel(unsigned char* screen, int x,int y, int color) {
    unsigned where = x*3 + y*2400;
    screen[where] = color & 255;              // BLUE
    screen[where + 1] = (color >> 8) & 255;   // GREEN
    screen[where + 2] = (color >> 16) & 255;  // RED
}
