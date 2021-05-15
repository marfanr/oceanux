#include <nux/ctype.h>
#include <nux/printf.h>
#include <nux/vesa.h>
#include <nux/vga.h>
#include <nux/ctype.h>

static void fillrect(unsigned char *vram, unsigned char r, unsigned char g, unsigned   char b, unsigned char w, unsigned char h);

void kern_main(vbe_info_t* vbe_info, mode_info_t* mode_info) {
    fillrect((unsigned char*)(size_t)mode_info->framebuffer, (unsigned char)mode_info->redMask,  (unsigned char)mode_info->greenMask,  (unsigned char)mode_info->blueMask, (unsigned char) 24, (unsigned char)50);
}

static void fillrect(unsigned char *vram, unsigned char r, unsigned char g, unsigned   char b, unsigned char w, unsigned char h) {
    unsigned char *where = vram;
    int i, j;

    for (i = 0; i < w; i++) {
        for (j = 0; j < h; j++) {
            //putpixel(vram, 64 + j, 64 + i, (r << 16) + (g << 8) + b);
            where[j*4] = r;
            where[j*4 + 1] = g;
            where[j*4 + 2] = b;
        }
        where+=3200;
    }
}
