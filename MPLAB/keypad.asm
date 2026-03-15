;===============================================================================
; PIC16F877A Matrix Keypad & 5x7 LED Display with UART Communication
; Project: ESP8266 MQTT Interface System
;===============================================================================
; Description:
;   - Reads input from 4x8 matrix keypad using interrupt-on-change
;   - Displays pressed character on 5x7 LED matrix (multiplexed)
;   - Transmits ASCII code via UART to ESP8266 at 9600 baud
;   - Supports SHIFT key for uppercase letters
;
; Hardware Configuration:
;   - Clock: 4 MHz
;   - Keypad Rows (Input): RB4-RB7 (with internal pull-ups)
;       Row 0 (Q row) = RB7, Row 3 (SHIFT row) = RB4 (inverted!)
;   - Keypad Columns (Output): RD0-RD7
;       Col 0 = RD7 (MSB), Col 7 = RD0 (LSB)
;   - Display Columns: RA0-RA4 (RA4 is open-drain - needs external pull-up)
;   - Display Rows: RC0-RC5, RA5
;   - UART TX: RC6 (9600 baud)
;===============================================================================

    LIST P=16F877A
    #INCLUDE <P16F877A.INC>

;-------------------------------------------------------------------------------
; Configuration Bits
;-------------------------------------------------------------------------------
    __CONFIG _FOSC_XT & _WDTE_OFF & _PWRTE_ON & _BOREN_ON & _LVP_OFF & _CPD_OFF & _WRT_OFF & _CP_OFF

;-------------------------------------------------------------------------------
; Variable Definitions (Bank 0: 0x20-0x7F)
;-------------------------------------------------------------------------------
    CBLOCK  0x20
        W_TEMP          
        STATUS_TEMP     
        PCLATH_TEMP     
        
        CURRENT_CHAR    
        COL_INDEX       
        ROW_DATA        
        
        KEY_ROW         
        KEY_COL         
        KEY_INDEX       
        
        SHIFT_FLAG      
        NEW_KEY_FLAG    
        
        DELAY_COUNT1    
        DELAY_COUNT2    
        DELAY_COUNT3    
        
        SCAN_COL        
        TEMP_VAR        
        FONT_OFFSET_L   
        FONT_OFFSET_H   

        ISR_DELAY_COUNT1
        ISR_DELAY_COUNT2
        
        LAST_KEY_INDEX  ; ADD THIS - tracks last processed key to prevent repeats
    ENDC

;-------------------------------------------------------------------------------
; Constants
;-------------------------------------------------------------------------------
DEFAULT_CHAR    EQU     'a'         ; Default character to display
SHIFT_INDEX_L   EQU     D'24'       ; Left shift key index (row3, col0)
SHIFT_INDEX_R   EQU     D'31'       ; Right shift key index (row3, col7)

;-------------------------------------------------------------------------------
; Reset Vector
;-------------------------------------------------------------------------------
    ORG     0x0000
    GOTO    MAIN

;-------------------------------------------------------------------------------
; Interrupt Vector
;-------------------------------------------------------------------------------
    ORG     0x0004
    GOTO    ISR

;===============================================================================
; MAIN PROGRAM
;===============================================================================
    ORG     0x0010

MAIN:
    CALL    INIT_PORTS          ; Initialize I/O ports
    CALL    INIT_UART           ; Initialize UART at 9600 baud
    CALL    INIT_INTERRUPTS     ; Initialize interrupts
    CALL    INIT_VARIABLES      ; Initialize variables
    
;-------------------------------------------------------------------------------
; Main Loop - Display Multiplexing with Shift Key Polling
;-------------------------------------------------------------------------------
MAIN_LOOP:
    ; Always refresh display first (critical for no flicker)
    CALL    DISPLAY_CHAR
    
    ; Check if in shift mode
    BTFSS   SHIFT_FLAG, 0
    GOTO    IDLE_MODE
    
;-------------------------------------------------------------------------------
; SHIFT Mode - Poll for shift release and character keys
; FIX: Use dedicated character key scan that ignores row 3 (shift row)
;-------------------------------------------------------------------------------
SHIFT_MODE:
    ; Disable Port B interrupts during polling
    BCF     INTCON, RBIE
    
    ; First check: Is shift key still held?
    CALL    CHECK_SHIFT_HELD
    BTFSS   SHIFT_FLAG, 0
    GOTO    SHIFT_RELEASED      ; Shift was released
    
    ; Scan for CHARACTER keys only (ignores shift row)
    CALL    SCAN_CHAR_KEY
    
    ; Check if a character key was found
    BTFSS   NEW_KEY_FLAG, 0
    GOTO    CHAR_KEY_RELEASED   ; No char key pressed, check for repeat reset
    
    ; Check if this is the SAME key as last time (prevent repeats)
    MOVF    KEY_INDEX, W
    XORWF   LAST_KEY_INDEX, W
    BTFSC   STATUS, Z
    GOTO    MAIN_LOOP           ; Same key still held, don't repeat
    
    ; NEW character key detected - process it
    MOVF    KEY_INDEX, W
    MOVWF   LAST_KEY_INDEX      ; Remember this key
    
    CALL    PROCESS_SHIFTED_KEY
    BCF     NEW_KEY_FLAG, 0
    GOTO    MAIN_LOOP

CHAR_KEY_RELEASED:
    ; No character key pressed - reset last key tracker
    MOVLW   0xFF
    MOVWF   LAST_KEY_INDEX
    GOTO    MAIN_LOOP
    
