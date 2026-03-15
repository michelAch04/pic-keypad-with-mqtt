# PIC16F877A Matrix Keypad & LED Display System

> **GEL558 – Microcontrollers Final Project | Fall 2025-2026**
USEK
---

## 📌 Project Overview

This embedded systems project implements a complete human-interface pipeline on a **PIC16F877A** microcontroller running at **4 MHz**. When a key is pressed on a custom **4×8 matrix keypad**, the system:

1. Detects the keypress via **interrupt-on-change** on PORTB
2. Debounces the input in software (20 ms timeout)
3. Renders the corresponding character graphically on a **5×7 LED matrix display** using a bitmap lookup table
4. Transmits the **ASCII code via UART** (9600 bps) to a serially connected device
5. Persists the **latest ASCII value in EEPROM**

The entire design is simulated in **Proteus** before any physical build.

---

## 🔧 Hardware Specifications

| Component | Details |
|---|---|
| Microcontroller | PIC16F877A @ 4 MHz, 5 V |
| Language | HI-TECH C |
| Keypad | 4 rows × 8 columns (32 keys) |
| Display | 5 columns × 7 rows LED matrix (red) |
| Serial Interface | UART @ 9600 bps, 8-N-1 |
| Simulation Tool | Proteus (COMPIM on COM1) |

---

## 🗺️ Pin Mapping

### 4×8 Matrix Keypad
| Signal | PIC Pins | Direction | Notes |
|---|---|---|---|
| Rows (R1–R4) | RB4, RB5, RB6, RB7 | Input | Internal weak pull-ups enabled; Interrupt-on-Change |
| Columns (C1–C8) | RD0–RD7 | Output | "Walking Zero" scan; default LOW |

**Keypad Layout:**
```
Row 1:  Q   W   E   R   T   Y   U   I
Row 2:  A   S   D   F   G   H   J   K
Row 3:  Z   X   C   V   B   N   M   L
Row 4: SHIFT  O   P   /   *   +   -  SHIFT
```
- **Without SHIFT:** `a b c d e f g h i j k l m n o p q r s t u v w x y z / * + -`
- **With SHIFT:** `A B C D E F G H I J K L M N O P Q R S T U V W X Y Z / * + -`

### 5×7 LED Matrix Display
| Signal | PIC Pins | Direction | Notes |
|---|---|---|---|
| Columns / Select (Active HIGH) | RA0, RA1, RA2, RA3, RA4 | Output | RA4 is open-drain → external 10 kΩ pull-up to VDD required |
| Rows / Data (Active LOW) | RC0–RC5, RA5 | Output | ADCON1 = 0x06 to force RA0–RA3, RA5 as digital I/O |

### UART
| Signal | PIC Pin | Notes |
|---|---|---|
| TX | RC6 | To COMPIM TXD in Proteus / ESP8266 TX in hardware |
| RX | RC7 | Reserved for future ESP8266 integration |
| SPBRG | 25 | Derived for 9600 baud @ 4 MHz with BRGH = 1 |

---

## ⚙️ Firmware Architecture
```
Main Loop
├── Initialization
│   ├── Port configuration (TRISA/B/C/D)
│   ├── ADCON1 → all-digital on PORTA
│   ├── Internal pull-ups on RB[4:7]
│   ├── UART setup (9600 bps, 8-N-1)
│   ├── EEPROM restore last character
│   └── Enable RBIF interrupt (GIE, PEIE, RBIE)
│
├── Display Refresh Loop (>50 Hz, column multiplexing @ ~2 ms/col)
│
└── ISR (Interrupt-on-Change on RB[4:7])
    ├── Save W and STATUS
    ├── Debounce (20 ms)
    ├── "Walking Zero" column scan to identify key
    ├── Decode character (SHIFT state aware)
    ├── Update display bitmap from lookup table
    ├── Transmit ASCII via UART
    ├── Write ASCII to EEPROM
    └── Restore W and STATUS
```

---

## 🖥️ Proteus Simulation

The Proteus schematic consists of two sub-circuits:

**Sheet 1 – MCU & Peripherals**
- `U1` PIC16F877A with oscillator, MCLR, and decoupling
- 5×7 red LED matrix on PORTA/PORTC
- `SW1` SPDT power switch
- `P1` COMPIM serial interface (COM1 @ 9600 baud) for UART output

**Sheet 2 – 4×8 Matrix Keypad**
- 32 push-button switches with diodes (phantom-key protection)
- Rows connected to RB[4:7] bus
- Columns connected to RD[0:7] bus

---

## 📂 Repository Structure
```
.
├── src/
│   └── keypad_display.c       # Main firmware (HI-TECH C)
├── docs/
│   ├── DOCUMENTATION.md       # Full technical documentation
│   └── font_bitmaps.md        # 5×7 character bitmap reference
├── proteus/
│   └── keypad_project.pdsprj  # Proteus simulation project
├── Circuit_Snapshot_1.png     # MCU & display sub-circuit
├── Circuit_Snapshot_2.png     # 4×8 keypad sub-circuit
└── README.md
```

---

## 🚀 Getting Started

### Prerequisites
- [MPLAB IDE](https://www.microchip.com/mplab) with **HI-TECH C** compiler
- [Proteus Design Suite](https://www.labcenter.com/) v8+
- Virtual serial port pair (e.g., com0com) for UART monitoring

### Build & Simulate
1. Open `src/keypad_display.c` in MPLAB and build → generates `keypad_display.hex`
2. Open `proteus/keypad_project.pdsprj` in Proteus
3. Load the `.hex` file into the PIC16F877A component
4. Run the simulation — press keys on the keypad and observe:
   - Character rendered on the 5×7 red LED matrix
   - ASCII byte transmitted on the virtual COM port terminal

---

## 📋 Key Design Decisions

| Decision | Rationale |
|---|---|
| Interrupt-on-Change (not polling) | Frees the CPU for continuous display refresh |
| 20 ms software debounce | Reliable across all mechanical switch types |
| "Walking Zero" column scan | Compatible with diodeless keypads; simple to implement |
| Column-multiplexed display @ 2 ms/col | Achieves >50 Hz refresh; eliminates visible flicker |
| EEPROM persistence | Character survives power cycles |
| ADCON1 = 0x06 | Forces PORTA to full digital I/O, disabling ADC on display pins |
| External pull-up on RA4 | RA4 is open-drain on PIC16F877A; cannot drive HIGH without it |
