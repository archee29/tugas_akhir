#include <ESP8266WiFi.h>
#include <FirebaseESP8266.h>
#include <NTPClient.h>
#include <WiFiUdp.h>
#include "addons/TokenHelper.h"
#include "addons/RTDBHelper.h"

// #define WIFI_SSID "Tugasakhir"
// #define WIFI_PASSWORD "wifisigit"
#define WIFI_SSID "HOME 2G"
#define WIFI_PASSWORD "wifirumah2"
#define API_KEY "AIzaSyD9cMliTs9G41vgRLcjS2VacvtMWWR1doQ"
#define DATABASE_URL "https://tugas-akhir-3c0d9-default-rtdb.asia-southeast1.firebasedatabase.app/"
#define USER_EMAIL "mhsigit01@gmail.com"
#define USER_PASSWORD "adminacf123"

WiFiUDP ntpUDP;
NTPClient timeClient(ntpUDP, "pool.ntp.org");

FirebaseData firebaseData;
FirebaseAuth auth;
FirebaseConfig config;

String uid;
String databasePath;

void initWiFi() {
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.print(".");
  }
}

void initFirebase() {
  config.api_key = API_KEY;
  auth.user.email = USER_EMAIL;
  auth.user.password = USER_PASSWORD;
  config.database_url = DATABASE_URL;

  Firebase.reconnectWiFi(true);
  config.token_status_callback = tokenStatusCallback;
  Firebase.begin(&config, &auth);

  while ((auth.token.uid) == "") {
    Serial.print(".");
    delay(1000);
  }
  uid = auth.token.uid.c_str();
  databasePath = "/UsersData/" + uid + "/iot/pengujianRTC/";
}

void processDataFromTransmitter() {
  static String inputBuffer = "";
  while (Serial.available() > 0) {
    char inChar = (char)Serial.read();
    if (inChar == '\n') {
      sendTestDataToFirebase(inputBuffer);
      inputBuffer = "";
    } else {
      inputBuffer += inChar;
    }
  }
}

void sendTestDataToFirebase(String testData) {
  timeClient.update();
  
  int separatorPos = testData.indexOf('#');
  
  if (separatorPos != -1) {
    String testNumber = testData.substring(0, separatorPos);
    String rtcTime = testData.substring(separatorPos + 1);
    
    String ntpTime = String(timeClient.getHours()) + ":" + 
                     String(timeClient.getMinutes()) + ":" + 
                     String(timeClient.getSeconds());
    
    int rtcHour = rtcTime.substring(0, rtcTime.indexOf('.')).toInt();
    int ntpHour = timeClient.getHours();
    int timeDifference = abs(ntpHour - rtcHour);
    
    FirebaseJson testJson;
    testJson.set("waktuRTC", rtcTime);
    testJson.set("waktuNTP", ntpTime);
    testJson.set("selisihWaktu", timeDifference);

    String fullPath = databasePath + testNumber;

    if (Firebase.setJSON(firebaseData, fullPath.c_str(), testJson)) {
      Serial.println("Test data sent successfully");
    } else {
      Serial.println("Failed to send test data: " + firebaseData.errorReason());
    }
  }
}

void setup() {
  Serial.begin(9600);
  initWiFi();
  initFirebase();
  timeClient.begin();
  timeClient.setTimeOffset(25200);
}

void loop() {
  if (Firebase.isTokenExpired()) {
    Firebase.refreshToken(&config);
  } 
  if (Firebase.ready()) {
    processDataFromTransmitter();
  }
}