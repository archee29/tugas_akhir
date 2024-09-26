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
const long notificationMonitoringInterval = 120000;

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
  static int step = 0;
  static unsigned long previousMillis = 0;
  const long interval = 1000;
  unsigned long currentMillis = millis();
  if (currentMillis - previousMillis >= interval) {
    previousMillis = currentMillis;
    if (step == 0) {
      myServo.write(0);
      step++;
    } else if (step == 1) {
      myServo.write(90);
      step++;
    } else if (step == 2) {
      myServo.write(180);
      step++;
    } else if (step == 3) {
      myServo.write(90);
      step = 0;
      jumlah--;
    }
  }
  if (jumlah <= 0) {
    servoStatus = true;
  }
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
      pumpStatus = true;
      Serial.println("Pump is ON");
    } else if (command == "Pump_OFF") {
      digitalWrite(relayPin, LOW);
      pumpStatus = false;
      Serial.println("Pump is OFF");
    } else if (command == "Servo_ON") {
      bukaServo(4);
      servoStatus = true;
      Serial.println("Servo is ON");
    } else if (command == "Servo_OFF") {
      myServo.write(0);
      servoStatus = false;
      Serial.println("Servo is OFF");
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
// kodingan wokwi
// #include <Wire.h>
// #include <LiquidCrystal_I2C.h>
// #include <RTClib.h>
// #include <Servo.h>
// #include <HX711.h>

// // Inisialisasi LCD
// LiquidCrystal_I2C lcd(0x27, 20, 4);

// // Inisialisasi RTC DS3231
// RTC_DS3231 rtc;
// char dataHari[7][12] = { "Minggu", "Senin", "Selasa", "Rabu", "Kamis", "Jum'at", "Sabtu" };
// int tanggal, bulan, tahun, jam, menit, detik;
// String hari, ketHari, ketWaktu;

// // Load Cell
// #define LOADCELL_WADAH_DOUT_PIN 4
// #define LOADCELL_WADAH_SCK_PIN 5
// HX711 lcWadah;
// float calibration_factor_wadah = -388.10; // Faktor kalibrasi load cell

// // Pin Ultrasonic untuk tabung dan wadah
// #define trigPinTabung 6
// #define echoPinTabung 7
// float maxTinggiTabung = 34.5; // Tinggi maksimum tabung (cm)
// float radiusTabung = 4.25; // Radius tabung (cm)

// #define relayPin 8

// // Servo
// Servo myServo;
// #define servoPin 9

// // Pin Ultrasonic untuk wadah
// #define echoPinWadah 10
// #define trigPinWadah 11
// float maxTinggiWadah = 14.5; // Tinggi maksimum wadah (cm)
// float radiusWadah = 4.5; // Radius wadah (cm)

// String sendDataToEsp;
// String request = "";

// bool pumpStatus = false;
// bool servoStatus = false;

// unsigned long previousLCDMillis = 0;
// const long lcdInterval = 1000;

// unsigned long previousNotificationMonitoringMillis = 0;
// const long notificationMonitoringInterval = 30000;

// // Fungsi untuk membaca sensor ultrasonic
// long readUltrasonic(int trigPin, int echoPin) {
//   digitalWrite(trigPin, LOW);
//   delayMicroseconds(2);
//   digitalWrite(trigPin, HIGH);
//   delayMicroseconds(10);
//   digitalWrite(trigPin, LOW);
//   long durasi = pulseIn(echoPin, HIGH);
//   long distance = durasi * 0.034 / 2;
//   return distance;
// }

// // Fungsi untuk menghitung volume dari sebuah silinder
// int calculateCylinderVolume(float heightCm, float radiusCm) {
//   float volumeCm3 = M_PI * (radiusCm * radiusCm) * heightCm;
//   return int(volumeCm3); // Volume in mL
// }

// // Inisialisasi LCD
// void initLCD() {
//   lcd.init();
//   lcd.backlight();
//   lcd.setCursor(5, 1);
//   lcd.print("TUGAS AKHIR");
//   lcd.setCursor(1, 2);
//   lcd.print("INTERNET OF THINGS");
//   delay(3000);
//   lcd.clear();
//   lcd.setCursor(8, 1);
//   lcd.print("Oleh : ");
//   lcd.setCursor(0, 2);
//   lcd.print("Muhammad Aswin Sigit");
//   delay(3000);
//   lcd.clear();
//   lcd.setCursor(3, 1);
//   lcd.print("MULAI PROGRAM");
//   lcd.setCursor(0, 2);
//   lcd.print("AUTOMATIC CAT FEEDER");
//   delay(3000);
// }

// // Inisialisasi RTC
// void initRTC() {
//   DateTime now = rtc.now();
//   tanggal = now.day();
//   bulan = now.month();
//   tahun = now.year();
//   detik = now.second();
//   jam = now.hour();
//   menit = now.minute();
//   hari = dataHari[now.dayOfTheWeek()];
//   ketHari = String(tanggal) + "/" + String(bulan) + "/" + String(tahun);
//   ketWaktu = String(jam) + ":" + String(menit) + ":" + String(detik);
// }

// // Membaca berat pakan dengan Load Cell
// void wadahPakan(int &beratWadah) {
//   beratWadah = lcWadah.get_units(10);
//   if (beratWadah < 0) {
//     beratWadah = 0;
//   }
// }

// // Fungsi sensor Ultrasonic untuk menghitung volume dalam mL
// void sensorUltrasonic(long &tinggiAirWadah, long &tinggiAirTabung, int &volumeAirWadah, int &volumeAirTabung) {
//   tinggiAirWadah = readUltrasonic(trigPinWadah, echoPinWadah);
//   tinggiAirTabung = readUltrasonic(trigPinTabung, echoPinTabung);

//   // Menghitung volume air wadah (silinder) dalam mL
//   float tinggiAirWadahCm = maxTinggiWadah - tinggiAirWadah;
//   volumeAirWadah = calculateCylinderVolume(tinggiAirWadahCm, radiusWadah);

//   // Menghitung volume air tabung (silinder) dalam mL
//   float tinggiAirTabungCm = maxTinggiTabung - tinggiAirTabung;
//   volumeAirTabung = calculateCylinderVolume(tinggiAirTabungCm, radiusTabung);

//   // Handling values <= 0
//   volumeAirWadah = max(volumeAirWadah, 0);
//   volumeAirTabung = max(volumeAirTabung, 0);
// }

// /*
// // Fungsi sensor Ultrasonic untuk menghitung volume dalam mL
// void sensorUltrasonic(long &tinggiAirWadah, long &tinggiAirTabung, int &volumeAirWadah, int &volumeAirTabung) {
//   tinggiAirWadah = readUltrasonic(trigPinWadah, echoPinWadah);
//   tinggiAirTabung = readUltrasonic(trigPinTabung, echoPinTabung);

//   // Menghitung volume air wadah (silinder) dalam mL
//   float tinggiAirWadahCm = maxTinggiWadah - tinggiAirWadah; // Tinggi air di wadah
//   float volumeWadah = 3.14 * (radiusWadah * radiusWadah) * tinggiAirWadahCm; // Volume dalam cm3
//   volumeAirWadah = int(volumeWadah); // Konversi ke integer (volume dalam mL)

//   if (volumeAirWadah <= 0.00){
//     volumeAirWadah = 0.00;
//   }

//   // Menghitung volume air tabung (silinder) dalam mL
//   float tinggiAirTabungCm = maxTinggiTabung - tinggiAirTabung; // Tinggi air di tabung
//   float volumeTabung = 3.14 * (radiusTabung * radiusTabung) * tinggiAirTabungCm; // Volume dalam cm3
//   volumeAirTabung = int(volumeTabung); // Konversi ke integer (volume dalam mL)

//   if (volumeAirTabung <= 0.00){
//     volumeAirTabung = 0.00;
//   }
// }
// */

// void bukaServo(int jumlah) {
//   static int step = 0;
//   static unsigned long previousMillis = 0;
//   const long interval = 1000;
//   unsigned long currentMillis = millis();
//   if (currentMillis - previousMillis >= interval) {
//     previousMillis = currentMillis;
//     if (step == 0) {
//       myServo.write(0);
//       step++;
//     } else if (step == 1) {
//       myServo.write(90);
//       step++;
//     } else if (step == 2) {
//       myServo.write(180);
//       step++;
//     } else if (step == 3) {
//       myServo.write(90);
//       step = 0;
//       jumlah--;
//     }
//   }
//   if (jumlah <= 0) {
//     servoStatus = true;
//   }
// }

// void onPump() {
//   unsigned long startMillis = millis();
//   while (millis() - startMillis <= 5000) {
//     digitalWrite(relayPin, HIGH);
//   }
//   digitalWrite(relayPin, LOW);
//   pumpStatus = true;
// }

// // Membaca data sensor
// void readSensor(int &beratWadah, long &tinggiAirWadah, long &tinggiAirTabung, int &volumeAirWadah, int &volumeAirTabung) {
//   initRTC();
//   wadahPakan(beratWadah);
//   sensorUltrasonic(tinggiAirWadah, tinggiAirTabung, volumeAirWadah, volumeAirTabung);
// }

// void monitoringNotification(String tittle, String message, int delayTime) {
//   lcd.clear();
//   lcd.setCursor(3, 0);
//   lcd.print("NOTIFIKASI !!!");
//   lcd.setCursor(0, 1);
//   lcd.print(tittle);
//   lcd.setCursor(2, 2);
//   lcd.print(message);
//   delay(delayTime);
// }

// void showNotification(String tittle, String message, int delayTime) {
//   lcd.clear();
//   lcd.setCursor(3, 1);
//   lcd.print(tittle);
//   lcd.setCursor(0, 2);
//   lcd.print(message);
//   delay(delayTime);
// }

// void monitoring(int beratWadah, int volumeAirWadah, int volumeAirTabung) {
//   unsigned long currentMillis = millis();
//   if (currentMillis - previousNotificationMonitoringMillis >= notificationMonitoringInterval) {
//     previousNotificationMonitoringMillis = currentMillis;
//     showNotification("NOTIFIKASI !!!", "MONITORING CHECKING!", 3000);
//     if (beratWadah >= 0 && beratWadah < 40) {
//       monitoringNotification("PAKAN WADAH < 40 GR", "WADAH PERLU DIISI!", 2000);
//       showNotification("NOTIFIKASI !!!", "PROSES PENGISIAN ...", 2000);
//       bukaServo(4);
//       showNotification("NOTIFIKASI !!!", "PROCESS SUCCESSFULL!", 2000);
//     } else if (beratWadah >= 41 && beratWadah < 100) {
//       monitoringNotification("PAKAN WADAH < 100 GR", "SEGERA ISI WADAH", 2000);
//     } else if (beratWadah > 120) {
//       monitoringNotification("PAKAN WADAH > 120 GR", "WADAH PAKAN PENUH", 2000);
//     }
//     if (volumeAirWadah >= 0 && volumeAirWadah < 150) {
//       monitoringNotification("AIR WADAH < 150 ML", "WADAH PERLU DIISI", 2000);
//       showNotification("NOTIFIKASI !!!", "PROSES PENGISIAN ...", 2000);
//       onPump();
//       showNotification("NOTIFIKASI !!!", "PROCESS SUCCESSFULL!", 2000);
//     } else if (volumeAirWadah >= 151 && volumeAirWadah < 280) {
//       monitoringNotification("AIR WADAH < 300 ML", "SEGERA ISI WADAH", 2000);
//     } else if (volumeAirWadah > 300) {
//       monitoringNotification("AIR WADAH > 300 ML", "WADAH MINUM PENUH", 2000);
//     }
//     if (volumeAirTabung >= 0 && volumeAirTabung < 300) {
//       monitoringNotification("AIR TABUNG < 300 ML", "SEGERA ISI TABUNG", 2000);
//     } else if (volumeAirTabung > 1000) {
//       monitoringNotification("AIR TABUNG > 1 L", "TABUNG MINUM PENUH", 2000);
//     }
//     if (jam != 7 && jam != 17) {
//       monitoringNotification("DILUAR WAKTU FEEDING", "CEK KET WAKTU", 2000);
//     }
//   }
// }

// void feeder() {  
//   if (jam == 0 && menit == 28 && detik == 0) {
//     showNotification("NOTIFIKASI !!!", "FEEDING CHECKING!!..", 3000);
//     showNotification("NOTIFIKASI !!!", "MORNING FEEDING!!!!!", 2000);
//     showNotification("NOTIFIKASI !!!", "PROSES PENGISIAN ...", 2000);
//     onPump();
//     bukaServo(4);
//     showNotification("NOTIFIKASI !!!", "PROCESS SUCCESSFULL!", 2000);
//   } else if (jam == 17 && menit == 0 && detik == 0) {
//     showNotification("NOTIFIKASI !!!", "FEEDING CHECKING!", 3000);
//     showNotification("NOTIFIKASI !!!", "AFTERNOON FEEDING!!!", 2000);
//     showNotification("NOTIFIKASI !!!", "PROSES PENGISIAN ...", 2000);
//     onPump();
//     bukaServo(4);
//     showNotification("NOTIFIKASI !!!", "PROCESS SUCCESSFULL!", 2000);
//   }
// }

// // Menampilkan data pada LCD (logika mL dan L)
// void displayLCD(int beratWadah, int volumeAirWadah, int volumeAirTabung) {
//   unsigned long currentMillis = millis();
//   if (currentMillis - previousLCDMillis >= lcdInterval) {
//     previousLCDMillis = currentMillis;
//     lcd.clear();

//     // Tampilkan berat pakan
//     lcd.setCursor(0, 0);
//     lcd.print("Pakan Wadah");
//     lcd.setCursor(11, 0);
//     lcd.print(": ");
//     lcd.print(beratWadah);
//     lcd.setCursor(17, 0);
//     lcd.print(" Gr");

//     // Tampilkan volume air di wadah dengan logika mL/L
//     lcd.setCursor(0, 1);
//     lcd.print("Air Wadah");
//     lcd.setCursor(11, 1);
//     lcd.print(": ");
//     if (volumeAirWadah >= 1000) {
//       lcd.print(volumeAirWadah / 1000.0, 1); // Tampilkan dalam liter
//       lcd.setCursor(17, 1);
//       lcd.print(" L");
//     } else {
//       lcd.print(volumeAirWadah);
//       lcd.setCursor(17, 1);
//       lcd.print(" mL");
//     }

//     // Tampilkan volume air di tabung dengan logika mL/L
//     lcd.setCursor(0, 2);
//     lcd.print("Air Tabung");
//     lcd.setCursor(11, 2);
//     lcd.print(": ");
//     if (volumeAirTabung >= 1000) {
//       lcd.print(volumeAirTabung / 1000.0, 1); // Tampilkan dalam liter
//       lcd.setCursor(17, 2);
//       lcd.print(" L");
//     } else {
//       lcd.print(volumeAirTabung);
//       lcd.setCursor(17, 2);
//       lcd.print(" mL");
//     }

//     // Tampilkan waktu saat ini
//     lcd.setCursor(0, 3);
//     lcd.print(ketHari + " - " + ketWaktu);
//   }
// }

// void sendData(int beratWadah, int volumeAirWadah, int volumeAirTabung) {
//   sendDataToEsp = String(beratWadah) + "#" + String(volumeAirWadah) + "#" + String(volumeAirTabung) + "#" + String(pumpStatus) + "#" + String(servoStatus) + "#" + String(ketHari) + "#" + String(ketWaktu);
//   Serial.println(sendDataToEsp);
// }

// void reqData() {
//   if (Serial.available() > 0) {
//     String command = Serial.readStringUntil('\n');
//     if (command == "Pump_ON") {
//       onPump();
//       pumpStatus = true;
//       Serial.println("Pump is ON");
//     } else if (command == "Pump_OFF") {
//       digitalWrite(relayPin, LOW);
//       pumpStatus = false;
//       Serial.println("Pump is OFF");
//     } else if (command == "Servo_ON") {
//       bukaServo(2);
//       servoStatus = true;
//       Serial.println("Servo is ON");
//     } else if (command == "Servo_OFF") {
//       myServo.write(0);
//       servoStatus = false;
//       Serial.println("Servo is OFF");
//     }
//   }
// }

// void setup() {
//   Serial.begin(9600);
//   Wire.begin();
//   if (!rtc.begin()) {
//     Serial.println("RTC Tidak Ditemukan");
//     Serial.flush();
//     abort();
//   }
//   if (rtc.lostPower()) {
//     rtc.adjust(DateTime(F(__DATE__), F(__TIME__)));
//   }
//   lcWadah.begin(LOADCELL_WADAH_DOUT_PIN, LOADCELL_WADAH_SCK_PIN);
//   lcWadah.set_scale(calibration_factor_wadah);
//   lcWadah.tare();
//   pinMode(echoPinTabung, INPUT);
//   pinMode(trigPinTabung, OUTPUT);
//   pinMode(echoPinWadah, INPUT);
//   pinMode(trigPinWadah, OUTPUT);
//   myServo.attach(servoPin);
//   myServo.write(0);
//   pinMode(relayPin, OUTPUT);
//   digitalWrite(relayPin, LOW);
//   initLCD();
// }

// // Fungsi loop utama
// void loop() {
//   int beratWadah;
//   long tinggiAirWadah, tinggiAirTabung;
//   int volumeAirWadah, volumeAirTabung; // Variabel untuk volume air

//   // Baca sensor untuk mendapatkan berat, tinggi, dan volume
//   readSensor(beratWadah, tinggiAirWadah, tinggiAirTabung, volumeAirWadah, volumeAirTabung);

//   // Monitoring kondisi berdasarkan data sensor
//   monitoring(beratWadah, volumeAirWadah, volumeAirTabung);

//   // Kontrol feeder berdasarkan waktu
//   feeder();

//   // Tampilkan data pada LCD dengan logika mL atau L
//   displayLCD(beratWadah, volumeAirWadah, volumeAirTabung);

//   // Kirim data ke ESP (berat wadah, volume air di wadah dan tabung)
//   sendData(beratWadah, volumeAirWadah, volumeAirTabung);

//   // Cek apakah ada permintaan dari ESP untuk menyalakan pump/servo
//   reqData();
// }