import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import './../../../../app/widgets/dialog/custom_notification.dart';
import './../../data_pengguna.dart';

class FeederController extends GetxController {
  RxBool isLoading = false.obs;
  RxString currentTime = RxString('');
  RxBool isTimeInitialized = RxBool(false);
  FirebaseAuth auth = FirebaseAuth.instance;
  DatabaseReference database = FirebaseDatabase.instance.ref();

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeTimeListener();
  }

  Future<void> _initializeTimeListener() async {
    try {
      String uid = auth.currentUser!.uid;
      database.child("UsersData/$uid/iot/monitoring").onValue.listen(
        (event) {
          if (event.snapshot.value != null) {
            Map<String, dynamic> data =
                Map<String, dynamic>.from(event.snapshot.value as Map);
            currentTime.value = data['ketWaktu']?.toString() ?? '';
            isTimeInitialized.value = true;
          }
        },
        onError: (error) {
          CustomNotification.errorNotification("Kesalahan Koneksi",
              "Gagal mendapatkan data waktu: ${error.toString()}");
        },
      );
    } catch (e) {
      CustomNotification.errorNotification("Terjadi Kesalahan",
          "Error inisialisasi listener waktu: ${e.toString()}");
    }
  }

  Future<void> feeder() async {
    isLoading.value = true;

    try {
      await Future.delayed(const Duration(seconds: 2));

      if (!isTimeInitialized.value || currentTime.value.isEmpty) {
        isLoading.value = false;
        CustomNotification.errorNotification("Terjadi Kesalahan",
            "Gagal mendapatkan waktu saat ini. Periksa koneksi database.");
        return;
      }

      String uid = auth.currentUser!.uid;
      DatabaseReference monitoringRef =
          database.child("UsersData/$uid/iot/monitoring");
      DatabaseReference feederRef = database.child("UsersData/$uid/iot/feeder");
      DatabaseReference systemsStatusRef =
          database.child("UsersData/$uid/iot/systemsStatus");

      DatabaseEvent monitoringSnapshot = await monitoringRef.once();
      Map<String, dynamic> monitoringData =
          Map<String, dynamic>.from(monitoringSnapshot.snapshot.value as Map);

      DatabaseEvent systemsStatusSnapshot = await systemsStatusRef.once();
      Map<String, dynamic> systemsStatusData = Map<String, dynamic>.from(
          systemsStatusSnapshot.snapshot.value as Map);

      if (systemsStatusData['isConnected'] == true) {
        isLoading.value = false;
        CustomNotification.errorNotification("Perangkat Aktif",
            "Button feeder hanya dapat digunakan saat perangkat tidak bekerja.");
        return;
      }

      String todayDocId =
          DateFormat.yMd().format(DateTime.now()).replaceAll("/", "-");
      bool isValidMorning =
          _isWithinFeedingTime(currentTime.value, "07:00", 15, 60);
      bool isValidAfternoon =
          _isWithinFeedingTime(currentTime.value, "17:00", 15, 60);

      DatabaseEvent morningFeedEvent =
          await feederRef.child("jadwalPagi/$todayDocId").once();
      DatabaseEvent afternoonFeedEvent =
          await feederRef.child("jadwalSore/$todayDocId").once();

      if ((isValidMorning && morningFeedEvent.snapshot.value != null) ||
          (isValidAfternoon && afternoonFeedEvent.snapshot.value != null)) {
        isLoading.value = false;
        CustomNotification.errorNotification("Terjadi Kesalahan",
            "Sudah terdapat jadwal pemberian makan pada tanggal ini.");
        return;
      }

      if (!isValidMorning && !isValidAfternoon) {
        isLoading.value = false;
        CustomNotification.errorNotification("Terjadi Kesalahan",
            "Tidak berada dalam rentang waktu (07:00 & 17:00) untuk memberi makan dan minum kucing.");
        return;
      }

      Map<String, dynamic> determinePosition = await _determinePosition();
      if (!determinePosition["error"]) {
        Position position = determinePosition["position"];
        List<Placemark> placemarks = await placemarkFromCoordinates(
            position.latitude, position.longitude);
        String alamat =
            "${placemarks.first.street}, ${placemarks.first.subLocality}, ${placemarks.first.locality}";
        double distance = Geolocator.distanceBetween(
          DataPengguna.house['latitude'],
          DataPengguna.house['longtitude'],
          position.latitude,
          position.longitude,
        );
        if (isValidAfternoon && !isValidMorning) {
          await _processFeederBackup(feederRef, todayDocId, position, alamat,
              distance, "afternoon", monitoringData);
        } else if (isValidMorning) {
          await _processFeederBackup(feederRef, todayDocId, position, alamat,
              distance, "morning", monitoringData);
        }
        await updatePumpAndServoStatus(true, true);
        isLoading.value = false;
      } else {
        isLoading.value = false;
        CustomNotification.errorNotification(
            "Terjadi Kesalahan", determinePosition["message"]);
      }
    } catch (e) {
      isLoading.value = false;
      CustomNotification.errorNotification(
          "Terjadi Kesalahan", "Error: ${e.toString()}");
    }
  }

  Future<void> _processFeederBackup(
    DatabaseReference feederRef,
    String todayDocId,
    Position position,
    String alamat,
    double distance,
    String feederType,
    Map<String, dynamic> monitoringData,
  ) async {
    bool inArea = distance <= 200;

    Map<String, dynamic> feederData = {
      "date": DateTime.now().toIso8601String(),
      "latitude": position.latitude,
      "longtitude": position.longitude,
      "alamat": alamat,
      "in_area": inArea,
      "distance": distance,
      "beratWadah": monitoringData['beratWadah'],
      "ketHari": DateFormat('dd/MM/yyyy').format(DateTime.now()),
      "ketWaktu": feederType == "morning" ? "7:0:0" : "17:0:0",
      "volumeMLTabung": monitoringData['volumeMLTabung'],
      "volumeMLWadah": monitoringData['volumeMLWadah'],
    };

    if (feederType == "morning") {
      await feederRef.child("jadwalPagi").child(todayDocId).set(feederData);
      CustomNotification.successNotification(
          "Sukses", "Berhasil Melakukan Feeder Backup di Pagi Hari");
    } else {
      await feederRef.child("jadwalSore").child(todayDocId).set(feederData);
      CustomNotification.successNotification(
          "Sukses", "Berhasil Melakukan Feeder Backup di Sore Hari");
    }
  }

  bool _isWithinFeedingTime(String currentTime, String feedTime,
      int toleranceBefore, int toleranceAfter) {
    DateTime current = DateFormat("HH:mm").parse(currentTime);
    DateTime feed = DateFormat("HH:mm").parse(feedTime);
    DateTime startValidTime = feed.subtract(Duration(minutes: toleranceBefore));
    DateTime endValidTime = feed.add(Duration(minutes: toleranceAfter));

    return current.isAfter(startValidTime) && current.isBefore(endValidTime);
  }

  Future<void> updatePosisi(Position position, String alamat) async {
    String uid = auth.currentUser!.uid;
    await database.child("UsersData/$uid/UsersProfile").update({
      "position": {
        "latitude": position.latitude,
        "longtitude": position.longitude,
      },
      "address": alamat,
    });
  }

  Future<void> updatePumpAndServoStatus(
      bool pumpControl, bool servoControl) async {
    String uid = auth.currentUser!.uid;
    await database.child("UsersData/$uid/iot/control").update({
      "pumpControl": pumpControl,
      "servoControl": servoControl,
    });
  }

  Future<Map<String, dynamic>> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return {
        "message": "Layanan lokasi dinonaktifkan.",
        "error": true,
      };
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return {
          "message":
              "Akses lokasi ditolak. Izinkan akses lokasi untuk melanjutkan.",
          "error": true,
        };
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return {
        "message":
            "Akses lokasi ditolak secara permanen. Buka pengaturan untuk mengubah izin.",
        "error": true,
      };
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);

    return {
      "position": position,
      "message": "Berhasil mendapatkan posisi perangkat",
      "error": false,
    };
  }
}
