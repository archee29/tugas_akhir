#include <ESP8266WiFi.h>
#include <FirebaseESP8266.h>
#include "addons/TokenHelper.h"
#include "addons/RTDBHelper.h"
#include <NTPClient.h>
#include <WiFiUdp.h>
#include <TimeLib.h>

#define WIFI_SSID "Tugasakhir"
#define WIFI_PASSWORD "wifisigit"
// #define WIFI_SSID "HOME 2G"
// #define WIFI_PASSWORD "wifirumah2"
#define API_KEY "AIzaSyD9cMliTs9G41vgRLcjS2VacvtMWWR1doQ"
#define DATABASE_URL "https://tugas-akhir-3c0d9-default-rtdb.asia-southeast1.firebasedatabase.app/"
#define USER_EMAIL "mhsigit01@gmail.com"
#define USER_PASSWORD "adminacf123"

WiFiUDP ntpUDP;
NTPClient timeClient(ntpUDP, "pool.ntp.org");

FirebaseData firebaseData;
FirebaseAuth auth;
FirebaseConfig config;
FirebaseJson monitoringJson;
FirebaseJson feederJson;
FirebaseJsonData jsonData;

String uid, databasePath;

bool lastPumpControl = false;
bool lastServoControl = false;

int putaranServo = 4;
int waktuPump = 5;

// Structure to hold user schedule data
struct UserSchedule {
  bool exists;
  String feedingType;
  int hour;
  int minute;
  String date;
};

unsigned long sendDataMonitoringToFirebasePrevMillis = 0;
unsigned long sendDataMonitoringToFirebaseDelay = 3000;

unsigned long sendDataFeedingToFirebasePrevMillis = 0;
unsigned long sendDataFeedingToFirebasePrevDelay = 1000;

unsigned long receiveDataControlFromFirebasePrevMillis = 0;
unsigned long receiveDataControlFromFirebaseDelay = 1000;

unsigned long receiveDataControlFromTransmitterPrevMillis = 0;
unsigned long receiveDataControlFromTransmitterDelay = 1000;

// New timer for schedule check
unsigned long checkSchedulePrevMillis = 0;
unsigned long checkScheduleDelay = 60000; // Check every minute

struct TimeComponents {
  int hour;
  int minute;
  int second;
};

void initWiFi() {
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Mencoba Menghubungkan ke WiFi");
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print('.');
    delay(1000);
  }
  Serial.println();
  Serial.println("Terhubung dengan IP ADDRESS : ");
  Serial.println(WiFi.localIP());
}

void initFirebase() {
  config.api_key = API_KEY;
  auth.user.email = USER_EMAIL;
  auth.user.password = USER_PASSWORD;
  config.database_url = DATABASE_URL;

  Firebase.reconnectWiFi(true);
  firebaseData.setResponseSize(4096);

  config.token_status_callback = tokenStatusCallback;
  config.max_token_generation_retry = 5;
  Firebase.begin(&config, &auth);

  Serial.println("Mendapatkan User UID");
  while ((auth.token.uid) == "") {
    Serial.print(".");
    delay(1000);
  }
  uid = auth.token.uid.c_str();
  Serial.print("User UID : ");
  Serial.print(uid);
  Serial.println();
  databasePath = "/UsersData/" + uid;
}

void initNTP() {
  timeClient.begin();
  timeClient.setTimeOffset(25200);
  timeClient.update();
}

TimeComponents parseTime(String timeStr) {
  TimeComponents tc;
  int firstColon = timeStr.indexOf(':');
  int secondColon = timeStr.lastIndexOf(':');

  tc.hour = timeStr.substring(0, firstColon).toInt();
  tc.minute = timeStr.substring(firstColon + 1, secondColon).toInt();
  tc.second = timeStr.substring(secondColon + 1).toInt();

  return tc;
}

int calculateTimeDifference(String rtcTime) {
  TimeComponents rtc = parseTime(rtcTime);

  timeClient.update();
  int ntpHour = timeClient.getHours();
  int ntpMinute = timeClient.getMinutes();
  int ntpSecond = timeClient.getSeconds();

  int rtcTotalSeconds = rtc.hour * 3600 + rtc.minute * 60 + rtc.second;
  int ntpTotalSeconds = ntpHour * 3600 + ntpMinute * 60 + ntpSecond;

  return abs(ntpTotalSeconds - rtcTotalSeconds);
}

String getNTPTime() {
  timeClient.update();
  char timeString[9];
  sprintf(timeString, "%02d:%02d:%02d",
          timeClient.getHours(),
          timeClient.getMinutes(),
          timeClient.getSeconds());
  return String(timeString);
}

