/*******************************************************************************
 * ESP8266 UART to MQTT Bridge
 * Project: Matrix Keypad & 5x7 LED Display System
 *******************************************************************************
 * Description:
 *   Receives ASCII codes from PIC16F877A via UART (9600 baud, 8N1)
 *   Publishes ASCII codes to MQTT broker for Android app consumption
 *   Provides visual LED feedback for connection and transmission status
 *   
 * Hardware:
 *   - ESP8266 Board: LOLIN WEMOS D1 R2 & mini
 *   - UART Connection: RX pin to PIC TX (RC6)
 *   - Baud Rate: 9600 bps, 8 data bits, No parity, 1 stop bit
 *   - LED: Built-in LED (GPIO2 on most boards) for status indication
 *   
 * WiFi Configuration:
 *   - SSID: "Joe Msann"
 *   - Password: "Joe12345"
 *   
 * MQTT Configuration:
 *   - Broker: broker.emqx.io
 *   - Port: 1883
 *   - Topic: "lab_micro_usek/ascii"
 *   - Client ID: "ESP8266_Keypad_Bridge"
 *   
 * LED Behavior:
 *   - Flashing (250ms interval): Connecting to WiFi/MQTT
 *   - Solid ON: Connected and ready
 *   - 3 fast flashes (50ms): Data transmitted successfully
 *   - Rapid flashing (100ms): Error, system restarting
 *   
 * Required Libraries:
 *   - ESP8266WiFi (built-in)
 *   - PubSubClient (install via Library Manager)
 *   
 * Author: Generated for GEL558 Final Project
 * Date: December 2024
 ******************************************************************************/

#include <ESP8266WiFi.h>
#include <PubSubClient.h>

// ============================================================================
// CONFIGURATION CONSTANTS
// ============================================================================

// WiFi Credentials
const char* WIFI_SSID = "Joe Msann";
const char* WIFI_PASSWORD = "Joe12345";

// MQTT Configuration
const char* MQTT_BROKER = "broker.emqx.io";
const int MQTT_PORT = 1883;
const char* MQTT_CLIENT_ID = "ESP8266_Keypad_Bridge";
const char* MQTT_TOPIC_ASCII = "lab_micro_usek/ascii";

// UART Configuration
const long UART_BAUD_RATE = 9600;

// LED Configuration
const int LED_PIN = LED_BUILTIN;          // Built-in LED (GPIO2 on most ESP8266 boards)
const int LED_FLASH_INTERVAL = 250;       // ms for connection flashing
const int LED_FAST_FLASH_DURATION = 50;   // ms for transmission flash

// Connection Retry Configuration
const int WIFI_RETRY_DELAY = 500;        // ms between WiFi connection attempts
const int MQTT_RETRY_DELAY = 5000;       // ms between MQTT connection attempts
const int MAX_CONNECTION_ATTEMPTS = 20;   // Max attempts before restart

// ============================================================================
// GLOBAL OBJECTS
// ============================================================================

WiFiClient wifiClient;
PubSubClient mqttClient(wifiClient);

// LED state tracking
unsigned long lastLEDToggle = 0;
bool ledState = false;

// ============================================================================
// FUNCTION DECLARATIONS
// ============================================================================

void setupWiFi();
void setupMQTT();
void reconnectMQTT();
void processIncomingUART();
void publishASCII(uint8_t asciiCode);
void ledFlashConnecting();
void ledStatic(bool state);
void ledFlashTransmit();

// ============================================================================
// SETUP FUNCTION
// ============================================================================

