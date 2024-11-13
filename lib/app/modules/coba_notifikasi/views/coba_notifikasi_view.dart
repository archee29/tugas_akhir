// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';

// import 'package:get/get.dart';
// import 'package:intl/intl.dart';

// import '../../../routes/app_pages.dart';
// import '../../../styles/app_colors.dart';
// import '../../../widgets/CustomWidgets/custom_input.dart';
// import '../../../widgets/CustomWidgets/custom_schedule_input.dart';
// import '../controllers/coba_notifikasi_controller.dart';

// class CobaNotifikasiView extends GetView<CobaNotifikasiController> {
//   const CobaNotifikasiView({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Coba Notifikasi',
//           style: TextStyle(
//             color: AppColors.secondary,
//             fontSize: 14,
//           ),
//         ),
//         leading: IconButton(
//           onPressed: () => Get.back(),
//           icon: SvgPicture.asset('assets/icons/arrow-left.svg'),
//         ),
//         backgroundColor: Colors.white,
//         elevation: 0,
//         centerTitle: true,
//         bottom: PreferredSize(
//           preferredSize: const Size.fromHeight(1),
//           child: Container(
//             width: MediaQuery.of(context).size.width,
//             height: 1,
//             color: AppColors.secondaryExtraSoft,
//           ),
//         ),
//       ),
//       extendBody: true,
//       body: ListView(
//         shrinkWrap: true,
//         physics: const BouncingScrollPhysics(),
//         padding: const EdgeInsets.all(20),
//         children: [
//           // Kalender
//           CustomScheduleInput(
//             controller: controller.dateController,
//             suffixIcon: const Icon(Icons.calendar_month_outlined),
//             label: "Kalender",
//             hint: DateFormat("dd-MM-yyyy")
//                 .format(controller.selectedDate.value)
//                 .toString(),
//             onTap: () {
//               controller.chooseDate();
//             },
//           ),

//           // Custom Time Input 07/17
//           TimeInput(
//             controller: controller.timeController,
//             label: "Pilih Waktu",
//             hint: "Pilih Waktu",
//             onTap: controller.handleTimeSelection,
//             disabled: true, // or true if you want it disabled
//           ),

//           // Input Judul
//           CustomInput(
//             controller: controller.titleController,
//             suffixIcon: const Icon(Icons.text_snippet_outlined),
//             label: "Judul",
//             hint: "Masukkan Judul",
//           ),
//           // Input Deskripsi
//           CustomInput(
//             controller: controller.deskripsiController,
//             suffixIcon: const Icon(Icons.text_snippet_outlined),
//             label: "Deskripsi",
//             hint: "Masukkan Deskripsi",
//           ),
//           // Input Makanan
//           CustomInput(
//             controller: controller.makananController,
//             suffixIcon: const Icon(Icons.fastfood_outlined),
//             label: "Makanan",
//             hint: "Masukkan Jumlah Makanan",
//             keyboardType: TextInputType.number,
//           ),
//           // Input Minuman
//           CustomInput(
//             controller: controller.minumanController,
//             suffixIcon: const Icon(Icons.fastfood_outlined),
//             label: "Minuman",
//             hint: "Masukkan Jumlah Minuman",
//             keyboardType: TextInputType.number,
//           ),

//           const SizedBox(height: 20),
//           // Button
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               // Cancel Button
//               SizedBox(
//                 width: 120,
//                 height: 60,
//                 child: ElevatedButton.icon(
//                   onPressed: () {
//                     Get.toNamed(Routes.MAIN);
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(vertical: 18),
//                     elevation: 0,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                       side:
//                           const BorderSide(width: 1, color: Color(0xFFFF39B0)),
//                     ),
//                     shadowColor: const Color(0x3F000000),
//                   ),
//                   icon: SvgPicture.asset('assets/icons/cancel_button.svg'),
//                   label: const Text(
//                     "Cancel",
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontWeight: FontWeight.w600,
//                       fontSize: 12,
//                       fontFamily: 'poppins',
//                     ),
//                   ),
//                 ),
//               ),
//               // Tambah Button
//               SizedBox(
//                 width: 200,
//                 height: 60,
//                 child: Obx(
//                   () => ElevatedButton.icon(
//                     onPressed: () {
//                       if (controller.isLoading.isFalse) {
//                         controller.cobaNotifikasi();
//                       }
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.primary,
//                       padding: const EdgeInsets.symmetric(vertical: 18),
//                       elevation: 0,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                         side: const BorderSide(
//                           width: 1,
//                           color: Colors.white,
//                         ),
//                       ),
//                       shadowColor: const Color(0x3F000000),
//                     ),
//                     icon: SvgPicture.asset('assets/icons/tambah_button.svg'),
//                     label: Text(
//                       (controller.isLoading.isFalse)
//                           ? 'Coba Notifikasi'
//                           : 'Loading ...',
//                       style: const TextStyle(
//                         fontSize: 14,
//                         fontFamily: 'poppins',
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../controllers/notification_service.dart';

