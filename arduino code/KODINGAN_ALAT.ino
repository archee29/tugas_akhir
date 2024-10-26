#include <Wire.h>
#include <LiquidCrystal_I2C.h>
#include <RTClib.h>
#include <Servo.h>
#include <HX711.h>

LiquidCrystal_I2C lcd(0x27, 20, 4);

RTC_DS3231 rtc;
char dataHari[7][12] = { "Minggu", "Senin", "Selasa", "Rabu", "Kamis", "Jum'at", "Sabtu" };
int tanggal, bulan, tahun, jam, menit, detik;
String hari, ketHari, ketWaktu;

#define LOADCELL_WADAH_DOUT_PIN 4
#define LOADCELL_WADAH_SCK_PIN 5
HX711 lcWadah;
float calibration_factor_wadah = -388.10;

#define trigPinTabung 6
#define echoPinTabung 7
long durasiTabung;
float maxTinggiTabung = 34.5;
float radiusTabung = 4.25;

#define relayPin 8

Servo myServo;
#define servoPin 9

#define echoPinWadah 10
#define trigPinWadah 11
long durasiWadah;
float maxTinggiWadah = 15.0;
float radiusWadah = 4.5;

String sendDataToEsp;
String request = "";

bool pumpStatus = false;
bool servoStatus = false;

unsigned long previousLCDMillis = 0;
const long lcdInterval = 1000;

unsigned long previousNotificationMonitoringMillis = 0;
const long notificationMonitoringInterval = 60000;

long readUltrasonic(int trigPin, int echoPin) {
  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);
  long durasi = pulseIn(echoPin, HIGH);
  long distance = durasi * 0.034 / 2;
  return distance;
}

void initLCD() {
  lcd.init();
  lcd.backlight();
  lcd.setCursor(5, 1);
  lcd.print("TUGAS AKHIR");
  lcd.setCursor(1, 2);
  lcd.print("INTERNET OF THINGS");
  delay(3000);
  lcd.clear();
  lcd.setCursor(8, 1);
  lcd.print("Oleh : ");
  lcd.setCursor(0, 2);
  lcd.print("Muhammad Aswin Sigit");
  delay(3000);
  lcd.clear();
  lcd.setCursor(3, 1);
  lcd.print("MULAI PROGRAM");
  lcd.setCursor(0, 2);
  lcd.print("AUTOMATIC CAT FEEDER");
  delay(3000);
}

void initRTC() {
  DateTime now = rtc.now();
  tanggal = now.day();
  bulan = now.month();
  tahun = now.year();
  detik = now.second();
  jam = now.hour();
  menit = now.minute();
  hari = dataHari[now.dayOfTheWeek()];
  ketHari = String(tanggal) + "/" + String(bulan) + "/" + String(tahun);
  ketWaktu = String(jam) + ":" + String(menit) + ":" + String(detik);
}

void wadahPakan(int &beratWadah) {
  beratWadah = lcWadah.get_units(10);
  if (beratWadah < 0) {
    beratWadah = 0;
  }
}

void sensorUltrasonic(long &tinggiAirWadah, long &tinggiAirTabung) {
  tinggiAirWadah = readUltrasonic(trigPinWadah, echoPinWadah);
  tinggiAirTabung = readUltrasonic(trigPinTabung, echoPinTabung);
}

void bukaServo(int jumlah) {
  for (int i = 0; i < jumlah; i++) {
    for (int posisi = 0; posisi <= 90; posisi++) {
      myServo.write(posisi);
      delay(10);
    }
    for (int posisi = 90; posisi >= 0; posisi--) {
      myServo.write(posisi);
      delay(10);
    }
  }
  servoStatus = true;
}

void onPump() {
  unsigned long startMillis = millis();
  while (millis() - startMillis <= 5000) {
    digitalWrite(relayPin, HIGH);
  }
  digitalWrite(relayPin, LOW);
  pumpStatus = true;
}


void readSensor(int &beratWadah, long &tinggiAirWadah, long &tinggiAirTabung) {
  initRTC();
  wadahPakan(beratWadah);
  sensorUltrasonic(tinggiAirWadah, tinggiAirTabung);
}