void processDataTransmitter() {
  static String inputBuffer = "";
  while (Serial.available() > 0) {
    char inChar = (char)Serial.read();
    if (inChar == '\n') {
      receivedDataFromTransmitter(inputBuffer);
      inputBuffer = "";
    } else {
      inputBuffer += inChar;
    }
  }
}

void receivedDataFromTransmitter(String message) {
  message.trim();
  if (message.startsWith("monitoring#")) {
    message.remove(0, 11);
    int separatorPos[4];
    int count = 0;
    for (int i = 0; i < message.length() && count < 4; i++) {
      if (message.charAt(i) == '#') {
        separatorPos[count] = i;
        count++;
      }
    }
    if (count == 4) {
      int beratWadah = message.substring(0, separatorPos[0]).toInt();
      int volumeAirWadah = message.substring(separatorPos[0] + 1, separatorPos[1]).toInt();
      int volumeAirTabung = message.substring(separatorPos[1] + 1, separatorPos[2]).toInt();
      String ketHari = message.substring(separatorPos[2] + 1, separatorPos[3]);
      String ketWaktu = message.substring(separatorPos[3] + 1);

      sendDataMonitoringToFirebase(beratWadah, volumeAirWadah, volumeAirTabung, ketHari, ketWaktu);
    }
  } else if (message.startsWith("feeding#")) {
    message.remove(0, 8);
    int separatorPos[9]; // Updated to handle feedingType
    int count = 0;
    for (int i = 0; i < message.length() && count < 9; i++) {
      if (message.charAt(i) == '#') {
        separatorPos[count] = i;
        count++;
      }
    }
    if (count >= 8) { // Can handle both old and new formats
      String waktuFeeding = message.substring(0, separatorPos[0]);
      int beratWadah = message.substring(separatorPos[0] + 1, separatorPos[1]).toInt();
      int volumeAirWadah = message.substring(separatorPos[1] + 1, separatorPos[2]).toInt();
      int volumeAirTabung = message.substring(separatorPos[2] + 1, separatorPos[3]).toInt();
      String ketHari = message.substring(separatorPos[3] + 1, separatorPos[4]);
      String ketWaktu = message.substring(separatorPos[4] + 1, separatorPos[5]);
      String pumpStatusStr = message.substring(separatorPos[5] + 1, separatorPos[6]);
      String servoStatusStr = message.substring(separatorPos[6] + 1, separatorPos[7]);

      // Get feedingType (bySystem or byApplication)
      String feedingType = "bySystem"; // Default
      if (count == 9) {
        feedingType = message.substring(separatorPos[7] + 1, separatorPos[8]);
      }

      bool pumpStatus = (pumpStatusStr == "1");
      bool servoStatus = (servoStatusStr == "1");

      String formattedDate = formatDate(ketHari);
      if (waktuFeeding == "jadwalPagi" || waktuFeeding == "jadwalSore") {
        sendDataFeedingToFirebase(waktuFeeding, beratWadah, volumeAirWadah, volumeAirTabung, ketHari, ketWaktu, formattedDate, pumpStatus, servoStatus, feedingType);
      } else {
        Serial.println("Error: Invalid waktuFeeding value: " + waktuFeeding);
      }
    }
  } else if (message == "Pump_OFF" || message == "Servo_OFF") {
    updateFirebaseControlStatus(message);
  } else if (message.startsWith("RequestSchedule#")) {
    String requestDate = message.substring(15);
    checkAndSendTodaySchedule(requestDate);
  }
}

void sendDataMonitoringToFirebase(int beratWadah, int volumeAirWadah, int volumeAirTabung, String ketHari, String ketWaktu) {
  unsigned long currentMillis = millis();
  if (currentMillis - sendDataMonitoringToFirebasePrevMillis >= sendDataMonitoringToFirebaseDelay) {
    sendDataMonitoringToFirebasePrevMillis = currentMillis;

    String waktuNTP = getNTPTime();
    int selisihWaktu = calculateTimeDifference(ketWaktu);

    monitoringJson.clear();
    monitoringJson.set("beratWadah", beratWadah);
    monitoringJson.set("volumeMLWadah", volumeAirWadah);
    monitoringJson.set("volumeMLTabung", volumeAirTabung);
    monitoringJson.set("ketHari", ketHari);
    monitoringJson.set("ketWaktu", ketWaktu);
    monitoringJson.set("waktuNTP", waktuNTP);
    monitoringJson.set("selisihWaktu", selisihWaktu);

    if (Firebase.updateNode(firebaseData, databasePath + "/UsersProfile/iot/monitoring", monitoringJson)) {
      Serial.println("PASSED");
      Serial.println("PATH: " + firebaseData.dataPath());
      Serial.println("TYPE: " + firebaseData.dataType());
      Serial.println("ETag: " + firebaseData.ETag());
      Serial.println();
    } else {
      Serial.println("FAILED");
      Serial.println("REASON: " + firebaseData.errorReason());
      Serial.println();
    }
  }
}

