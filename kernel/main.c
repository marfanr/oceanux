void putc(char c);
void set(int fg, int bg);

struct vga_t {
        unsigned short *video;
	    unsigned short attribute;
};

struct vga_t v;

void apa() {
	v.video = (unsigned short*)0xB8000;
	set(13, 0);
	putc('A');
}

void putc(char c)
{
    *v.video++ = v.attribute | c;
}

void set(int fg, int bg)
{
    v.attribute = ((bg << 4) | (fg & 0x0F)) << 8;
}