SHIFT_RELEASED:
    ; Shift key released - re-enable interrupts
    BCF     NEW_KEY_FLAG, 0
    MOVLW   0xFF
    MOVWF   LAST_KEY_INDEX      ; Reset key tracker
    BSF     INTCON, RBIE
    GOTO    MAIN_LOOP

;-------------------------------------------------------------------------------
; IDLE Mode - Wait for interrupt
;-------------------------------------------------------------------------------
IDLE_MODE:
    ; Enable Port B interrupts
    BSF     INTCON, RBIE
    GOTO    MAIN_LOOP

;-------------------------------------------------------------------------------
; Check if shift key is currently held (checks both shift positions)
; Sets SHIFT_FLAG if either shift is pressed
; Col 0 = RD7, Col 7 = RD0, Row 3 = RB4 (not RB7!)
;-------------------------------------------------------------------------------
CHECK_SHIFT_HELD:
    BCF     SHIFT_FLAG, 0       ; Assume not held
    
    ; Check left shift (col 0 = RD0, row 3 = RB7)
    MOVLW   0xFF
    MOVWF   PORTD
    BCF     PORTD, 0            ; Activate column 0 (RD0 low)
    NOP
    NOP
    BTFSS   PORTB, 7            ; Check RB7 (row 3)
    BSF     SHIFT_FLAG, 0       ; Left shift is held
    
    ; Check right shift (col 7 = RD7, row 3 = RB7)
    MOVLW   0xFF
    MOVWF   PORTD
    BCF     PORTD, 7            ; Activate column 7 (RD7 low)
    NOP
    NOP
    BTFSS   PORTB, 7            ; Check RB7 (row 3)
    BSF     SHIFT_FLAG, 0       ; Right shift is held
    
    ; Reset columns
    CLRF    PORTD
    RETURN

;===============================================================================
; INITIALIZATION SUBROUTINES
;===============================================================================

;-------------------------------------------------------------------------------
; Initialize I/O Ports
;-------------------------------------------------------------------------------
INIT_PORTS:
    ; Bank 1 for TRIS registers
    BSF     STATUS, RP0
    BCF     STATUS, RP1
    
    ; Configure PORTA (display columns + row 7)
    ; RA0-RA4 outputs (columns), RA5 output (row 7)
    MOVLW   B'00000000'
    MOVWF   TRISA
    
    ; Configure PORTB
    ; RB4-RB7 inputs (keypad rows), RB0-RB3 unused
    MOVLW   B'11110000'
    MOVWF   TRISB
    
    ; Configure PORTC
    ; RC0-RC5 outputs (display rows), RC6 output (TX), RC7 input (RX)
    MOVLW   B'10000000'
    MOVWF   TRISC
    
    ; Configure PORTD - all outputs (keypad columns)
    MOVLW   B'00000000'
    MOVWF   TRISD
    
    ; Enable weak pull-ups on PORTB
    BCF     OPTION_REG, NOT_RBPU
    
    ; Configure ADCON1 - all digital I/O
    MOVLW   0x06
    MOVWF   ADCON1
    
    ; Bank 0
    BCF     STATUS, RP0
    
    ; Initialize port outputs
    CLRF    PORTA               ; All columns off
    MOVLW   B'01111111'         ; All rows high (LEDs off - active low)
    MOVWF   PORTC
    BSF     PORTA, 5            ; RA5 high (row 7 off)
    CLRF    PORTD               ; All keypad columns LOW (for interrupt detection)
    
    RETURN

;-------------------------------------------------------------------------------
; Initialize UART at 9600 baud (4 MHz clock)
;-------------------------------------------------------------------------------
INIT_UART:
    ; Bank 1
    BSF     STATUS, RP0
    
    ; SPBRG = 25 for 9600 baud @ 4 MHz with BRGH=1
    MOVLW   D'25'
    MOVWF   SPBRG
    
    ; TXSTA: Enable transmission, high speed baud rate
    ; TXEN=1, SYNC=0, BRGH=1
    MOVLW   B'00100100'
    MOVWF   TXSTA
    
    ; Bank 0
    BCF     STATUS, RP0
    
    ; RCSTA: Enable serial port
    ; SPEN=1
    MOVLW   B'10000000'
    MOVWF   RCSTA
    
    RETURN

;-------------------------------------------------------------------------------
; Initialize Interrupts
;-------------------------------------------------------------------------------
INIT_INTERRUPTS:
    ; Clear PORTB interrupt flag
    BCF     INTCON, RBIF
    
    ; Enable PORTB change interrupt
    BSF     INTCON, RBIE
    
    ; Enable global interrupts
    BSF     INTCON, GIE
    
    RETURN

;-------------------------------------------------------------------------------
; Initialize Variables
;-------------------------------------------------------------------------------
INIT_VARIABLES:
    ; Set default character
    MOVLW   DEFAULT_CHAR
    MOVWF   CURRENT_CHAR
    
    ; Clear flags - FIX: was incorrectly BSF instead of CLRF
    CLRF    SHIFT_FLAG
    CLRF    NEW_KEY_FLAG
    CLRF    COL_INDEX
    CLRF    KEY_ROW
    CLRF    KEY_COL
    CLRF    KEY_INDEX

    MOVLW   0xFF                ; Initialize to invalid key
    MOVWF   LAST_KEY_INDEX      ; ADD THIS
    
    RETURN