String formatDate(String date) {
  // Convert from DD/MM/YYYY to MM-DD-YYYY format
  int firstSlash = date.indexOf('/');
  int secondSlash = date.lastIndexOf('/');

  if (firstSlash > 0 && secondSlash > firstSlash) {
    String day = date.substring(0, firstSlash);
    String month = date.substring(firstSlash + 1, secondSlash);
    String year = date.substring(secondSlash + 1);

    // Ensure day and month have two digits
    if (day.length() == 1) day = "0" + day;
    if (month.length() == 1) month = "0" + month;

    return month + "-" + day + "-" + year;
  }

  return date; // Return original if format doesn't match
}

void sendDataFeedingToFirebase(String waktuFeeding, int beratWadah, int volumeAirWadah, int volumeAirTabung, String ketHari, String ketWaktu, String formattedDate, bool pumpStatus, bool servoStatus, String feedingType) {
  unsigned long currentMillis = millis();
  if (currentMillis - sendDataFeedingToFirebasePrevMillis >= sendDataFeedingToFirebasePrevDelay) {
    sendDataFeedingToFirebasePrevMillis = currentMillis;

    String waktuNTP = getNTPTime();
    int selisihWaktu = calculateTimeDifference(ketWaktu);

    feederJson.clear();
    feederJson.set("beratWadah", beratWadah);
    feederJson.set("volumeMLWadah", volumeAirWadah);
    feederJson.set("volumeMLTabung", volumeAirTabung);
    feederJson.set("ketHari", ketHari);
    feederJson.set("ketWaktu", ketWaktu);
    feederJson.set("waktuNTP", waktuNTP);
    feederJson.set("selisihWaktu", selisihWaktu);
    feederJson.set("pumpStatus", pumpStatus);
    feederJson.set("servoStatus", servoStatus);
    feederJson.set("feedingType", feedingType);

    String feedingPath = databasePath + "/UsersProfile/iot/feeder/" + waktuFeeding + "/" + formattedDate;

    if (Firebase.setJSON(firebaseData, feedingPath, feederJson)) {
      Serial.println("PASSED");
      Serial.println("PATH: " + firebaseData.dataPath());
      Serial.println("TYPE: " + firebaseData.dataType());
      Serial.println("ETag: " + firebaseData.ETag());
      Serial.println();
    } else {
      Serial.println("FAILED");
      Serial.println("REASON: " + firebaseData.errorReason());
      Serial.println();
    }
  }
}

void updateFirebaseControlStatus(String command) {
  if (command == "Pump_OFF") {
    if (Firebase.setBool(firebaseData, databasePath + "/UsersProfile/iot/control/pumpStatus", false)) {
      Serial.println("Pump Status Updated to OFF");
    } else {
      Serial.println("FAILED to update Pump Status");
      Serial.println("REASON: " + firebaseData.errorReason());
    }
  } else if (command == "Servo_OFF") {
    if (Firebase.setBool(firebaseData, databasePath + "/UsersProfile/iot/control/servoStatus", false)) {
      Serial.println("Servo Status Updated to OFF");
    } else {
      Serial.println("FAILED to update Servo Status");
      Serial.println("REASON: " + firebaseData.errorReason());
    }
  }
}

