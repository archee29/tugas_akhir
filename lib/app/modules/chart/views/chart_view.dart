import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../styles/app_colors.dart';
import '../../../widgets/CustomWidgets/custom_bottom_navbar.dart';
import '../../../routes/app_pages.dart';
import '../controllers/chart_controller.dart';

class ChartView extends GetView<ChartController> {
  const ChartView({super.key});
  Color getProgressColor(String scale, double percent) {
    if (percent > 1.0) {
      return Colors.orange;
    }
    switch (scale) {
      case "Low":
        return Colors.red;
      case "Medium":
        return Colors.yellow;
      case "High":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
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
            Map<String, dynamic> user =
                Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);
            String avatarUrl = user["avatar"] ?? "";
            if (avatarUrl.isEmpty) {
              avatarUrl = "https://ui-avatars.com/api/?name=${user['name']}";
            }
            return ListView(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 36,
                bottom: 15,
              ),
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Chart Feeder",
                          style: TextStyle(
                            fontFamily: 'poppins',
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                        DetailTile(
                          title: "Data Feeder",
                          icon: SvgPicture.asset('assets/icons/database.svg'),
                          onTap: () => Get.toNamed(Routes.DETAIL_FEEDER),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      height: 290,
                      child: SfCartesianChart(
                        legend: const Legend(isVisible: true),
                        tooltipBehavior: TooltipBehavior(
                          enable: true,
                          builder: (dynamic data, dynamic point, dynamic series,
                              int pointIndex, int seriesIndex) {
                            Color tooltipColor;
                            Color textColor = Colors.white;
                            String unit = '';
                            switch (series.name) {
                              case 'Makanan Pagi':
                                tooltipColor = Colors.blue;
                                unit = 'Gr';
                                break;
                              case 'Minuman Pagi':
                                tooltipColor = Colors.green;
                                unit = 'mL';
                                break;
                              case 'Makanan Sore':
                                tooltipColor = Colors.yellow;
                                unit = 'Gr';
                                break;
                              case 'Minuman Sore':
                                tooltipColor = AppColors.primary;
                                unit = 'mL';
                                break;
                              default:
                                tooltipColor = Colors.grey;
                            }

                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: tooltipColor,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    series.name,
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Divider(
                                    color: textColor.withOpacity(0.5),
                                    thickness: 1,
                                    height: 8,
                                  ),
                                  Text(
                                    '${point.x} : ${point.y} $unit',
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        primaryXAxis: const CategoryAxis(
                          labelIntersectAction:
                              AxisLabelIntersectAction.rotate45,
                          interval: 1,
                          // plotOffset: 5,
                        ),
                        primaryYAxis: const NumericAxis(),
                        series: <CartesianSeries>[
                          ColumnSeries<Map<String, dynamic>, String>(
                            dataSource: controller.listDataMf,
                            xValueMapper: (Map<String, dynamic> data, _) =>
                                data['ketHari'] as String,
                            yValueMapper: (Map<String, dynamic> data, _) =>
                                int.tryParse(
                                    data['beratWadah']?.toString() ?? '0'),
                            name: 'Makanan Pagi',
                            color: Colors.blue,
                            width: 0.8,
                            spacing: 0.1,
                            dataLabelSettings:
                                const DataLabelSettings(isVisible: false),
                          ),
                          ColumnSeries<Map<String, dynamic>, String>(
                            dataSource: controller.listDataMf,
                            xValueMapper: (Map<String, dynamic> data, _) =>
                                data['ketHari'] as String,
                            yValueMapper: (Map<String, dynamic> data, _) =>
                                int.tryParse(
                                    data['volumeMLWadah']?.toString() ?? '0'),
                            name: 'Minuman Pagi',
                            color: Colors.green,
                            width: 0.8,
                            spacing: 0.1,
                            dataLabelSettings:
                                const DataLabelSettings(isVisible: false),
                          ),
                          ColumnSeries<Map<String, dynamic>, String>(
                            dataSource: controller.listDataAf,
                            xValueMapper: (Map<String, dynamic> data, _) =>
                                data['ketHari'] as String,
                            yValueMapper: (Map<String, dynamic> data, _) =>
                                int.tryParse(
                                    data['beratWadah']?.toString() ?? '0'),
                            name: 'Makanan Sore',
                            width: 0.8,
                            spacing: 0.1,
                            color: Colors.yellow,
                            dataLabelSettings:
                                const DataLabelSettings(isVisible: false),
                          ),
                          ColumnSeries<Map<String, dynamic>, String>(
                            dataSource: controller.listDataAf,
                            xValueMapper: (Map<String, dynamic> data, _) =>
                                data['ketHari'] as String,
                            yValueMapper: (Map<String, dynamic> data, _) =>
                                int.tryParse(
                                    data['volumeMLWadah']?.toString() ?? '0'),
                            name: 'Minuman Sore',
                            width: 0.8,
                            spacing: 0.1,
                            color: AppColors.primary,
                            dataLabelSettings:
                                const DataLabelSettings(isVisible: false),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Statistik Monitoring",
                          style: TextStyle(
                            fontFamily: 'poppins',
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                        DetailTile(
                          title: "IoT Data",
                          icon: SvgPicture.asset('assets/icons/wifi.svg'),
                          onTap: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    StreamBuilder<Map<String, double>>(
                      stream: controller.streamMonitoring(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child:
                                Text("Error loading data: ${snapshot.error}"),
                          );
                        } else if (!snapshot.hasData || snapshot.data == null) {
                          return const Center(child: Text("No Data"));
                        } else {
                          final data = snapshot.data!;
                          double beratWadah = data['beratWadah'] ?? 0;
                          double volumeMLWadah = data['volumeMLWadah'] ?? 0;
                          double volumeMLTabung = data['volumeMLTabung'] ?? 0;

                          String beratWadahDisplay = beratWadah > 999
                              ? "${(beratWadah / 1000).toStringAsFixed(2)} Kg"
                              : "${beratWadah.toStringAsFixed(2)} Gr";
                          String volumeMLWadahDisplay = volumeMLWadah > 999
                              ? "${(volumeMLWadah / 1000).toStringAsFixed(2)} L"
                              : "${volumeMLWadah.toStringAsFixed(2)} mL";
                          String volumeMLTabungDisplay = volumeMLTabung > 999
                              ? "${(volumeMLTabung / 1000).toStringAsFixed(2)} L"
                              : "${volumeMLTabung.toStringAsFixed(2)} mL";

                          double beratWadahPercent = beratWadah / 120;
                          double volumeMLWadahPercent = volumeMLWadah / 300;
                          double volumeMLTabungPercent = volumeMLTabung / 1000;

                          String beratWadahScale = beratWadahPercent > 1.0
                              ? "Over"
                              : beratWadahPercent < 0.33
                                  ? "Low"
                                  : beratWadahPercent < 0.66
                                      ? "Medium"
                                      : "High";
                          String volumeMLWadahScale = volumeMLWadahPercent > 1.0
                              ? "Over"
                              : volumeMLWadahPercent < 0.33
                                  ? "Low"
                                  : volumeMLWadahPercent < 0.66
                                      ? "Medium"
                                      : "High";
                          String volumeMLTabungScale =
                              volumeMLTabungPercent > 1.0
                                  ? "Over"
                                  : volumeMLTabungPercent < 0.33
                                      ? "Low"
                                      : volumeMLTabungPercent < 0.66
                                          ? "Medium"
                                          : "High";

                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularPercentIndicator(
                                radius: 60.0,
                                lineWidth: 10.0,
                                percent: beratWadahPercent > 1.0
                                    ? 1.0
                                    : beratWadahPercent.clamp(0.0, 1.0),
                                center: Text(
                                  "${(beratWadahPercent * 100).round()}%\n$beratWadahScale",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                  ),
                                ),
                                progressColor: getProgressColor(
                                    beratWadahScale, beratWadahPercent),
                                backgroundColor: Colors.grey.shade300,
                                footer: Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const Text(
                                        "Makanan",
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        "Total: $beratWadahDisplay",
                                        style: const TextStyle(
                                          fontSize: 14.0,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  // Volume ML Wadah indicator
                                  CircularPercentIndicator(
                                    radius: 60.0,
                                    lineWidth: 10.0,
                                    percent: volumeMLWadahPercent > 1.0
                                        ? 1.0
                                        : volumeMLWadahPercent.clamp(0.0, 1.0),
                                    center: Text(
                                      "${(volumeMLWadahPercent * 100).round()}%\n$volumeMLWadahScale",
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0,
                                      ),
                                    ),
                                    progressColor: getProgressColor(
                                        volumeMLWadahScale,
                                        volumeMLWadahPercent),
                                    backgroundColor: Colors.grey.shade300,
                                    footer: Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          const Text(
                                            "Minuman Wadah",
                                            style: TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            "Total: $volumeMLWadahDisplay",
                                            style: const TextStyle(
                                              fontSize: 14.0,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  CircularPercentIndicator(
                                    radius: 60.0,
                                    lineWidth: 10.0,
                                    percent: volumeMLTabungPercent > 1.0
                                        ? 1.0
                                        : volumeMLTabungPercent.clamp(0.0, 1.0),
                                    center: Text(
                                      "${(volumeMLTabungPercent * 100).round()}%\n$volumeMLTabungScale",
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0,
                                      ),
                                    ),
                                    progressColor: getProgressColor(
                                        volumeMLTabungScale,
                                        volumeMLTabungPercent),
                                    backgroundColor: Colors.grey.shade300,
                                    footer: Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          const Text(
                                            "Minuman Tabung",
                                            style: TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            "Total: $volumeMLTabungDisplay",
                                            style: const TextStyle(
                                              fontSize: 14.0,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        }
                      },
                    )
                  ],
                )
              ],
            );
          }
        },
      ),
    );
  }
}

class DetailTile extends StatelessWidget {
  final String title;
  final Widget icon;
  final void Function() onTap;

  const DetailTile({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Container(child: icon),
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