void setup() {
  // Initialize Serial for debugging (USB) and UART for PIC communication
  Serial.begin(UART_BAUD_RATE);
  
  // Initialize LED pin
  pinMode(LED_PIN, OUTPUT);
  digitalWrite(LED_PIN, HIGH);  // LED OFF (most ESP8266 LEDs are active LOW)
  
  // Small delay for serial to stabilize
  delay(100);
  
  Serial.println("\n\n========================================");
  Serial.println("ESP8266 UART to MQTT Bridge");
  Serial.println("GEL558 Final Project");
  Serial.println("========================================\n");
  
  // Connect to WiFi (LED will flash during connection)
  setupWiFi();
  
  // Configure MQTT (LED will flash during connection)
  setupMQTT();
  
  // Connection successful - LED stays ON
  ledStatic(true);
  
  Serial.println("\n[INFO] System initialized successfully");
  Serial.println("[INFO] Waiting for UART data from PIC...\n");
}

// ============================================================================
// MAIN LOOP
// ============================================================================

void loop() {
  // Ensure MQTT connection is maintained
  if (!mqttClient.connected()) {
    reconnectMQTT();
  }
  mqttClient.loop();
  
  // Process incoming UART data from PIC
  processIncomingUART();
}

// ============================================================================
// WiFi SETUP FUNCTION
// ============================================================================

void setupWiFi() {
  Serial.print("[WIFI] Connecting to: ");
  Serial.println(WIFI_SSID);
  
  // Start WiFi connection
  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  
  int attempts = 0;
  while (WiFi.status() != WL_CONNECTED && attempts < MAX_CONNECTION_ATTEMPTS) {
    // Flash LED while connecting
    ledFlashConnecting();
    delay(WIFI_RETRY_DELAY);
    Serial.print(".");
    attempts++;
  }
  
  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("\n[WIFI] Connected successfully!");
    Serial.print("[WIFI] IP Address: ");
    Serial.println(WiFi.localIP());
    Serial.print("[WIFI] Signal Strength (RSSI): ");
    Serial.print(WiFi.RSSI());
    Serial.println(" dBm");
  } else {
    Serial.println("\n[ERROR] WiFi connection failed!");
    Serial.println("[ERROR] Restarting ESP8266...");
    
    // Flash LED rapidly to indicate error before restart
    for (int i = 0; i < 10; i++) {
      ledFlashConnecting();
      delay(100);
    }
    
    delay(3000);
    ESP.restart();
  }
}

// ============================================================================
// MQTT SETUP FUNCTION
// ============================================================================

void setupMQTT() {
  mqttClient.setServer(MQTT_BROKER, MQTT_PORT);
  
  Serial.print("[MQTT] Configured broker: ");
  Serial.print(MQTT_BROKER);
  Serial.print(":");
  Serial.println(MQTT_PORT);
  
  // Initial connection attempt
  reconnectMQTT();
}

// ============================================================================
// MQTT RECONNECTION FUNCTION
// ============================================================================

void reconnectMQTT() {
  int attempts = 0;
  
  while (!mqttClient.connected() && attempts < MAX_CONNECTION_ATTEMPTS) {
    Serial.print("[MQTT] Attempting connection... ");
    
    // Flash LED while connecting
    ledFlashConnecting();
    
    // Attempt to connect with clean session
    if (mqttClient.connect(MQTT_CLIENT_ID)) {
      Serial.println("Connected!");
      Serial.print("[MQTT] Client ID: ");
      Serial.println(MQTT_CLIENT_ID);
      Serial.print("[MQTT] Publishing to topic: ");
      Serial.println(MQTT_TOPIC_ASCII);
      
      // LED stays ON when connected
      ledStatic(true);
      return;
    } else {
      Serial.print("Failed, rc=");
      Serial.print(mqttClient.state());
      Serial.print(" | Retrying in ");
      Serial.print(MQTT_RETRY_DELAY / 1000);
      Serial.println(" seconds...");
      
      attempts++;
      
      // Flash LED during retry delay
      unsigned long startTime = millis();
      while (millis() - startTime < MQTT_RETRY_DELAY) {
        ledFlashConnecting();
        delay(LED_FLASH_INTERVAL);
      }
    }
  }
  
  // If max attempts reached, restart ESP
  if (!mqttClient.connected()) {
    Serial.println("\n[ERROR] MQTT connection failed after max attempts!");
    Serial.println("[ERROR] Restarting ESP8266...");
    
    // Flash LED rapidly to indicate error before restart
    for (int i = 0; i < 10; i++) {
      ledFlashConnecting();
      delay(100);
    }
    
    delay(3000);
    ESP.restart();
  }
}

