import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:tugas_akhir/app/widgets/card/weekly_card.dart';
import '../../../controllers/page_index_controller.dart';
import '../../../routes/app_pages.dart';
import '../../../styles/app_colors.dart';
import '../../../widgets/CustomWidgets/custom_bottom_navbar.dart';
import '../../../widgets/CustomWidgets/custom_textfield.dart';
import '../../detail_feeder/controllers/detail_feeder_controller.dart';
import '../controllers/statistik_controller.dart';

class StatistikView extends GetView<StatistikController> {
  final pageIndexController = Get.find<PageIndexController>();
  final dataFeederController = Get.find<DetailFeederController>();

  StatistikView({super.key});

  @override
  Widget build(BuildContext context) {
    StatistikController statistikController = Get.put(StatistikController());
    return Scaffold(
        bottomNavigationBar: const CustomBottomNavigationBar(),
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
                padding: const EdgeInsets.only(
                    left: 20, right: 20, top: 36, bottom: 15),
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
                      border:
                          Border.all(color: AppColors.primarySoft, width: 3),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Otomatisasi",
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
                                value: statistikController.servoSwitched.value,
                                onToggle: (val) =>
                                    statistikController.servoControl(),
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
                                value: statistikController.pumpSwitched.value,
                                onToggle: (val) =>
                                    statistikController.pumpControl(),
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
                        onTap: () => Get.toNamed(Routes.CHART),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  StreamBuilder<Map<String, double>>(
                      stream: controller.calculateTotals(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                            child:
                                Text("Error loading data: ${snapshot.error}"),
                          );
                        } else if (!snapshot.hasData) {
                          return const Center(child: Text("No Data"));
                        } else {
                          final data = snapshot.data!;
                          return SingleChildScrollView(
                              child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: SizedBox(
                                      child: Column(children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        WeeklyCard(
                                          title: "Total Food / Day",
                                          value: controller.formatFoodOutput(
                                              data['totalFoodDay']!),
                                        ),
                                        WeeklyCard(
                                          title: "Total Water / Day",
                                          value: controller.formatWaterOutput(
                                              data['totalFoodDay']!),
                                        ),
                                      ],
                                    ),
                                    Center(
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxWidth: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.95,
                                        ),
                                        child: CustomTextField(
                                          title: "Nilai RER",
                                          subTitle:
                                              "Nilai Asupan Harian\nMakan dan Minum Kucing",
                                          titleNilai: "Makanan",
                                          valueNilai:
                                              controller.formatFoodOutput(
                                                  data['totalFoodDay']!),
                                          titlePertumbuhan: "Minuman",
                                          valuePertumbuhan:
                                              controller.formatWaterOutput(
                                                  data['totalWaterDay']!),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 35),
                                    SizedBox(
                                        child: Column(children: [
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            WeeklyCard(
                                              title: "Total Food / Week",
                                              value:
                                                  controller.formatFoodOutput(
                                                      data['totalFoodWeek']!),
                                            ),
                                            WeeklyCard(
                                              title: "Total Water / Week",
                                              value:
                                                  controller.formatWaterOutput(
                                                      data['totalFoodWeek']!),
                                            )
                                          ]),
                                      Center(
                                        child: ConstrainedBox(
                                          constraints: BoxConstraints(
                                            maxWidth: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.95,
                                          ),
                                          child: CustomTextField(
                                            title: "Pertumbuhan Kucing",
                                            subTitle:
                                                "Berat Ideal Kucing\nPertumbuhan Mingguan, Berat Badan Kucing",
                                            titleNilai: "Sebelum",
                                            valueNilai:
                                                controller.formatFoodOutput(
                                                    data['totalFoodDay']!),
                                            titlePertumbuhan: "Sesudah",
                                            valuePertumbuhan:
                                                controller.formatFoodOutput(
                                                    data['totalFoodWeek']!),
                                          ),
                                        ),
                                      ),
                                    ]))
                                  ]))));
                        }
                      }),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Feeder",
                        style: TextStyle(
                          fontFamily: 'poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                      MainTile(
                        title: "Penjadwalan",
                        icon: SvgPicture.asset('assets/icons/penjadwalan.svg'),
                        onTap: () => Get.toNamed(Routes.DETAIL_FEEDER),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Obx(() {
                    return Card(
                      child: TableCalendar(
                        focusedDay: dataFeederController.focusedDay.value,
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
                          var eventsForDay =
                              dataFeederController.getEvents(day);
                          return eventsForDay;
                        },
                        selectedDayPredicate: (day) {
                          return isSameDay(
                              dataFeederController.selectedDay.value, day);
                        },
                        onDaySelected: (selectedDay, focusedDay) {
                          if (!isSameDay(dataFeederController.selectedDay.value,
                              selectedDay)) {
                            dataFeederController.selectedDay.value =
                                selectedDay;
                            dataFeederController.focusedDay.value = focusedDay;
                            var eventsForDay =
                                dataFeederController.getEvents(selectedDay);
                            if (eventsForDay.isNotEmpty) {
                              dataFeederController
                                  .showEventDetails(eventsForDay);
                            }
                          }
                        },
                        onPageChanged: (focusedDay) {
                          dataFeederController.focusedDay.value = focusedDay;
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