// Function to check and retrieve today's feeding schedule from Firebase
void checkAndSendTodaySchedule(String requestDate) {
  // Convert DD/MM/YYYY to MM-DD-YYYY for Firebase path
  String formattedDate = formatDate(requestDate);
  Serial.println("Checking schedule for date: " + formattedDate);

  // First check jadwalPagi for user-defined schedule
  String morningPath = databasePath + "/UsersProfile/iot/feeder/jadwalPagi/" + formattedDate;

  if (Firebase.getJSON(firebaseData, morningPath)) {
    FirebaseJson &json = firebaseData.jsonObject();
    FirebaseJsonData feedingTypeData;
    FirebaseJsonData ketWaktuData;

    json.get(feedingTypeData, "feedingType");
    json.get(ketWaktuData, "ketWaktu");

    if (feedingTypeData.success && feedingTypeData.stringValue == "byApplication" && ketWaktuData.success) {
      // Parse the time from ketWaktu format (H:M:S)
      TimeComponents tc = parseTime(ketWaktuData.stringValue);

      // Send schedule to Arduino (exists, feedingType, hour, minute)
      String scheduleCommand = "Schedule#1#byApplication#" + String(tc.hour) + "#" + String(tc.minute);
      Serial.println(scheduleCommand);
      return; // Found and sent a morning application schedule
    }
  }

  // Then check jadwalSore for user-defined schedule
  String eveningPath = databasePath + "/UsersProfile/iot/feeder/jadwalSore/" + formattedDate;

  if (Firebase.getJSON(firebaseData, eveningPath)) {
    FirebaseJson &json = firebaseData.jsonObject();
    FirebaseJsonData feedingTypeData;
    FirebaseJsonData ketWaktuData;

    json.get(feedingTypeData, "feedingType");
    json.get(ketWaktuData, "ketWaktu");

    if (feedingTypeData.success && feedingTypeData.stringValue == "byApplication" && ketWaktuData.success) {
      // Parse the time from ketWaktu format (H:M:S)
      TimeComponents tc = parseTime(ketWaktuData.stringValue);

      // Send schedule to Arduino (exists, feedingType, hour, minute)
      String scheduleCommand = "Schedule#1#byApplication#" + String(tc.hour) + "#" + String(tc.minute);
      Serial.println(scheduleCommand);
      return; // Found and sent an evening application schedule
    }
  }

  // If no user schedule found, inform Arduino there's no custom schedule today
  Serial.println("Schedule#0#none#0#0");
}

void receiveDataControlFromFirebase() {
  unsigned long currentMillis = millis();
  if (currentMillis - receiveDataControlFromFirebasePrevMillis >= receiveDataControlFromFirebaseDelay) {
    receiveDataControlFromFirebasePrevMillis = currentMillis;

    // Check for pump control
    if (Firebase.getBool(firebaseData, databasePath + "/UsersProfile/iot/control/pumpStatus")) {
      bool currentPumpControl = firebaseData.boolData();
      if (currentPumpControl != lastPumpControl) {
        lastPumpControl = currentPumpControl;
        if (currentPumpControl) {
          Serial.println("Pump_ON");
        } else {
          // No need to send Pump_OFF as it will be sent by the Arduino
        }
      }
    }

    // Check for servo control
    if (Firebase.getBool(firebaseData, databasePath + "/UsersProfile/iot/control/servoStatus")) {
      bool currentServoControl = firebaseData.boolData();
      if (currentServoControl != lastServoControl) {
        lastServoControl = currentServoControl;
        if (currentServoControl) {
          Serial.println("Servo_ON");
        } else {
          // No need to send Servo_OFF as it will be sent by the Arduino
        }
      }
    }

    // Check for servo rotation updates
    if (Firebase.getInt(firebaseData, databasePath + "/UsersProfile/iot/control/putaranServo")) {
      int newPutaranServo = firebaseData.intData();
      if (newPutaranServo != putaranServo) {
        putaranServo = newPutaranServo;
        Serial.println("ServoRotation#" + String(putaranServo));
      }
    }

    // Check for pump duration updates
    if (Firebase.getInt(firebaseData, databasePath + "/UsersProfile/iot/control/waktuPump")) {
      int newWaktuPump = firebaseData.intData();
      if (newWaktuPump != waktuPump) {
        waktuPump = newWaktuPump;
        Serial.println("PumpDuration#" + String(waktuPump));
      }
    }
  }
}

// Function to periodically check and process user schedules
void checkUserSchedules() {
  unsigned long currentMillis = millis();
  if (currentMillis - checkSchedulePrevMillis >= checkScheduleDelay) {
    checkSchedulePrevMillis = currentMillis;

    // Get current date in the format used by your system
    timeClient.update();
    time_t epochTime = timeClient.getEpochTime();
    struct tm *ptm = gmtime((time_t *)&epochTime);

    char dateString[11];
    sprintf(dateString, "%d/%d/%d", ptm->tm_mday, ptm->tm_mon + 1, ptm->tm_year + 1900);
    String currentDate = String(dateString);

    // Send request to Arduino to check if there's a schedule for today
    Serial.println("RequestSchedule#" + currentDate);
  }
}

void setup() {
  Serial.begin(9600);
  initWiFi();
  initFirebase();
  initNTP();
}

void loop() {
  processDataTransmitter();
  receiveDataControlFromFirebase();
  checkUserSchedules();
}