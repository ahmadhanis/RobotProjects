
#include <Arduino.h>
#include <ESP8266WiFi.h>
#include <WiFiClient.h>
#include <Servo.h>
#include "minikame.h"
#include <ESP8266WebServer.h>
#include <EEPROM.h>

// Wifi Access Point configuration
String ssid = "";
String password = "";
ESP8266WebServer server(80);
void parseData(String data);
MiniKame robot;
int count = 0;
bool running = 0;
String input;


void setup() {
  Serial.begin(115200);
  //pinMode(D3, INPUT_PULLUP);
  readData();
  delay(1000);
  WiFi.mode(WIFI_AP);
  Serial.println(ssid);
  Serial.println(password);
  if (ssid.length() < 1) {
    ssid = "kame";
    password = "";
  }
  WiFi.softAP(ssid.c_str(), password.c_str());
  server.begin();
  robot.init();
  robot.home();

  server.on("/", handle_root);

  server.on("/0", []() {
    parseData("0");
    server.send(200, "text/plain", "ZERO");
  });

  server.on("/1", []() {
    parseData("1");
    server.send(200, "text/plain", "FORWARD");
  });

  server.on("/2", []() {
    parseData("2");
    server.send(200, "text/plain", "DOWN");
  });

  server.on("/3", []() {
    parseData("3");
    server.send(200, "text/plain", "LEFT");
  });

  server.on("/4", []() {
    parseData("4");
    server.send(200, "text/plain", "RIGTH");
  });

  server.on("/5", []() {
    parseData("5");
    server.send(200, "text/plain", "HOME");
  });

  server.on("/6", []() {
    parseData("6");
    server.send(200, "text/plain", "PUSH UP");
  });

  server.on("/7", []() {
    parseData("7");
    server.send(200, "text/plain", "UP DOWN");
  });

  server.on("/8", []() {
    parseData("8");
    server.send(200, "text/plain", "JUMP");
  });

  server.on("/9", []() {
    parseData("9");
    server.send(200, "text/plain", "HELLO");
  });

  server.on("/10", []() {
    parseData("10");
    server.send(200, "text/plain", "PUNCH");
  });

  server.on("/11", []() {
    parseData("11");
    server.send(200, "text/plain", "DANCE");
  });

  server.on("/12", []() {
    parseData("12");
    server.send(200, "text/plain", "MOONWALK");
  });

  server.on("/13", []() {
    parseData("13");
    server.send(200, "text/plain", "RUN");
  });

  server.on("/14", []() {
    parseData("14");
    server.send(200, "text/plain", "OMNI");
  });

  server.on("/15", []() {
    parseData("15");
    server.send(200, "text/plain", "INIT");
  });
  server.on("/16", []() {
    String ssidw = server.arg("ssid");
    String passw = server.arg("password");
    clearData();
    delay(100);
    writeData(ssidw, passw);
    server.send(200, "text/plain", "SUCCESS");
    delay(2000);
    ESP.restart();
  });
  server.on("/17", []() {
    clearData();
    server.send(200, "text/plain", "SUCCESS");
    delay(2000);
    ESP.restart();
  });

  server.begin();
  Serial.println("HTTP server started");

}

void handle_root() {
  server.send(200, "text/plain", "Robot is ready!!!");
  delay(100);
}


void loop() {
//  if (digitalRead(D3) == LOW) {
//    count++;
//    Serial.println("Flash Press");
//    delay(1000);
//    if (count > 3) {
//      clearData();
//      delay(2000);
//      ESP.restart();
//    }
//  }
  server.handleClient();

}

void parseData(String data) {

  switch (data.toInt()) {
    case 0: // Up
      robot.zero();
      Serial.println("ZERO");
      break;
    case 1: // Up
      robot.walk(4, 550);
      running = 0;
      Serial.println("FORWARD");
      break;

    case 2: // Down
      Serial.println("DOWN");
      break;

    case 3: // Left
      robot.turnL(3, 550);
      running = 1;
      Serial.println("LEFT");
      break;

    case 4: // Right
      robot.turnR(3, 550);
      running = 1;
      Serial.println("RIGHT");
      break;

    case 5: // HOME
      running = 0;
      robot.home();
      break;

    case 6: // pushup
      robot.pushUp(2, 1000);
      robot.home();
      break;

    case 7: // fire
      robot.upDown(4, 300);
      robot.home();
      break;

    case 8: // skull
      robot.jump();
      robot.home();
      break;

    case 9: // cross
      robot.hello();
      robot.home();
      break;

    case 10: // punch
      robot.frontBack(4, 300);
      robot.home();
      break;

    case 11: // mask
      robot.dance(2, 1000);
      robot.home();
      break;

    case 12: // moonwalk
      robot.moonwalkL(3, 3000);
      robot.home();
      break;

    case 13: // Run
      robot.run(5, 200);
      running = 1;
      break;

    case 14: // omniwalk
      robot.omniWalk(10, 500, true, 100);
      robot.home();
      running = 0;
      break;

    case 15: // init
      robot.init();
      running = 0;
      break;
    default:
      robot.home();
      break;
  }
}

void readData() {                                 //Read from EEPROM memory
  EEPROM.begin(512);
  Serial.println("Reading From EEPROM..");
  for (int i = 0; i < 20; i++) {                  //Reading for SSID max for 20 characters long
    if (char(EEPROM.read(i)) > 0) {
      ssid += char(EEPROM.read(i));
    }
  }
  for (int i = 20; i < 40; i++) {                 //Reading for WiFi password max for 40 characters long
    if (char(EEPROM.read(i)) > 0) {
      password += char(EEPROM.read(i));
    }
  }

  Serial.println("Wifi AP ssid: " + ssid);
  Serial.println("Wifi AP password: " + password);
  EEPROM.end();
}

void writeData(String a, String b) {              //Writing WiFi credentials to EEPROM
  clearData();                                    //Clear current EEPROM memory
  EEPROM.begin(512);
  Serial.println("Writing to EEPROM...");
  for (int i = 0; i < 20; i++) {                  //Writing for SSID max for 20 characters long
    EEPROM.write(i, a[i]);
  }
  for (int i = 20; i < 40; i++) {                 //Reading for password max for 40 characters long
    EEPROM.write(i, b[i - 20]);
    Serial.println(b[i]);
  }
  EEPROM.commit();
  EEPROM.end();
  Serial.println("Write Successfull");
}

void clearData() {                                //Clear current EEPROM memory function
  EEPROM.begin(512);
  Serial.println("Clearing EEPROM ");
  for (int i = 0; i < 512; i++) {
    Serial.print(".");
    EEPROM.write(i, 0);
  }
  EEPROM.commit();
  EEPROM.end();
}
