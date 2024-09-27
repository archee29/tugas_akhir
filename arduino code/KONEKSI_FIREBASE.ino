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
FirebaseJsonData jsonData;

String uid, databasePath, monitoringNode, controlNode;

unsigned long sendDataPrevMillis = 0;
unsigned long timerDelay = 3000;

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
    receiveDataFromUno();
    getControlData();
  } else {
    Serial.println("Kodingan Loop berjalan");
  }
}

void receiveDataFromUno() {
  String receivedData = "";
  while (Serial.available()) {
    receivedData = Serial.readStringUntil('\n');
  }
  if (receivedData.length() > 0) {
    int separator1 = receivedData.indexOf('#');
    int separator2 = receivedData.indexOf('#', separator1 + 1);
    int separator3 = receivedData.indexOf('#', separator2 + 1);
    int separator4 = receivedData.indexOf('#', separator3 + 1);
    int separator5 = receivedData.indexOf('#', separator4 + 1);
    int separator6 = receivedData.indexOf('#', separator5 + 1);

    int beratWadah = receivedData.substring(0, separator1).toInt();
    int volumeMLTabung = receivedData.substring(separator1 + 1, separator2).toInt();
    int volumeMLWadah = receivedData.substring(separator2 + 1, separator3).toInt();
    bool pumpStatus = receivedData.substring(separator3 + 1, separator4) == "1";
    bool servoStatus = receivedData.substring(separator4 + 1, separator5) == "1";
    String ketHari = receivedData.substring(separator5 + 1, separator6);
    String ketWaktu = receivedData.substring(separator6 + 1);

    sendDataToFirebase(beratWadah, volumeMLTabung, volumeMLWadah, pumpStatus, servoStatus, ketHari, ketWaktu);
  }
}

void sendDataToFirebase(int beratWadah, int volumeMLTabung, int volumeMLWadah, bool pumpStatus, bool servoStatus, String ketHari, String ketWaktu) {
  unsigned long currentMillis = millis();
  if (currentMillis - sendDataPrevMillis > timerDelay || sendDataPrevMillis == 0) {
    sendDataPrevMillis = currentMillis;
    monitoringNode = databasePath + "/iot/monitoring";
    monitoringJson.set("beratWadah", beratWadah);
    monitoringJson.set("volumeMLTabung", volumeMLTabung);
    monitoringJson.set("volumeMLWadah", volumeMLWadah);
    monitoringJson.set("pumpStatus", pumpStatus);
    monitoringJson.set("servoStatus", servoStatus);
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

void getControlData() {
  controlNode = databasePath + "/iot/control";
  if (Firebase.getBool(firebaseData, controlNode + "/pumpControl")) {
    bool pumpControl = firebaseData.boolData();
    if (pumpControl) {
      Serial.println("Pump_ON");
    } else {
      Serial.println("Pump_OFF");
    }
  } else {
    Serial.println("Gagal mendapatkan data pumpControl: " + firebaseData.errorReason());
  }

  if (Firebase.getBool(firebaseData, controlNode + "/servoControl")) {
    bool servoControl = firebaseData.boolData();
    if (servoControl) {
      Serial.println("Servo_ON");
    } else {
      Serial.println("Servo_OFF");
    }
  } else {
    Serial.println("Gagal mendapatkan data servoControl: " + firebaseData.errorReason());
  }
}