// ============================================================================
// UART DATA PROCESSING FUNCTION
// ============================================================================

void processIncomingUART() {
  // Check if data is available from PIC via UART
  if (Serial.available() > 0) {
    // Read one byte (ASCII code from PIC)
    uint8_t asciiCode = Serial.read();
    
    // Validate ASCII code (printable characters: 42-122 based on PIC lookup table)
    if (asciiCode >= 42 && asciiCode <= 122) {
      // Print to debug console
      Serial.print("[UART] Received ASCII code: ");
      Serial.print(asciiCode);
      Serial.print(" (Character: '");
      Serial.print((char)asciiCode);
      Serial.println("')");
      
      // Publish to MQTT
      publishASCII(asciiCode);
    } else {
      // Invalid ASCII code received
      Serial.print("[WARNING] Invalid ASCII code received: ");
      Serial.println(asciiCode);
    }
  }
}

// ============================================================================
// MQTT PUBLISH FUNCTION
// ============================================================================

void publishASCII(uint8_t asciiCode) {
  // Convert ASCII code to string for MQTT payload
  char payload[4];  // Max 3 digits + null terminator
  sprintf(payload, "%d", asciiCode);
  
  // Publish with QoS 0 (fire and forget - fastest)
  bool success = mqttClient.publish(MQTT_TOPIC_ASCII, payload, false);
  
  if (success) {
    Serial.print("[MQTT] Published successfully: ");
    Serial.println(payload);
    
    // Flash LED 3 times quickly to indicate transmission
    ledFlashTransmit();
  } else {
    Serial.println("[ERROR] MQTT publish failed!");
    // Connection might be lost, will reconnect in next loop
  }
}

/*******************************************************************************
 * MQTT STATE CODES (for debugging):
 *   -4 : MQTT_CONNECTION_TIMEOUT - the server didn't respond within the keepalive time
 *   -3 : MQTT_CONNECTION_LOST - the network connection was broken
 *   -2 : MQTT_CONNECT_FAILED - the network connection failed
 *   -1 : MQTT_DISCONNECTED - the client is disconnected cleanly
 *    0 : MQTT_CONNECTED - the client is connected
 *    1 : MQTT_CONNECT_BAD_PROTOCOL - the server doesn't support the requested version of MQTT
 *    2 : MQTT_CONNECT_BAD_CLIENT_ID - the server rejected the client identifier
 *    3 : MQTT_CONNECT_UNAVAILABLE - the server was unable to accept the connection
 *    4 : MQTT_CONNECT_BAD_CREDENTIALS - the username/password were rejected
 *    5 : MQTT_CONNECT_UNAUTHORIZED - the client was not authorized to connect
 ******************************************************************************/

// ============================================================================
// LED HELPER FUNCTIONS
// ============================================================================

/**
 * Flash LED while connecting (toggles LED state)
 * Called repeatedly during WiFi and MQTT connection attempts
 */
void ledFlashConnecting() {
  unsigned long currentMillis = millis();
  
  // Toggle LED at defined interval
  if (currentMillis - lastLEDToggle >= LED_FLASH_INTERVAL) {
    lastLEDToggle = currentMillis;
    ledState = !ledState;
    
    // Note: Most ESP8266 built-in LEDs are active LOW
    // LOW = LED ON, HIGH = LED OFF
    digitalWrite(LED_PIN, ledState ? LOW : HIGH);
  }
}

/**
 * Set LED to static state (ON or OFF)
 * Used when connection is established or failed
 * 
 * @param state - true for LED ON (connected), false for LED OFF
 */
