/*******************************************************************************
 * File:        keypad_display.c
 * Project:     Matrix Keypad Control with 5x7 LED Display
 * MCU:         PIC16F877A @ 4MHz
 * Compiler:    Hi-Tech C (MPLAB IDE)
 * 
 * Description: Reads input from a 4x8 matrix keypad, displays characters on
 *              a 5x7 LED matrix, and transmits ASCII via UART.
 *
 * Hardware Configuration:
 *   - Keypad Rows (Inputs):    RB4, RB5, RB6, RB7 (with internal pull-ups)
 *   - Keypad Columns (Outputs): RD0-RD7
 *   - Display Columns:          RA0-RA4 (RA4 is open-drain, needs pull-up)
 *   - Display Rows:             RC0-RC5, RA5
 *   - UART TX:                  RC6 @ 9600 baud
 *
 * Author:      Generated for GEL558 Project
 * Date:        2025
 ******************************************************************************/

#include <htc.h>
#include <pic16f877a.h>

/*******************************************************************************
 * Configuration Bits
 ******************************************************************************/
__CONFIG(FOSC_XT & WDTE_OFF & PWRTE_ON & BOREN_ON & LVP_OFF & CPD_OFF & 
         WRT_OFF & DEBUG_OFF & CP_OFF);

/*******************************************************************************
 * Definitions
 ******************************************************************************/
#define _XTAL_FREQ  4000000     // 4 MHz crystal frequency

// Port Definitions
#define KEYPAD_ROWS     PORTB   // RB4-RB7 for rows
#define KEYPAD_COLS     PORTD   // RD0-RD7 for columns
#define DISPLAY_COLS    PORTA   // RA0-RA4 for display columns
#define DISPLAY_ROWS    PORTC   // RC0-RC5 for display rows (RC6=TX, RC7=RX)

// Row masks for PORTB (RB4-RB7)
#define ROW_MASK        0xF0    // Mask for RB4-RB7
#define ROW1_MASK       0x10    // RB4
#define ROW2_MASK       0x20    // RB5
#define ROW3_MASK       0x40    // RB6
#define ROW4_MASK       0x80    // RB7

// Shift key detection (Column 0 and Column 7 in Row 4)
#define SHIFT_COL_LEFT  0       // Left shift at column 0
#define SHIFT_COL_RIGHT 7       // Right shift at column 7
#define SHIFT_ROW       3       // Shift keys are in row 4 (index 3)

// UART Configuration
#define BAUD_RATE       9600
#define SPBRG_VALUE     25      // For 4MHz and 9600 baud with BRGH=1

// Timing
#define DEBOUNCE_MS     20      // Debounce delay in milliseconds
#define COLUMN_DELAY_MS 2       // Display column delay in milliseconds

/*******************************************************************************
 * Global Variables
 ******************************************************************************/
volatile unsigned char current_char = 'a';  // Current character to display
volatile unsigned char shift_flag = 0;      // Shift key status
volatile unsigned char key_pressed = 0;     // Flag indicating a key was pressed
volatile unsigned char new_char = 0;        // Newly detected character

/*******************************************************************************
 * Keypad Layout Table
 * Maps [row][column] to lowercase characters
 * Row 0 (RB4): Q W E R T Y U I
 * Row 1 (RB5): A S D F G H J K
 * Row 2 (RB6): Z X C V B N M L
 * Row 3 (RB7): SHIFT O P / * + - SHIFT
 ******************************************************************************/
const unsigned char keypad_map[4][8] = {
    {'q', 'w', 'e', 'r', 't', 'y', 'u', 'i'},  // Row 0 (RB4)
    {'a', 's', 'd', 'f', 'g', 'h', 'j', 'k'},  // Row 1 (RB5)
    {'z', 'x', 'c', 'v', 'b', 'n', 'm', 'l'},  // Row 2 (RB6)
    {0,   'o', 'p', '/', '*', '+', '-', 0  }   // Row 3 (RB7) - 0 = SHIFT keys
};

/*******************************************************************************
 * 5x7 Font Table
 * Each character has 5 bytes (one per column)
 * Bits represent rows (LSB = top row, bit 6 = bottom row)
 * Characters from ASCII 42 ('*') to ASCII 122 ('z')
 * Active LOW: 0 = LED ON, 1 = LED OFF
 ******************************************************************************/
