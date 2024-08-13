#include <WiFi.h>
#include <WebServer.h>
#include <ArduinoJson.h>
// This script uses pin numbering "by Arduino (default). Not by GPIO (legacy)!"

// Access Point credentials
const char* ssid = "ESP32_AccessPoint";
const char* password = "12345678";

// Web server on port 80
WebServer server(80);

// Struct to hold general variables
struct VarGeneral {
  int operationMode = 1;        // 0, 1, 2, 3
} varGeneral;

// Struct to hold driving-related variables
struct VarDriving {
  int acceleration = 0;  // 0 (stop) to 1000 (max)
  int steering = 0;      // -1000 (left) to 1000 (right)
} varDriving;

// Utility function to send HTTP response with custom status code
void sendResponse(int statusCode, const String& message, int value) {
  DynamicJsonDocument doc(1024);
  doc["message"] = message;
  doc["value"] = value;
  String responseBody;
  serializeJson(doc, responseBody);
  server.send(statusCode, "application/json", responseBody);
}


// Utility function to get HTML form for testing purposes
String getHtmlForm(const String& label, const String& id, const String& name, const String& value, const String& submitValue) {
  return "<form action=\"/" + id + "\" method=\"get\">"
         "<label for=\"" + id + "\">" + label + ":</label><br>"
         "<input type=\"text\" id=\"" + id + "\" name=\"" + name + "\" value=\"" + value + "\"><br><br>"
         "<input type=\"submit\" value=\"" + submitValue + "\">"
         "</form><br>";
}


// Main page of the web interface for testing
void handleRoot() {
  String html = "<html><body><h1>ESP32 Control</h1>"
                "<p>Acceleration: " + String(varDriving.acceleration) + "</p>"
                "<p>Steering: " + String(varDriving.steering) + "</p>"
                "<p>Operation Mode: " + String(varGeneral.operationMode) + "</p>"
                + getHtmlForm("Acceleration (0 to 1000)", "setAcceleration", "value", String(varDriving.acceleration), "Set Acceleration")
                + getHtmlForm("Steering (-1000 to 1000)", "setSteering", "value", String(varDriving.steering), "Set Steering")
                + getHtmlForm("Operation Mode (1, 2, 3)", "setOperationMode", "value", String(varGeneral.operationMode), "Set Operation Mode")
                + "</body></html>";
  server.send(200, "text/html", html);
}


// Handle setting acceleration
void setAcceleration() {
  int value = server.arg("value").toInt();
  if (value >= -1000 && value <= 1000) {
    varDriving.acceleration = value;
    sendResponse(200, "Acceleration set to ", varDriving.acceleration);
  } else {
    sendResponse(400, "Invalid acceleration value", varDriving.acceleration);
  }
}

// Handle setting steering
void setSteering() {
  int value = server.arg("value").toInt();
  if (value >= -1000 && value <= 1000) {
    varDriving.steering = value;
    sendResponse(200, "Steering set to ", varDriving.steering);
  } else {
    sendResponse(400, "Invalid steering value", varDriving.steering);
  }
}

// Handle setting operation mode
void setOperationMode() {
  int value = server.arg("value").toInt();
  if (value >= 1 && value <= 3) {
    varGeneral.operationMode = value;
    sendResponse(200, "Operation Mode set to ", varGeneral.operationMode);
  } else {
    sendResponse(400, "Invalid operation mode value", varGeneral.operationMode);
  }
}

// Handle setting acceleration and steering
void setAccSteer() {
  int accelValue = server.arg("acceleration").toInt();
  int steerValue = server.arg("steering").toInt();

 // Validate acceleration value
  if (accelValue < 0 || accelValue > 1000) {
    sendResponse(400, "Invalid acceleration value", varDriving.acceleration);
    return;
  }

  // Validate steering value
  if (steerValue < -1000 || steerValue > 1000) {
    sendResponse(400, "Invalid steering value", varDriving.steering);
    return;
  }

  // Set the values in the struct
  varDriving.acceleration = accelValue;
  varDriving.steering = steerValue;

  // Send success response with current values
  DynamicJsonDocument doc(1024);
  doc["message"] = "Acceleration and Steering set";
  doc["acceleration"] = varDriving.acceleration;
  doc["steering"] = varDriving.steering;
  String responseBody;
  serializeJson(doc, responseBody);
  server.send(200, "application/json", responseBody);
}

void setup() {
  Serial.begin(115200);

  // Set up Access Point
  WiFi.softAP(ssid, password);
  Serial.println("Access Point Started");
  Serial.print("IP Address: ");
  Serial.println(WiFi.softAPIP());

  // HTTP endpoints
  // Commands get send from mobile device via Wifi to these adresses: Example: http://192.168.4.1:80/acceleration?value=100
  server.on("/", handleRoot); // Root endpoint
  
  server.on("/setOperationMode", setOperationMode); // Endpoint for operation mode
  server.on("/setAcceleration", setAcceleration); // Endpoint for acceleration
  server.on("/setSteering", setSteering); // Endpoint for steering
  server.on("/setAccSteer", setAccSteer); // Endpoint for steering and acceleration)

  server.begin();
  Serial.println("HTTP server started");
}

// Loop function runs continuously after setup
void loop() {
  server.handleClient(); // Handles incoming client requests
}