void monitoringNotification(String tittle, String message, int delayTime) {
  lcd.clear();
  lcd.setCursor(3, 0);
  lcd.print("NOTIFIKASI !!!");
  lcd.setCursor(0, 1);
  lcd.print(tittle);
  lcd.setCursor(2, 2);
  lcd.print(message);
  delay(delayTime);
}

void showNotification(String tittle, String message, int delayTime) {
  lcd.clear();
  lcd.setCursor(3, 1);
  lcd.print(tittle);
  lcd.setCursor(0, 2);
  lcd.print(message);
  delay(delayTime);
}

void monitoring(int beratWadah, long tinggiAirWadah, long tinggiAirTabung) {
  unsigned long currentMillis = millis();
  if (currentMillis - previousNotificationMonitoringMillis >= notificationMonitoringInterval) {
    previousNotificationMonitoringMillis = currentMillis;
    showNotification("NOTIFIKASI !!!", "MONITORING CHECKING!", 3000);
    if (beratWadah >= 0 && beratWadah < 40) {
      monitoringNotification("PAKAN WADAH < 40 GR", "WADAH PERLU DIISI!", 2000);
      showNotification("NOTIFIKASI !!!", "PROSES PENGISIAN ...", 1000);
      bukaServo(4);
      showNotification("NOTIFIKASI !!!", "PROCESS SUCCESSFULL!", 2000);
    } else if (beratWadah >= 41 && beratWadah < 100) {
      monitoringNotification("PAKAN WADAH < 100 GR", "SEGERA ISI WADAH", 2000);
    } else if (beratWadah > 120) {
      monitoringNotification("PAKAN WADAH > 120 GR", "WADAH PAKAN PENUH", 2000);
    }
    if (tinggiAirWadah >= 0 && tinggiAirWadah < 150) {
      monitoringNotification("AIR WADAH < 150 ML", "WADAH PERLU DIISI", 2000);
      showNotification("NOTIFIKASI !!!", "PROSES PENGISIAN ...", 1000);
      onPump();
      showNotification("NOTIFIKASI !!!", "PROCESS SUCCESSFULL!", 2000);
    } else if (tinggiAirWadah >= 151 && tinggiAirWadah < 280) {
      monitoringNotification("AIR WADAH < 300 ML", "SEGERA ISI WADAH", 2000);
    } else if (tinggiAirWadah > 300) {
      monitoringNotification("AIR WADAH > 300 ML", "WADAH MINUM PENUH", 2000);
    }
    if (tinggiAirTabung >= 0 && tinggiAirTabung < 300) {
      monitoringNotification("AIR TABUNG < 300 ML", "SEGERA ISI TABUNG", 2000);
    } else if (tinggiAirTabung > 1000) {
      monitoringNotification("AIR TABUNG > 1 L", "TABUNG MINUM PENUH", 2000);
    }
    if (jam != 7 && jam != 17) {
      monitoringNotification("DILUAR WAKTU FEEDING", "CEK KET WAKTU", 2000);
    }
  }
}

void feeder() {
  if (jam == 7 && menit == 0 && detik == 0) {
    showNotification("NOTIFIKASI !!!", "FEEDING CHECKING!!..", 3000);
    showNotification("NOTIFIKASI !!!", "MORNING FEEDING!!!!!", 2000);
    showNotification("NOTIFIKASI !!!", "PROSES PENGISIAN ...", 1000);
    onPump();
    bukaServo(4);
    showNotification("NOTIFIKASI !!!", "PROCESS SUCCESSFULL!", 2000);
  } else if (jam == 17 && menit == 0 && detik == 0) {
    showNotification("NOTIFIKASI !!!", "FEEDING CHECKING!!..", 3000);
    showNotification("NOTIFIKASI !!!", "AFTERNOON FEEDING!!!", 2000);
    showNotification("NOTIFIKASI !!!", "PROSES PENGISIAN ...", 1000);
    onPump();
    bukaServo(4);
    showNotification("NOTIFIKASI !!!", "PROCESS SUCCESSFULL!", 2000);
  }
}