const unsigned char font_table[][5] = {
    // '*' ASCII 42
    {0x7F, 0x6B, 0x5D, 0x6B, 0x7F},
    // '+' ASCII 43
    {0x77, 0x77, 0x41, 0x77, 0x77},
    // ',' ASCII 44
    {0x7F, 0x67, 0x6F, 0x7F, 0x7F},
    // '-' ASCII 45
    {0x77, 0x77, 0x77, 0x77, 0x77},
    // '.' ASCII 46
    {0x7F, 0x7F, 0x67, 0x7F, 0x7F},
    // '/' ASCII 47
    {0x7E, 0x7D, 0x7B, 0x77, 0x6F},
    // '0' ASCII 48
    {0x41, 0x3E, 0x36, 0x3E, 0x41},
    // '1' ASCII 49
    {0x7F, 0x5D, 0x00, 0x5F, 0x7F},
    // '2' ASCII 50
    {0x4D, 0x36, 0x36, 0x36, 0x59},
    // '3' ASCII 51
    {0x5D, 0x36, 0x36, 0x36, 0x49},
    // '4' ASCII 52
    {0x70, 0x77, 0x77, 0x00, 0x77},
    // '5' ASCII 53
    {0x58, 0x36, 0x36, 0x36, 0x66},
    // '6' ASCII 54
    {0x41, 0x36, 0x36, 0x36, 0x4D},
    // '7' ASCII 55
    {0x7E, 0x7E, 0x06, 0x7E, 0x78},
    // '8' ASCII 56
    {0x49, 0x36, 0x36, 0x36, 0x49},
    // '9' ASCII 57
    {0x59, 0x36, 0x36, 0x36, 0x41},
    // ':' ASCII 58
    {0x7F, 0x7F, 0x55, 0x7F, 0x7F},
    // ';' ASCII 59
    {0x7F, 0x67, 0x55, 0x7F, 0x7F},
    // '<' ASCII 60
    {0x77, 0x6B, 0x5D, 0x3E, 0x7F},
    // '=' ASCII 61
    {0x6B, 0x6B, 0x6B, 0x6B, 0x6B},
    // '>' ASCII 62
    {0x7F, 0x3E, 0x5D, 0x6B, 0x77},
    // '?' ASCII 63
    {0x79, 0x7E, 0x56, 0x76, 0x79},
    // '@' ASCII 64
    {0x41, 0x3E, 0x2A, 0x2A, 0x51},
    // 'A' ASCII 65
    {0x01, 0x76, 0x76, 0x76, 0x01},
    // 'B' ASCII 66
    {0x00, 0x36, 0x36, 0x36, 0x49},
    // 'C' ASCII 67
    {0x41, 0x3E, 0x3E, 0x3E, 0x5D},
    // 'D' ASCII 68
    {0x00, 0x3E, 0x3E, 0x3E, 0x41},
    // 'E' ASCII 69
    {0x00, 0x36, 0x36, 0x36, 0x3E},
    // 'F' ASCII 70
    {0x00, 0x76, 0x76, 0x76, 0x7E},
    // 'G' ASCII 71
    {0x41, 0x3E, 0x36, 0x36, 0x4D},
    // 'H' ASCII 72
    {0x00, 0x77, 0x77, 0x77, 0x00},
    // 'I' ASCII 73
    {0x7F, 0x3E, 0x00, 0x3E, 0x7F},
    // 'J' ASCII 74
    {0x5F, 0x3F, 0x3F, 0x3F, 0x40},
    // 'K' ASCII 75
    {0x00, 0x77, 0x6B, 0x5D, 0x3E},
    // 'L' ASCII 76
    {0x00, 0x7F, 0x7F, 0x7F, 0x7F},
    // 'M' ASCII 77
    {0x00, 0x7D, 0x7B, 0x7D, 0x00},
    // 'N' ASCII 78
    {0x00, 0x7D, 0x7B, 0x77, 0x00},
    // 'O' ASCII 79
    {0x41, 0x3E, 0x3E, 0x3E, 0x41},
    // 'P' ASCII 80
    {0x00, 0x76, 0x76, 0x76, 0x79},
    // 'Q' ASCII 81
    {0x41, 0x3E, 0x2E, 0x1E, 0x21},
    // 'R' ASCII 82
    {0x00, 0x76, 0x66, 0x56, 0x39},
    // 'S' ASCII 83
    {0x59, 0x36, 0x36, 0x36, 0x4D},
    // 'T' ASCII 84
    {0x7E, 0x7E, 0x00, 0x7E, 0x7E},
    // 'U' ASCII 85
    {0x40, 0x3F, 0x3F, 0x3F, 0x40},
    // 'V' ASCII 86
    {0x60, 0x5F, 0x3F, 0x5F, 0x60},
    // 'W' ASCII 87
    {0x40, 0x3F, 0x4F, 0x3F, 0x40},
    // 'X' ASCII 88
    {0x1C, 0x6B, 0x77, 0x6B, 0x1C},
    // 'Y' ASCII 89
    {0x78, 0x77, 0x07, 0x77, 0x78},
    // 'Z' ASCII 90
    {0x1E, 0x2E, 0x36, 0x3A, 0x3C},
    // '[' ASCII 91
    {0x7F, 0x00, 0x3E, 0x7F, 0x7F},
    // '\' ASCII 92
    {0x6F, 0x77, 0x7B, 0x7D, 0x7E},
    // ']' ASCII 93
    {0x7F, 0x7F, 0x3E, 0x00, 0x7F},
    // '^' ASCII 94
    {0x7B, 0x7D, 0x7E, 0x7D, 0x7B},
    // '_' ASCII 95
    {0x3F, 0x3F, 0x3F, 0x3F, 0x3F},
    // '`' ASCII 96
    {0x7F, 0x7E, 0x7D, 0x7F, 0x7F},
    // 'a' ASCII 97
    {0x4F, 0x57, 0x57, 0x57, 0x0F},
    // 'b' ASCII 98
    {0x00, 0x57, 0x57, 0x57, 0x6F},
    // 'c' ASCII 99
    {0x0F, 0x57, 0x57, 0x57, 0x7F},
    // 'd' ASCII 100
    {0x6F, 0x57, 0x57, 0x57, 0x00},
    // 'e' ASCII 101
    {0x0F, 0x57, 0x57, 0x57, 0x1F},
    // 'f' ASCII 102
    {0x77, 0x00, 0x76, 0x76, 0x7D},
    // 'g' ASCII 103
    {0x1F, 0x57, 0x57, 0x57, 0x4F},
    // 'h' ASCII 104
    {0x00, 0x77, 0x77, 0x77, 0x0F},
    // 'i' ASCII 105
    {0x7F, 0x7F, 0x04, 0x7F, 0x7F},
    // 'j' ASCII 106
    {0x5F, 0x7F, 0x7F, 0x04, 0x7F},
    // 'k' ASCII 107
    {0x00, 0x6F, 0x57, 0x3F, 0x7F},
    // 'l' ASCII 108
    {0x7F, 0x40, 0x3F, 0x7F, 0x7F},
    // 'm' ASCII 109
    {0x0F, 0x77, 0x0F, 0x77, 0x0F},
    // 'n' ASCII 110
    {0x0F, 0x77, 0x77, 0x77, 0x0F},
    // 'o' ASCII 111
    {0x0F, 0x57, 0x57, 0x57, 0x0F},
    // 'p' ASCII 112
    {0x07, 0x57, 0x57, 0x57, 0x6F},
    // 'q' ASCII 113
    {0x6F, 0x57, 0x57, 0x57, 0x07},
    // 'r' ASCII 114
    {0x0F, 0x77, 0x77, 0x77, 0x7F},
    // 's' ASCII 115
    {0x5F, 0x57, 0x57, 0x57, 0x77},
    // 't' ASCII 116
    {0x77, 0x00, 0x57, 0x7F, 0x7F},
    // 'u' ASCII 117
    {0x4F, 0x7F, 0x7F, 0x7F, 0x0F},
    // 'v' ASCII 118
    {0x6F, 0x5F, 0x3F, 0x5F, 0x6F},
    // 'w' ASCII 119
    {0x0F, 0x7F, 0x0F, 0x7F, 0x0F},
    // 'x' ASCII 120
    {0x37, 0x6F, 0x7F, 0x6F, 0x37},
    // 'y' ASCII 121
    {0x67, 0x57, 0x57, 0x57, 0x0F},
    // 'z' ASCII 122
    {0x37, 0x27, 0x17, 0x57, 0x77}
};

