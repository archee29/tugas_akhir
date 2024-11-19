#include <ESP8266WiFi.h>
#include <FirebaseESP8266.h>
#include "addons/TokenHelper.h"
#include "addons/RTDBHelper.h"

// #define WIFI_SSID "Tugasakhir"
// #define WIFI_PASSWORD "wifisigit"
#define WIFI_SSID "HOME 2G"
#define WIFI_PASSWORD "wifirumah2"
#define API_KEY "AIzaSyD9cMliTs9G41vgRLcjS2VacvtMWWR1doQ"
#define DATABASE_URL "https://tugas-akhir-3c0d9-default-rtdb.asia-southeast1.firebasedatabase.app/"
#define USER_EMAIL "mhsigit01@gmail.com"
#define USER_PASSWORD "muhammadsigit292001"

FirebaseData firebaseData;
FirebaseAuth auth;
FirebaseConfig config;
FirebaseJson monitoringJson;
FirebaseJson feederJson;
FirebaseJsonData jsonData;

String uid, databasePath;

unsigned long sendDataMonitoringToFirebasePrevMillis = 0;
unsigned long sendDataMonitoringToFirebaseDelay = 3000;

unsigned long sendDataFeedingToFirebasePrevMillis = 0;
unsigned long sendDataFeedingToFirebasePrevDelay = 5000;

unsigned long receiveDataControlFromFirebasePrevMillis = 0;
unsigned long receiveDataControlFromFirebaseDelay = 1000;

unsigned long receiveDataControlFromTransmitterPrevMillis = 0;
unsigned long receiveDataControlFromTransmitterDelay = 1000;

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
    int separatorPos[5];
    int count = 0;
    for (int i = 0; i < message.length() && count < 5; i++) {
      if (message.charAt(i) == '#') {
        separatorPos[count] = i;
        count++;
      }
    }
    if (count == 5) {
      String waktuFeeding = message.substring(0, separatorPos[0]);
      int beratWadah = message.substring(separatorPos[0] + 1, separatorPos[1]).toInt();
      int volumeAirWadah = message.substring(separatorPos[1] + 1, separatorPos[2]).toInt();
      int volumeAirTabung = message.substring(separatorPos[2] + 1, separatorPos[3]).toInt();
      String ketHari = message.substring(separatorPos[3] + 1, separatorPos[4]);
      String ketWaktu = message.substring(separatorPos[4] + 1);

      String formattedDate = formatDate(ketHari);
      if (waktuFeeding == "morningFeeder" || waktuFeeding == "afternoonFeeder") {
        sendDataFeedingToFirebase(waktuFeeding, beratWadah, volumeAirWadah, volumeAirTabung, ketHari, ketWaktu, formattedDate);
      } else {
        Serial.println("Error: Invalid waktuFeeding value: " + waktuFeeding);
      }
    }
  } else if (message == "Pump_OFF" || message == "Servo_OFF") {
    updateFirebaseControlStatus(message);
  }
}

void sendDataMonitoringToFirebase(int beratWadah, int volumeAirWadah, int volumeAirTabung, String ketHari, String ketWaktu) {
  unsigned long currentMillis = millis();
  if (currentMillis - sendDataMonitoringToFirebasePrevMillis > sendDataMonitoringToFirebaseDelay) {
    sendDataMonitoringToFirebasePrevMillis = currentMillis;

    String monitoringNode = databasePath + "/iot/monitoring";
    monitoringJson.clear();
    monitoringJson.set("beratWadah", beratWadah);
    monitoringJson.set("volumeMLWadah", volumeAirWadah);
    monitoringJson.set("volumeMLTabung", volumeAirTabung);
    monitoringJson.set("ketHari", ketHari);
    monitoringJson.set("ketWaktu", ketWaktu);

    if (Firebase.setJSON(firebaseData, monitoringNode.c_str(), monitoringJson)) {
      Serial.println("Data monitoring berhasil dikirim");
    } else {
      Serial.println("Gagal mengirim data monitoring: " + firebaseData.errorReason());
    }
  }
}

String formatDate(String ketHari) {
  int firstSlash = ketHari.indexOf('/');
  int secondSlash = ketHari.lastIndexOf('/');

  String day = ketHari.substring(0, firstSlash);
  String month = ketHari.substring(firstSlash + 1, secondSlash);
  String year = ketHari.substring(secondSlash + 1);

  if (day.length() == 1) day = "0" + day;
  if (month.length() == 1) month = "0" + month;

  return month + "-" + day + "-" + year;
}

