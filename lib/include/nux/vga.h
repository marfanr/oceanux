struct vga_t {
        unsigned short *video;
	    unsigned short attribute;
} v;



void putc(char c)
{
    *v.video++ = v.attribute | c;
}

void set(int fg, int bg)
{
    v.attribute = ((bg << 4) | (fg & 0x0F)) << 8;
}