// Starting ASCII value for font table
#define FONT_START_ASCII    42  // '*' character

/*******************************************************************************
 * Function Prototypes
 ******************************************************************************/
void init_ports(void);
void init_uart(void);
void init_interrupts(void);
void delay_ms(unsigned int ms);
void delay_2ms(void);
void delay_20ms(void);
void uart_transmit(unsigned char data);
void display_character(unsigned char ch);
void scan_keypad(void);
void write_eeprom(unsigned char address, unsigned char data);
unsigned char read_eeprom(unsigned char address);
void output_row_data(unsigned char data);

/*******************************************************************************
 * Interrupt Service Routine
 * Handles Port B Change Interrupt for keypad detection
 ******************************************************************************/
void interrupt isr(void)
{
    unsigned char dummy;
    unsigned char col, row_bits, row;
    unsigned char detected_char = 0;
    unsigned char shift_detected = 0;
    
    // Check if this is a Port B Change Interrupt
    if (RBIF && RBIE)
    {
        // Read PORTB to clear mismatch condition
        dummy = PORTB;
        
        // Debounce delay
        delay_20ms();
        
        // Read rows after debounce
        row_bits = (PORTB & ROW_MASK) >> 4;
        
        // Check if any row is still LOW (button still pressed)
        if (row_bits != 0x0F)
        {
            // Walking Zero scan to identify the pressed key
            for (col = 0; col < 8; col++)
            {
                // Set all columns HIGH
                KEYPAD_COLS = 0xFF;
                
                // Set current column LOW
                KEYPAD_COLS = ~(1 << col);
                
                // Small delay for signal to settle
                NOP();
                NOP();
                NOP();
                NOP();
                
                // Read rows
                row_bits = PORTB & ROW_MASK;
                
                // Check each row
                for (row = 0; row < 4; row++)
                {
                    if (!(row_bits & (ROW1_MASK << row)))
                    {
                        // Key found at [row][col]
                        
                        // Check if this is a SHIFT key
                        if (row == SHIFT_ROW && (col == SHIFT_COL_LEFT || col == SHIFT_COL_RIGHT))
                        {
                            shift_detected = 1;
                            shift_flag = 1;
                        }
                        else
                        {
                            // Get character from keypad map
                            detected_char = keypad_map[row][col];
                        }
                    }
                }
            }
            
            // Process detected character (if not a shift key)
            if (detected_char != 0 && !shift_detected)
            {
                // Apply shift if shift flag is set
                if (shift_flag && detected_char >= 'a' && detected_char <= 'z')
                {
                    detected_char = detected_char - 32;  // Convert to uppercase
                }
                
                // Update current character
                current_char = detected_char;
                key_pressed = 1;
                
                // Transmit via UART
                uart_transmit(current_char);
                
                // Save to EEPROM
                write_eeprom(0x00, current_char);
                
                // Clear shift flag after use (for non-letter characters too)
                shift_flag = 0;
            }
        }
        
        // Reset columns to LOW for next interrupt detection
        KEYPAD_COLS = 0x00;
        
        // Read PORTB again to clear mismatch
        dummy = PORTB;
        
        // Clear interrupt flag
        RBIF = 0;
    }
}