void sendDataFeedingToFirebase(String waktuFeeding, int beratWadah, int volumeAirWadah, int volumeAirTabung, String ketHari, String ketWaktu, String formattedDate) {
  unsigned long currentMillis = millis();
  if (currentMillis - sendDataFeedingToFirebasePrevMillis > sendDataFeedingToFirebasePrevDelay) {
    sendDataFeedingToFirebasePrevMillis = currentMillis;
    String feederType = waktuFeeding == "morningFeeder" ? "morningFeeder" : "afternoonFeeder";
    
/*
    if (waktuFeeding == "morningFeeder") {
      feederType = "morningFeeder";
    } else if (waktuFeeding == "afternoonFeeder") {
      feederType = "afternoonFeeder";
    } else {
      return;
    }
*/
    String feederFullPath = databasePath + "/iot/feeder/" + formattedDate + "/" + feederType;

    feederJson.clear();
    feederJson.set("beratWadah", beratWadah);
    feederJson.set("volumeMLWadah", volumeAirWadah);
    feederJson.set("volumeMLTabung", volumeAirTabung);
    feederJson.set("ketHari", ketHari);
    feederJson.set("ketWaktu", ketWaktu);

    if (Firebase.setJSON(firebaseData, feederFullPath.c_str(), feederJson)) {
      Serial.println("Data feeding berhasil dikirim");
    } else {
      Serial.println("Gagal mengirim data feeding: " + firebaseData.errorReason());
    }
  }
}

void sendDataControlToTransmitter(String command) {
  Serial.println(command);
}

void receiveDataControlFromDatabase() {
  unsigned long currentMillis = millis();
  if (currentMillis - receiveDataControlFromFirebasePrevMillis > receiveDataControlFromFirebaseDelay || receiveDataControlFromFirebasePrevMillis == 0) {
    receiveDataControlFromFirebasePrevMillis = currentMillis;
    String controlNode = databasePath + "/iot/control";
    if (Firebase.getJSON(firebaseData, controlNode.c_str())) {
      FirebaseJson controlJson = firebaseData.jsonObject();
      bool pumpControl, servoControl;
      controlJson.get(jsonData, "pumpControl");
      pumpControl = jsonData.boolValue;
      controlJson.get(jsonData, "servoControl");
      servoControl = jsonData.boolValue;
      if (pumpControl == true) {
        sendDataControlToTransmitter("Pump_ON");
      } else {
        sendDataControlToTransmitter("Pump_OFF");
      }

      if (servoControl == true) {
        sendDataControlToTransmitter("Servo_ON");
      } else {
        sendDataControlToTransmitter("Servo_OFF");
      }
    } else {
      Serial.println("Error mendapatkan data kontrol: " + firebaseData.errorReason());
    }
  }
}

void updateFirebaseControlStatus(String status) {
  unsigned long currentMillis = millis();
  if (currentMillis - receiveDataControlFromTransmitterPrevMillis > receiveDataControlFromTransmitterDelay || receiveDataControlFromTransmitterPrevMillis == 0) {
    receiveDataControlFromTransmitterPrevMillis = currentMillis;
    String controlPath = databasePath + "/iot/control";
    FirebaseJson updateJson;
    if (status == "Pump_OFF") {
      updateJson.set("pumpControl", false);
      if (Firebase.updateNode(firebaseData, controlPath.c_str(), updateJson)) {
        Serial.println("Status pompa berhasil diupdate ke OFF");
      } else {
        Serial.println("Gagal mengupdate status pompa: " + firebaseData.errorReason());
      }
    } else if (status == "Servo_OFF") {
      updateJson.set("servoControl", false);
      if (Firebase.updateNode(firebaseData, controlPath.c_str(), updateJson)) {
        Serial.println("Status servo berhasil diupdate ke OFF");
      } else {
        Serial.println("Gagal mengupdate status servo: " + firebaseData.errorReason());
      }
    }
  }
}

void setup() {
  Serial.begin(9600);
  initWiFi();
  initFirebase();
  delay(500);
}

void loop() {
  if (Firebase.isTokenExpired()) {
    Firebase.refreshToken(&config);
    Serial.println("Memperbarui Token");
  } else if (Firebase.ready()) {
    processDataTransmitter();
    receiveDataControlFromDatabase();
  } else {
    Serial.println("Kodingan Loop berjalan");
  }
}