;===============================================================================
; INTERRUPT SERVICE ROUTINE
;===============================================================================
ISR:
    ; --- Context Saving ---
    MOVWF   W_TEMP
    SWAPF   STATUS, W
    MOVWF   STATUS_TEMP
    MOVF    PCLATH, W
    MOVWF   PCLATH_TEMP
    
    ; --- CRITICAL FIX: Reset PCLATH for ISR Code ---
    CLRF    PCLATH          ; Assuming ISR code is in Page 0
    
    ; --- Interrupt Logic ---
    BTFSS   INTCON, RBIF
    GOTO    ISR_EXIT
    
    ; Debounce delay (20ms)
    CALL    DELAY_20MS
    
    ; Read PORTB to clear mismatch condition
    MOVF    PORTB, W
    
    ; Check if any row is LOW (key pressed)
    ANDLW   B'11110000'         ; Mask rows RB4-RB7
    XORLW   B'11110000'         ; Compare with all HIGH
    BTFSC   STATUS, Z
    GOTO    ISR_CLEAR_EXIT      ; No key pressed, exit
    
    ; Scan keypad to find pressed key
    CALL    SCAN_KEYPAD
    
    ; Check if new key was found
    BTFSS   NEW_KEY_FLAG, 0
    GOTO    ISR_CLEAR_EXIT
    
    ; Check if SHIFT key pressed
    MOVF    KEY_INDEX, W
    XORLW   SHIFT_INDEX_L
    BTFSC   STATUS, Z
    GOTO    ISR_SHIFT_PRESSED
    
    MOVF    KEY_INDEX, W
    XORLW   SHIFT_INDEX_R
    BTFSC   STATUS, Z
    GOTO    ISR_SHIFT_PRESSED
    
	MOVF	KEY_INDEX, W

    ; Regular key - lookup ASCII and process
    CALL    LOOKUP_ASCII
    MOVWF   CURRENT_CHAR
    
    ; Transmit via UART
    CALL    UART_TRANSMIT
    
    GOTO    ISR_CLEAR_EXIT
    
ISR_SHIFT_PRESSED:
    ; Set shift flag and disable interrupt
    BSF     SHIFT_FLAG, 0
    BCF     INTCON, RBIE        ; Disable PORTB interrupt for polling mode
    
ISR_CLEAR_EXIT:
    ; Clear new key flag
    BCF     NEW_KEY_FLAG, 0
    
    ; Reset keypad columns to LOW
    CLRF    PORTD
    
    ; Clear interrupt flag
    BCF     INTCON, RBIF
    
ISR_EXIT:
    ; Restore context
    MOVF    PCLATH_TEMP, W
    MOVWF   PCLATH
    SWAPF   STATUS_TEMP, W
    MOVWF   STATUS
    SWAPF   W_TEMP, F
    SWAPF   W_TEMP, W
    
    RETFIE

;===============================================================================
; KEYPAD SCANNING SUBROUTINE
;===============================================================================
SCAN_KEYPAD:
    ; Clear flags
    BCF     NEW_KEY_FLAG, 0
    CLRF    KEY_ROW
    CLRF    KEY_COL
    CLRF    KEY_INDEX
    
    ; Set all columns HIGH first
    MOVLW   0xFF
    MOVWF   PORTD
    
    ; Walking zero scan
    CLRF    SCAN_COL            ; Start with column 0

SCAN_NEXT_COL:
    ; Set only current column LOW
    MOVLW   0xFF
    MOVWF   PORTD               ; All columns HIGH
    
    ; Calculate bit mask for current column (active LOW)
    ; Col 0 = RD7 (MSB), Col 7 = RD0 (LSB)
    MOVF    SCAN_COL, W
    CALL    GET_COL_MASK        ; Get inverted mask
    MOVWF   PORTD               ; Apply to columns
    
    ; Small delay for signal settling
    NOP
    NOP
    NOP
    NOP
    
    ; Read rows - Row 0 = RB7, Row 3 = RB4 (inverted physical mapping)
    MOVF    PORTB, W
    ANDLW   B'11110000'         ; Mask rows
    
    ; Check Row 0 (RB7 - Q W E R T Y U I row)
    BTFSS   PORTB, 4
    GOTO    FOUND_ROW0
    
    ; Check Row 1 (RB6 - A S D F G H J K row)
    BTFSS   PORTB, 5
    GOTO    FOUND_ROW1
    
    ; Check Row 2 (RB5 - Z X C V B N M L row)
    BTFSS   PORTB, 6
    GOTO    FOUND_ROW2
    
    ; Check Row 3 (RB4 - SHIFT O P / * + - SHIFT row)
    BTFSS   PORTB, 7
    GOTO    FOUND_ROW3
    
    ; No key in this column, try next
    INCF    SCAN_COL, F
    MOVF    SCAN_COL, W
    XORLW   D'8'
    BTFSS   STATUS, Z
    GOTO    SCAN_NEXT_COL
    
    ; No key found
    GOTO    SCAN_DONE

FOUND_ROW0:
    CLRF    KEY_ROW             ; Row 0
    GOTO    CALC_INDEX
    
FOUND_ROW1:
    MOVLW   D'1'
    MOVWF   KEY_ROW             ; Row 1
    GOTO    CALC_INDEX
    
FOUND_ROW2:
    MOVLW   D'2'
    MOVWF   KEY_ROW             ; Row 2
    GOTO    CALC_INDEX
    
FOUND_ROW3:
    MOVLW   D'3'
    MOVWF   KEY_ROW             ; Row 3
    GOTO    CALC_INDEX