/*******************************************************************************
 * Main Function
 ******************************************************************************/
void main(void)
{
    // Initialize hardware
    init_ports();
    init_uart();
    init_interrupts();
    
    // Load last character from EEPROM (if valid)
    unsigned char saved_char = read_eeprom(0x00);
    if (saved_char >= '*' && saved_char <= 'z')
    {
        current_char = saved_char;
    }
    else
    {
        current_char = 'a';  // Default character
    }
    
    // Main loop - continuously refresh display
    while (1)
    {
        // Refresh the LED matrix display
        display_character(current_char);
        
        // Check if shift key needs to be polled
        if (shift_flag)
        {
            // Disable interrupts while polling
            RBIE = 0;
            
            // Poll for shift key release or character press
            scan_keypad();
            
            // Re-enable interrupts
            RBIE = 1;
        }
    }
}

/*******************************************************************************
 * Initialize I/O Ports
 ******************************************************************************/
void init_ports(void)
{
    // Configure PORTA as digital I/O (disable ADC)
    ADCON1 = 0x06;
    
    // PORTA: RA0-RA4 as outputs (display columns), RA5 as output (7th row)
    TRISA = 0x00;
    PORTA = 0x1F;  // All display columns OFF (HIGH), RA5 HIGH
    
    // PORTB: RB4-RB7 as inputs (keypad rows), RB0-RB3 as outputs
    TRISB = 0xF0;
    
    // Enable weak pull-ups on PORTB
    OPTION_REGbits.nRBPU = 0;
    
    // PORTC: RC0-RC5 as outputs (display rows), RC6 as output (TX), RC7 as input (RX)
    TRISC = 0x80;
    PORTC = 0x3F;  // All rows HIGH (LEDs OFF since active low)
    
    // PORTD: All outputs (keypad columns)
    TRISD = 0x00;
    PORTD = 0x00;  // All columns LOW (ready for interrupt detection)
}

