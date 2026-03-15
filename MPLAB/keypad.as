opt subtitle "HI-TECH Software Omniscient Code Generator (PRO mode) build 10920"

opt pagewidth 120

	opt pm

	processor	16F877A
clrc	macro
	bcf	3,0
	endm
clrz	macro
	bcf	3,2
	endm
setc	macro
	bsf	3,0
	endm
setz	macro
	bsf	3,2
	endm
skipc	macro
	btfss	3,0
	endm
skipz	macro
	btfss	3,2
	endm
skipnc	macro
	btfsc	3,0
	endm
skipnz	macro
	btfsc	3,2
	endm
indf	equ	0
indf0	equ	0
pc	equ	2
pcl	equ	2
status	equ	3
fsr	equ	4
fsr0	equ	4
c	equ	1
z	equ	0
pclath	equ	10
# 27 "C:\Users\micho\OneDrive - Université Saint-Esprit de Kaslik\Desktop\FALL 25-26\GEL558 Microcontrollers\Project 2 - Keypad\MPLAB\keypad-c.c"
	psect config,class=CONFIG,delta=2 ;#
# 27 "C:\Users\micho\OneDrive - Université Saint-Esprit de Kaslik\Desktop\FALL 25-26\GEL558 Microcontrollers\Project 2 - Keypad\MPLAB\keypad-c.c"
	dw 0xFFFD & 0xFFFB & 0xFFF7 & 0xFFFF & 0xFF7F & 0xFFFF & 0xFFFF & 0xFFFF & 0xFFFF ;#
	FNCALL	_main,_init_ports
	FNCALL	_main,_init_uart
	FNCALL	_main,_init_interrupts
	FNCALL	_main,_read_eeprom
	FNCALL	_main,_display_character
	FNCALL	_main,_scan_keypad
	FNCALL	_scan_keypad,_delay_20ms
	FNCALL	_scan_keypad,_uart_transmit
	FNCALL	_scan_keypad,_write_eeprom
	FNCALL	_scan_keypad,_delay_ms
	FNCALL	_display_character,___wmul
	FNCALL	_display_character,_output_row_data
	FNCALL	_display_character,_delay_2ms
	FNROOT	_main
	FNCALL	_isr,i1_delay_20ms
	FNCALL	_isr,i1_uart_transmit
	FNCALL	_isr,i1_write_eeprom
	FNCALL	intlevel1,_isr
	global	intlevel1
	FNROOT	intlevel1
	global	_current_char
psect	idataBANK0,class=CODE,space=0,delta=2
global __pidataBANK0
__pidataBANK0:
	file	"C:\Users\micho\OneDrive - Université Saint-Esprit de Kaslik\Desktop\FALL 25-26\GEL558 Microcontrollers\Project 2 - Keypad\MPLAB\keypad-c.c"
	line	64

;initializer for _current_char
	retlw	061h
	global	_font_table
psect	stringtext,class=STRCODE,delta=2,reloc=256
global __pstringtext
__pstringtext:
;	global	stringtab,__stringbase
stringtab:
;	String table - string pointers are 2 bytes each
	btfsc	(btemp+1),7
	ljmp	stringcode
	bcf	status,7
	btfsc	(btemp+1),0
	bsf	status,7
	movf	indf,w
	incf fsr
skipnz
incf btemp+1
	return
stringcode:
	movf btemp+1,w
andlw 7Fh
movwf	pclath
	movf	fsr,w
incf fsr
skipnz
incf btemp+1
	movwf pc
__stringbase:
	file	"C:\Users\micho\OneDrive - Université Saint-Esprit de Kaslik\Desktop\FALL 25-26\GEL558 Microcontrollers\Project 2 - Keypad\MPLAB\keypad-c.c"
	line	91
_font_table:
	retlw	07Fh
	retlw	06Bh
	retlw	05Dh
	retlw	06Bh
	retlw	07Fh
	retlw	077h
	retlw	077h
	retlw	041h
	retlw	077h
	retlw	077h
	retlw	07Fh
	retlw	067h
	retlw	06Fh
	retlw	07Fh
	retlw	07Fh
	retlw	077h
	retlw	077h
	retlw	077h
	retlw	077h
	retlw	077h
	retlw	07Fh
	retlw	07Fh
	retlw	067h
	retlw	07Fh
	retlw	07Fh
	retlw	07Eh
	retlw	07Dh
	retlw	07Bh
	retlw	077h
	retlw	06Fh
	retlw	041h
	retlw	03Eh
	retlw	036h
	retlw	03Eh
	retlw	041h
	retlw	07Fh
	retlw	05Dh
	retlw	0
	retlw	05Fh
	retlw	07Fh
	retlw	04Dh
	retlw	036h
	retlw	036h
	retlw	036h
	retlw	059h
	retlw	05Dh
	retlw	036h
	retlw	036h
	retlw	036h
	retlw	049h
	retlw	070h
	retlw	077h
	retlw	077h
	retlw	0
	retlw	077h
	retlw	058h
	retlw	036h
	retlw	036h
	retlw	036h
	retlw	066h
	retlw	041h
	retlw	036h
	retlw	036h
	retlw	036h
	retlw	04Dh
	retlw	07Eh
	retlw	07Eh
	retlw	06h
	retlw	07Eh
	retlw	078h
	retlw	049h
	retlw	036h
	retlw	036h
	retlw	036h
	retlw	049h
	retlw	059h
	retlw	036h
	retlw	036h
	retlw	036h
	retlw	041h
	retlw	07Fh
	retlw	07Fh
	retlw	055h
	retlw	07Fh
	retlw	07Fh
	retlw	07Fh
	retlw	067h
	retlw	055h
	retlw	07Fh
	retlw	07Fh
	retlw	077h
	retlw	06Bh
	retlw	05Dh
	retlw	03Eh
	retlw	07Fh
	retlw	06Bh
	retlw	06Bh
	retlw	06Bh
	retlw	06Bh
	retlw	06Bh
	retlw	07Fh
	retlw	03Eh
	retlw	05Dh
	retlw	06Bh
	retlw	077h
	retlw	079h
	retlw	07Eh
	retlw	056h
	retlw	076h
	retlw	079h
	retlw	041h
	retlw	03Eh
	retlw	02Ah
	retlw	02Ah
	retlw	051h
	retlw	01h
	retlw	076h
	retlw	076h
	retlw	076h
	retlw	01h
	retlw	0
	retlw	036h
	retlw	036h
	retlw	036h
	retlw	049h
	retlw	041h
	retlw	03Eh
	retlw	03Eh
	retlw	03Eh
	retlw	05Dh
	retlw	0
	retlw	03Eh
	retlw	03Eh
	retlw	03Eh
	retlw	041h
	retlw	0
	retlw	036h
	retlw	036h
	retlw	036h
	retlw	03Eh
	retlw	0
	retlw	076h
	retlw	076h
	retlw	076h
	retlw	07Eh
	retlw	041h
	retlw	03Eh
	retlw	036h
	retlw	036h
	retlw	04Dh
	retlw	0
	retlw	077h
	retlw	077h
	retlw	077h
	retlw	0
	retlw	07Fh
	retlw	03Eh
	retlw	0
	retlw	03Eh
	retlw	07Fh
	retlw	05Fh
	retlw	03Fh
	retlw	03Fh
	retlw	03Fh
	retlw	040h
	retlw	0
	retlw	077h
	retlw	06Bh
	retlw	05Dh
	retlw	03Eh
	retlw	0
	retlw	07Fh
	retlw	07Fh
	retlw	07Fh
	retlw	07Fh
	retlw	0
	retlw	07Dh
	retlw	07Bh
	retlw	07Dh
	retlw	0
	retlw	0
	retlw	07Dh
	retlw	07Bh
	retlw	077h
	retlw	0
	retlw	041h
	retlw	03Eh
	retlw	03Eh
	retlw	03Eh
	retlw	041h
	retlw	0
	retlw	076h
	retlw	076h
	retlw	076h
	retlw	079h
	retlw	041h
	retlw	03Eh
	retlw	02Eh
	retlw	01Eh
	retlw	021h
	retlw	0
	retlw	076h
	retlw	066h
	retlw	056h
	retlw	039h
	retlw	059h
	retlw	036h
	retlw	036h
	retlw	036h
	retlw	04Dh
	retlw	07Eh
	retlw	07Eh
	retlw	0
	retlw	07Eh
	retlw	07Eh
	retlw	040h
	retlw	03Fh
	retlw	03Fh
	retlw	03Fh
	retlw	040h
	retlw	060h
	retlw	05Fh
	retlw	03Fh
	retlw	05Fh
	retlw	060h
	retlw	040h
	retlw	03Fh
	retlw	04Fh
	retlw	03Fh
	retlw	040h
	retlw	01Ch
	retlw	06Bh
	retlw	077h
	retlw	06Bh
	retlw	01Ch
	retlw	078h
	retlw	077h
	retlw	07h
	retlw	077h
	retlw	078h
	retlw	01Eh
	retlw	02Eh
	retlw	036h
	retlw	03Ah
	retlw	03Ch
	retlw	07Fh
	retlw	0
	retlw	03Eh
	retlw	07Fh
	retlw	07Fh
	retlw	06Fh
	retlw	077h
	retlw	07Bh
	retlw	07Dh
	retlw	07Eh
	retlw	07Fh
	retlw	07Fh
	retlw	03Eh
	retlw	0
	retlw	07Fh
	retlw	07Bh
	retlw	07Dh
	retlw	07Eh
	retlw	07Dh
	retlw	07Bh
	retlw	03Fh
	retlw	03Fh
	retlw	03Fh
	retlw	03Fh
	retlw	03Fh
	retlw	07Fh
	retlw	07Eh
	retlw	07Dh
	retlw	07Fh
	retlw	07Fh
	retlw	04Fh
	retlw	057h
	retlw	057h
	retlw	057h
	retlw	0Fh
	retlw	0
	retlw	057h
	retlw	057h
	retlw	057h
	retlw	06Fh
	retlw	0Fh
	retlw	057h
	retlw	057h
	retlw	057h
	retlw	07Fh
	retlw	06Fh
	retlw	057h
	retlw	057h
	retlw	057h
	retlw	0
	retlw	0Fh
	retlw	057h
	retlw	057h
	retlw	057h
	retlw	01Fh
	retlw	077h
	retlw	0
	retlw	076h
	retlw	076h
	retlw	07Dh
	retlw	01Fh
	retlw	057h
	retlw	057h
	retlw	057h
	retlw	04Fh
	retlw	0
	retlw	077h
	retlw	077h
	retlw	077h
	retlw	0Fh
	retlw	07Fh
	retlw	07Fh
	retlw	04h
	retlw	07Fh
	retlw	07Fh
	retlw	05Fh
	retlw	07Fh
	retlw	07Fh
	retlw	04h
	retlw	07Fh
	retlw	0
	retlw	06Fh
	retlw	057h
	retlw	03Fh
	retlw	07Fh
	retlw	07Fh
	retlw	040h
	retlw	03Fh
	retlw	07Fh
	retlw	07Fh
	retlw	0Fh
	retlw	077h
	retlw	0Fh
	retlw	077h
	retlw	0Fh
	retlw	0Fh
	retlw	077h
	retlw	077h
	retlw	077h
	retlw	0Fh
	retlw	0Fh
	retlw	057h
	retlw	057h
	retlw	057h
	retlw	0Fh
	retlw	07h
	retlw	057h
	retlw	057h
	retlw	057h
	retlw	06Fh
	retlw	06Fh
	retlw	057h
	retlw	057h
	retlw	057h
	retlw	07h
	retlw	0Fh
	retlw	077h
	retlw	077h
	retlw	077h
	retlw	07Fh
	retlw	05Fh
	retlw	057h
	retlw	057h
	retlw	057h
	retlw	077h
	retlw	077h
	retlw	0
	retlw	057h
	retlw	07Fh
	retlw	07Fh
	retlw	04Fh
	retlw	07Fh
	retlw	07Fh
	retlw	07Fh
	retlw	0Fh
	retlw	06Fh
	retlw	05Fh
	retlw	03Fh
	retlw	05Fh
	retlw	06Fh
	retlw	0Fh
	retlw	07Fh
	retlw	0Fh
	retlw	07Fh
	retlw	0Fh
	retlw	037h
	retlw	06Fh
	retlw	07Fh
	retlw	06Fh
	retlw	037h
	retlw	067h
	retlw	057h
	retlw	057h
	retlw	057h
	retlw	0Fh
	retlw	037h
	retlw	027h
	retlw	017h
	retlw	057h
	retlw	077h
	global	_keypad_map
psect	stringtext
	file	"C:\Users\micho\OneDrive - Université Saint-Esprit de Kaslik\Desktop\FALL 25-26\GEL558 Microcontrollers\Project 2 - Keypad\MPLAB\keypad-c.c"
	line	77
_keypad_map:
	retlw	071h
	retlw	077h
	retlw	065h
	retlw	072h
	retlw	074h
	retlw	079h
	retlw	075h
	retlw	069h
	retlw	061h
	retlw	073h
	retlw	064h
	retlw	066h
	retlw	067h
	retlw	068h
	retlw	06Ah
	retlw	06Bh
	retlw	07Ah
	retlw	078h
	retlw	063h
	retlw	076h
	retlw	062h
	retlw	06Eh
	retlw	06Dh
	retlw	06Ch
	retlw	0
	retlw	06Fh
	retlw	070h
	retlw	02Fh
	retlw	02Ah
	retlw	02Bh
	retlw	02Dh
	retlw	0
	global	_font_table
	global	_keypad_map
	global	_key_pressed
	global	_new_char
	global	_shift_flag
	global	_PORTA
