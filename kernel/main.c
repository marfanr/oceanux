void write_string( int colour, const char *string );

#define text "hello world"

void apa() {

    write_string(5, "asa");

}

void write_string( int colour, const char *string )
{
    volatile char *video = (volatile char*)0xb8000;
    while( *string != 0 )
    {
        *video++ = *string++;
        *video++ = colour;
    }
}
