#include <nux/ctype.h>
#include <nux/printf.h>
#include <nux/vesa.h>
#include <nux/vga.h>
#include <nux/ctype.h>

void kern_main(vbe_info_t* vbe) {
    v.video = (unsigned short*)0xb8000;
    set(14, 0);
    putc('S');
}