CALC_INDEX:
    MOVF    SCAN_COL, W
    MOVWF   KEY_COL
    
    ; ROW * 8 (shift left 3 times)
    MOVF    KEY_ROW, W
    MOVWF   KEY_INDEX
    BCF     STATUS, C
    RLF     KEY_INDEX, F        ; *2
    BCF     STATUS, C
    RLF     KEY_INDEX, F        ; *4
    BCF     STATUS, C
    RLF     KEY_INDEX, F        ; *8
    
    ; Add column
    MOVF    KEY_COL, W
    ADDWF   KEY_INDEX, F
    
    ; Set new key flag
    BSF     NEW_KEY_FLAG, 0

SCAN_DONE:
    ; Reset all columns LOW to ensure interrupts work for next press
    CLRF    PORTD
    RETURN

;===============================================================================
; SCAN FOR CHARACTER KEYS ONLY (ignores SHIFT keys at row3/col0 and row3/col7)
; This allows detecting character keys while shift is held
;===============================================================================
SCAN_CHAR_KEY:
    ; Clear flags
    BCF     NEW_KEY_FLAG, 0
    CLRF    KEY_ROW
    CLRF    KEY_COL
    CLRF    KEY_INDEX
    
    ; Set all columns HIGH first
    MOVLW   0xFF
    MOVWF   PORTD
    
    ; Walking zero scan
    CLRF    SCAN_COL

SCAN_CHAR_NEXT_COL:
    ; Set only current column LOW
    MOVLW   0xFF
    MOVWF   PORTD
    
    ; Get column mask
    MOVF    SCAN_COL, W
    CALL    GET_COL_MASK
    MOVWF   PORTD
    
    ; Small delay for signal settling
    NOP
    NOP
    NOP
    NOP
    
    ; Check all rows 0-3
    ; Row 0 = RB4, Row 1 = RB5, Row 2 = RB6, Row 3 = RB7
    
    BTFSS   PORTB, 4
    GOTO    FOUND_CHAR_ROW0
    
    BTFSS   PORTB, 5
    GOTO    FOUND_CHAR_ROW1
    
    BTFSS   PORTB, 6
    GOTO    FOUND_CHAR_ROW2
    
    BTFSS   PORTB, 7
    GOTO    CHECK_ROW3_NOT_SHIFT    ; Row 3 found - but check if it's a shift key
    
    ; No key in this column, try next
    INCF    SCAN_COL, F
    MOVF    SCAN_COL, W
    XORLW   D'8'
    BTFSS   STATUS, Z
    GOTO    SCAN_CHAR_NEXT_COL
    
    ; No character key found
    GOTO    SCAN_CHAR_DONE

CHECK_ROW3_NOT_SHIFT:
    ; Row 3 key detected - check if it's column 0 or 7 (shift keys)
    MOVF    SCAN_COL, W
    XORLW   D'0'                ; Is it column 0 (left shift)?
    BTFSC   STATUS, Z
    GOTO    SKIP_THIS_COL       ; Yes, skip left shift
    
    MOVF    SCAN_COL, W
    XORLW   D'7'                ; Is it column 7 (right shift)?
    BTFSC   STATUS, Z
    GOTO    SKIP_THIS_COL       ; Yes, skip right shift
    
    ; It's a valid row 3 character key (O, P, /, *, +, -)
    GOTO    FOUND_CHAR_ROW3

SKIP_THIS_COL:
    ; This column has a shift key pressed, continue to next column
    INCF    SCAN_COL, F
    MOVF    SCAN_COL, W
    XORLW   D'8'
    BTFSS   STATUS, Z
    GOTO    SCAN_CHAR_NEXT_COL
    
    ; No character key found
    GOTO    SCAN_CHAR_DONE

FOUND_CHAR_ROW0:
    CLRF    KEY_ROW
    GOTO    CALC_CHAR_INDEX
    
FOUND_CHAR_ROW1:
    MOVLW   D'1'
    MOVWF   KEY_ROW
    GOTO    CALC_CHAR_INDEX
    
FOUND_CHAR_ROW2:
    MOVLW   D'2'
    MOVWF   KEY_ROW
    GOTO    CALC_CHAR_INDEX

FOUND_CHAR_ROW3:
    MOVLW   D'3'
    MOVWF   KEY_ROW
    GOTO    CALC_CHAR_INDEX

CALC_CHAR_INDEX:
    MOVF    SCAN_COL, W
    MOVWF   KEY_COL
    
    ; KEY_INDEX = ROW * 8 + COL
    MOVF    KEY_ROW, W
    MOVWF   KEY_INDEX
    BCF     STATUS, C
    RLF     KEY_INDEX, F
    BCF     STATUS, C
    RLF     KEY_INDEX, F
    BCF     STATUS, C
    RLF     KEY_INDEX, F
    
    MOVF    KEY_COL, W
    ADDWF   KEY_INDEX, F
    
    BSF     NEW_KEY_FLAG, 0

SCAN_CHAR_DONE:
    CLRF    PORTD
    RETURN

;-------------------------------------------------------------------------------
; Get Column Mask (returns mask with bit N cleared)
; Input: W = column number (0-7)
; Output: W = mask with appropriate bit cleared
; MAPPING: Col 0 = RD7 (MSB), Col 7 = RD0 (LSB)
;-------------------------------------------------------------------------------
GET_COL_MASK:
    ; 1. Save Column Index (W)
    MOVWF   TEMP_VAR
    
    ; 2. Set PCLATH to point to THIS routine
    MOVLW   HIGH COL_MASK_TABLE
    MOVWF   PCLATH
    
    ; 3. Restore W
    MOVF    TEMP_VAR, W
    
    ; 4. Jump
    ADDWF   PCL, F

