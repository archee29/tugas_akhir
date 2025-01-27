#include <Wire.h>
#include <RTClib.h>

RTC_DS3231 rtc;

const int testStartHour = 7;
const int testEndHour = 21;
const int testInterval = 30;
const int totalTests = 30;

void setup() {
  Serial.begin(9600);
  Wire.begin();
  
  if (!rtc.begin()) {
    Serial.println("RTC not found");
    while (1);
  }
}

void performRTCTest() {
  for (int test = 1; test <= totalTests; test++) {
    DateTime rtcTime = rtc.now();
    
    String testData = String(test) + "#" + 
                      String(rtcTime.hour()) + ":" + 
                      String(rtcTime.minute()) + ":" + 
                      String(rtcTime.second());
    
    Serial.println(testData);
    delay(testInterval * 60 * 1000);
  }
}

void loop() {
  DateTime now = rtc.now();
  if (now.hour() >= testStartHour && now.hour() < testEndHour) {
    performRTCTest();
  }
  
  delay(60000);
}