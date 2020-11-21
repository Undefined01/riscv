ENTRY(_start)
OUTPUT_FORMAT("elf32-littleriscv")

SECTIONS {
	. = 0x00000000;
	.text : {
		*(entry)
		*(.text*)
		*(text_end)
	}
	etext = .;
	_etext = .;
	.rodata : {
		*(.rodata*)
	}
	.data : {
		*(.data)
	}
	edata = .;
	_data = .;
	.bss : {
	_bss_start = .;
		*(.bss*)
		*(.sbss*)
		*(.scommon)
	}
	_stack_top = ALIGN(0x1000);
	. = _stack_top + 0x8000;
	_stack_pointer = .;
	end = .;
	_end = .;
	_heap_start = ALIGN(0x1000);
}