void ledStatic(bool state) {
  // Note: Most ESP8266 built-in LEDs are active LOW
  // LOW = LED ON, HIGH = LED OFF
  digitalWrite(LED_PIN, state ? LOW : HIGH);
  ledState = state;
}

/**
 * Flash LED 3 times quickly to indicate data transmission
 * Blocking function that takes ~300ms to complete
 */
void ledFlashTransmit() {
  // Save current LED state
  bool originalState = ledState;
  
  // Flash 3 times
  for (int i = 0; i < 3; i++) {
    digitalWrite(LED_PIN, LOW);   // LED ON (active LOW)
    delay(LED_FAST_FLASH_DURATION);
    digitalWrite(LED_PIN, HIGH);  // LED OFF (active LOW)
    delay(LED_FAST_FLASH_DURATION);
  }
  
  // Restore original LED state (should be ON if connected)
  digitalWrite(LED_PIN, originalState ? LOW : HIGH);
}

/*******************************************************************************
 * LED BEHAVIOR SUMMARY:
 * 
 * 1. CONNECTING (WiFi/MQTT):
 *    - LED flashes at 250ms intervals (2 Hz)
 *    - Continues until connection established or failed
 * 
 * 2. CONNECTED:
 *    - LED stays ON (solid)
 *    - Indicates system ready to receive/transmit data
 * 
 * 3. TRANSMITTING:
 *    - 3 fast flashes (50ms ON, 50ms OFF each)
 *    - Total duration: ~300ms
 *    - Returns to solid ON after transmission
 * 
 * 4. ERROR (Connection Failed):
 *    - Rapid flashing (10 flashes at 100ms intervals)
 *    - Indicates system will restart
 * 
 * NOTE: Most ESP8266 boards use active-LOW LEDs
 *       - digitalWrite(LOW) turns LED ON
 *       - digitalWrite(HIGH) turns LED OFF
 ******************************************************************************/

/*******************************************************************************
 * UPLOAD INSTRUCTIONS:
 * 
 * 1. Install Required Libraries:
 *    - Tools > Manage Libraries
 *    - Search for "PubSubClient" by Nick O'Leary
 *    - Click Install
 * 
 * 2. Select Board:
 *    - Tools > Board > ESP8266 Boards > LOLIN(WEMOS) D1 R2 & mini
 *    - OR your specific ESP8266 board variant
 * 
 * 3. Configure Upload Settings:
 *    - Tools > Upload Speed: 115200
 *    - Tools > CPU Frequency: 80 MHz
 *    - Tools > Flash Size: 4MB (depending on your board)
 * 
 * 4. Select COM Port:
 *    - Tools > Port > [Your ESP8266 COM port]
 * 
 * 5. Upload:
 *    - Click Upload button (→)
 *    - Wait for "Done uploading" message
 * 
 * 6. Monitor Serial Output & LED Behavior:
 *    - Tools > Serial Monitor
 *    - Set baud rate to 9600
 *    - Observe LED during startup:
 *      • Flashing = Connecting to WiFi/MQTT
 *      • Solid ON = Connected and ready
 *      • 3 fast flashes = Data transmitted
 * 
 * LED TROUBLESHOOTING:
 *    - If LED doesn't light up, your board may use different LED pin
 *    - Check your board documentation for built-in LED pin
 *    - Modify LED_PIN constant if needed (GPIO2 is default)
 *    - Some boards use active-HIGH LEDs (swap LOW/HIGH in code)
 * 
 * PROTEUS SIMULATION:
 *    - Use COMPIM component in Proteus
 *    - Connect PIC TX (RC6) to COMPIM TXD
 *    - Set COMPIM Physical Port to match your ESP8266 COM port
 *    - Set Virtual Baud Rate to 9600
 *    - Run Proteus simulation and ESP8266 together
 *    - Watch LED for visual feedback:
 *      • Flashing during startup
 *      • Solid when ready
 *      • 3 quick flashes when key pressed in Proteus
 ******************************************************************************/
