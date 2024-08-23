import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:tugas_akhir/app/widgets/card/weekly_card.dart';
import './../../../../app/controllers/page_index_controller.dart';
import './../../../../app/routes/app_pages.dart';
import './../../../../app/styles/app_colors.dart';
import './../../../../app/widgets/CustomWidgets/custom_bottom_navbar.dart';
import '../../data/controllers/data_controller.dart';
import '../controllers/main_controller.dart';

class MainView extends GetView<MainController> {
  final pageIndexController = Get.find<PageIndexController>();
  final dataController = Get.find<DataController>();

  MainView({super.key});

  @override
  Widget build(BuildContext context) {
    MainController mc = Get.put(MainController());
    return Scaffold(
        bottomNavigationBar: const CustomBottomNavigationBar(),
        extendBody: true,
        body: StreamBuilder<DatabaseEvent>(
          stream: controller.streamUser(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text("Error loading data"));
            } else if (!snapshot.hasData ||
                snapshot.data!.snapshot.value == null) {
              return const Center(child: Text("No Data"));
            } else {
              Map<String, dynamic> user = Map<String, dynamic>.from(
                  snapshot.data!.snapshot.value as Map);
              String avatarUrl = user["avatar"] ?? "";
              if (avatarUrl.isEmpty) {
                avatarUrl = "https://ui-avatars.com/api/?name=${user['name']}";
              }
              return ListView(
                physics: const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
                children: [
                  const SizedBox(height: 16),
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      children: [
                        ClipOval(
                          child: SizedBox(
                            width: 42,
                            height: 42,
                            child: Image.network(
                              (user["avatar"] == null || user['avatar'] == "")
                                  ? "https://ui-avatars.com/api/?name=${user['name']}/"
                                  : user['avatar'],
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Selamat Datang",
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.secondarySoft,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user["name"] ?? "",
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontFamily: 'poppins',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.only(
                        left: 24, top: 24, right: 24, bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primary),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Feeder",
                              style: TextStyle(
                                fontSize: 20,
                                color: AppColors.primary,
                              ),
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Get.toNamed(Routes.STATUS_ALAT);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 18),
                                      elevation: 0,
                                      shadowColor: const Color(0x3F000000),
                                    ),
                                    icon: SvgPicture.asset(
                                        'assets/icons/tools.svg'),
                                    label: const Text(
                                      "Cek Status Alat",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        fontFamily: 'poppins',
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Divider(
                          color: Colors.black,
                          thickness: 1,
                        ),
                        const SizedBox(height: 15),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Obx(
                              () => FlutterSwitch(
                                toggleSize: 30,
                                width: 110,
                                height: 55,
                                valueFontSize: 15,
                                padding: 7,
                                activeText: "Servo",
                                activeIcon: const Text("ON"),
                                activeColor: AppColors.success,
                                activeTextFontWeight: FontWeight.normal,
                                inactiveText: "Servo",
                                inactiveIcon: const Text("OFF"),
                                inactiveColor: AppColors.error,
                                inactiveTextFontWeight: FontWeight.normal,
                                showOnOff: true,
                                value: mc.servoSwitched.value,
                                onToggle: (val) => mc.servoControl(),
                              ),
                            ),
                            Obx(
                              () => FlutterSwitch(
                                toggleSize: 30,
                                width: 110,
                                height: 55,
                                valueFontSize: 15,
                                padding: 7,
                                activeText: "Pump Water",
                                activeIcon: const Text("ON"),
                                activeColor: AppColors.success,
                                activeTextFontWeight: FontWeight.normal,
                                inactiveText: "Pump Water",
                                inactiveIcon: const Text("OFF"),
                                inactiveColor: AppColors.error,
                                inactiveTextFontWeight: FontWeight.normal,
                                showOnOff: true,
                                value: mc.pumpSwitched.value,
                                onToggle: (val) => mc.pumpControl(),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Stok Pakan",
                        style: TextStyle(
                          fontFamily: 'poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                      MainTile(
                        title: "Log Data",
                        icon: SvgPicture.asset('assets/icons/database.svg'),
                        onTap: () => Get.toNamed(Routes.DETAIL_JADWAL),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // display data total makanan harian dan mingguan
                  FutureBuilder<Map<String, double>>(
                    future: controller.calculateTotals(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return const Center(child: Text("Error loading data"));
                      } else if (!snapshot.hasData) {
                        return const Center(child: Text("No Data"));
                      } else {
                        final data = snapshot.data!;
                        return SizedBox(
                          child: Column(
                            children: [
                              WeeklyCard(
                                title: "Total Food / Day",
                                value: controller
                                    .formatOutput(data['totalFoodDay']!),
                              ),
                              const SizedBox(height: 15),
                              WeeklyCard(
                                title: "Total Water / Day",
                                value: controller
                                    .formatWaterOutput(data['totalWaterDay']!),
                              ),
                              const SizedBox(height: 15),
                              WeeklyCard(
                                title: "Total Food/ Week",
                                value: controller
                                    .formatOutput(data['totalFoodWeek']!),
                              ),
                              const SizedBox(height: 15),
                              WeeklyCard(
                                  title: "Total Water / Week",
                                  value: controller.formatWaterOutput(
                                      data['totalWaterWeek']!)),
                              const SizedBox(height: 15),
                            ],
                          ),
                        );
                      }
                    },
                  ),

                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Jadwal Feeder",
                        style: TextStyle(
                          fontFamily: 'poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                      MainTile(
                        title: "Tambah Jadwal",
                        icon: SvgPicture.asset('assets/icons/tambah.svg'),
                        onTap: () => Get.toNamed(Routes.TAMBAH_JADWAL),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Obx(() {
                    return Card(
                      child: TableCalendar(
                        focusedDay: dataController.focusedDay.value,
                        firstDay: DateTime(1950),
                        lastDay: DateTime(2100),
                        headerStyle: HeaderStyle(
                          decoration: BoxDecoration(color: AppColors.primary),
                          headerMargin: const EdgeInsets.only(bottom: 8.0),
                          titleTextStyle: const TextStyle(color: Colors.white),
                          formatButtonDecoration: BoxDecoration(
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          formatButtonTextStyle:
                              const TextStyle(color: Colors.white),
                          leftChevronIcon: const Icon(
                            Icons.chevron_left,
                            color: Colors.white,
                          ),
                          rightChevronIcon: const Icon(
                            Icons.chevron_right,
                            color: Colors.white,
                          ),
                        ),
                        calendarStyle: CalendarStyle(
                          todayDecoration: BoxDecoration(
                              color: AppColors.primary, shape: BoxShape.circle),
                          todayTextStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'poppins',
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          weekendTextStyle: TextStyle(color: AppColors.primary),
                          selectedDecoration: BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                          selectedTextStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'poppins',
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        eventLoader: (day) {
                          var eventsForDay = dataController.getEvents(day);
                          return eventsForDay;
                        },
                        selectedDayPredicate: (day) {
                          return isSameDay(
                              dataController.selectedDay.value, day);
                        },
                        onDaySelected: (selectedDay, focusedDay) {
                          if (!isSameDay(
                              dataController.selectedDay.value, selectedDay)) {
                            dataController.selectedDay.value = selectedDay;
                            dataController.focusedDay.value = focusedDay;
                            var eventsForDay =
                                dataController.getEvents(selectedDay);
                            if (eventsForDay.isNotEmpty) {
                              dataController.showEventDetails(eventsForDay);
                            }
                          }
                        },
                        onPageChanged: (focusedDay) {
                          dataController.focusedDay.value = focusedDay;
                        },
                      ),
                    );
                  }),
                ],
              );
            }
          },
        ));
  }
}

class MainTile extends StatelessWidget {
  final String title;
  final Widget icon;
  final void Function() onTap;
  final bool isDanger;

  const MainTile({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            child: icon,
          ),
          const SizedBox(width: 5),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
