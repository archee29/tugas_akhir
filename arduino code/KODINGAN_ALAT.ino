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

#define trigPinWadah 6
#define echoPinWadah 7
long durasiWadah;
float maxTinggiWadah = 15.0;
float radiusWadah = 4.5;

#define relayPin 8

Servo myServo;
#define servoPin 9

#define echoPinTabung 10
#define trigPinTabung 11
long durasiTabung;
float maxTinggiTabung = 34.5;
float radiusTabung = 4.25;

String dataMonitoring;
String dataFeeding;

unsigned long previousLCDMillis = 0;
const long lcdInterval = 1000;

unsigned long previousNotificationMonitoringMillis = 0;
const long notificationMonitoringInterval = 960000;

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
      delay(20);
    }
    for (int posisi = 90; posisi >= 90; posisi--) {
      myServo.write(posisi);
      delay(20);
    }
  }
  sendDataControlToReceiver("Servo_OFF");
}

void onPump() {
  unsigned long startMillis = millis();
  digitalWrite(relayPin, HIGH);
  while (millis() - startMillis <= 5000) {
  }
  digitalWrite(relayPin, LOW);
  sendDataControlToReceiver("Pump_OFF");
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

void feeder(String &waktuFeeding, int &beratWadah, long &tinggiAirWadah, long &tinggiAirTabung) {
  if ((jam == 18 && menit == 23 && detik == 0) || (jam == 18 && menit == 28 && detik == 0)) {
    waktuFeeding = (jam == 18) ? "morningFeeder" : "afternoonFeeder";
    showNotification("NOTIFIKASI !!!", "FEEDING CHECKING!!..", 3000);
    showNotification("NOTIFIKASI !!!", waktuFeeding, 2000);
    showNotification("NOTIFIKASI !!!", "PROSES PENGISIAN ...", 1000);
    onPump();
    bukaServo(4);
    showNotification("NOTIFIKASI !!!", "PROCESS SUCCESSFULL!", 2000);
    sendDataFeedingToReceiver(waktuFeeding, beratWadah, tinggiAirWadah, tinggiAirTabung);
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
    lcd.print(ketHari + "-" + ketWaktu);
  }
}

void sendDataMonitoringToReceiver(int beratWadah, long tinggiAirWadah, long tinggiAirTabung) {
  static unsigned long lastSendTime = 0;
  const unsigned long SEND_INTERVAL = 1000;

  unsigned long currentTime = millis();
  if (currentTime - lastSendTime >= SEND_INTERVAL) {
    lastSendTime = currentTime;
    dataMonitoring = String(beratWadah) + "#" + String(tinggiAirWadah) + "#" + String(tinggiAirTabung) + "#" + ketHari + "#" + ketWaktu;
    Serial.println("monitoring#" + dataMonitoring);
  }
}

void sendDataFeedingToReceiver(String waktuFeeding, int beratWadah, long tinggiAirWadah, long tinggiAirTabung) {
  String feedingData = "feeding#" + waktuFeeding + "#" + String(beratWadah) + "#" + String(tinggiAirWadah) + "#" + String(tinggiAirTabung) + "#" + ketHari + "#" + ketWaktu;
  Serial.println(feedingData);
}

void sendDataControlToReceiver(String command) {
  Serial.println(command);
}

void reqDataFromReceiver() {
  if (Serial.available()) {
    String receivedCommand = Serial.readStringUntil('\n');
    receivedCommand.trim();
    if (receivedCommand == "Pump_ON") {
      onPump();
    } else if (receivedCommand == "Pump_OFF") {
      digitalWrite(relayPin, LOW);
    }
    if (receivedCommand == "Servo_ON") {
      bukaServo(4);
    } else if (receivedCommand == "Servo_OFF") {
      myServo.write(0);
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
  pinMode(echoPinWadah, INPUT);
  pinMode(trigPinWadah, OUTPUT);
  pinMode(echoPinTabung, INPUT);
  pinMode(trigPinTabung, OUTPUT);
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
  displayLCD(beratWadah, tinggiAirWadah, tinggiAirTabung);
  sendDataMonitoringToReceiver(beratWadah, tinggiAirWadah, tinggiAirTabung);
  String waktuFeeding;
  feeder(waktuFeeding, beratWadah, tinggiAirWadah, tinggiAirTabung);
  reqDataFromReceiver();
}