COL_MASK_TABLE:
    ; REVERSED MAPPING: Col 0 = RD0 (bit 0), Col 7 = RD7 (bit 7)
    RETLW   B'11111110'         ; Col 0 -> clear bit 0 (RD0)
    RETLW   B'11111101'         ; Col 1 -> clear bit 1 (RD1)
    RETLW   B'11111011'         ; Col 2 -> clear bit 2 (RD2)
    RETLW   B'11110111'         ; Col 3 -> clear bit 3 (RD3)
    RETLW   B'11101111'         ; Col 4 -> clear bit 4 (RD4)
    RETLW   B'11011111'         ; Col 5 -> clear bit 5 (RD5)
    RETLW   B'10111111'         ; Col 6 -> clear bit 6 (RD6)
    RETLW   B'01111111'         ; Col 7 -> clear bit 7 (RD7)

;===============================================================================
; ASCII LOOKUP TABLE
;===============================================================================
; Keypad layout (matching Proteus schematic):
; Row 0: Q W E R T Y U I
; Row 1: A S D F G H J K
; Row 2: Z X C V B N M L
; Row 3: SHIFT O P / * + - SHIFT
;
; Returns lowercase by default
;-------------------------------------------------------------------------------
LOOKUP_ASCII:
    ; 1. Save the Offset (Key Index) temporarily
    MOVWF   TEMP_VAR        ; Save W (Key Index) to temp

    ; 2. Set PCLATH to point to THIS table's page
    MOVLW   HIGH ASCII_TABLE_START
    MOVWF   PCLATH

    ; 3. Add the Offset to the Table Base Address
    MOVF    TEMP_VAR, W     ; Restore Key Index
    ADDLW   LOW ASCII_TABLE_START
    
    ; 4. Handle Carry if we cross a 256-byte boundary
    BTFSC   STATUS, C
    INCF    PCLATH, F
    
    ; 5. The Jump
    MOVWF   PCL

ASCII_TABLE_START:
    ; Row 0 (indices 0-7): Q W E R T Y U I
    RETLW   'q'             ; Index 0
    RETLW   'w'             ; Index 1
    RETLW   'e'             ; Index 2
    RETLW   'r'             ; Index 3
    RETLW   't'             ; Index 4
    RETLW   'y'             ; Index 5
    RETLW   'u'             ; Index 6
    RETLW   'i'             ; Index 7
    
    ; Row 1 (indices 8-15): A S D F G H J K
    RETLW   'a'             ; Index 8
    RETLW   's'             ; Index 9
    RETLW   'd'             ; Index 10
    RETLW   'f'             ; Index 11
    RETLW   'g'             ; Index 12
    RETLW   'h'             ; Index 13
    RETLW   'j'             ; Index 14
    RETLW   'k'             ; Index 15
    
    ; Row 2 (indices 16-23): Z X C V B N M L
    RETLW   'z'             ; Index 16
    RETLW   'x'             ; Index 17
    RETLW   'c'             ; Index 18
    RETLW   'v'             ; Index 19
    RETLW   'b'             ; Index 20
    RETLW   'n'             ; Index 21
    RETLW   'm'             ; Index 22
    RETLW   'l'             ; Index 23
    
    ; Row 3 (indices 24-31): SHIFT O P / * + - SHIFT
    RETLW   0x00            ; Index 24 - LEFT SHIFT
    RETLW   'o'             ; Index 25
    RETLW   'p'             ; Index 26
    RETLW   '/'             ; Index 27
    RETLW   '*'             ; Index 28
    RETLW   '+'             ; Index 29
    RETLW   '-'             ; Index 30
    RETLW   0x00            ; Index 31 - RIGHT SHIFT

;-------------------------------------------------------------------------------
; Process Shifted Key - Convert to uppercase if applicable
;-------------------------------------------------------------------------------
PROCESS_SHIFTED_KEY:
    ; Skip if shift key itself
    MOVF    KEY_INDEX, W
    XORLW   SHIFT_INDEX_L
    BTFSC   STATUS, Z
    RETURN
    MOVF    KEY_INDEX, W
    XORLW   SHIFT_INDEX_R
    BTFSC   STATUS, Z
    RETURN
    
    ; Get ASCII code - CRITICAL FIX: Reload KEY_INDEX into W!
    MOVF    KEY_INDEX, W        ; <-- THIS LINE WAS MISSING!
    CALL    LOOKUP_ASCII
    MOVWF   CURRENT_CHAR
    
    ; Check if lowercase letter (a-z: 0x61-0x7A)
    MOVF    CURRENT_CHAR, W
    SUBLW   'z'                 ; W = 'z' - CURRENT_CHAR
    BTFSS   STATUS, C           ; Skip if CURRENT_CHAR <= 'z'
    GOTO    SEND_CHAR           ; Not a letter, send as-is
    
    MOVLW   'a'
    SUBWF   CURRENT_CHAR, W     ; W = CURRENT_CHAR - 'a'
    BTFSS   STATUS, C           ; Skip if CURRENT_CHAR >= 'a'
    GOTO    SEND_CHAR           ; Not a letter, send as-is
    
    ; Convert to uppercase (subtract 0x20)
    MOVLW   D'32'
    SUBWF   CURRENT_CHAR, F

SEND_CHAR:
    ; Transmit via UART
    CALL    UART_TRANSMIT
    
    RETURN

;===============================================================================
; UART TRANSMISSION
;===============================================================================
UART_TRANSMIT:
    ; Wait for transmit buffer to be empty
    BSF     STATUS, RP0         ; Bank 1