_PORTA	set	5
	global	_PORTB
_PORTB	set	6
	global	_PORTC
_PORTC	set	7
	global	_PORTD
_PORTD	set	8
	global	_RCSTAbits
_RCSTAbits	set	24
	global	_TXREG
_TXREG	set	25
	global	_GIE
_GIE	set	95
	global	_PEIE
_PEIE	set	94
	global	_RA5
_RA5	set	45
	global	_RBIE
_RBIE	set	91
	global	_RBIF
_RBIF	set	88
	global	_TXIF
_TXIF	set	100
	global	_ADCON1
_ADCON1	set	159
	global	_OPTION_REGbits
_OPTION_REGbits	set	129
	global	_SPBRG
_SPBRG	set	153
	global	_TRISA
_TRISA	set	133
	global	_TRISB
_TRISB	set	134
	global	_TRISC
_TRISC	set	135
	global	_TRISD
_TRISD	set	136
	global	_TXSTAbits
_TXSTAbits	set	152
	global	_EEADR
_EEADR	set	269
	global	_EEDATA
_EEDATA	set	268
	global	_EECON1bits
_EECON1bits	set	396
	global	_EECON2
_EECON2	set	397
	global	_RD
_RD	set	3168
	global	_WR
_WR	set	3169
	file	"keypad.as"
	line	#
psect cinit,class=CODE,delta=2
global start_initialization
start_initialization:

psect	bssBANK0,class=BANK0,space=1
global __pbssBANK0
__pbssBANK0:
_key_pressed:
       ds      1

_new_char:
       ds      1

_shift_flag:
       ds      1

psect	dataBANK0,class=BANK0,space=1
global __pdataBANK0
__pdataBANK0:
	file	"C:\Users\micho\OneDrive - Université Saint-Esprit de Kaslik\Desktop\FALL 25-26\GEL558 Microcontrollers\Project 2 - Keypad\MPLAB\keypad-c.c"
	line	64
_current_char:
       ds      1

; Clear objects allocated to BANK0
psect cinit,class=CODE,delta=2
	clrf	((__pbssBANK0)+0)&07Fh
	clrf	((__pbssBANK0)+1)&07Fh
	clrf	((__pbssBANK0)+2)&07Fh
; Initialize objects allocated to BANK0
	global __pidataBANK0
psect cinit,class=CODE,delta=2
	fcall	__pidataBANK0+0		;fetch initializer
	movwf	__pdataBANK0+0&07fh		
psect cinit,class=CODE,delta=2
global end_of_initialization

;End of C runtime variable initialization code

end_of_initialization:
clrf status
ljmp _main	;jump to C main() function
psect	cstackCOMMON,class=COMMON,space=1
global __pcstackCOMMON
__pcstackCOMMON:
	global	?_delay_20ms
?_delay_20ms:	; 0 bytes @ 0x0
	global	?_uart_transmit
?_uart_transmit:	; 0 bytes @ 0x0
	global	?_init_ports
?_init_ports:	; 0 bytes @ 0x0
	global	?_init_uart
?_init_uart:	; 0 bytes @ 0x0
	global	?_init_interrupts
?_init_interrupts:	; 0 bytes @ 0x0
	global	?_display_character
?_display_character:	; 0 bytes @ 0x0
	global	?_scan_keypad
?_scan_keypad:	; 0 bytes @ 0x0
	global	?_isr
?_isr:	; 0 bytes @ 0x0
	global	?_main
?_main:	; 0 bytes @ 0x0
	global	?_delay_2ms
?_delay_2ms:	; 0 bytes @ 0x0
	global	?_output_row_data
?_output_row_data:	; 0 bytes @ 0x0
	global	?i1_delay_20ms
?i1_delay_20ms:	; 0 bytes @ 0x0
	global	??i1_delay_20ms
??i1_delay_20ms:	; 0 bytes @ 0x0
	global	?i1_uart_transmit
?i1_uart_transmit:	; 0 bytes @ 0x0
	global	??i1_uart_transmit
??i1_uart_transmit:	; 0 bytes @ 0x0
	global	?i1_write_eeprom
?i1_write_eeprom:	; 0 bytes @ 0x0
	global	?_read_eeprom
?_read_eeprom:	; 1 bytes @ 0x0
	global	i1uart_transmit@data
i1uart_transmit@data:	; 1 bytes @ 0x0
	global	i1write_eeprom@data
i1write_eeprom@data:	; 1 bytes @ 0x0
	ds	1
	global	??i1_write_eeprom
??i1_write_eeprom:	; 0 bytes @ 0x1
	global	i1write_eeprom@address
i1write_eeprom@address:	; 1 bytes @ 0x1
	ds	1
	global	??_isr
??_isr:	; 0 bytes @ 0x2
	ds	7
	global	isr@shift_detected
isr@shift_detected:	; 1 bytes @ 0x9
	ds	1
	global	isr@row_bits
isr@row_bits:	; 1 bytes @ 0xA
	ds	1
	global	isr@detected_char
isr@detected_char:	; 1 bytes @ 0xB
	ds	1
	global	isr@row
isr@row:	; 1 bytes @ 0xC
	ds	1
	global	isr@col
isr@col:	; 1 bytes @ 0xD
	ds	1
psect	cstackBANK0,class=BANK0,space=1
global __pcstackBANK0
__pcstackBANK0:
	global	??_delay_20ms
??_delay_20ms:	; 0 bytes @ 0x0
	global	??_uart_transmit
??_uart_transmit:	; 0 bytes @ 0x0
	global	?_write_eeprom
?_write_eeprom:	; 0 bytes @ 0x0
	global	??_init_ports
??_init_ports:	; 0 bytes @ 0x0
	global	??_init_uart
??_init_uart:	; 0 bytes @ 0x0
	global	??_init_interrupts
??_init_interrupts:	; 0 bytes @ 0x0
	global	??_read_eeprom
??_read_eeprom:	; 0 bytes @ 0x0
	global	?_delay_ms
?_delay_ms:	; 0 bytes @ 0x0
	global	??_delay_2ms
??_delay_2ms:	; 0 bytes @ 0x0
	global	??_output_row_data
??_output_row_data:	; 0 bytes @ 0x0
	global	?___wmul
?___wmul:	; 2 bytes @ 0x0
	global	uart_transmit@data
uart_transmit@data:	; 1 bytes @ 0x0
	global	write_eeprom@data
write_eeprom@data:	; 1 bytes @ 0x0
	global	read_eeprom@address
read_eeprom@address:	; 1 bytes @ 0x0
	global	delay_ms@ms
delay_ms@ms:	; 2 bytes @ 0x0
	global	___wmul@multiplier
___wmul@multiplier:	; 2 bytes @ 0x0
	ds	1
	global	??_write_eeprom
??_write_eeprom:	; 0 bytes @ 0x1
	global	output_row_data@data
output_row_data@data:	; 1 bytes @ 0x1
	global	write_eeprom@address
write_eeprom@address:	; 1 bytes @ 0x1
	ds	1
	global	??_delay_ms
??_delay_ms:	; 0 bytes @ 0x2
	global	___wmul@multiplicand
___wmul@multiplicand:	; 2 bytes @ 0x2
	ds	1
	global	delay_ms@i
delay_ms@i:	; 2 bytes @ 0x3
	ds	1
	global	??___wmul
??___wmul:	; 0 bytes @ 0x4
	global	___wmul@product
___wmul@product:	; 2 bytes @ 0x4
	ds	1
	global	??_scan_keypad
??_scan_keypad:	; 0 bytes @ 0x5
	ds	1
	global	??_display_character
??_display_character:	; 0 bytes @ 0x6
	ds	2
	global	scan_keypad@row_bits
scan_keypad@row_bits:	; 1 bytes @ 0x8
	ds	1
	global	scan_keypad@shift_still_pressed
scan_keypad@shift_still_pressed:	; 1 bytes @ 0x9
	ds	1
	global	display_character@row_data
display_character@row_data:	; 1 bytes @ 0xA
	global	scan_keypad@detected_char
scan_keypad@detected_char:	; 1 bytes @ 0xA
	ds	1
	global	display_character@font_index
display_character@font_index:	; 1 bytes @ 0xB
	global	scan_keypad@row
scan_keypad@row:	; 1 bytes @ 0xB
	ds	1
	global	display_character@col_mask
display_character@col_mask:	; 1 bytes @ 0xC
	global	scan_keypad@col
scan_keypad@col:	; 1 bytes @ 0xC
	ds	1
	global	display_character@ch
display_character@ch:	; 1 bytes @ 0xD
	ds	1
	global	display_character@col
display_character@col:	; 1 bytes @ 0xE
	ds	1
	global	??_main
??_main:	; 0 bytes @ 0xF
	global	main@saved_char
main@saved_char:	; 1 bytes @ 0xF
	ds	1
;;Data sizes: Strings 0, constant 437, data 1, bss 3, persistent 0 stack 0
;;Auto spaces:   Size  Autos    Used
;; COMMON          14     14      14
;; BANK0           80     16      20
;; BANK1           80      0       0
;; BANK3           96      0       0
;; BANK2           96      0       0

;;
;; Pointer list with targets:

;; ?___wmul	unsigned int  size(1) Largest target is 0
;;


;;
;; Critical Paths under _main in COMMON
;;
;;   None.
;;
;; Critical Paths under _isr in COMMON
;;
;;   _isr->i1_delay_20ms
;;   _isr->i1_write_eeprom
;;
;; Critical Paths under _main in BANK0
;;
;;   _main->_display_character
;;   _scan_keypad->_delay_ms
;;   _display_character->___wmul
;;
;; Critical Paths under _isr in BANK0
;;
;;   None.
;;
;; Critical Paths under _main in BANK1
;;
;;   None.
;;
;; Critical Paths under _isr in BANK1
;;
;;   None.
;;
;; Critical Paths under _main in BANK3
;;
;;   None.
;;
;; Critical Paths under _isr in BANK3
;;
;;   None.
;;
;; Critical Paths under _main in BANK2
;;
;;   None.
;;
;; Critical Paths under _isr in BANK2
;;
;;   None.

;;
;;Main: autosize = 0, tempsize = 0, incstack = 0, save=0
;;

;;
;;Call Graph Tables:
;;
;; ---------------------------------------------------------------------------------
;; (Depth) Function   	        Calls       Base Space   Used Autos Params    Refs
;; ---------------------------------------------------------------------------------
;; (0) _main                                                 1     1      0     993
;;                                             15 BANK0      1     1      0
;;                         _init_ports
;;                          _init_uart
;;                    _init_interrupts
;;                        _read_eeprom
;;                  _display_character
;;                        _scan_keypad
;; ---------------------------------------------------------------------------------
;; (1) _scan_keypad                                          8     8      0     541
;;                                              5 BANK0      8     8      0
;;                         _delay_20ms
;;                      _uart_transmit
;;                       _write_eeprom
;;                           _delay_ms
;; ---------------------------------------------------------------------------------
;; (1) _display_character                                    9     9      0     363
;;                                              6 BANK0      9     9      0
;;                             ___wmul
;;                    _output_row_data
;;                          _delay_2ms
;; ---------------------------------------------------------------------------------
;; (2) _delay_2ms                                            2     2      0       0
;;                                              0 BANK0      2     2      0
;; ---------------------------------------------------------------------------------
;; (2) _delay_ms                                             5     3      2      46
;;                                              0 BANK0      5     3      2
;; ---------------------------------------------------------------------------------
;; (2) _delay_20ms                                           2     2      0       0
;;                                              0 BANK0      2     2      0
;; ---------------------------------------------------------------------------------
;; (2) ___wmul                                               6     2      4      92
;;                                              0 BANK0      6     2      4
;; ---------------------------------------------------------------------------------
;; (2) _output_row_data                                      2     2      0      44
;;                                              0 BANK0      2     2      0
;; ---------------------------------------------------------------------------------
;; (1) _read_eeprom                                          1     1      0      22
;;                                              0 BANK0      1     1      0
;; ---------------------------------------------------------------------------------
;; (1) _init_interrupts                                      1     1      0       0
;; ---------------------------------------------------------------------------------
;; (1) _init_uart                                            0     0      0       0
;; ---------------------------------------------------------------------------------
;; (1) _init_ports                                           0     0      0       0
;; ---------------------------------------------------------------------------------
;; (2) _write_eeprom                                         2     1      1      44
;;                                              0 BANK0      2     1      1
;; ---------------------------------------------------------------------------------
;; (2) _uart_transmit                                        1     1      0      22
;;                                              0 BANK0      1     1      0
;; ---------------------------------------------------------------------------------
;; Estimated maximum stack depth 2
;; ---------------------------------------------------------------------------------
;; (Depth) Function   	        Calls       Base Space   Used Autos Params    Refs
;; ---------------------------------------------------------------------------------
;; (3) _isr                                                 13    13      0     628
;;                                              2 COMMON    12    12      0
;;                       i1_delay_20ms
;;                    i1_uart_transmit
;;                     i1_write_eeprom
;; ---------------------------------------------------------------------------------
;; (4) i1_delay_20ms                                         2     2      0       0
;;                                              0 COMMON     2     2      0
;; ---------------------------------------------------------------------------------
;; (4) i1_write_eeprom                                       2     1      1     146
;;                                              0 COMMON     2     1      1
;; ---------------------------------------------------------------------------------
;; (4) i1_uart_transmit                                      1     1      0      73
;;                                              0 COMMON     1     1      0
;; ---------------------------------------------------------------------------------
;; Estimated maximum stack depth 4
;; ---------------------------------------------------------------------------------