/*******************************************************************************
 * Initialize UART for 9600 baud, 8N1
 ******************************************************************************/
void init_uart(void)
{
    // Set baud rate
    SPBRG = SPBRG_VALUE;
    
    // Configure TXSTA
    TXSTAbits.BRGH = 1;     // High speed baud rate
    TXSTAbits.SYNC = 0;     // Asynchronous mode
    TXSTAbits.TX9 = 0;      // 8-bit transmission
    TXSTAbits.TXEN = 1;     // Enable transmitter
    
    // Configure RCSTA
    RCSTAbits.SPEN = 1;     // Enable serial port
    RCSTAbits.RX9 = 0;      // 8-bit reception
    RCSTAbits.CREN = 0;     // Disable continuous receive (TX only)
}

/*******************************************************************************
 * Initialize Interrupts
 ******************************************************************************/
void init_interrupts(void)
{
    unsigned char dummy;
    
    // Read PORTB to clear any mismatch
    dummy = PORTB;
    
    // Clear Port B Change Interrupt Flag
    RBIF = 0;
    
    // Enable Port B Change Interrupt
    RBIE = 1;
    
    // Enable Peripheral Interrupts
    PEIE = 1;
    
    // Enable Global Interrupts
    GIE = 1;
}

/*******************************************************************************
 * Delay Functions
 ******************************************************************************/
void delay_ms(unsigned int ms)
{
    unsigned int i;
    for (i = 0; i < ms; i++)
    {
        __delay_ms(1);
    }
}

void delay_2ms(void)
{
    __delay_ms(2);
}

void delay_20ms(void)
{
    __delay_ms(20);
}

/*******************************************************************************
 * UART Transmit
 * Sends a single character via UART
 ******************************************************************************/
void uart_transmit(unsigned char data)
{
    // Wait for transmit buffer to be empty
    while (!TXIF);
    
    // Write data to transmit register
    TXREG = data;
}

/*******************************************************************************
 * Output Row Data to Display
 * Handles the split between PORTC (RC0-RC5) and PORTA (RA5)
 ******************************************************************************/
void output_row_data(unsigned char data)
{
    // RC0-RC5 get bits 0-5 of data
    // Keep RC6 and RC7 unchanged (UART pins)
    PORTC = (PORTC & 0xC0) | (data & 0x3F);
    
    // RA5 gets bit 6 of data
    if (data & 0x40)
    {
        RA5 = 1;
    }
    else
    {
        RA5 = 0;
    }
}

/*******************************************************************************
 * Display Character on 5x7 LED Matrix
 * Uses column scanning with multiplexing
 ******************************************************************************/