UART_WAIT:
    BTFSS   TXSTA, TRMT         ; Check if TSR is empty
    GOTO    UART_WAIT
    BCF     STATUS, RP0         ; Bank 0
    
    ; Transmit character
    MOVF    CURRENT_CHAR, W
    MOVWF   TXREG
    
    RETURN

;===============================================================================
; DISPLAY SUBROUTINES
;===============================================================================

;-------------------------------------------------------------------------------
; Display Character - Multiplexed 5x7 LED matrix
; Active HIGH columns (RA0-RA4)
; Active LOW rows (RC0-RC5, RA5)
;-------------------------------------------------------------------------------
DISPLAY_CHAR:
    ; --- Step 1: Range Check ---
    MOVF    CURRENT_CHAR, W
    SUBLW   ')'                 ; Check if char < '*'
    BTFSC   STATUS, C
    GOTO    USE_DEFAULT_FONT

    MOVF    CURRENT_CHAR, W
    SUBLW   'z'                 ; Check if char > 'z'
    BTFSS   STATUS, C
    GOTO    USE_DEFAULT_FONT
    GOTO    CALC_OFFSET

USE_DEFAULT_FONT:
    MOVLW   DEFAULT_CHAR
    MOVWF   TEMP_VAR
    GOTO    DO_CALC_OFFSET

CALC_OFFSET:
    MOVF    CURRENT_CHAR, W
    MOVWF   TEMP_VAR

DO_CALC_OFFSET:
    ; --- Step 2: Calculate 16-bit Offset = (Char - 42) * 5 ---
    
    ; A. Subtract Base (42)
    MOVLW   D'42'
    SUBWF   TEMP_VAR, W         ; W = Char - 42
    MOVWF   FONT_OFFSET_L       ; L = Base Index
    CLRF    FONT_OFFSET_H       ; H = 0

    ; B. Multiply by 4 (Shift Left twice)
    ; Shift 1 (x2)
    BCF     STATUS, C
    RLF     FONT_OFFSET_L, F
    RLF     FONT_OFFSET_H, F    ; Carry rotates into High Byte
    ; Shift 2 (x4)
    BCF     STATUS, C
    RLF     FONT_OFFSET_L, F
    RLF     FONT_OFFSET_H, F

    ; C. Add Original (x4 + x1 = x5)
    MOVLW   D'42'               ; Reload original char
    SUBWF   TEMP_VAR, W         ; Get original index again (Char-42)
    ADDWF   FONT_OFFSET_L, F    ; Add to Low Byte
    BTFSC   STATUS, C           ; Did Low Byte overflow?
    INCF    FONT_OFFSET_H, F    ; Yes, increment High Byte

    ; --- Step 3: Display Loop ---
    CLRF    COL_INDEX

DISPLAY_LOOP:
    ; Turn off all columns first
    BCF     PORTA, 0
    BCF     PORTA, 1
    BCF     PORTA, 2
    BCF     PORTA, 3
    BCF     PORTA, 4

    ; Get row data using the 16-bit offset
    CALL    GET_FONT_DATA
    MOVWF   ROW_DATA

    ; Output row data (active LOW)
    COMF    ROW_DATA, W         ; Invert for active low
    ANDLW   B'00111111'         ; Mask bits 0-5
    MOVWF   PORTC               ; RC0-RC5
    
    ; Handle bit 6 -> RA5
    BTFSS   ROW_DATA, 6
    BSF     PORTA, 5            ; LED on
    BTFSC   ROW_DATA, 6
    BCF     PORTA, 5            ; LED off

    ; Activate current column
    MOVF    COL_INDEX, W
    CALL    ACTIVATE_COLUMN

    ; Delay and Cleanup
    CALL    DELAY_2MS
    
    ; Turn off columns
    BCF     PORTA, 0
    BCF     PORTA, 1
    BCF     PORTA, 2
    BCF     PORTA, 3
    BCF     PORTA, 4

    ; Next column
    INCF    COL_INDEX, F
    MOVF    COL_INDEX, W
    XORLW   D'5'
    BTFSS   STATUS, Z
    GOTO    DISPLAY_LOOP

    RETURN

;-------------------------------------------------------------------------------
; Activate Display Column
; Input: W = column number (0-4)
;-------------------------------------------------------------------------------
ACTIVATE_COLUMN:
    ; 1. Save the column index (W) temporarily so we don't lose it
    MOVWF   TEMP_VAR

    ; 2. Set PCLATH to point to THIS routine's location in memory
    MOVLW   HIGH ACTIVATE_COLUMN
    MOVWF   PCLATH

    ; 3. Restore the column index into W
    MOVF    TEMP_VAR, W

    ; 4. Perform the Computed GOTO
    ADDWF   PCL, F
    
    ; Jump Table
    GOTO    ACTIVATE_COL0
    GOTO    ACTIVATE_COL1
    GOTO    ACTIVATE_COL2
    GOTO    ACTIVATE_COL3
    GOTO    ACTIVATE_COL4

ACTIVATE_COL0:
    BSF     PORTA, 0
    RETURN
ACTIVATE_COL1:
    BSF     PORTA, 1
    RETURN
ACTIVATE_COL2:
    BSF     PORTA, 2
    RETURN
ACTIVATE_COL3:
    BSF     PORTA, 3
    RETURN
ACTIVATE_COL4:
    BSF     PORTA, 4            ; Note: RA4 is open-drain, needs external pull-up
    RETURN