;; Call Graph Graphs:

;; _main (ROOT)
;;   _init_ports
;;   _init_uart
;;   _init_interrupts
;;   _read_eeprom
;;   _display_character
;;     ___wmul
;;     _output_row_data
;;     _delay_2ms
;;   _scan_keypad
;;     _delay_20ms
;;     _uart_transmit
;;     _write_eeprom
;;     _delay_ms
;;
;; _isr (ROOT)
;;   i1_delay_20ms
;;   i1_uart_transmit
;;   i1_write_eeprom
;;

;; Address spaces:

;;Name               Size   Autos  Total    Cost      Usage
;;BANK3               60      0       0       9        0.0%
;;BITBANK3            60      0       0       8        0.0%
;;SFR3                 0      0       0       4        0.0%
;;BITSFR3              0      0       0       4        0.0%
;;BANK2               60      0       0      11        0.0%
;;BITBANK2            60      0       0      10        0.0%
;;SFR2                 0      0       0       5        0.0%
;;BITSFR2              0      0       0       5        0.0%
;;SFR1                 0      0       0       2        0.0%
;;BITSFR1              0      0       0       2        0.0%
;;BANK1               50      0       0       7        0.0%
;;BITBANK1            50      0       0       6        0.0%
;;CODE                 0      0       0       0        0.0%
;;DATA                 0      0      28      12        0.0%
;;ABS                  0      0      22       3        0.0%
;;NULL                 0      0       0       0        0.0%
;;STACK                0      0       6       2        0.0%
;;BANK0               50     10      14       5       25.0%
;;BITBANK0            50      0       0       4        0.0%
;;SFR0                 0      0       0       1        0.0%
;;BITSFR0              0      0       0       1        0.0%
;;COMMON               E      E       E       1      100.0%
;;BITCOMMON            E      0       0       0        0.0%
;;EEDATA             100      0       0       0        0.0%

	global	_main
psect	maintext,global,class=CODE,delta=2
global __pmaintext
__pmaintext:

;; *************** function _main *****************
;; Defined at:
;;		line 380 in file "C:\Users\micho\OneDrive - Université Saint-Esprit de Kaslik\Desktop\FALL 25-26\GEL558 Microcontrollers\Project 2 - Keypad\MPLAB\keypad-c.c"
;; Parameters:    Size  Location     Type
;;		None
;; Auto vars:     Size  Location     Type
;;  saved_char      1   15[BANK0 ] unsigned char 
;; Return value:  Size  Location     Type
;;		None               void
;; Registers used:
;;		wreg, fsr0l, fsr0h, status,2, status,0, btemp+1, pclath, cstack
;; Tracked objects:
;;		On entry : 17F/0
;;		On exit  : 60/0
;;		Unchanged: 0/0
;; Data sizes:     COMMON   BANK0   BANK1   BANK3   BANK2
;;      Params:         0       0       0       0       0
;;      Locals:         0       1       0       0       0
;;      Temps:          0       0       0       0       0
;;      Totals:         0       1       0       0       0
;;Total ram usage:        1 bytes
;; Hardware stack levels required when called:    4
;; This function calls:
;;		_init_ports
;;		_init_uart
;;		_init_interrupts
;;		_read_eeprom
;;		_display_character
;;		_scan_keypad
;; This function is called by:
;;		Startup code after reset
;; This function uses a non-reentrant model
;;
psect	maintext
	file	"C:\Users\micho\OneDrive - Université Saint-Esprit de Kaslik\Desktop\FALL 25-26\GEL558 Microcontrollers\Project 2 - Keypad\MPLAB\keypad-c.c"
	line	380
	global	__size_of_main
	__size_of_main	equ	__end_of_main-_main
	
_main:	
	opt	stack 4
; Regs used in _main: [wreg-fsr0h+status,2+status,0+btemp+1+pclath+cstack]
	line	382
	
l2552:	
;keypad-c.c: 382: init_ports();
	fcall	_init_ports
	line	383
;keypad-c.c: 383: init_uart();
	fcall	_init_uart
	line	384
;keypad-c.c: 384: init_interrupts();
	fcall	_init_interrupts
	line	387
	
l2554:	
;keypad-c.c: 387: unsigned char saved_char = read_eeprom(0x00);
	movlw	(0)
	fcall	_read_eeprom
	bcf	status, 6	;RP1=0, select bank0
	movwf	(main@saved_char)
	line	388
	
l2556:	
;keypad-c.c: 388: if (saved_char >= '*' && saved_char <= 'z')
	movlw	(02Ah)
	subwf	(main@saved_char),w
	skipc
	goto	u931
	goto	u930
u931:
	goto	l2562
u930:
	
l2558:	
	movlw	(07Bh)
	subwf	(main@saved_char),w
	skipnc
	goto	u941
	goto	u940
u941:
	goto	l2562
u940:
	line	390
	
l2560:	
;keypad-c.c: 389: {
;keypad-c.c: 390: current_char = saved_char;
	movf	(main@saved_char),w
	movwf	(_current_char)	;volatile
	line	391
;keypad-c.c: 391: }
	goto	l2564
	line	394
	