void displayLCD(int beratWadah, long tinggiAirWadah, long tinggiAirTabung) {
  unsigned long currentMillis = millis();
  if (currentMillis - previousLCDMillis >= lcdInterval) {
    previousLCDMillis = currentMillis;
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("Pakan Wadah");
    lcd.setCursor(11, 0);
    lcd.print(": ");
    lcd.print(beratWadah);
    lcd.setCursor(17, 0);
    lcd.print(" Gr");
    lcd.setCursor(0, 1);
    lcd.print("Air Wadah");
    lcd.setCursor(11, 1);
    lcd.print(": ");
    lcd.print(tinggiAirWadah);
    lcd.setCursor(18, 1);
    lcd.print("mL");
    lcd.setCursor(0, 2);
    lcd.print("Air Tabung");
    lcd.setCursor(11, 2);
    lcd.print(": ");
    lcd.print(tinggiAirTabung);
    lcd.setCursor(18, 2);
    lcd.print("mL");
    lcd.setCursor(0, 3);
    lcd.print(ketHari + " - " + ketWaktu);
  }
}

void sendData(int beratWadah, long tinggiAirWadah, long tinggiAirTabung) {
  sendDataToEsp = String(beratWadah) + "#" + String(tinggiAirWadah) + "#" + String(tinggiAirTabung) + "#" + String(pumpStatus) + "#" + String(servoStatus) + "#" + String(ketHari) + "#" + String(ketWaktu);
  Serial.println(sendDataToEsp);
}

void reqData() {
  if (Serial.available() > 0) {
    String command = Serial.readStringUntil('\n');
    if (command == "Pump_ON") {
      onPump();
    } else if (command == "Pump_OFF") {
      digitalWrite(relayPin, LOW);
      pumpStatus = false;
    } else if (command == "Servo_ON") {
      bukaServo(4);
      servoStatus = true;
    } else if (command == "Servo_OFF") {
      myServo.write(0);
      servoStatus = false;
    }
  }
}

void setup() {
  Serial.begin(9600);
  Wire.begin();
  if (!rtc.begin()) {
    Serial.println("RTC Tidak Ditemukan");
    Serial.flush();
    abort();
  }
  if (rtc.lostPower()) {
    rtc.adjust(DateTime(F(__DATE__), F(__TIME__)));
  }
  lcWadah.begin(LOADCELL_WADAH_DOUT_PIN, LOADCELL_WADAH_SCK_PIN);
  lcWadah.set_scale(calibration_factor_wadah);
  lcWadah.tare();
  pinMode(echoPinTabung, INPUT);
  pinMode(trigPinTabung, OUTPUT);
  pinMode(echoPinWadah, INPUT);
  pinMode(trigPinWadah, OUTPUT);
  myServo.attach(servoPin);
  myServo.write(0);
  pinMode(relayPin, OUTPUT);
  digitalWrite(relayPin, LOW);
  initLCD();
}

void loop() {
  int beratWadah;
  long tinggiAirWadah, tinggiAirTabung;
  readSensor(beratWadah, tinggiAirWadah, tinggiAirTabung);
  monitoring(beratWadah, tinggiAirWadah, tinggiAirTabung);
  feeder();
  displayLCD(beratWadah, tinggiAirWadah, tinggiAirTabung);
  sendData(beratWadah, tinggiAirWadah, tinggiAirTabung);
  reqData();
}