;===============================================================================
; FONT TABLE (5x7)
; Characters from '*' (0x2A) to 'z' (0x7A)
; Each character has 5 bytes (columns), LSB = top row
; Bit 0 = Row 0 (top), Bit 6 = Row 6 (bottom), Bit 7 = unused
;===============================================================================
GET_FONT_DATA:
    ; 1. Add COL_INDEX to the Low Byte of the offset
    MOVF    COL_INDEX, W
    ADDWF   FONT_OFFSET_L, W    ; Add column to low byte
    MOVWF   TEMP_VAR            ; Store temporarily
    
    ; 2. Handle Carry (if Col index caused overflow)
    MOVF    FONT_OFFSET_H, W    ; Get high byte
    BTFSC   STATUS, C           ; Did the add overflow?
    ADDLW   1                   ; Yes, add 1 to High Byte accumulator
    MOVWF   PCLATH_TEMP         ; Save calculated High Byte temporarily

    ; 3. Add Table Base Address HIGH Byte
    MOVLW   HIGH FONT_TABLE
    ADDWF   PCLATH_TEMP, F      ; Add table location to our offset

    ; 4. Set PCLATH
    MOVF    PCLATH_TEMP, W
    MOVWF   PCLATH

    ; 5. Add Table Base Address LOW Byte
    MOVF    TEMP_VAR, W         ; Get our calculated low offset
    ADDLW   LOW FONT_TABLE      ; Add table start location
    
    ; 6. Final Overflow Check
    ; If (Low_Offset + Table_Low) overflows, we must increment PCLATH
    BTFSC   STATUS, C
    INCF    PCLATH, F
    
    ; 7. The Jump
    MOVWF   PCL                 ; Jump to Table

FONT_TABLE:
    ; '*' (42) - asterisk
    DT      0x14, 0x08, 0x3E, 0x08, 0x14
    ; '+' (43) - plus
    DT      0x08, 0x08, 0x3E, 0x08, 0x08
    ; ',' (44) - comma
    DT      0x00, 0x50, 0x30, 0x00, 0x00
    ; '-' (45) - minus
    DT      0x08, 0x08, 0x08, 0x08, 0x08
    ; '.' (46) - period
    DT      0x00, 0x60, 0x60, 0x00, 0x00
    ; '/' (47) - slash
    DT      0x20, 0x10, 0x08, 0x04, 0x02
    ; '0' (48)
    DT      0x3E, 0x51, 0x49, 0x45, 0x3E
    ; '1' (49)
    DT      0x00, 0x42, 0x7F, 0x40, 0x00
    ; '2' (50)
    DT      0x42, 0x61, 0x51, 0x49, 0x46
    ; '3' (51)
    DT      0x21, 0x41, 0x45, 0x4B, 0x31
    ; '4' (52)
    DT      0x18, 0x14, 0x12, 0x7F, 0x10
    ; '5' (53)
    DT      0x27, 0x45, 0x45, 0x45, 0x39
    ; '6' (54)
    DT      0x3C, 0x4A, 0x49, 0x49, 0x30
    ; '7' (55)
    DT      0x01, 0x71, 0x09, 0x05, 0x03
    ; '8' (56)
    DT      0x36, 0x49, 0x49, 0x49, 0x36
    ; '9' (57)
    DT      0x06, 0x49, 0x49, 0x29, 0x1E
    ; ':' (58)
    DT      0x00, 0x36, 0x36, 0x00, 0x00
    ; ';' (59)
    DT      0x00, 0x56, 0x36, 0x00, 0x00
    ; '<' (60)
    DT      0x08, 0x14, 0x22, 0x41, 0x00
    ; '=' (61)
    DT      0x14, 0x14, 0x14, 0x14, 0x14
    ; '>' (62)
    DT      0x00, 0x41, 0x22, 0x14, 0x08
    ; '?' (63)
    DT      0x02, 0x01, 0x51, 0x09, 0x06
    ; '@' (64)
    DT      0x32, 0x49, 0x79, 0x41, 0x3E
    ; 'A' (65)
    DT      0x7E, 0x11, 0x11, 0x11, 0x7E
    ; 'B' (66)
    DT      0x7F, 0x49, 0x49, 0x49, 0x36
    ; 'C' (67)
    DT      0x3E, 0x41, 0x41, 0x41, 0x22
    ; 'D' (68)
    DT      0x7F, 0x41, 0x41, 0x22, 0x1C
    ; 'E' (69)
    DT      0x7F, 0x49, 0x49, 0x49, 0x41
    ; 'F' (70)
    DT      0x7F, 0x09, 0x09, 0x09, 0x01
    ; 'G' (71)
    DT      0x3E, 0x41, 0x49, 0x49, 0x7A
    ; 'H' (72)
    DT      0x7F, 0x08, 0x08, 0x08, 0x7F
    ; 'I' (73)
    DT      0x00, 0x41, 0x7F, 0x41, 0x00
    ; 'J' (74)
    DT      0x20, 0x40, 0x41, 0x3F, 0x01
    ; 'K' (75)
    DT      0x7F, 0x08, 0x14, 0x22, 0x41
    ; 'L' (76)
    DT      0x7F, 0x40, 0x40, 0x40, 0x40
    ; 'M' (77)
    DT      0x7F, 0x02, 0x0C, 0x02, 0x7F
    ; 'N' (78)
    DT      0x7F, 0x04, 0x08, 0x10, 0x7F
    ; 'O' (79)
    DT      0x3E, 0x41, 0x41, 0x41, 0x3E
    ; 'P' (80)
    DT      0x7F, 0x09, 0x09, 0x09, 0x06
    ; 'Q' (81)
    DT      0x3E, 0x41, 0x51, 0x21, 0x5E
    ; 'R' (82)
    DT      0x7F, 0x09, 0x19, 0x29, 0x46
    ; 'S' (83)
    DT      0x46, 0x49, 0x49, 0x49, 0x31
    ; 'T' (84)
    DT      0x01, 0x01, 0x7F, 0x01, 0x01
    ; 'U' (85)
    DT      0x3F, 0x40, 0x40, 0x40, 0x3F
    ; 'V' (86)
    DT      0x1F, 0x20, 0x40, 0x20, 0x1F
    ; 'W' (87)
    DT      0x3F, 0x40, 0x38, 0x40, 0x3F
    ; 'X' (88)
    DT      0x63, 0x14, 0x08, 0x14, 0x63
    ; 'Y' (89)
    DT      0x07, 0x08, 0x70, 0x08, 0x07
    ; 'Z' (90)
    DT      0x61, 0x51, 0x49, 0x45, 0x43
    ; '[' (91)
    DT      0x00, 0x7F, 0x41, 0x41, 0x00
    ; '\' (92)
    DT      0x02, 0x04, 0x08, 0x10, 0x20
    ; ']' (93)
    DT      0x00, 0x41, 0x41, 0x7F, 0x00
    ; '^' (94)
    DT      0x04, 0x02, 0x01, 0x02, 0x04
    ; '_' (95)
    DT      0x40, 0x40, 0x40, 0x40, 0x40
    ; '`' (96)
    DT      0x00, 0x01, 0x02, 0x04, 0x00
    ; 'a' (97)
    DT      0x20, 0x54, 0x54, 0x54, 0x78
    ; 'b' (98)
    DT      0x7F, 0x48, 0x44, 0x44, 0x38
    ; 'c' (99)
    DT      0x38, 0x44, 0x44, 0x44, 0x20
    ; 'd' (100)
    DT      0x38, 0x44, 0x44, 0x48, 0x7F
    ; 'e' (101)
    DT      0x38, 0x54, 0x54, 0x54, 0x18
    ; 'f' (102)
    DT      0x08, 0x7E, 0x09, 0x01, 0x02
    ; 'g' (103)
    DT      0x0C, 0x52, 0x52, 0x52, 0x3E
    ; 'h' (104)
    DT      0x7F, 0x08, 0x04, 0x04, 0x78
    ; 'i' (105)
    DT      0x00, 0x44, 0x7D, 0x40, 0x00
    ; 'j' (106)
    DT      0x20, 0x40, 0x44, 0x3D, 0x00
    ; 'k' (107)
    DT      0x7F, 0x10, 0x28, 0x44, 0x00
    ; 'l' (108)
    DT      0x00, 0x41, 0x7F, 0x40, 0x00
    ; 'm' (109)
    DT      0x7C, 0x04, 0x18, 0x04, 0x78
    ; 'n' (110)
    DT      0x7C, 0x08, 0x04, 0x04, 0x78
    ; 'o' (111)
    DT      0x38, 0x44, 0x44, 0x44, 0x38
    ; 'p' (112)
    DT      0x7C, 0x14, 0x14, 0x14, 0x08
    ; 'q' (113)
    DT      0x08, 0x14, 0x14, 0x18, 0x7C
    ; 'r' (114)
    DT      0x7C, 0x08, 0x04, 0x04, 0x08
    ; 's' (115)
    DT      0x48, 0x54, 0x54, 0x54, 0x20
    ; 't' (116)
    DT      0x04, 0x3F, 0x44, 0x40, 0x20
    ; 'u' (117)
    DT      0x3C, 0x40, 0x40, 0x20, 0x7C
    ; 'v' (118)
    DT      0x1C, 0x20, 0x40, 0x20, 0x1C
    ; 'w' (119)
    DT      0x3C, 0x40, 0x30, 0x40, 0x3C
    ; 'x' (120)
    DT      0x44, 0x28, 0x10, 0x28, 0x44
    ; 'y' (121)
    DT      0x0C, 0x50, 0x50, 0x50, 0x3C
    ; 'z' (122)
    DT      0x44, 0x64, 0x54, 0x4C, 0x44