l2562:	
;keypad-c.c: 392: else
;keypad-c.c: 393: {
;keypad-c.c: 394: current_char = 'a';
	movlw	(061h)
	movwf	(_current_char)	;volatile
	line	401
	
l2564:	
;keypad-c.c: 399: {
;keypad-c.c: 401: display_character(current_char);
	movf	(_current_char),w	;volatile
	fcall	_display_character
	line	404
	
l2566:	
;keypad-c.c: 404: if (shift_flag)
	movf	(_shift_flag),w	;volatile
	skipz
	goto	u950
	goto	l2564
u950:
	line	407
	
l2568:	
;keypad-c.c: 405: {
;keypad-c.c: 407: RBIE = 0;
	bcf	(91/8),(91)&7
	line	410
	
l2570:	
;keypad-c.c: 410: scan_keypad();
	fcall	_scan_keypad
	line	413
	
l2572:	
;keypad-c.c: 413: RBIE = 1;
	bsf	(91/8),(91)&7
	goto	l2564
	global	start
	ljmp	start
	opt stack 0
psect	maintext
	line	416
GLOBAL	__end_of_main
	__end_of_main:
;; =============== function _main ends ============

	signat	_main,88
	global	_scan_keypad
psect	text378,local,class=CODE,delta=2
global __ptext378
__ptext378:

;; *************** function _scan_keypad *****************
;; Defined at:
;;		line 601 in file "C:\Users\micho\OneDrive - Université Saint-Esprit de Kaslik\Desktop\FALL 25-26\GEL558 Microcontrollers\Project 2 - Keypad\MPLAB\keypad-c.c"
;; Parameters:    Size  Location     Type
;;		None
;; Auto vars:     Size  Location     Type
;;  col             1   12[BANK0 ] unsigned char 
;;  row             1   11[BANK0 ] unsigned char 
;;  detected_cha    1   10[BANK0 ] unsigned char 
;;  shift_still_    1    9[BANK0 ] unsigned char 
;;  row_bits        1    8[BANK0 ] unsigned char 
;; Return value:  Size  Location     Type
;;		None               void
;; Registers used:
;;		wreg, fsr0l, fsr0h, status,2, status,0, btemp+1, pclath, cstack
;; Tracked objects:
;;		On entry : 60/0
;;		On exit  : 60/0
;;		Unchanged: 0/0
;; Data sizes:     COMMON   BANK0   BANK1   BANK3   BANK2
;;      Params:         0       0       0       0       0
;;      Locals:         0       5       0       0       0
;;      Temps:          0       3       0       0       0
;;      Totals:         0       8       0       0       0
;;Total ram usage:        8 bytes
;; Hardware stack levels used:    1
;; Hardware stack levels required when called:    3
;; This function calls:
;;		_delay_20ms
;;		_uart_transmit
;;		_write_eeprom
;;		_delay_ms
;; This function is called by:
;;		_main
;; This function uses a non-reentrant model
;;
psect	text378
	file	"C:\Users\micho\OneDrive - Université Saint-Esprit de Kaslik\Desktop\FALL 25-26\GEL558 Microcontrollers\Project 2 - Keypad\MPLAB\keypad-c.c"
	line	601
	global	__size_of_scan_keypad
	__size_of_scan_keypad	equ	__end_of_scan_keypad-_scan_keypad
	
_scan_keypad:	
	opt	stack 4
; Regs used in _scan_keypad: [wreg-fsr0h+status,2+status,0+btemp+1+pclath+cstack]
	line	603
	
l2480:	
;keypad-c.c: 602: unsigned char col, row_bits, row;
;keypad-c.c: 603: unsigned char detected_char = 0;
	clrf	(scan_keypad@detected_char)
	line	604
;keypad-c.c: 604: unsigned char shift_still_pressed = 0;
	clrf	(scan_keypad@shift_still_pressed)
	line	607
;keypad-c.c: 607: for (col = 0; col < 8; col++)
	clrf	(scan_keypad@col)
	
l2482:	
	movlw	(08h)
	subwf	(scan_keypad@col),w
	skipc
	goto	u801
	goto	u800
u801:
	goto	l2486
u800:
	goto	l2526
	line	610
	
l2486:	
;keypad-c.c: 608: {
;keypad-c.c: 610: PORTD = 0xFF;
	movlw	(0FFh)
	movwf	(8)	;volatile
	line	613
	
l2488:	
;keypad-c.c: 613: PORTD = ~(1 << col);
	movlw	(01h)
	movwf	(??_scan_keypad+0)+0
	incf	(scan_keypad@col),w
	goto	u814
u815:
	clrc
	rlf	(??_scan_keypad+0)+0,f
u814:
	addlw	-1
	skipz
	goto	u815
	movf	0+(??_scan_keypad+0)+0,w
	xorlw	0ffh
	movwf	(8)	;volatile
	line	616
	
l2490:	
;keypad-c.c: 616: _nop();
	nop
	line	617
	
l2492:	
;keypad-c.c: 617: _nop();
	nop
	line	618
	
l2494:	
;keypad-c.c: 618: _nop();
	nop
	line	619
	
l2496:	
;keypad-c.c: 619: _nop();
	nop
	line	622
	
l2498:	
;keypad-c.c: 622: row_bits = PORTB & 0xF0;
	bcf	status, 5	;RP0=0, select bank0
	bcf	status, 6	;RP1=0, select bank0
	movf	(6),w
	movwf	(scan_keypad@row_bits)
	movlw	(0F0h)
	andwf	(scan_keypad@row_bits),f
	line	625
	
l2500:	
;keypad-c.c: 625: for (row = 0; row < 4; row++)
	clrf	(scan_keypad@row)
	line	627
	
l2506:	
;keypad-c.c: 626: {
;keypad-c.c: 627: if (!(row_bits & (0x10 << row)))
	movlw	(010h)
	movwf	(??_scan_keypad+0)+0
	incf	(scan_keypad@row),w
	goto	u824
u825:
	clrc
	rlf	(??_scan_keypad+0)+0,f
u824:
	addlw	-1
	skipz
	goto	u825
	movf	0+(??_scan_keypad+0)+0,w
	andwf	(scan_keypad@row_bits),w
	btfss	status,2
	goto	u831
	goto	u830
u831:
	goto	l2518
u830:
	line	632
	
l2508:	
;keypad-c.c: 628: {
;keypad-c.c: 632: if (row == 3 && (col == 0 || col == 7))
	movf	(scan_keypad@row),w
	xorlw	03h
	skipz
	goto	u841
	goto	u840
u841:
	goto	l2514
u840:
	
l2510:	
	movf	(scan_keypad@col),w
	skipz
	goto	u850
	goto	l790
u850:
	
l2512:	
	movf	(scan_keypad@col),w
	xorlw	07h
	skipz
	goto	u861
	goto	u860
u861:
	goto	l2514
u860:
	
l790:	
	line	634
;keypad-c.c: 633: {
;keypad-c.c: 634: shift_still_pressed = 1;
	clrf	(scan_keypad@shift_still_pressed)
	incf	(scan_keypad@shift_still_pressed),f
	line	635
;keypad-c.c: 635: }
	goto	l2518
	line	639
	
l2514:	
;keypad-c.c: 636: else
;keypad-c.c: 637: {
;keypad-c.c: 639: if (keypad_map[row][col] != 0)
	movf	(scan_keypad@row),w
	movwf	(??_scan_keypad+0)+0
	clrc
	rlf	(??_scan_keypad+0)+0,f
	clrc
	rlf	(??_scan_keypad+0)+0,f
	clrc
	rlf	(??_scan_keypad+0)+0,w
	addlw	low(_keypad_map|8000h)
	movwf	(??_scan_keypad+1)+0
	movlw	high(_keypad_map|8000h)
	skipnc
	addlw	1
	movwf	1+((??_scan_keypad+1)+0)
	movf	(scan_keypad@col),w
	addwf	0+(??_scan_keypad+1)+0,w
	movwf	fsr0
	movf	1+(??_scan_keypad+1)+0,w
	skipnc
	incf	1+(??_scan_keypad+1)+0,w
	movwf	btemp+1
	fcall	stringtab
	xorlw	0
	skipnz
	goto	u871
	goto	u870
u871:
	goto	l2518
u870:
	line	641
	
l2516:	
;keypad-c.c: 640: {
;keypad-c.c: 641: detected_char = keypad_map[row][col];
	movf	(scan_keypad@row),w
	movwf	(??_scan_keypad+0)+0
	clrc
	rlf	(??_scan_keypad+0)+0,f
	clrc
	rlf	(??_scan_keypad+0)+0,f
	clrc
	rlf	(??_scan_keypad+0)+0,w
	addlw	low(_keypad_map|8000h)
	movwf	(??_scan_keypad+1)+0
	movlw	high(_keypad_map|8000h)
	skipnc
	addlw	1
	movwf	1+((??_scan_keypad+1)+0)
	movf	(scan_keypad@col),w
	addwf	0+(??_scan_keypad+1)+0,w
	movwf	fsr0
	movf	1+(??_scan_keypad+1)+0,w
	skipnc
	incf	1+(??_scan_keypad+1)+0,w
	movwf	btemp+1
	fcall	stringtab
	movwf	(scan_keypad@detected_char)
	line	625
	
l2518:	
	incf	(scan_keypad@row),f
	
l2520:	
	movlw	(04h)
	subwf	(scan_keypad@row),w
	skipc
	goto	u881
	goto	u880
u881:
	goto	l2506
u880:
	line	607
	
l2522:	
	incf	(scan_keypad@col),f
	goto	l2482
	line	649
	
l2526:	
;keypad-c.c: 642: }
;keypad-c.c: 643: }
;keypad-c.c: 644: }
;keypad-c.c: 645: }
;keypad-c.c: 646: }
;keypad-c.c: 649: PORTD = 0x00;
	clrf	(8)	;volatile
	line	652
	
l2528:	
;keypad-c.c: 652: shift_flag = shift_still_pressed;
	movf	(scan_keypad@shift_still_pressed),w
	movwf	(_shift_flag)	;volatile
	line	655
	
l2530:	
;keypad-c.c: 655: if (detected_char != 0 && shift_flag)
	movf	(scan_keypad@detected_char),w
	skipz
	goto	u890
	goto	l795
u890:
	
l2532:	
	movf	(_shift_flag),w	;volatile
	skipz
	goto	u900
	goto	l795
u900:
	line	658
	
l2534:	
;keypad-c.c: 656: {
;keypad-c.c: 658: delay_20ms();
	fcall	_delay_20ms
	line	661
	
l2536:	
;keypad-c.c: 661: if (detected_char >= 'a' && detected_char <= 'z')
	movlw	(061h)
	bcf	status, 5	;RP0=0, select bank0
	bcf	status, 6	;RP1=0, select bank0
	subwf	(scan_keypad@detected_char),w
	skipc
	goto	u911
	goto	u910
u911:
	goto	l2542
u910:
	
l2538:	
	movlw	(07Bh)
	subwf	(scan_keypad@detected_char),w
	skipnc
	goto	u921
	goto	u920
u921:
	goto	l2542
u920:
	line	663
	
l2540:	
;keypad-c.c: 662: {
;keypad-c.c: 663: detected_char = detected_char - 32;
	movlw	(0E0h)
	addwf	(scan_keypad@detected_char),f
	line	667
	
l2542:	
;keypad-c.c: 664: }
;keypad-c.c: 667: current_char = detected_char;
	movf	(scan_keypad@detected_char),w
	movwf	(_current_char)	;volatile
	line	668
	
l2544:	
;keypad-c.c: 668: key_pressed = 1;
	clrf	(_key_pressed)	;volatile
	incf	(_key_pressed),f	;volatile
	line	671
	
l2546:	
;keypad-c.c: 671: uart_transmit(current_char);
	movf	(_current_char),w	;volatile
	fcall	_uart_transmit
	line	674
	
l2548:	
;keypad-c.c: 674: write_eeprom(0x00, current_char);
	movf	(_current_char),w	;volatile
	movwf	(?_write_eeprom)
	movlw	(0)
	fcall	_write_eeprom
	line	677
	
l2550:	
;keypad-c.c: 677: delay_ms(200);
	movlw	0C8h
	bcf	status, 5	;RP0=0, select bank0
	bcf	status, 6	;RP1=0, select bank0
	movwf	(?_delay_ms)
	clrf	(?_delay_ms+1)
	fcall	_delay_ms
	line	679
	
l795:	
	return
	opt stack 0
GLOBAL	__end_of_scan_keypad
	__end_of_scan_keypad:
;; =============== function _scan_keypad ends ============

	signat	_scan_keypad,88
	global	_display_character
psect	text379,local,class=CODE,delta=2
global __ptext379
__ptext379:

;; *************** function _display_character *****************
;; Defined at:
;;		line 549 in file "C:\Users\micho\OneDrive - Université Saint-Esprit de Kaslik\Desktop\FALL 25-26\GEL558 Microcontrollers\Project 2 - Keypad\MPLAB\keypad-c.c"
;; Parameters:    Size  Location     Type
;;  ch              1    wreg     unsigned char 
;; Auto vars:     Size  Location     Type
;;  ch              1   13[BANK0 ] unsigned char 
;;  col             1   14[BANK0 ] unsigned char 
;;  col_mask        1   12[BANK0 ] unsigned char 
;;  font_index      1   11[BANK0 ] unsigned char 
;;  row_data        1   10[BANK0 ] unsigned char 
;; Return value:  Size  Location     Type
;;		None               void
;; Registers used:
;;		wreg, fsr0l, fsr0h, status,2, status,0, btemp+1, pclath, cstack
;; Tracked objects:
;;		On entry : 60/0
;;		On exit  : 60/0
;;		Unchanged: 0/0
;; Data sizes:     COMMON   BANK0   BANK1   BANK3   BANK2
;;      Params:         0       0       0       0       0
;;      Locals:         0       5       0       0       0
;;      Temps:          0       4       0       0       0
;;      Totals:         0       9       0       0       0
;;Total ram usage:        9 bytes
;; Hardware stack levels used:    1
;; Hardware stack levels required when called:    3
;; This function calls:
;;		___wmul
;;		_output_row_data
;;		_delay_2ms
;; This function is called by:
;;		_main
;; This function uses a non-reentrant model
;;
psect	text379
	file	"C:\Users\micho\OneDrive - Université Saint-Esprit de Kaslik\Desktop\FALL 25-26\GEL558 Microcontrollers\Project 2 - Keypad\MPLAB\keypad-c.c"
	line	549
	global	__size_of_display_character
	__size_of_display_character	equ	__end_of_display_character-_display_character
	
_display_character:	
	opt	stack 4
; Regs used in _display_character: [wreg-fsr0h+status,2+status,0+btemp+1+pclath+cstack]
;display_character@ch stored from wreg
	line	556
	movwf	(display_character@ch)
	
l2444:	
;keypad-c.c: 550: unsigned char col;
;keypad-c.c: 551: unsigned char font_index;
;keypad-c.c: 552: unsigned char row_data;
;keypad-c.c: 553: unsigned char col_mask;
;keypad-c.c: 556: if (ch >= 42 && ch <= 'z')
	movlw	(02Ah)
	subwf	(display_character@ch),w
	skipc
	goto	u761
	goto	u760
u761:
	goto	l2450
u760:
	
l2446:	
	movlw	(07Bh)
	subwf	(display_character@ch),w
	skipnc
	goto	u771
	goto	u770
u771:
	goto	l2450
u770:
	line	558
	
l2448:	
;keypad-c.c: 557: {
;keypad-c.c: 558: font_index = ch - 42;
	movf	(display_character@ch),w
	addlw	0D6h
	movwf	(display_character@font_index)
	line	559
;keypad-c.c: 559: }
	goto	l2452
	line	563
	
l2450:	
;keypad-c.c: 560: else
;keypad-c.c: 561: {
;keypad-c.c: 563: font_index = 'a' - 42;
	movlw	(037h)
	movwf	(display_character@font_index)
	line	567
	
l2452:	
;keypad-c.c: 564: }
;keypad-c.c: 567: for (col = 0; col < 5; col++)
	clrf	(display_character@col)
	
l2454:	
	movlw	(05h)
	subwf	(display_character@col),w
	skipc
	goto	u781
	goto	u780
u781:
	goto	l2458
u780:
	goto	l2478
	line	570
	
l2458:	
;keypad-c.c: 568: {
;keypad-c.c: 570: PORTA = PORTA | 0x1F;
	movlw	(01Fh)
	iorwf	(5),f	;volatile
	line	573
	
l2460:	
;keypad-c.c: 573: row_data = font_table[font_index][col];
	movf	(display_character@font_index),w
	movwf	(?___wmul)
	clrf	(?___wmul+1)
	movlw	05h
	movwf	0+(?___wmul)+02h
	clrf	1+(?___wmul)+02h
	fcall	___wmul
	movlw	low(_font_table|8000h)
	movwf	(??_display_character+0)+0
	movlw	high(_font_table|8000h)
	movwf	(??_display_character+0)+0+1
	movf	(0+(?___wmul)),w
	addwf	0+(??_display_character+0)+0,w
	movwf	(??_display_character+2)+0
	movf	(1+(?___wmul)),w
	skipnc
	incf	(1+(?___wmul)),w
	addwf	1+(??_display_character+0)+0,w
	movwf	1+(??_display_character+2)+0
	movf	(display_character@col),w
	addwf	0+(??_display_character+2)+0,w
	movwf	fsr0
	movf	1+(??_display_character+2)+0,w
	skipnc
	incf	1+(??_display_character+2)+0,w
	movwf	btemp+1
	fcall	stringtab
	movwf	(display_character@row_data)
	line	576
	
l2462:	
;keypad-c.c: 576: output_row_data(row_data);
	movf	(display_character@row_data),w
	fcall	_output_row_data
	line	579
	
l2464:	
;keypad-c.c: 579: col_mask = ~(1 << col) & 0x1F;
	movlw	(01h)
	movwf	(??_display_character+0)+0
	incf	(display_character@col),w
	goto	u794
u795:
	clrc
	rlf	(??_display_character+0)+0,f
u794:
	addlw	-1
	skipz
	goto	u795
	movf	0+(??_display_character+0)+0,w
	xorlw	0ffh
	movwf	(display_character@col_mask)
	
l2466:	
	movlw	(01Fh)
	andwf	(display_character@col_mask),f
	line	583
	
l2468:	
;keypad-c.c: 583: PORTA = (PORTA & 0x20) | col_mask;
	movf	(5),w
	andlw	020h
	iorwf	(display_character@col_mask),w
	movwf	(5)	;volatile
	line	586
	
l2470:	
;keypad-c.c: 586: delay_2ms();
	fcall	_delay_2ms
	line	589
	
l2472:	
;keypad-c.c: 589: PORTA = PORTA | 0x1F;
	movlw	(01Fh)
	bcf	status, 5	;RP0=0, select bank0
	bcf	status, 6	;RP1=0, select bank0
	iorwf	(5),f	;volatile
	line	567
	
l2474:	
	incf	(display_character@col),f
	goto	l2454
	line	593
	
l2478:	
;keypad-c.c: 590: }
;keypad-c.c: 593: output_row_data(0x7F);
	movlw	(07Fh)
	fcall	_output_row_data
	line	594
	
l780:	
	return
	opt stack 0
GLOBAL	__end_of_display_character
	__end_of_display_character:
;; =============== function _display_character ends ============

	signat	_display_character,4216
	global	_delay_2ms
psect	text380,local,class=CODE,delta=2
global __ptext380
__ptext380:

;; *************** function _delay_2ms *****************
;; Defined at:
;;		line 501 in file "C:\Users\micho\OneDrive - Université Saint-Esprit de Kaslik\Desktop\FALL 25-26\GEL558 Microcontrollers\Project 2 - Keypad\MPLAB\keypad-c.c"
;; Parameters:    Size  Location     Type
;;		None
;; Auto vars:     Size  Location     Type
;;		None
;; Return value:  Size  Location     Type
;;		None               void
;; Registers used:
;;		wreg
;; Tracked objects:
;;		On entry : 60/0
;;		On exit  : 0/0
;;		Unchanged: 0/0
;; Data sizes:     COMMON   BANK0   BANK1   BANK3   BANK2
;;      Params:         0       0       0       0       0
;;      Locals:         0       0       0       0       0
;;      Temps:          0       2       0       0       0
;;      Totals:         0       2       0       0       0
;;Total ram usage:        2 bytes
;; Hardware stack levels used:    1
;; Hardware stack levels required when called:    2
;; This function calls:
;;		Nothing
;; This function is called by:
;;		_display_character
;; This function uses a non-reentrant model
;;
psect	text380
	file	"C:\Users\micho\OneDrive - Université Saint-Esprit de Kaslik\Desktop\FALL 25-26\GEL558 Microcontrollers\Project 2 - Keypad\MPLAB\keypad-c.c"
	line	501
	global	__size_of_delay_2ms
	__size_of_delay_2ms	equ	__end_of_delay_2ms-_delay_2ms
	
_delay_2ms:	
	opt	stack 4
; Regs used in _delay_2ms: [wreg]
	line	502
	
l2442:	
;keypad-c.c: 502: _delay((unsigned long)((2)*(4000000/4000.0)));
	opt asmopt_off
movlw	3
movwf	((??_delay_2ms+0)+0+1),f
	movlw	151
movwf	((??_delay_2ms+0)+0),f
u967:
	decfsz	((??_delay_2ms+0)+0),f
	goto	u967
	decfsz	((??_delay_2ms+0)+0+1),f
	goto	u967
	nop2
opt asmopt_on

	line	503
	
l759:	
	return
	opt stack 0
GLOBAL	__end_of_delay_2ms
	__end_of_delay_2ms:
;; =============== function _delay_2ms ends ============

	signat	_delay_2ms,88
	global	_delay_ms
psect	text381,local,class=CODE,delta=2
global __ptext381
__ptext381:

;; *************** function _delay_ms *****************
;; Defined at:
;;		line 492 in file "C:\Users\micho\OneDrive - Université Saint-Esprit de Kaslik\Desktop\FALL 25-26\GEL558 Microcontrollers\Project 2 - Keypad\MPLAB\keypad-c.c"
;; Parameters:    Size  Location     Type
;;  ms              2    0[BANK0 ] unsigned int 
;; Auto vars:     Size  Location     Type
;;  i               2    3[BANK0 ] unsigned int 
;; Return value:  Size  Location     Type
;;		None               void
;; Registers used:
;;		wreg, status,2, status,0
;; Tracked objects:
;;		On entry : 60/0
;;		On exit  : 60/0
;;		Unchanged: 0/0
;; Data sizes:     COMMON   BANK0   BANK1   BANK3   BANK2
;;      Params:         0       2       0       0       0
;;      Locals:         0       2       0       0       0
;;      Temps:          0       1       0       0       0
;;      Totals:         0       5       0       0       0
;;Total ram usage:        5 bytes
;; Hardware stack levels used:    1
;; Hardware stack levels required when called:    2
;; This function calls:
;;		Nothing
;; This function is called by:
;;		_scan_keypad
;; This function uses a non-reentrant model
;;
psect	text381
	file	"C:\Users\micho\OneDrive - Université Saint-Esprit de Kaslik\Desktop\FALL 25-26\GEL558 Microcontrollers\Project 2 - Keypad\MPLAB\keypad-c.c"
	line	492
	global	__size_of_delay_ms
	__size_of_delay_ms	equ	__end_of_delay_ms-_delay_ms
	
_delay_ms:	
	opt	stack 4
; Regs used in _delay_ms: [wreg+status,2+status,0]
	line	494
	
l2434:	
;keypad-c.c: 493: unsigned int i;
;keypad-c.c: 494: for (i = 0; i < ms; i++)
	clrf	(delay_ms@i)
	clrf	(delay_ms@i+1)
	goto	l2440
	line	496
	
l2436:	
;keypad-c.c: 495: {
;keypad-c.c: 496: _delay((unsigned long)((1)*(4000000/4000.0)));
	opt asmopt_off
movlw	249
movwf	(??_delay_ms+0)+0,f
u977:
	clrwdt
decfsz	(??_delay_ms+0)+0,f
	goto	u977
	nop2	;nop
	clrwdt
opt asmopt_on

	line	494
	
l2438:	
	bcf	status, 5	;RP0=0, select bank0
	bcf	status, 6	;RP1=0, select bank0
	incf	(delay_ms@i),f
	skipnz
	incf	(delay_ms@i+1),f
	
l2440:	
	movf	(delay_ms@ms+1),w
	subwf	(delay_ms@i+1),w
	skipz
	goto	u755
	movf	(delay_ms@ms),w
	subwf	(delay_ms@i),w
u755:
	skipc
	goto	u751
	goto	u750
u751:
	goto	l2436
u750:
	line	498
	
l756:	
	return
	opt stack 0
GLOBAL	__end_of_delay_ms
	__end_of_delay_ms:
;; =============== function _delay_ms ends ============

	signat	_delay_ms,4216
	global	_delay_20ms
psect	text382,local,class=CODE,delta=2
global __ptext382
__ptext382:

;; *************** function _delay_20ms *****************
;; Defined at:
;;		line 506 in file "C:\Users\micho\OneDrive - Université Saint-Esprit de Kaslik\Desktop\FALL 25-26\GEL558 Microcontrollers\Project 2 - Keypad\MPLAB\keypad-c.c"
;; Parameters:    Size  Location     Type
;;		None
;; Auto vars:     Size  Location     Type
;;		None
;; Return value:  Size  Location     Type
;;		None               void
;; Registers used:
;;		wreg
;; Tracked objects:
;;		On entry : 60/0
;;		On exit  : 0/0
;;		Unchanged: 0/0
;; Data sizes:     COMMON   BANK0   BANK1   BANK3   BANK2
;;      Params:         0       0       0       0       0
;;      Locals:         0       0       0       0       0
;;      Temps:          0       2       0       0       0
;;      Totals:         0       2       0       0       0
;;Total ram usage:        2 bytes
;; Hardware stack levels used:    1
;; Hardware stack levels required when called:    2
;; This function calls:
;;		Nothing
;; This function is called by:
;;		_scan_keypad
;; This function uses a non-reentrant model
;;
psect	text382
	file	"C:\Users\micho\OneDrive - Université Saint-Esprit de Kaslik\Desktop\FALL 25-26\GEL558 Microcontrollers\Project 2 - Keypad\MPLAB\keypad-c.c"
	line	506
	global	__size_of_delay_20ms
	__size_of_delay_20ms	equ	__end_of_delay_20ms-_delay_20ms
	
_delay_20ms:	
	opt	stack 4
; Regs used in _delay_20ms: [wreg]
	line	507
	
l2432:	
;keypad-c.c: 507: _delay((unsigned long)((20)*(4000000/4000.0)));
	opt asmopt_off
movlw	26
movwf	((??_delay_20ms+0)+0+1),f
	movlw	248
movwf	((??_delay_20ms+0)+0),f
u987:
	decfsz	((??_delay_20ms+0)+0),f
	goto	u987
	decfsz	((??_delay_20ms+0)+0+1),f
	goto	u987
	clrwdt
opt asmopt_on

	line	508
	
l762:	
	return
	opt stack 0
GLOBAL	__end_of_delay_20ms
	__end_of_delay_20ms:
;; =============== function _delay_20ms ends ============

	signat	_delay_20ms,88
	global	___wmul
psect	text383,local,class=CODE,delta=2
global __ptext383
__ptext383:

;; *************** function ___wmul *****************
;; Defined at:
;;		line 3 in file "C:\Program Files (x86)\HI-TECH Software\PICC\9.83\sources\wmul.c"
;; Parameters:    Size  Location     Type
;;  multiplier      2    0[BANK0 ] unsigned int 
;;  multiplicand    2    2[BANK0 ] unsigned int 
;; Auto vars:     Size  Location     Type
;;  product         2    4[BANK0 ] unsigned int 
;; Return value:  Size  Location     Type
;;                  2    0[BANK0 ] unsigned int 
;; Registers used:
;;		wreg, status,2, status,0
;; Tracked objects:
;;		On entry : 60/0
;;		On exit  : 60/0
;;		Unchanged: FFF9F/0
;; Data sizes:     COMMON   BANK0   BANK1   BANK3   BANK2
;;      Params:         0       4       0       0       0
;;      Locals:         0       2       0       0       0
;;      Temps:          0       0       0       0       0
;;      Totals:         0       6       0       0       0
;;Total ram usage:        6 bytes
;; Hardware stack levels used:    1
;; Hardware stack levels required when called:    2
;; This function calls:
;;		Nothing
;; This function is called by:
;;		_display_character
;; This function uses a non-reentrant model
;;
psect	text383
	file	"C:\Program Files (x86)\HI-TECH Software\PICC\9.83\sources\wmul.c"
	line	3
	global	__size_of___wmul
	__size_of___wmul	equ	__end_of___wmul-___wmul
	
___wmul:	
	opt	stack 4
; Regs used in ___wmul: [wreg+status,2+status,0]
	line	4
	
l2396:	
	clrf	(___wmul@product)
	clrf	(___wmul@product+1)
	line	7
	
l2398:	
	btfss	(___wmul@multiplier),(0)&7
	goto	u701
	goto	u700
u701:
	goto	l2402
u700:
	line	8
	
l2400:	
	movf	(___wmul@multiplicand),w
	addwf	(___wmul@product),f
	skipnc
	incf	(___wmul@product+1),f
	movf	(___wmul@multiplicand+1),w
	addwf	(___wmul@product+1),f
	line	9
	
l2402:	
	clrc
	rlf	(___wmul@multiplicand),f
	rlf	(___wmul@multiplicand+1),f
	line	10
	
l2404:	
	clrc
	rrf	(___wmul@multiplier+1),f
	rrf	(___wmul@multiplier),f
	line	11
	
l2406:	
	movf	((___wmul@multiplier+1)),w
	iorwf	((___wmul@multiplier)),w
	skipz
	goto	u711
	goto	u710
u711:
	goto	l2398
u710:
	line	12
	
l2408:	
	movf	(___wmul@product+1),w
	movwf	(?___wmul+1)
	movf	(___wmul@product),w
	movwf	(?___wmul)
	line	13
	
l1493:	
	return
	opt stack 0
GLOBAL	__end_of___wmul
	__end_of___wmul:
;; =============== function ___wmul ends ============

	signat	___wmul,8314
	global	_output_row_data
psect	text384,local,class=CODE,delta=2
global __ptext384
__ptext384:

;; *************** function _output_row_data *****************
;; Defined at:
;;		line 528 in file "C:\Users\micho\OneDrive - Université Saint-Esprit de Kaslik\Desktop\FALL 25-26\GEL558 Microcontrollers\Project 2 - Keypad\MPLAB\keypad-c.c"
;; Parameters:    Size  Location     Type
;;  data            1    wreg     unsigned char 
;; Auto vars:     Size  Location     Type
;;  data            1    1[BANK0 ] unsigned char 
;; Return value:  Size  Location     Type
;;		None               void
;; Registers used:
;;		wreg, status,2, status,0
;; Tracked objects:
;;		On entry : 60/0
;;		On exit  : 60/0
;;		Unchanged: FFF9F/0
;; Data sizes:     COMMON   BANK0   BANK1   BANK3   BANK2
;;      Params:         0       0       0       0       0
;;      Locals:         0       1       0       0       0
;;      Temps:          0       1       0       0       0
;;      Totals:         0       2       0       0       0
;;Total ram usage:        2 bytes
;; Hardware stack levels used:    1
;; Hardware stack levels required when called:    2
;; This function calls:
;;		Nothing
;; This function is called by:
;;		_display_character
;; This function uses a non-reentrant model
;;
psect	text384
	file	"C:\Users\micho\OneDrive - Université Saint-Esprit de Kaslik\Desktop\FALL 25-26\GEL558 Microcontrollers\Project 2 - Keypad\MPLAB\keypad-c.c"
	line	528
	global	__size_of_output_row_data
	__size_of_output_row_data	equ	__end_of_output_row_data-_output_row_data
	
_output_row_data:	
	opt	stack 4
; Regs used in _output_row_data: [wreg+status,2+status,0]
;output_row_data@data stored from wreg
	line	531
	movwf	(output_row_data@data)
	
l2390:	
;keypad-c.c: 531: PORTC = (PORTC & 0xC0) | (data & 0x3F);
	movlw	(03Fh)
	andwf	(output_row_data@data),w
	movwf	(??_output_row_data+0)+0
	movf	(7),w
	andlw	0C0h
	iorwf	0+(??_output_row_data+0)+0,w
	movwf	(7)	;volatile
	line	534
	
l2392:	
;keypad-c.c: 534: if (data & 0x40)
	btfss	(output_row_data@data),(6)&7
	goto	u691
	goto	u690
u691:
	goto	l771
u690:
	line	536
	
l2394:	
;keypad-c.c: 535: {
;keypad-c.c: 536: RA5 = 1;
	bsf	(45/8),(45)&7
	line	537
;keypad-c.c: 537: }
	goto	l773
	line	538
	
l771:	
	line	540
;keypad-c.c: 538: else
;keypad-c.c: 539: {
;keypad-c.c: 540: RA5 = 0;
	bcf	(45/8),(45)&7
	line	542
	
l773:	
	return
	opt stack 0
GLOBAL	__end_of_output_row_data
	__end_of_output_row_data:
;; =============== function _output_row_data ends ============

	signat	_output_row_data,4216
	global	_read_eeprom
psect	text385,local,class=CODE,delta=2
global __ptext385
__ptext385:

;; *************** function _read_eeprom *****************
;; Defined at:
;;		line 725 in file "C:\Users\micho\OneDrive - Université Saint-Esprit de Kaslik\Desktop\FALL 25-26\GEL558 Microcontrollers\Project 2 - Keypad\MPLAB\keypad-c.c"
;; Parameters:    Size  Location     Type
;;  address         1    wreg     unsigned char 
;; Auto vars:     Size  Location     Type
;;  address         1    0[BANK0 ] unsigned char 
;; Return value:  Size  Location     Type
;;                  1    wreg      unsigned char 
;; Registers used:
;;		wreg
;; Tracked objects:
;;		On entry : 17F/0
;;		On exit  : 17F/40
;;		Unchanged: FFE80/0
;; Data sizes:     COMMON   BANK0   BANK1   BANK3   BANK2
;;      Params:         0       0       0       0       0
;;      Locals:         0       1       0       0       0
;;      Temps:          0       0       0       0       0
;;      Totals:         0       1       0       0       0
;;Total ram usage:        1 bytes
;; Hardware stack levels used:    1
;; Hardware stack levels required when called:    2
;; This function calls:
;;		Nothing
;; This function is called by:
;;		_main
;; This function uses a non-reentrant model
;;
psect	text385
	file	"C:\Users\micho\OneDrive - Université Saint-Esprit de Kaslik\Desktop\FALL 25-26\GEL558 Microcontrollers\Project 2 - Keypad\MPLAB\keypad-c.c"
	line	725
	global	__size_of_read_eeprom
	__size_of_read_eeprom	equ	__end_of_read_eeprom-_read_eeprom
	
_read_eeprom:	
	opt	stack 5
; Regs used in _read_eeprom: [wreg]
;read_eeprom@address stored from wreg
	line	727
	movwf	(read_eeprom@address)
	
l2382:	
;keypad-c.c: 727: EEADR = address;
	movf	(read_eeprom@address),w
	bsf	status, 6	;RP1=1, select bank2
	movwf	(269)^0100h	;volatile
	line	730
	
l2384:	
;keypad-c.c: 730: EECON1bits.EEPGD = 0;
	bsf	status, 5	;RP0=1, select bank3
	bcf	(396)^0180h,7	;volatile
	line	733
	
l2386:	
;keypad-c.c: 733: RD = 1;
	bsf	(3168/8)^0180h,(3168)&7
	line	736
;keypad-c.c: 736: return EEDATA;
	bcf	status, 5	;RP0=0, select bank2
	movf	(268)^0100h,w	;volatile
	line	737
	
l807:	
	return
	opt stack 0
GLOBAL	__end_of_read_eeprom
	__end_of_read_eeprom:
;; =============== function _read_eeprom ends ============

	signat	_read_eeprom,4217
	global	_init_interrupts
psect	text386,local,class=CODE,delta=2
global __ptext386
__ptext386:

;; *************** function _init_interrupts *****************
;; Defined at:
;;		line 469 in file "C:\Users\micho\OneDrive - Université Saint-Esprit de Kaslik\Desktop\FALL 25-26\GEL558 Microcontrollers\Project 2 - Keypad\MPLAB\keypad-c.c"
;; Parameters:    Size  Location     Type
;;		None
;; Auto vars:     Size  Location     Type
;;  dummy           1    0        unsigned char 
;; Return value:  Size  Location     Type
;;		None               void
;; Registers used:
;;		wreg
;; Tracked objects:
;;		On entry : 17F/0
;;		On exit  : 17F/0
;;		Unchanged: FFE80/0
;; Data sizes:     COMMON   BANK0   BANK1   BANK3   BANK2
;;      Params:         0       0       0       0       0
;;      Locals:         0       0       0       0       0
;;      Temps:          0       0       0       0       0
;;      Totals:         0       0       0       0       0
;;Total ram usage:        0 bytes
;; Hardware stack levels used:    1
;; Hardware stack levels required when called:    2
;; This function calls:
;;		Nothing
;; This function is called by:
;;		_main
;; This function uses a non-reentrant model
;;
psect	text386
	file	"C:\Users\micho\OneDrive - Université Saint-Esprit de Kaslik\Desktop\FALL 25-26\GEL558 Microcontrollers\Project 2 - Keypad\MPLAB\keypad-c.c"
	line	469
	global	__size_of_init_interrupts
	__size_of_init_interrupts	equ	__end_of_init_interrupts-_init_interrupts
	
_init_interrupts:	
	opt	stack 5
; Regs used in _init_interrupts: [wreg]
	line	473
	
l2372:	
;keypad-c.c: 470: unsigned char dummy;
;keypad-c.c: 473: dummy = PORTB;
	movf	(6),w	;volatile
	line	476
	
l2374:	
;keypad-c.c: 476: RBIF = 0;
	bcf	(88/8),(88)&7
	line	479
	
l2376:	
;keypad-c.c: 479: RBIE = 1;
	bsf	(91/8),(91)&7
	line	482
	
l2378:	
;keypad-c.c: 482: PEIE = 1;
	bsf	(94/8),(94)&7
	line	485
	
l2380:	
;keypad-c.c: 485: GIE = 1;
	bsf	(95/8),(95)&7
	line	486
	
l750:	
	return
	opt stack 0
GLOBAL	__end_of_init_interrupts
	__end_of_init_interrupts:
;; =============== function _init_interrupts ends ============

	signat	_init_interrupts,88
	global	_init_uart
psect	text387,local,class=CODE,delta=2
global __ptext387
__ptext387:

;; *************** function _init_uart *****************
;; Defined at:
;;		line 449 in file "C:\Users\micho\OneDrive - Université Saint-Esprit de Kaslik\Desktop\FALL 25-26\GEL558 Microcontrollers\Project 2 - Keypad\MPLAB\keypad-c.c"
;; Parameters:    Size  Location     Type
;;		None
;; Auto vars:     Size  Location     Type
;;		None
;; Return value:  Size  Location     Type
;;		None               void
;; Registers used:
;;		wreg
;; Tracked objects:
;;		On entry : 17F/0
;;		On exit  : 17F/0
;;		Unchanged: FFE80/0
;; Data sizes:     COMMON   BANK0   BANK1   BANK3   BANK2
;;      Params:         0       0       0       0       0
;;      Locals:         0       0       0       0       0
;;      Temps:          0       0       0       0       0
;;      Totals:         0       0       0       0       0
;;Total ram usage:        0 bytes
;; Hardware stack levels used:    1
;; Hardware stack levels required when called:    2
;; This function calls:
;;		Nothing
;; This function is called by:
;;		_main
;; This function uses a non-reentrant model
;;
psect	text387
	file	"C:\Users\micho\OneDrive - Université Saint-Esprit de Kaslik\Desktop\FALL 25-26\GEL558 Microcontrollers\Project 2 - Keypad\MPLAB\keypad-c.c"
	line	449
	global	__size_of_init_uart
	__size_of_init_uart	equ	__end_of_init_uart-_init_uart
	
_init_uart:	
	opt	stack 5
; Regs used in _init_uart: [wreg]
	line	451
	
l2356:	
;keypad-c.c: 451: SPBRG = 25;
	movlw	(019h)
	bsf	status, 5	;RP0=1, select bank1
	movwf	(153)^080h	;volatile
	line	454
	
l2358:	
;keypad-c.c: 454: TXSTAbits.BRGH = 1;
	bsf	(152)^080h,2	;volatile
	line	455
	
l2360:	
;keypad-c.c: 455: TXSTAbits.SYNC = 0;
	bcf	(152)^080h,4	;volatile
	line	456
	
l2362:	
;keypad-c.c: 456: TXSTAbits.TX9 = 0;
	bcf	(152)^080h,6	;volatile
	line	457
	
l2364:	
;keypad-c.c: 457: TXSTAbits.TXEN = 1;
	bsf	(152)^080h,5	;volatile
	line	460
	
l2366:	
;keypad-c.c: 460: RCSTAbits.SPEN = 1;
	bcf	status, 5	;RP0=0, select bank0
	bsf	(24),7	;volatile
	line	461
	
l2368:	
;keypad-c.c: 461: RCSTAbits.RX9 = 0;
	bcf	(24),6	;volatile
	line	462
	
l2370:	
;keypad-c.c: 462: RCSTAbits.CREN = 0;
	bcf	(24),4	;volatile
	line	463
	
l747:	
	return
	opt stack 0
GLOBAL	__end_of_init_uart
	__end_of_init_uart:
;; =============== function _init_uart ends ============

	signat	_init_uart,88
	global	_init_ports
psect	text388,local,class=CODE,delta=2
global __ptext388
__ptext388:

;; *************** function _init_ports *****************
;; Defined at:
;;		line 422 in file "C:\Users\micho\OneDrive - Université Saint-Esprit de Kaslik\Desktop\FALL 25-26\GEL558 Microcontrollers\Project 2 - Keypad\MPLAB\keypad-c.c"
;; Parameters:    Size  Location     Type
;;		None
;; Auto vars:     Size  Location     Type
;;		None
;; Return value:  Size  Location     Type
;;		None               void
;; Registers used:
;;		wreg, status,2
;; Tracked objects:
;;		On entry : 17F/0
;;		On exit  : 17F/0
;;		Unchanged: FFE80/0
;; Data sizes:     COMMON   BANK0   BANK1   BANK3   BANK2
;;      Params:         0       0       0       0       0
;;      Locals:         0       0       0       0       0
;;      Temps:          0       0       0       0       0
;;      Totals:         0       0       0       0       0
;;Total ram usage:        0 bytes
;; Hardware stack levels used:    1
;; Hardware stack levels required when called:    2
;; This function calls:
;;		Nothing
;; This function is called by:
;;		_main
;; This function uses a non-reentrant model
;;
psect	text388
	file	"C:\Users\micho\OneDrive - Université Saint-Esprit de Kaslik\Desktop\FALL 25-26\GEL558 Microcontrollers\Project 2 - Keypad\MPLAB\keypad-c.c"
	line	422
	global	__size_of_init_ports
	__size_of_init_ports	equ	__end_of_init_ports-_init_ports
	
_init_ports:	
	opt	stack 5
; Regs used in _init_ports: [wreg+status,2]
	line	424
	
l2338:	
;keypad-c.c: 424: ADCON1 = 0x06;
	movlw	(06h)
	bsf	status, 5	;RP0=1, select bank1
	movwf	(159)^080h	;volatile
	line	427
	
l2340:	
;keypad-c.c: 427: TRISA = 0x00;
	clrf	(133)^080h	;volatile
	line	428
	
l2342:	
;keypad-c.c: 428: PORTA = 0x1F;
	movlw	(01Fh)
	bcf	status, 5	;RP0=0, select bank0
	movwf	(5)	;volatile
	line	431
	
l2344:	
;keypad-c.c: 431: TRISB = 0xF0;
	movlw	(0F0h)
	bsf	status, 5	;RP0=1, select bank1
	movwf	(134)^080h	;volatile
	line	434
	
l2346:	
;keypad-c.c: 434: OPTION_REGbits.nRBPU = 0;
	bcf	(129)^080h,7	;volatile
	line	437
	
l2348:	
;keypad-c.c: 437: TRISC = 0x80;
	movlw	(080h)
	movwf	(135)^080h	;volatile
	line	438
	
l2350:	
;keypad-c.c: 438: PORTC = 0x3F;
	movlw	(03Fh)
	bcf	status, 5	;RP0=0, select bank0
	movwf	(7)	;volatile
	line	441
	
l2352:	
;keypad-c.c: 441: TRISD = 0x00;
	bsf	status, 5	;RP0=1, select bank1
	clrf	(136)^080h	;volatile
	line	442
	
l2354:	
;keypad-c.c: 442: PORTD = 0x00;
	bcf	status, 5	;RP0=0, select bank0
	clrf	(8)	;volatile
	line	443
	
l744:	
	return
	opt stack 0
GLOBAL	__end_of_init_ports
	__end_of_init_ports:
;; =============== function _init_ports ends ============

	signat	_init_ports,88
	global	_write_eeprom
psect	text389,local,class=CODE,delta=2
global __ptext389
__ptext389:

;; *************** function _write_eeprom *****************
;; Defined at:
;;		line 685 in file "C:\Users\micho\OneDrive - Université Saint-Esprit de Kaslik\Desktop\FALL 25-26\GEL558 Microcontrollers\Project 2 - Keypad\MPLAB\keypad-c.c"
;; Parameters:    Size  Location     Type
;;  address         1    wreg     unsigned char 
;;  data            1    0[BANK0 ] unsigned char 
;; Auto vars:     Size  Location     Type
;;  address         1    1[BANK0 ] unsigned char 
;; Return value:  Size  Location     Type
;;		None               void
;; Registers used:
;;		wreg
;; Tracked objects:
;;		On entry : 60/0
;;		On exit  : 60/60
;;		Unchanged: FFF9F/0
;; Data sizes:     COMMON   BANK0   BANK1   BANK3   BANK2
;;      Params:         0       1       0       0       0
;;      Locals:         0       1       0       0       0
;;      Temps:          0       0       0       0       0
;;      Totals:         0       2       0       0       0
;;Total ram usage:        2 bytes
;; Hardware stack levels used:    1
;; Hardware stack levels required when called:    2
;; This function calls:
;;		Nothing
;; This function is called by:
;;		_scan_keypad
;; This function uses a non-reentrant model
;;
psect	text389
	file	"C:\Users\micho\OneDrive - Université Saint-Esprit de Kaslik\Desktop\FALL 25-26\GEL558 Microcontrollers\Project 2 - Keypad\MPLAB\keypad-c.c"
	line	685
	global	__size_of_write_eeprom
	__size_of_write_eeprom	equ	__end_of_write_eeprom-_write_eeprom
	
_write_eeprom:	
	opt	stack 4
; Regs used in _write_eeprom: [wreg]
;write_eeprom@address stored from wreg
	movwf	(write_eeprom@address)
	line	687
	
l2324:	
;keypad-c.c: 687: while (WR);
	
l798:	
	bsf	status, 5	;RP0=1, select bank3
	bsf	status, 6	;RP1=1, select bank3
	btfsc	(3169/8)^0180h,(3169)&7
	goto	u671
	goto	u670
u671:
	goto	l798
u670:
	line	690
	
l2326:	
;keypad-c.c: 690: EEADR = address;
	bcf	status, 5	;RP0=0, select bank0
	bcf	status, 6	;RP1=0, select bank0
	movf	(write_eeprom@address),w
	bsf	status, 6	;RP1=1, select bank2
	movwf	(269)^0100h	;volatile
	line	693
;keypad-c.c: 693: EEDATA = data;
	bcf	status, 6	;RP1=0, select bank0
	movf	(write_eeprom@data),w
	bsf	status, 6	;RP1=1, select bank2
	movwf	(268)^0100h	;volatile
	line	696
	
l2328:	
;keypad-c.c: 696: EECON1bits.EEPGD = 0;
	bsf	status, 5	;RP0=1, select bank3
	bcf	(396)^0180h,7	;volatile
	line	699
	
l2330:	
;keypad-c.c: 699: EECON1bits.WREN = 1;
	bsf	(396)^0180h,2	;volatile
	line	702
	
l2332:	
;keypad-c.c: 702: GIE = 0;
	bcf	(95/8),(95)&7
	line	705
;keypad-c.c: 705: EECON2 = 0x55;
	movlw	(055h)
	movwf	(397)^0180h	;volatile
	line	706
;keypad-c.c: 706: EECON2 = 0xAA;
	movlw	(0AAh)
	movwf	(397)^0180h	;volatile
	line	709
	
l2334:	
;keypad-c.c: 709: WR = 1;
	bsf	(3169/8)^0180h,(3169)&7
	line	712
	
l2336:	
;keypad-c.c: 712: GIE = 1;
	bsf	(95/8),(95)&7
	line	715
;keypad-c.c: 715: while (WR);
	
l801:	
	btfsc	(3169/8)^0180h,(3169)&7
	goto	u681
	goto	u680
u681:
	goto	l801
u680:
	
l803:	
	line	718
;keypad-c.c: 718: EECON1bits.WREN = 0;
	bcf	(396)^0180h,2	;volatile
	line	719
	
l804:	
	return
	opt stack 0
GLOBAL	__end_of_write_eeprom
	__end_of_write_eeprom:
;; =============== function _write_eeprom ends ============

	signat	_write_eeprom,8312
	global	_uart_transmit
psect	text390,local,class=CODE,delta=2
global __ptext390
__ptext390:

;; *************** function _uart_transmit *****************
;; Defined at:
;;		line 515 in file "C:\Users\micho\OneDrive - Université Saint-Esprit de Kaslik\Desktop\FALL 25-26\GEL558 Microcontrollers\Project 2 - Keypad\MPLAB\keypad-c.c"
;; Parameters:    Size  Location     Type
;;  data            1    wreg     unsigned char 
;; Auto vars:     Size  Location     Type
;;  data            1    0[BANK0 ] unsigned char 
;; Return value:  Size  Location     Type
;;		None               void
;; Registers used:
;;		wreg
;; Tracked objects:
;;		On entry : 60/0
;;		On exit  : 60/0
;;		Unchanged: FFF9F/0
;; Data sizes:     COMMON   BANK0   BANK1   BANK3   BANK2
;;      Params:         0       0       0       0       0
;;      Locals:         0       1       0       0       0
;;      Temps:          0       0       0       0       0
;;      Totals:         0       1       0       0       0
;;Total ram usage:        1 bytes
;; Hardware stack levels used:    1
;; Hardware stack levels required when called:    2
;; This function calls:
;;		Nothing
;; This function is called by:
;;		_scan_keypad
;; This function uses a non-reentrant model
;;
psect	text390
	file	"C:\Users\micho\OneDrive - Université Saint-Esprit de Kaslik\Desktop\FALL 25-26\GEL558 Microcontrollers\Project 2 - Keypad\MPLAB\keypad-c.c"
	line	515
	global	__size_of_uart_transmit
	__size_of_uart_transmit	equ	__end_of_uart_transmit-_uart_transmit
	
_uart_transmit:	
	opt	stack 4
; Regs used in _uart_transmit: [wreg]
;uart_transmit@data stored from wreg
	movwf	(uart_transmit@data)
	line	517
	
l2320:	
;keypad-c.c: 517: while (!TXIF);
	
l765:	
	btfss	(100/8),(100)&7
	goto	u661
	goto	u660
u661:
	goto	l765
u660:
	line	520
	
l2322:	
;keypad-c.c: 520: TXREG = data;
	movf	(uart_transmit@data),w
	movwf	(25)	;volatile
	line	521
	
l768:	
	return
	opt stack 0
GLOBAL	__end_of_uart_transmit
	__end_of_uart_transmit:
;; =============== function _uart_transmit ends ============

	signat	_uart_transmit,4216
	global	_isr
psect	text391,local,class=CODE,delta=2
global __ptext391
__ptext391:

;; *************** function _isr *****************
;; Defined at:
;;		line 280 in file "C:\Users\micho\OneDrive - Université Saint-Esprit de Kaslik\Desktop\FALL 25-26\GEL558 Microcontrollers\Project 2 - Keypad\MPLAB\keypad-c.c"
;; Parameters:    Size  Location     Type
;;		None
;; Auto vars:     Size  Location     Type
;;  col             1   13[COMMON] unsigned char 
;;  row             1   12[COMMON] unsigned char 
;;  detected_cha    1   11[COMMON] unsigned char 
;;  row_bits        1   10[COMMON] unsigned char 
;;  shift_detect    1    9[COMMON] unsigned char 
;;  dummy           1    0        unsigned char 
;; Return value:  Size  Location     Type
;;		None               void
;; Registers used:
;;		wreg, fsr0l, fsr0h, status,2, status,0, btemp+1, pclath, cstack
;; Tracked objects:
;;		On entry : 0/0
;;		On exit  : 60/0
;;		Unchanged: 0/0
;; Data sizes:     COMMON   BANK0   BANK1   BANK3   BANK2
;;      Params:         0       0       0       0       0
;;      Locals:         5       0       0       0       0
;;      Temps:          7       0       0       0       0
;;      Totals:        12       0       0       0       0
;;Total ram usage:       12 bytes
;; Hardware stack levels used:    1
;; Hardware stack levels required when called:    1
;; This function calls:
;;		i1_delay_20ms
;;		i1_uart_transmit
;;		i1_write_eeprom
;; This function is called by:
;;		Interrupt level 1
;; This function uses a non-reentrant model
;;
psect	text391
	file	"C:\Users\micho\OneDrive - Université Saint-Esprit de Kaslik\Desktop\FALL 25-26\GEL558 Microcontrollers\Project 2 - Keypad\MPLAB\keypad-c.c"
	line	280
	global	__size_of_isr
	__size_of_isr	equ	__end_of_isr-_isr
	
_isr:	
	opt	stack 4
; Regs used in _isr: [wreg-fsr0h+status,2+status,0+btemp+1+pclath+cstack]
psect	intentry,class=CODE,delta=2
global __pintentry
__pintentry:
global interrupt_function
interrupt_function:
	global saved_w
	saved_w	set	btemp+0
	movwf	saved_w
	swapf	status,w
	movwf	(??_isr+3)
	movf	fsr0,w
	movwf	(??_isr+4)
	movf	pclath,w
	movwf	(??_isr+5)
	bcf	status, 5	;RP0=0, select bank0
	bcf	status, 6	;RP1=0, select bank0
	movf	btemp+1,w
	movwf	(??_isr+6)
	ljmp	_isr
psect	text391
	line	283
	
i1l2232:	
;keypad-c.c: 281: unsigned char dummy;
;keypad-c.c: 282: unsigned char col, row_bits, row;
;keypad-c.c: 283: unsigned char detected_char = 0;
	clrf	(isr@detected_char)
	line	284
;keypad-c.c: 284: unsigned char shift_detected = 0;
	clrf	(isr@shift_detected)
	line	287
	
i1l2234:	
;keypad-c.c: 287: if (RBIF && RBIE)
	btfss	(88/8),(88)&7
	goto	u50_21
	goto	u50_20
u50_21:
	goto	i1l732
u50_20:
	
i1l2236:	
	btfss	(91/8),(91)&7
	goto	u51_21
	goto	u51_20
u51_21:
	goto	i1l732
u51_20:
	line	290
	
i1l2238:	
;keypad-c.c: 288: {
;keypad-c.c: 290: dummy = PORTB;
	movf	(6),w	;volatile
	line	293
	
i1l2240:	
;keypad-c.c: 293: delay_20ms();
	fcall	i1_delay_20ms
	line	296
	
i1l2242:	
;keypad-c.c: 296: row_bits = (PORTB & 0xF0) >> 4;
	bcf	status, 5	;RP0=0, select bank0
	bcf	status, 6	;RP1=0, select bank0
	swapf	(6),w
	andlw	(0ffh shr 4) & 0ffh
	movwf	(isr@row_bits)
	
i1l2244:	
	movlw	(0Fh)
	andwf	(isr@row_bits),f
	line	299
	
i1l2246:	
;keypad-c.c: 299: if (row_bits != 0x0F)
	movf	(isr@row_bits),w
	xorlw	0Fh
	skipnz
	goto	u52_21
	goto	u52_20
u52_21:
	goto	i1l2314
u52_20:
	line	302
	
i1l2248:	
;keypad-c.c: 300: {
;keypad-c.c: 302: for (col = 0; col < 8; col++)
	clrf	(isr@col)
	
i1l2250:	
	movlw	(08h)
	subwf	(isr@col),w
	skipc
	goto	u53_21
	goto	u53_20
u53_21:
	goto	i1l2254
u53_20:
	goto	i1l2292
	line	305
	
i1l2254:	
;keypad-c.c: 303: {
;keypad-c.c: 305: PORTD = 0xFF;
	movlw	(0FFh)
	movwf	(8)	;volatile
	line	308
	
i1l2256:	
;keypad-c.c: 308: PORTD = ~(1 << col);
	movlw	(01h)
	movwf	(??_isr+0)+0
	incf	(isr@col),w
	goto	u54_24
u54_25:
	clrc
	rlf	(??_isr+0)+0,f
u54_24:
	addlw	-1
	skipz
	goto	u54_25
	movf	0+(??_isr+0)+0,w
	xorlw	0ffh
	movwf	(8)	;volatile
	line	311
	
i1l2258:	
;keypad-c.c: 311: _nop();
	nop
	line	312
	
i1l2260:	
;keypad-c.c: 312: _nop();
	nop
	line	313
	
i1l2262:	
;keypad-c.c: 313: _nop();
	nop
	line	314
	
i1l2264:	
;keypad-c.c: 314: _nop();
	nop
	line	317
	
i1l2266:	
;keypad-c.c: 317: row_bits = PORTB & 0xF0;
	bcf	status, 5	;RP0=0, select bank0
	bcf	status, 6	;RP1=0, select bank0
	movf	(6),w
	movwf	(isr@row_bits)
	movlw	(0F0h)
	andwf	(isr@row_bits),f
	line	320
	
i1l2268:	
;keypad-c.c: 320: for (row = 0; row < 4; row++)
	clrf	(isr@row)
	line	322
	
i1l2274:	
;keypad-c.c: 321: {
;keypad-c.c: 322: if (!(row_bits & (0x10 << row)))
	movlw	(010h)
	movwf	(??_isr+0)+0
	incf	(isr@row),w
	goto	u55_24
u55_25:
	clrc
	rlf	(??_isr+0)+0,f
u55_24:
	addlw	-1
	skipz
	goto	u55_25
	movf	0+(??_isr+0)+0,w
	andwf	(isr@row_bits),w
	btfss	status,2
	goto	u56_21
	goto	u56_20
u56_21:
	goto	i1l2284
u56_20:
	line	327
	
i1l2276:	
;keypad-c.c: 323: {
;keypad-c.c: 327: if (row == 3 && (col == 0 || col == 7))
	movf	(isr@row),w
	xorlw	03h
	skipz
	goto	u57_21
	goto	u57_20
u57_21:
	goto	i1l2282
u57_20:
	
i1l2278:	
	movf	(isr@col),w
	skipz
	goto	u58_20
	goto	i1l728
u58_20:
	
i1l2280:	
	movf	(isr@col),w
	xorlw	07h
	skipz
	goto	u59_21
	goto	u59_20
u59_21:
	goto	i1l2282
u59_20:
	
i1l728:	
	line	329
;keypad-c.c: 328: {
;keypad-c.c: 329: shift_detected = 1;
	clrf	(isr@shift_detected)
	incf	(isr@shift_detected),f
	line	330
;keypad-c.c: 330: shift_flag = 1;
	clrf	(_shift_flag)	;volatile
	incf	(_shift_flag),f	;volatile
	line	331
;keypad-c.c: 331: }
	goto	i1l2284
	line	335
	
i1l2282:	
;keypad-c.c: 332: else
;keypad-c.c: 333: {
;keypad-c.c: 335: detected_char = keypad_map[row][col];
	movf	(isr@row),w
	movwf	(??_isr+0)+0
	clrc
	rlf	(??_isr+0)+0,f
	clrc
	rlf	(??_isr+0)+0,f
	clrc
	rlf	(??_isr+0)+0,w
	addlw	low(_keypad_map|8000h)
	movwf	(??_isr+1)+0
	movlw	high(_keypad_map|8000h)
	skipnc
	addlw	1
	movwf	1+((??_isr+1)+0)
	movf	(isr@col),w
	addwf	0+(??_isr+1)+0,w
	movwf	fsr0
	movf	1+(??_isr+1)+0,w
	skipnc
	incf	1+(??_isr+1)+0,w
	movwf	btemp+1
	fcall	stringtab
	movwf	(isr@detected_char)
	line	320
	
i1l2284:	
	incf	(isr@row),f
	
i1l2286:	
	movlw	(04h)
	subwf	(isr@row),w
	skipc
	goto	u60_21
	goto	u60_20
u60_21:
	goto	i1l2274
u60_20:
	line	302
	
i1l2288:	
	incf	(isr@col),f
	goto	i1l2250
	line	342
	
i1l2292:	
;keypad-c.c: 336: }
;keypad-c.c: 337: }
;keypad-c.c: 338: }
;keypad-c.c: 339: }
;keypad-c.c: 342: if (detected_char != 0 && !shift_detected)
	movf	(isr@detected_char),w
	skipz
	goto	u61_20
	goto	i1l2314
u61_20:
	
i1l2294:	
	movf	(isr@shift_detected),f
	skipz
	goto	u62_21
	goto	u62_20
u62_21:
	goto	i1l2314
u62_20:
	line	345
	
i1l2296:	
;keypad-c.c: 343: {
;keypad-c.c: 345: if (shift_flag && detected_char >= 'a' && detected_char <= 'z')
	movf	(_shift_flag),w	;volatile
	skipz
	goto	u63_20
	goto	i1l2304
u63_20:
	
i1l2298:	
	movlw	(061h)
	subwf	(isr@detected_char),w
	skipc
	goto	u64_21
	goto	u64_20
u64_21:
	goto	i1l2304
u64_20:
	
i1l2300:	
	movlw	(07Bh)
	subwf	(isr@detected_char),w
	skipnc
	goto	u65_21
	goto	u65_20
u65_21:
	goto	i1l2304
u65_20:
	line	347
	
i1l2302:	
;keypad-c.c: 346: {
;keypad-c.c: 347: detected_char = detected_char - 32;
	movlw	(0E0h)
	addwf	(isr@detected_char),f
	line	351
	
i1l2304:	
;keypad-c.c: 348: }
;keypad-c.c: 351: current_char = detected_char;
	movf	(isr@detected_char),w
	movwf	(_current_char)	;volatile
	line	352
	
i1l2306:	
;keypad-c.c: 352: key_pressed = 1;
	clrf	(_key_pressed)	;volatile
	incf	(_key_pressed),f	;volatile
	line	355
	
i1l2308:	
;keypad-c.c: 355: uart_transmit(current_char);
	movf	(_current_char),w	;volatile
	fcall	i1_uart_transmit
	line	358
	
i1l2310:	
;keypad-c.c: 358: write_eeprom(0x00, current_char);
	movf	(_current_char),w	;volatile
	movwf	(?i1_write_eeprom)
	movlw	(0)
	fcall	i1_write_eeprom
	line	361
	
i1l2312:	
;keypad-c.c: 361: shift_flag = 0;
	bcf	status, 5	;RP0=0, select bank0
	bcf	status, 6	;RP1=0, select bank0
	clrf	(_shift_flag)	;volatile
	line	366
	
i1l2314:	
;keypad-c.c: 362: }
;keypad-c.c: 363: }
;keypad-c.c: 366: PORTD = 0x00;
	clrf	(8)	;volatile
	line	369
	
i1l2316:	
;keypad-c.c: 369: dummy = PORTB;
	movf	(6),w	;volatile
	line	372
	
i1l2318:	
;keypad-c.c: 372: RBIF = 0;
	bcf	(88/8),(88)&7
	line	374
	
i1l732:	
	movf	(??_isr+6),w
	movwf	btemp+1
	movf	(??_isr+5),w
	movwf	pclath
	movf	(??_isr+4),w
	movwf	fsr0
	swapf	(??_isr+3)^0FFFFFF80h,w
	movwf	status
	swapf	saved_w,f
	swapf	saved_w,w
	retfie
	opt stack 0
GLOBAL	__end_of_isr
	__end_of_isr:
;; =============== function _isr ends ============

	signat	_isr,88
	global	i1_delay_20ms
psect	text392,local,class=CODE,delta=2
global __ptext392
__ptext392:

;; *************** function i1_delay_20ms *****************
;; Defined at:
;;		line 506 in file "C:\Users\micho\OneDrive - Université Saint-Esprit de Kaslik\Desktop\FALL 25-26\GEL558 Microcontrollers\Project 2 - Keypad\MPLAB\keypad-c.c"
;; Parameters:    Size  Location     Type
;;		None
;; Auto vars:     Size  Location     Type
;;		None
;; Return value:  Size  Location     Type
;;		None               void
;; Registers used:
;;		wreg
;; Tracked objects:
;;		On entry : 60/0
;;		On exit  : 0/0
;;		Unchanged: 0/0
;; Data sizes:     COMMON   BANK0   BANK1   BANK3   BANK2
;;      Params:         0       0       0       0       0
;;      Locals:         0       0       0       0       0
;;      Temps:          2       0       0       0       0
;;      Totals:         2       0       0       0       0
;;Total ram usage:        2 bytes
;; Hardware stack levels used:    1
;; This function calls:
;;		Nothing
;; This function is called by:
;;		_isr
;; This function uses a non-reentrant model
;;
psect	text392
	file	"C:\Users\micho\OneDrive - Université Saint-Esprit de Kaslik\Desktop\FALL 25-26\GEL558 Microcontrollers\Project 2 - Keypad\MPLAB\keypad-c.c"
	line	506
	global	__size_ofi1_delay_20ms
	__size_ofi1_delay_20ms	equ	__end_ofi1_delay_20ms-i1_delay_20ms
	
i1_delay_20ms:	
	opt	stack 4
; Regs used in i1_delay_20ms: [wreg]
	line	507
	
i1l2412:	
;keypad-c.c: 507: _delay((unsigned long)((20)*(4000000/4000.0)));
	opt asmopt_off
movlw	26
movwf	((??i1_delay_20ms+0)+0+1),f
	movlw	248
movwf	((??i1_delay_20ms+0)+0),f
u99_27:
	decfsz	((??i1_delay_20ms+0)+0),f
	goto	u99_27
	decfsz	((??i1_delay_20ms+0)+0+1),f
	goto	u99_27
	clrwdt
opt asmopt_on

	line	508
	
i1l762:	
	return
	opt stack 0
GLOBAL	__end_ofi1_delay_20ms
	__end_ofi1_delay_20ms:
;; =============== function i1_delay_20ms ends ============

	signat	i1_delay_20ms,88
	global	i1_write_eeprom
psect	text393,local,class=CODE,delta=2
global __ptext393
__ptext393:

;; *************** function i1_write_eeprom *****************
;; Defined at:
;;		line 685 in file "C:\Users\micho\OneDrive - Université Saint-Esprit de Kaslik\Desktop\FALL 25-26\GEL558 Microcontrollers\Project 2 - Keypad\MPLAB\keypad-c.c"
;; Parameters:    Size  Location     Type
;;  write_eeprom    1    wreg     unsigned char 
;;  write_eeprom    1    0[COMMON] unsigned char 
;; Auto vars:     Size  Location     Type
;;  write_eeprom    1    1[COMMON] unsigned char 
;; Return value:  Size  Location     Type
;;		None               void
;; Registers used:
;;		wreg
;; Tracked objects:
;;		On entry : 60/0
;;		On exit  : 60/60
;;		Unchanged: FFF9F/0
;; Data sizes:     COMMON   BANK0   BANK1   BANK3   BANK2
;;      Params:         1       0       0       0       0
;;      Locals:         1       0       0       0       0
;;      Temps:          0       0       0       0       0
;;      Totals:         2       0       0       0       0
;;Total ram usage:        2 bytes
;; Hardware stack levels used:    1
;; This function calls:
;;		Nothing
;; This function is called by:
;;		_isr
;; This function uses a non-reentrant model
;;
psect	text393
	file	"C:\Users\micho\OneDrive - Université Saint-Esprit de Kaslik\Desktop\FALL 25-26\GEL558 Microcontrollers\Project 2 - Keypad\MPLAB\keypad-c.c"
	line	685
	global	__size_ofi1_write_eeprom
	__size_ofi1_write_eeprom	equ	__end_ofi1_write_eeprom-i1_write_eeprom
	
i1_write_eeprom:	
	opt	stack 4
; Regs used in i1_write_eeprom: [wreg]
;i1write_eeprom@address stored from wreg
	movwf	(i1write_eeprom@address)
	line	687
	
i1l2418:	
;keypad-c.c: 687: while (WR);
	
i1l798:	
	bsf	status, 5	;RP0=1, select bank3
	bsf	status, 6	;RP1=1, select bank3
	btfsc	(3169/8)^0180h,(3169)&7
	goto	u73_21
	goto	u73_20
u73_21:
	goto	i1l798
u73_20:
	line	690
	
i1l2420:	
;keypad-c.c: 690: EEADR = address;
	movf	(i1write_eeprom@address),w
	bcf	status, 5	;RP0=0, select bank2
	movwf	(269)^0100h	;volatile
	line	693
;keypad-c.c: 693: EEDATA = data;
	movf	(i1write_eeprom@data),w
	movwf	(268)^0100h	;volatile
	line	696
	
i1l2422:	
;keypad-c.c: 696: EECON1bits.EEPGD = 0;
	bsf	status, 5	;RP0=1, select bank3
	bcf	(396)^0180h,7	;volatile
	line	699
	
i1l2424:	
;keypad-c.c: 699: EECON1bits.WREN = 1;
	bsf	(396)^0180h,2	;volatile
	line	702
	
i1l2426:	
;keypad-c.c: 702: GIE = 0;
	bcf	(95/8),(95)&7
	line	705
;keypad-c.c: 705: EECON2 = 0x55;
	movlw	(055h)
	movwf	(397)^0180h	;volatile
	line	706
;keypad-c.c: 706: EECON2 = 0xAA;
	movlw	(0AAh)
	movwf	(397)^0180h	;volatile
	line	709
	
i1l2428:	
;keypad-c.c: 709: WR = 1;
	bsf	(3169/8)^0180h,(3169)&7
	line	712
	
i1l2430:	
;keypad-c.c: 712: GIE = 1;
	bsf	(95/8),(95)&7
	line	715
;keypad-c.c: 715: while (WR);
	
i1l801:	
	btfsc	(3169/8)^0180h,(3169)&7
	goto	u74_21
	goto	u74_20
u74_21:
	goto	i1l801
u74_20:
	
i1l803:	
	line	718
;keypad-c.c: 718: EECON1bits.WREN = 0;
	bcf	(396)^0180h,2	;volatile
	line	719
	
i1l804:	
	return
	opt stack 0
GLOBAL	__end_ofi1_write_eeprom
	__end_ofi1_write_eeprom:
;; =============== function i1_write_eeprom ends ============

	signat	i1_write_eeprom,88
	global	i1_uart_transmit
psect	text394,local,class=CODE,delta=2
global __ptext394
__ptext394:

;; *************** function i1_uart_transmit *****************
;; Defined at:
;;		line 515 in file "C:\Users\micho\OneDrive - Université Saint-Esprit de Kaslik\Desktop\FALL 25-26\GEL558 Microcontrollers\Project 2 - Keypad\MPLAB\keypad-c.c"
;; Parameters:    Size  Location     Type
;;  uart_transmi    1    wreg     unsigned char 
;; Auto vars:     Size  Location     Type
;;  uart_transmi    1    0[COMMON] unsigned char 
;; Return value:  Size  Location     Type
;;		None               void
;; Registers used:
;;		wreg
;; Tracked objects:
;;		On entry : 60/0
;;		On exit  : 60/0
;;		Unchanged: FFF9F/0
;; Data sizes:     COMMON   BANK0   BANK1   BANK3   BANK2
;;      Params:         0       0       0       0       0
;;      Locals:         1       0       0       0       0
;;      Temps:          0       0       0       0       0
;;      Totals:         1       0       0       0       0
;;Total ram usage:        1 bytes
;; Hardware stack levels used:    1
;; This function calls:
;;		Nothing
;; This function is called by:
;;		_isr
;; This function uses a non-reentrant model
;;
psect	text394
	file	"C:\Users\micho\OneDrive - Université Saint-Esprit de Kaslik\Desktop\FALL 25-26\GEL558 Microcontrollers\Project 2 - Keypad\MPLAB\keypad-c.c"
	line	515
	global	__size_ofi1_uart_transmit
	__size_ofi1_uart_transmit	equ	__end_ofi1_uart_transmit-i1_uart_transmit
	
i1_uart_transmit:	
	opt	stack 4
; Regs used in i1_uart_transmit: [wreg]
;i1uart_transmit@data stored from wreg
	movwf	(i1uart_transmit@data)
	line	517
	
i1l2414:	
;keypad-c.c: 517: while (!TXIF);
	
i1l765:	
	btfss	(100/8),(100)&7
	goto	u72_21
	goto	u72_20
u72_21:
	goto	i1l765
u72_20:
	line	520
	
i1l2416:	
;keypad-c.c: 520: TXREG = data;
	movf	(i1uart_transmit@data),w
	movwf	(25)	;volatile
	line	521
	
i1l768:	
	return
	opt stack 0
GLOBAL	__end_ofi1_uart_transmit
	__end_ofi1_uart_transmit:
;; =============== function i1_uart_transmit ends ============

	signat	i1_uart_transmit,88
psect	text395,local,class=CODE,delta=2
global __ptext395
__ptext395:
	global	btemp
	btemp set 07Eh

	DABS	1,126,2	;btemp
	global	wtemp0
	wtemp0 set btemp
	end
