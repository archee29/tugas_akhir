#include <ESP8266WiFi.h>
#include <FirebaseESP8266.h>
#include "addons/TokenHelper.h"
#include "addons/RTDBHelper.h"

#define WIFI_SSID "Tugasakhir"
#define WIFI_PASSWORD "wifisigit"
#define API_KEY "AIzaSyD9cMliTs9G41vgRLcjS2VacvtMWWR1doQ"
#define DATABASE_URL "tugas-akhir-3c0d9-default-rtdb.asia-southeast1.firebasedatabase.app/"
#define USER_EMAIL "mhsigit01@gmail.com"
#define USER_PASSWORD "muhammadsigit292001"

FirebaseData firebaseData;
FirebaseAuth auth;
FirebaseConfig config;
FirebaseJson monitoringJson;
FirebaseJson feederJson;
FirebaseJsonData jsonData;

String uid, databasePath, feederPath, feederNode, dateNode, feederFullPath, monitoringNode, controlNode;

unsigned long sendDataMonitoringToFirebasePrevMillis = 0;
unsigned long sendDataMonitoringToFirebaseDelay = 3000;

unsigned long sendDataFeedingToFirebasePrevMillis = 0;
unsigned long sendDataFeedingToFirebasePrevDelay = 1000;

unsigned long receiveDataControlFromFirebasePrevMillis = 0;
unsigned long receiveDataControlFromFirebaseDelay = 1000;

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
    receiveDataMonitoringFromTransmitter();
    receiveDataFeedingFromTransmitter();
    receiveDataControlFromDatabase();
    receiveDataStatusFromTransmitter();
  } else {
    Serial.println("Kodingan Loop berjalan");
  }
}

void receiveDataMonitoringFromTransmitter() {
  String receivedDataMonitoring = "";
  while (Serial.available()) {
    receivedDataMonitoring = Serial.readStringUntil('\n');
  }
  if (receivedDataMonitoring.length() > 0) {
    int separator1 = receivedDataMonitoring.indexOf('#');
    int separator2 = receivedDataMonitoring.indexOf('#', separator1 + 1);
    int separator3 = receivedDataMonitoring.indexOf('#', separator2 + 1);
    int separator4 = receivedDataMonitoring.indexOf('#', separator3 + 1);

    int beratWadah = receivedDataMonitoring.substring(0, separator1).toInt();
    int tinggiAirWadah = receivedDataMonitoring.substring(separator1 + 1, separator2).toInt();
    int tinggiAirTabung = receivedDataMonitoring.substring(separator2 + 1, separator3).toInt();
    String ketHari = receivedDataMonitoring.substring(separator3 + 1, separator4);
    String ketWaktu = receivedDataMonitoring.substring(separator4 + 1);

    sendDataMonitoringToFirebase(beratWadah, tinggiAirWadah, tinggiAirTabung, ketHari, ketWaktu);
  }
}

void sendDataMonitoringToFirebase(int beratWadah, int tinggiAirWadah, int tinggiAirTabung, String ketHari, String ketWaktu) {
  unsigned long currentMillis = millis();
  if (currentMillis - sendDataMonitoringToFirebasePrevMillis > sendDataMonitoringToFirebaseDelay || sendDataMonitoringToFirebasePrevMillis == 0) {
    sendDataMonitoringToFirebasePrevMillis = currentMillis;
    monitoringNode = databasePath + "/iot/monitoring";
    monitoringJson.set("beratWadah", beratWadah);
    monitoringJson.set("volumeMLWadah", tinggiAirWadah);
    monitoringJson.set("volumeMLTabung", tinggiAirTabung);
    monitoringJson.set("ketHari", ketHari);
    monitoringJson.set("ketWaktu", ketWaktu);
    if (Firebase.setJSON(firebaseData, monitoringNode.c_str(), monitoringJson)) {
      Serial.println("DATA TERKIRIM");
      Serial.println("PATH : " + firebaseData.dataPath());
      Serial.println("TYPE: " + firebaseData.dataType());
      Serial.print("VALUE: ");
      printResult(firebaseData);
      Serial.println("------------------------------------");
    } else {
      Serial.println("GAGAL MENGIRIM DATA");
      Serial.println("Error : " + firebaseData.errorReason());
      Serial.println("------------------------------------");
    }
  }
}

