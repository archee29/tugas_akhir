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
float maxTinggiWadah = 14.0, radiusWadah = 5.1;  // radius wadah bisa 5.05 atau 4.55

#define relayPin 8
bool isPumpActive = false;
int waktuPump = 5000;

Servo myServo;
#define servoPin 9
bool isServoActive = false;
int putaranServo = 4;

#define echoPinTabung 10
#define trigPinTabung 11
float maxTinggiTabung = 9.0, radiusTabung = 4.0;  // Tinggi Tabung = 34.5

String dataMonitoring;
String dataFeeding;

unsigned long previousLCDMillis = 0;
const long lcdInterval = 1000;

unsigned long previousNotificationMonitoringMillis = 0;
const long notificationMonitoringInterval = 960000;

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
  if (beratWadah < 1200) {
    beratWadah = 0;
  }
}

void USWadah(int &volumeMLAirWadah) {
  digitalWrite(trigPinWadah, LOW);
  delayMicroseconds(2);
  digitalWrite(trigPinWadah, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPinWadah, LOW);
  long durasiWadah = pulseIn(echoPinWadah, HIGH);
  float jarakAirWadah = durasiWadah * 0.034 / 2;
  // volumeMLAirWadah = durasiWadah * 0.034 / 2;
  float tinggiAirWadah = abs(maxTinggiWadah - jarakAirWadah);
  if (tinggiAirWadah <= 1) {
    tinggiAirWadah == 0;
  }
  float volumeAirWadah = 3.14159 * radiusWadah * radiusWadah * tinggiAirWadah;
  volumeMLAirWadah = abs(volumeAirWadah);
}

void USTabung(int &volumeMLAirTabung) {
  digitalWrite(trigPinTabung, LOW);
  delayMicroseconds(2);
  digitalWrite(trigPinTabung, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPinTabung, LOW);
  long durasiTabung = pulseIn(echoPinTabung, HIGH);
  float jarakAirTabung = durasiTabung * 0.034 / 2;
  // volumeMLAirTabung = durasiTabung * 0.034 / 2;
  float tinggiAirTabung = abs(maxTinggiTabung - jarakAirTabung);
  if (tinggiAirTabung <= 1) {
    tinggiAirTabung == 0;
  }
  float volumeAirTabung = 3.14159 * radiusTabung * radiusTabung * tinggiAirTabung;
  volumeMLAirTabung = abs(volumeAirTabung);
}

void bukaServo(int jumlah) {
  if (!isServoActive) {
    isServoActive = true;
    for (int i = 0; i < jumlah; i++) {
      for (int posisi = 90; posisi >= 0; posisi--) {
        myServo.write(posisi);
        delay(20);
      }
      for (int posisi = 0; posisi <= 90; posisi++) {
        myServo.write(posisi);
        delay(20);
      }
    }
    myServo.write(90);
    isServoActive = false;
    sendDataControlToReceiver("Servo_OFF");
  }
}

void onPump() {
  if (!isPumpActive) {
    unsigned long startMillis = millis();
    digitalWrite(relayPin, HIGH);
    isPumpActive = true;
    while (millis() - startMillis <= waktuPump) {}
    digitalWrite(relayPin, LOW);
    isPumpActive = false;
    sendDataControlToReceiver("Pump_OFF");
  }
}

