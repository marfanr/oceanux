ENTRY(start)

SECTIONS
{
    . = 0x8000;

    .boot :
    {
        KEEP(*(.multiboot_header))
    }

    .text : {
        *(.text)
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