void receiveDataFeedingFromTransmitter() {
  String receivedDataFeeding = "";

  while (Serial.available()) {
    receivedDataFeeding = Serial.readStringUntil('\n');
  }

  if (receivedDataFeeding.startsWith("morningFeeder") || receivedDataFeeding.startsWith("afternoonFeeder")) {
    if (receivedDataFeeding.length() > 0) {
      int separator1 = receivedDataFeeding.indexOf('@');
      int separator2 = receivedDataFeeding.indexOf('@', separator1 + 1);
      int separator3 = receivedDataFeeding.indexOf('@', separator2 + 1);
      int separator4 = receivedDataFeeding.indexOf('@', separator3 + 1);
      int separator5 = receivedDataFeeding.indexOf('@', separator4 + 1);

      String waktuFeeding = receivedDataFeeding.substring(0, separator1);
      int beratWadah = receivedDataFeeding.substring(separator1 + 1, separator2).toInt();
      int tinggiAirWadah = receivedDataFeeding.substring(separator2 + 1, separator3).toInt();
      int tinggiAirTabung = receivedDataFeeding.substring(separator3 + 1, separator4).toInt();
      String ketHari = receivedDataFeeding.substring(separator4 + 1, separator5);
      String ketWaktu = receivedDataFeeding.substring(separator5 + 1);

      sendDataFeedingToFirebase(waktuFeeding, beratWadah, tinggiAirWadah, tinggiAirTabung, ketHari, ketWaktu);
    }
  }
}

void sendDataFeedingToFirebase(String waktuFeeding, int beratWadah, int tinggiAirWadah, int tinggiAirTabung, String ketHari, String ketWaktu) {
  unsigned long currentMillis = millis();
  if (currentMillis - sendDataFeedingToFirebasePrevMillis > sendDataFeedingToFirebasePrevDelay || sendDataFeedingToFirebasePrevMillis == 0) {
    sendDataFeedingToFirebasePrevMillis = currentMillis;
    dateNode = ketHari;
    feederPath = waktuFeeding;

    feederNode = databasePath + "iot/feeder/";
    feederFullPath = feederNode + dateNode + "/" + feederPath;

    feederJson.set("beratWadah", beratWadah);
    feederJson.set("volumeMLWadah", tinggiAirWadah);
    feederJson.set("volumeMLTabung", tinggiAirTabung);
    feederJson.set("ketHari", ketHari);
    feederJson.set("ketWaktu", ketWaktu);
    if (Firebase.pushJSON(firebaseData, feederFullPath.c_str(), feederJson)) {
      Serial.println("DATA TERKIRIM");
      Serial.println("PATH : " + firebaseData.dataPath());
      Serial.println("TYPE: " + firebaseData.dataType());
      Serial.print("VALUE: ");
      printResult(firebaseData);
      Serial.println("------------------------------------");
    } else {
      Serial.println("GAGAL MENGIRIM DATA");
      Serial.println("Error : " + firebaseData.errorReason());
      Serial.println("------------------------------------");
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
    controlNode = databasePath + "/iot/control";
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

void receiveDataStatusFromTransmitter() {
  if (Serial.available()) {
    String receivedStatus = Serial.readStringUntil('\n');
    if (receivedStatus == "Pump_OFF" || receivedStatus == "Servo_OFF") {
      updateFirebaseControlStatus(receivedStatus);
    }
  }
}

void updateFirebaseControlStatus(String status) {
  String controlPath = controlNode + "/";
  if (status == "Pump_OFF") {
    Firebase.setBool(firebaseData, controlPath + "pumpControl", false);
  } else if (status == "Servo_OFF") {
    Firebase.setBool(firebaseData, controlPath + "servoControl", false);
  }
}