/*
#include <Wire.h>
#include <LiquidCrystal_I2C.h>
#include <RTClib.h>
#include <Servo.h>
#include <HX711.h>

LiquidCrystal_I2C lcd(0x27, 20, 4);

RTC_DS3231 rtc;
char dataHari[7][12] = { "Minggu", "Senin", "Selasa", "Rabu", "Kamis", "Jum'at", "Sabtu" };
int tanggal, bulan, tahun, jam, menit, detik;
String hari, ketHari, ketWaktu;

#define LOADCELL_WADAH_DOUT_PIN 4
#define LOADCELL_WADAH_SCK_PIN 5
HX711 lcWadah;
float calibration_factor_wadah = -388.10;

#define trigPinTabung 6
#define echoPinTabung 7
long durasiTabung;
float maxTinggiTabung = 34.5;
float radiusTabung = 4.25;
float luasTabung = 57.0;
// setelah dihutung menggunkan rumus luas alas maka menjadi 57,0 cm persegi
float tinggiAirTabung;

#define relayPin 8

Servo myServo;
#define servoPin 9

#define echoPinWadah 10
#define trigPinWadah 11
long durasiWadah;
float maxTinggiWadah = 15.0;
float radiusWadah = 4.5;
float luasWadah = 63.57;
// setelah dihutung menggunkan rumus luas alas maka menjadi 63,57 cm persegi
float tinggiAirWadah;

String sendDataToEsp;
String request = "";

bool pumpStatus = false;
bool servoStatus = false;

unsigned long previousLCDMillis = 0;
const long lcdInterval = 1000;

unsigned long previousNotificationMonitoringMillis = 0;
const long notificationMonitoringInterval = 6000000;

long readUltrasonic(int trigPin, int echoPin) {
  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);
  long durasi = pulseIn(echoPin, HIGH);
  float distance = durasi * 0.034 / 2;
  return distance;
}

void initLCD() {
  lcd.init();
  lcd.backlight();
  lcd.setCursor(5, 1);
  lcd.print("TUGAS AKHIR");
  lcd.setCursor(1, 2);
  lcd.print("INTERNET OF THINGS");
  delay(3000);
  lcd.clear();
  lcd.setCursor(8, 1);
  lcd.print("Oleh : ");
  lcd.setCursor(0, 2);
  lcd.print("Muhammad Aswin Sigit");
  delay(3000);
  lcd.clear();
  lcd.setCursor(3, 1);
  lcd.print("MULAI PROGRAM");
  lcd.setCursor(0, 2);
  lcd.print("AUTOMATIC CAT FEEDER");
  delay(3000);
}

void initRTC() {
  DateTime now = rtc.now();
  tanggal = now.day();
  bulan = now.month();
  tahun = now.year();
  detik = now.second();
  jam = now.hour();
  menit = now.minute();
  hari = dataHari[now.dayOfTheWeek()];
  ketHari = String(tanggal) + "/" + String(bulan) + "/" + String(tahun);
  ketWaktu = String(jam) + ":" + String(menit) + ":" + String(detik);
}

void wadahPakan(int &beratWadah) {
  beratWadah = lcWadah.get_units(10);
  if (beratWadah < 0) {
    beratWadah = 0;
  }
}

void sensorUltrasonic(int &volumeMLAirWadah, int &volumeMLAirTabung) {
  float jarakAirWadah = readUltrasonic(trigPinWadah, echoPinWadah);
  if (tinggiAirWadah <= 1) {
     tinggiAirWadah = 0;
  }
  tinggiAirWadah = abs(maxTinggiWadah - jarakAirWadah);
  float volumeWadah = luasWadah * tinggiAirWadah;
  volumeMLAirWadah = abs(static_cast<int>(volumeWadah));
  
  float jarakAirTabung = readUltrasonic(trigPinTabung, echoPinTabung);
  if (maxTinggiTabung <= 1) {
    maxTinggiTabung = 0;
  }
  tinggiAirTabung = abs(maxTinggiTabung - jarakAirTabung);
  float volumeTabung = luasTabung * tinggiAirTabung;
  volumeMLAirTabung = abs(static_cast<int>(volumeTabung)); 
}

void bukaServo(int jumlah) {
  for (int i = 0; i < jumlah; i++) {
    for (int posisi = 0; posisi <= 90; posisi++) {
      myServo.write(posisi);
      delay(20);
    }
    for (int posisi = 90; posisi >= 90; posisi--) {
      myServo.write(posisi);
      delay(20);
    }
  }
  servoStatus = true;
}

void onPump() {
  unsigned long startMillis = millis();
  while (millis() - startMillis <= 5000) {
    digitalWrite(relayPin, HIGH);
  }
  digitalWrite(relayPin, LOW);
  pumpStatus = true;
}

void readSensor(int &beratWadah, int &volumeMLAirWadah, int &volumeMLAirTabung) {
  initRTC();
  wadahPakan(beratWadah);
  sensorUltrasonic(volumeMLAirWadah, volumeMLAirTabung);
}

void monitoringNotification(String tittle, String message, int delayTime) {
  lcd.clear();
  lcd.setCursor(3, 0);
  lcd.print("NOTIFIKASI !!!");
  lcd.setCursor(0, 1);
  lcd.print(tittle);
  lcd.setCursor(2, 2);
  lcd.print(message);
  delay(delayTime);
}

void showNotification(String tittle, String message, int delayTime) {
  lcd.clear();
  lcd.setCursor(3, 1);
  lcd.print(tittle);
  lcd.setCursor(0, 2);
  lcd.print(message);
  delay(delayTime);
}

void monitoring(int beratWadah, int volumeMLAirWadah, int volumeMLAirTabung) {
  unsigned long currentMillis = millis();
  if (currentMillis - previousNotificationMonitoringMillis >= notificationMonitoringInterval) {
    previousNotificationMonitoringMillis = currentMillis;
    showNotification("NOTIFIKASI !!!", "MONITORING CHECKING!", 3000);
    if (beratWadah >= 0 && beratWadah < 40) {
      monitoringNotification("PAKAN WADAH < 40 GR", "WADAH PERLU DIISI!", 2000);
      showNotification("NOTIFIKASI !!!", "PROSES PENGISIAN ...", 1000);
      bukaServo(4);
      showNotification("NOTIFIKASI !!!", "PROCESS SUCCESSFULL!", 2000);
    } else if (beratWadah >= 41 && beratWadah < 100) {
      monitoringNotification("PAKAN WADAH < 100 GR", "SEGERA ISI WADAH", 2000);
    } else if (beratWadah > 120) {
      monitoringNotification("PAKAN WADAH > 120 GR", "WADAH PAKAN PENUH", 2000);
    }
    if (volumeMLAirWadah >= 0 && volumeMLAirWadah < 150) {
      monitoringNotification("AIR WADAH < 150 ML", "WADAH PERLU DIISI", 2000);
      showNotification("NOTIFIKASI !!!", "PROSES PENGISIAN ...", 1000);
      onPump();
      showNotification("NOTIFIKASI !!!", "PROCESS SUCCESSFULL!", 2000);
    } else if (volumeMLAirWadah >= 151 && volumeMLAirWadah < 280) {
      monitoringNotification("AIR WADAH < 300 ML", "SEGERA ISI WADAH", 2000);
    } else if (volumeMLAirWadah > 300) {
      monitoringNotification("AIR WADAH > 300 ML", "WADAH MINUM PENUH", 2000);
    }
    if (volumeMLAirTabung >= 0 && volumeMLAirTabung < 300) {
      monitoringNotification("AIR TABUNG < 300 ML", "SEGERA ISI TABUNG", 2000);
    } else if (volumeMLAirTabung > 1000) {
      monitoringNotification("AIR TABUNG > 1 L", "TABUNG MINUM PENUH", 2000);
    }
    if (jam != 7 && jam != 17) {
      monitoringNotification("DILUAR WAKTU FEEDING", "CEK KET WAKTU", 2000);
    }
  }
}

void feeder() {
  if (jam == 7 && menit == 0 && detik == 0) {
    showNotification("NOTIFIKASI !!!", "FEEDING CHECKING!!..", 3000);
    showNotification("NOTIFIKASI !!!", "MORNING FEEDING!!!!!", 2000);
    showNotification("NOTIFIKASI !!!", "PROSES PENGISIAN ...", 1000);
    onPump();
    bukaServo(4);
    showNotification("NOTIFIKASI !!!", "PROCESS SUCCESSFULL!", 2000);
  } else if (jam == 17 && menit == 0 && detik == 0) {
    showNotification("NOTIFIKASI !!!", "FEEDING CHECKING!!..", 3000);
    showNotification("NOTIFIKASI !!!", "AFTERNOON FEEDING!!!", 2000);
    showNotification("NOTIFIKASI !!!", "PROSES PENGISIAN ...", 1000);
    onPump();
    bukaServo(4);
    showNotification("NOTIFIKASI !!!", "PROCESS SUCCESSFULL!", 2000);
  }
}

void displayLCD(int beratWadah, int volumeMLAirWadah, int volumeMLAirTabung) {
  unsigned long currentMillis = millis();
  if (currentMillis - previousLCDMillis >= lcdInterval) {
    previousLCDMillis = currentMillis;
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("Pakan Wadah");
    lcd.setCursor(11, 0);
    lcd.print(": ");
    lcd.print(beratWadah);
    lcd.setCursor(17, 0);
    lcd.print(" Gr");
    lcd.setCursor(0, 1);
    lcd.print("Air Wadah");
    lcd.setCursor(11, 1);
    lcd.print(": ");
    lcd.print(volumeMLAirWadah);
    lcd.setCursor(18, 1);
    lcd.print("mL");
    lcd.setCursor(0, 2);
    lcd.print("Air Tabung");
    lcd.setCursor(11, 2);
    lcd.print(": ");
    lcd.print(volumeMLAirTabung);
    lcd.setCursor(18, 2);
    lcd.print("mL");
    lcd.setCursor(1, 3);
    lcd.print(ketHari + "-" + ketWaktu);
  }
}

void sendDataToReceiver(int beratWadah, int volumeMLAirWadah, int volumeMLAirTabung) {
  sendDataToEsp = String(beratWadah) + "#" + String(volumeMLAirWadah) + "#" + String(volumeMLAirTabung) + "#" + String(pumpStatus) + "#" + String(servoStatus) + "#" + String(ketHari) + "#" + String(ketWaktu);
  Serial.println(sendDataToEsp);
}

void reqDataFromReceiver() {
  if (Serial.available()) {
    String receivedCommand = Serial.readStringUntil('\n');
    receivedCommand.trim();
    if (receivedCommand == "Pump_ON") {
      onPump();
      activatePump(true);      
    } else if (receivedCommand == "Pump_OFF") {
      digitalWrite(relayPin, LOW);
      pumpStatus = false;
      activatePump(false);      
    }
    if (receivedCommand == "Servo_ON") {
      bukaServo(4);
      servoStatus = true;
      activateServo(true);      
    } else if (receivedCommand == "Servo_OFF") {
      myServo.write(0);
      servoStatus = false;
      activateServo(false);      
    }
  }
}

void activatePump(bool status) {
  if (status) {
    Serial.println("Pompa dihidupkan");
  } else {
    Serial.println("Pompa dimatikan");
  }
}

void activateServo(bool status) {
  if (status) {
    Serial.println("Servo dihidupkan");
  } else {
    Serial.println("Servo dimatikan");
  }
}

void setup() {
  Serial.begin(9600);
  Wire.begin();
  if (!rtc.begin()) {
    Serial.println("RTC Tidak Ditemukan");
    Serial.flush();
    abort();
  }
  if (rtc.lostPower()) {
    rtc.adjust(DateTime(F(__DATE__), F(__TIME__)));
  }
  lcWadah.begin(LOADCELL_WADAH_DOUT_PIN, LOADCELL_WADAH_SCK_PIN);
  lcWadah.set_scale(calibration_factor_wadah);
  lcWadah.tare();
  pinMode(trigPinWadah, OUTPUT);
  pinMode(echoPinTabung, INPUT);
  pinMode(trigPinTabung, OUTPUT);
  pinMode(echoPinWadah, INPUT);  
  myServo.attach(servoPin);
  myServo.write(0);
  pinMode(relayPin, OUTPUT);
  digitalWrite(relayPin, LOW);
  initLCD();
}

void loop() {
  int beratWadah, volumeMLAirWadah, volumeMLAirTabung;
  readSensor(beratWadah, volumeMLAirWadah, volumeMLAirTabung);
  monitoring(beratWadah, volumeMLAirWadah, volumeMLAirTabung);
  feeder();
  displayLCD(beratWadah, volumeMLAirWadah, volumeMLAirTabung);
  sendDataToReceiver(beratWadah, volumeMLAirWadah, volumeMLAirTabung);
  reqDataFromReceiver();
}
*/