class CobaNotifikasiView extends StatelessWidget {
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController bodyController = TextEditingController();
  final NotificationService notificationService = NotificationService();

  CobaNotifikasiView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Notification'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: dateController,
              decoration:
                  const InputDecoration(labelText: 'Tanggal (MM/dd/yyyy)'),
              onTap: () async {
                FocusScope.of(context)
                    .requestFocus(FocusNode()); // Hide keyboard
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  dateController.text =
                      DateFormat('MM/dd/yyyy').format(pickedDate);
                }
              },
            ),
            TextField(
              controller: timeController,
              decoration: const InputDecoration(labelText: 'Waktu (HH:mm)'),
              onTap: () async {
                FocusScope.of(context)
                    .requestFocus(FocusNode()); // Hide keyboard
                TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (pickedTime != null) {
                  timeController.text = pickedTime.format(context);
                }
              },
            ),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Judul Notifikasi'),
            ),
            TextField(
              controller: bodyController,
              decoration: const InputDecoration(labelText: 'Isi Notifikasi'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (dateController.text.isNotEmpty &&
                    timeController.text.isNotEmpty) {
                  try {
                    DateTime scheduleTime = DateFormat('MM/dd/yyyy HH:mm')
                        .parse('${dateController.text} ${timeController.text}');
                    await notificationService.scheduleNotification(
                      scheduleTime,
                      titleController.text,
                      bodyController.text,
                    );
                    Get.snackbar("Notifikasi Terjadwal",
                        "Notifikasi berhasil dijadwalkan untuk $scheduleTime");
                  } catch (e) {
                    Get.snackbar(
                        "Kesalahan", "Gagal menjadwalkan notifikasi: $e");
                  }
                } else {
                  Get.snackbar("Kesalahan", "Harap isi semua field");
                }
              },
              child: const Text('Jadwalkan Notifikasi'),
            ),
          ],
        ),
      ),
    );
  }
}

// class TimeInput extends StatelessWidget {
//   final TextEditingController controller;
//   final String label;
//   final String hint;
//   final bool disabled;
//   final EdgeInsetsGeometry margin;
//   final bool obsecureText;
//   final Widget? suffixIcon;
//   final VoidCallback onTap;

//   const TimeInput({
//     super.key,
//     required this.controller,
//     required this.label,
//     required this.hint,
//     required this.onTap,
//     this.disabled = true,
//     this.margin = const EdgeInsets.only(bottom: 16),
//     this.obsecureText = false,
//     this.suffixIcon,
//   });

//   Future<void> _selectTime(BuildContext context) async {
//     final TimeOfDay? pickedTime = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.now(),
//       builder: (context, child) {
//         return MediaQuery(
//           data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
//           child: child!,
//         );
//       },
//     );

//     if (pickedTime != null) {
//       final now = DateTime.now();
//       final formattedTime = DateFormat.Hm().format(DateTime(
//           now.year, now.month, now.day, pickedTime.hour, pickedTime.minute));
//       controller.text = formattedTime;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Colors.white,
//       child: Container(
//         width: MediaQuery.of(context).size.width,
//         padding: const EdgeInsets.only(left: 14, right: 14, top: 4, bottom: 10),
//         margin: margin,
//         decoration: BoxDecoration(
//           color: (disabled == false)
//               ? Colors.transparent
//               : AppColors.primaryExtraSoft,
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(width: 1, color: AppColors.secondaryExtraSoft),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             TextField(
//               onTap: () => _selectTime(context),
//               readOnly: disabled,
//               obscureText: obsecureText,
//               style: const TextStyle(
//                 fontSize: 14,
//                 fontFamily: 'poppins',
//               ),
//               maxLines: 1,
//               controller: controller,
//               decoration: InputDecoration(
//                 suffixIcon: suffixIcon ?? const SizedBox(),
//                 label: Text(
//                   label,
//                   style: TextStyle(
//                     color: AppColors.primary,
//                     fontSize: 14,
//                   ),
//                 ),
//                 floatingLabelBehavior: FloatingLabelBehavior.always,
//                 border: InputBorder.none,
//                 hintText: hint,
//                 hintStyle: TextStyle(
//                   fontSize: 14,
//                   fontFamily: 'poppins',
//                   fontWeight: FontWeight.w500,
//                   color: AppColors.secondarySoft,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