void readSensor(int &beratWadah, int &volumeMLAirWadah, int &volumeMLAirTabung) {
  initRTC();
  wadahPakan(beratWadah);
  USWadah(volumeMLAirWadah);
  USTabung(volumeMLAirTabung);
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
      bukaServo(putaranServo);
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

void feeder(String &waktuFeeding, int &beratWadah, int &volumeMLAirWadah, int &volumeMLAirTabung) {
  if ((jam == 7 && menit == 0 && detik == 0) || (jam == 17 && menit == 0 && detik == 0)) {
    waktuFeeding = (jam == 7) ? "jadwalPagi" : "jadwalSore";
    showNotification("NOTIFIKASI !!!", "FEEDING CHECKING!!..", 3000);
    showNotification("NOTIFIKASI !!!", waktuFeeding, 2000);
    showNotification("NOTIFIKASI !!!", "PROSES PENGISIAN ...", 1000);
    onPump();
    bukaServo(putaranServo);
    showNotification("NOTIFIKASI !!!", "PROCESS SUCCESSFULL!", 2000);
    sendDataFeedingToReceiver(waktuFeeding, beratWadah, volumeMLAirWadah, volumeMLAirTabung);
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
    lcd.setCursor(0, 3);
    lcd.print(ketHari + "-" + ketWaktu);
  }
}

void sendDataMonitoringToReceiver(int beratWadah, int volumeMLAirWadah, int volumeMLAirTabung) {
  static unsigned long lastSendTime = 0;
  const unsigned long SEND_INTERVAL = 1000;

  unsigned long currentTime = millis();
  if (currentTime - lastSendTime >= SEND_INTERVAL) {
    lastSendTime = currentTime;
    dataMonitoring = String(beratWadah) + "#" + String(volumeMLAirWadah) + "#" + String(volumeMLAirTabung) + "#" + ketHari + "#" + ketWaktu;
    Serial.println("monitoring#" + dataMonitoring);
  }
}

void sendDataFeedingToReceiver(String waktuFeeding, int beratWadah, int volumeMLAirWadah, int volumeMLAirTabung) {
  String feedingData = "feeding#" + waktuFeeding + "#" + String(beratWadah) + "#" + String(volumeMLAirWadah) + "#" + String(volumeMLAirTabung) + "#" + ketHari + "#" + ketWaktu + "#" + String(isPumpActive) + "#" + String(isServoActive);
  Serial.println(feedingData);
}

void sendDataControlToReceiver(String command) {
  Serial.println(command);
}

void reqDataFromReceiver() {
  if (Serial.available()) {
    String receivedCommand = Serial.readStringUntil('\n');
    receivedCommand.trim();

    if (receivedCommand.startsWith("ServoRotation#")) {
      String rotationValue = receivedCommand.substring(14);
      putaranServo = rotationValue.toInt();
    }
    else if (receivedCommand.startsWith("PumpDuration#")) {
      String durationValue = receivedCommand.substring(13);
      waktuPump = durationValue.toInt() * 1000;
    }
    else if (receivedCommand == "Pump_ON" && !isPumpActive) {
      onPump();
    } else if (receivedCommand == "Pump_OFF") {
      digitalWrite(relayPin, LOW);
      isPumpActive = false;
    }
    else if (receivedCommand == "Servo_ON" && !isServoActive) {
      bukaServo(putaranServo);
    } else if (receivedCommand == "Servo_OFF") {
      myServo.write(90);
      isServoActive = false;
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
  rtc.adjust(DateTime(2025, 1, 10, 6, 55, 0));
  lcWadah.begin(LOADCELL_WADAH_DOUT_PIN, LOADCELL_WADAH_SCK_PIN);
  lcWadah.set_scale(calibration_factor_wadah);
  lcWadah.tare();
  pinMode(echoPinWadah, INPUT);
  pinMode(trigPinWadah, OUTPUT);
  pinMode(echoPinTabung, INPUT);
  pinMode(trigPinTabung, OUTPUT);
  myServo.attach(servoPin);
  myServo.write(90);
  pinMode(relayPin, OUTPUT);
  digitalWrite(relayPin, LOW);
  initLCD();
  delay(500);
}

void loop() {
  int beratWadah, volumeMLAirWadah, volumeMLAirTabung;
  readSensor(beratWadah, volumeMLAirWadah, volumeMLAirTabung);
  monitoring(beratWadah, volumeMLAirWadah, volumeMLAirTabung);
  displayLCD(beratWadah, volumeMLAirWadah, volumeMLAirTabung);
  sendDataMonitoringToReceiver(beratWadah, volumeMLAirWadah, volumeMLAirTabung);
  String waktuFeeding;
  feeder(waktuFeeding, beratWadah, volumeMLAirWadah, volumeMLAirTabung);
  reqDataFromReceiver();
}