;===============================================================================
; DELAY SUBROUTINES
;===============================================================================

;-------------------------------------------------------------------------------
; Delay 2ms (for display multiplexing)
; At 4 MHz, each instruction cycle = 1 us
; 2ms = 2000 cycles
;-------------------------------------------------------------------------------
DELAY_2MS:
    MOVLW   D'4'
    MOVWF   DELAY_COUNT1
DELAY_2MS_OUTER:
    MOVLW   D'166'
    MOVWF   DELAY_COUNT2
DELAY_2MS_INNER:
    NOP
    DECFSZ  DELAY_COUNT2, F
    GOTO    DELAY_2MS_INNER
    DECFSZ  DELAY_COUNT1, F
    GOTO    DELAY_2MS_OUTER
    RETURN

;-------------------------------------------------------------------------------
; Delay 20ms (for debouncing)
; 20ms = 20000 cycles
;-------------------------------------------------------------------------------
DELAY_20MS:
    MOVLW   D'40'
    MOVWF   ISR_DELAY_COUNT1
DELAY_20MS_OUTER:
    MOVLW   D'166'
    MOVWF   ISR_DELAY_COUNT2
DELAY_20MS_INNER:
    NOP
    DECFSZ  ISR_DELAY_COUNT2, F
    GOTO    DELAY_20MS_INNER
    DECFSZ  ISR_DELAY_COUNT1, F
    GOTO    DELAY_20MS_OUTER
    RETURN

;===============================================================================
; END OF PROGRAM
;===============================================================================
    END