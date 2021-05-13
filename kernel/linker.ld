ENTRY(_start)

SECTIONS
{
    . = 0x8000;

    .text : {
        *(.text)
        *(.rodata*)
    }

    .rodata : {
        *(.rodata)
    }

    .data : {
        *(.data)
    }

    .bss : {
        *(COMMON)
        *(.bss)
    }
}
