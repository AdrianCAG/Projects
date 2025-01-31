#include "rfid1.h"  // Include the RFID library

RFID1 rfid; // Create an instance of the RFID1 class

void setup()
{
  Serial.begin(9600); // Initialize serial communication at 9600 baud
  Serial.println("Initializing RFID reader...");

  // Initialize RFID module with pin configuration
  rfid.begin(7, 5, 4, 3, 6, 2);  
  // (IRQ_PIN, SCK_PIN, MOSI_PIN, MISO_PIN, SDA_PIN, RST_PIN)

  delay(100); // Short delay for stability
  rfid.init(); // Initialize the RFID module

  Serial.println("RFID reader initialized.");
}

void loop()
{
  uchar status;
  uchar str[MAX_LEN]; // Buffer to store card data, max length 16

  // Search for a card in the reader’s field
  status = rfid.request(PICC_REQIDL, str);
  if (status != MI_OK)
  {
    return; // Exit loop if no card is detected
  }

  Serial.println("RFID card detected!");

  // Read the card type and display it
  Serial.print("Card type: ");
  Serial.println(rfid.readCardType(str));

  // Prevent conflicts and retrieve the 4-byte unique card ID
  status = rfid.anticoll(str);
  if (status == MI_OK)
  {
    Serial.print("Card ID: ");
    int IDlen = 4; // Standard UID length is 4 bytes
    for (int i = 0; i < IDlen; i++)
    {
      Serial.print(str[i], HEX); // Print the ID in hexadecimal format
      Serial.print(" "); // Add spacing for better readability
    }
    
    Serial.println(); // Newline for better output formatting
    Serial.println("Place a new card or remove the current one.");
    Serial.println("--------------------------------------");
  }

  delay(500); // Small delay before the next scan
  rfid.halt(); // Put the card into sleep mode to prevent re-reading
}
