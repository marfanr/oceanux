void write_string( int colour, const char *string );

void apa()
{
    char str[] = { 'h', 'e' };
    write_string(4, str);

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
