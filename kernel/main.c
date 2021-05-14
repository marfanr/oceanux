#include <nux/ctype.h>
#include <nux/printf.h>
#include <nux/vesa.h>
#include <nux/vga.h>

void kern_main(vbe_info_t* vbe) {
    v.video = (unsigned short*)0xB8000;
	set(0, 15);
	putc('O');
}