void display_character(unsigned char ch)
{
    unsigned char col;
    unsigned char font_index;
    unsigned char row_data;
    unsigned char col_mask;
    
    // Calculate font table index
    if (ch >= FONT_START_ASCII && ch <= 'z')
    {
        font_index = ch - FONT_START_ASCII;
    }
    else
    {
        // Default to 'a' if character not in table
        font_index = 'a' - FONT_START_ASCII;
    }
    
    // Scan through all 5 columns
    for (col = 0; col < 5; col++)
    {
        // Turn off all columns first
        PORTA = PORTA | 0x1F;  // Set RA0-RA4 HIGH (columns OFF)
        
        // Get row data for this column from font table
        row_data = font_table[font_index][col];
        
        // Output row data (active LOW)
        output_row_data(row_data);
        
        // Calculate column mask (active HIGH to sink current)
        col_mask = ~(1 << col) & 0x1F;
        
        // Activate current column (set LOW)
        // Keep RA5 state for 7th row
        PORTA = (PORTA & 0x20) | col_mask;
        
        // Delay for visibility
        delay_2ms();
        
        // Turn off column
        PORTA = PORTA | 0x1F;
    }
    
    // Turn off all rows after display cycle
    output_row_data(0x7F);
}

/*******************************************************************************
 * Scan Keypad (Polling Mode)
 * Used when in shift mode to detect key release or new character
 ******************************************************************************/
void scan_keypad(void)
{
    unsigned char col, row_bits, row;
    unsigned char detected_char = 0;
    unsigned char shift_still_pressed = 0;
    
    // Walking Zero scan
    for (col = 0; col < 8; col++)
    {
        // Set all columns HIGH
        KEYPAD_COLS = 0xFF;
        
        // Set current column LOW
        KEYPAD_COLS = ~(1 << col);
        
        // Small delay for signal to settle
        NOP();
        NOP();
        NOP();
        NOP();
        
        // Read rows
        row_bits = PORTB & ROW_MASK;
        
        // Check each row
        for (row = 0; row < 4; row++)
        {
            if (!(row_bits & (ROW1_MASK << row)))
            {
                // Key found at [row][col]
                
                // Check if this is a SHIFT key
                if (row == SHIFT_ROW && (col == SHIFT_COL_LEFT || col == SHIFT_COL_RIGHT))
                {
                    shift_still_pressed = 1;
                }
                else
                {
                    // Get character from keypad map
                    if (keypad_map[row][col] != 0)
                    {
                        detected_char = keypad_map[row][col];
                    }
                }
            }
        }
    }
    
    // Reset columns
    KEYPAD_COLS = 0x00;
    
    // Update shift flag
    shift_flag = shift_still_pressed;
    
    // If a character was detected while shift is held
    if (detected_char != 0 && shift_flag)
    {
        // Debounce
        delay_20ms();
        
        // Apply shift for letters
        if (detected_char >= 'a' && detected_char <= 'z')
        {
            detected_char = detected_char - 32;  // Convert to uppercase
        }
        
        // Update current character
        current_char = detected_char;
        key_pressed = 1;
        
        // Transmit via UART
        uart_transmit(current_char);
        
        // Save to EEPROM
        write_eeprom(0x00, current_char);
        
        // Wait for key release
        delay_ms(200);
    }
}

/*******************************************************************************
 * Write to EEPROM
 ******************************************************************************/
void write_eeprom(unsigned char address, unsigned char data)
{
    // Wait for any previous write to complete
    while (WR);
    
    // Set address
    EEADR = address;
    
    // Set data
    EEDATA = data;
    
    // Point to EEPROM data memory
    EECON1bits.EEPGD = 0;
    
    // Enable writes
    EECON1bits.WREN = 1;
    
    // Disable interrupts during write sequence
    GIE = 0;
    
    // Required write sequence
    EECON2 = 0x55;
    EECON2 = 0xAA;
    
    // Start write
    WR = 1;
    
    // Re-enable interrupts
    GIE = 1;
    
    // Wait for write to complete
    while (WR);
    
    // Disable writes
    EECON1bits.WREN = 0;
}

/*******************************************************************************
 * Read from EEPROM
 ******************************************************************************/
unsigned char read_eeprom(unsigned char address)
{
    // Set address
    EEADR = address;
    
    // Point to EEPROM data memory
    EECON1bits.EEPGD = 0;
    
    // Start read
    RD = 1;
    
    // Return data
    return EEDATA;
}

/*******************************************************************************
 * End of File
 ******************************************************************************/