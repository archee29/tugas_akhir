import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/percent_indicator.dart';
import './../../../styles/app_colors.dart';
import './../../../widgets/CustomWidgets/custom_bottom_navbar.dart';
import '../../../routes/app_pages.dart';
import '../../data/controllers/data_controller.dart';

class DetailJadwalView extends GetView<DataController> {
  const DetailJadwalView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const CustomBottomNavigationBar(),
      extendBody: true,
      body: Obx(() {
        if (controller.isLoading.value &&
            controller.listDataMf.isEmpty &&
            controller.listDataAf.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        } else {
          return Stack(
            children: [
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    buildHeader(),
                    const SizedBox(height: 30),
                    buildStatistik(),
                    const SizedBox(height: 30),
                    if (controller.listDataMf.isEmpty &&
                        controller.listDataAf.isEmpty)
                      const Center(child: Text("Data Tidak Tersedia")),
                    buildGrafikData(),
                    const SizedBox(height: 20),
                    buildIoT(),
                    const SizedBox(height: 15),
                    buildStatistikLingkaran(),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          );
        }
      }),
    );
  }

  Widget buildHeader() {
    return Row(
      children: [
        ClipOval(
          child: SizedBox(
            width: 42,
            height: 42,
            child: Image.network(
              controller.userData['avatarUrl']?.isEmpty ?? true
                  ? "https://ui-avatars.com/api/?name=${controller.userData['name']}/"
                  : controller.userData['avatarUrl'],
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
              controller.userData['name'] ?? "",
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontFamily: 'poppins',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildStatistik() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Statistik",
          style: TextStyle(
            fontFamily: 'poppins',
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        DetailTile(
          title: "Log Data",
          icon: SvgPicture.asset('assets/icons/database.svg'),
          onTap: () => Get.toNamed(Routes.DATA),
        ),
      ],
    );
  }

  Widget buildGrafikData() {
    return SizedBox(
      height: 300,
      child: SfCartesianChart(
        title: const ChartTitle(text: 'Data Makanan dan Minuman'),
        legend: const Legend(isVisible: true),
        tooltipBehavior: TooltipBehavior(enable: true),
        primaryXAxis: const CategoryAxis(),
        primaryYAxis: const NumericAxis(),
        series: <CartesianSeries>[
          ColumnSeries<Map<String, dynamic>, String>(
            dataSource: controller.listDataMf
              ..sort((a, b) => a['tanggal'].compareTo(b['tanggal'])),
            xValueMapper: (Map<String, dynamic> data, _) =>
                data['tanggal'] as String,
            yValueMapper: (Map<String, dynamic> data, _) =>
                int.tryParse(data['makanan'] ?? '0'),
            name: 'Makanan Pagi',
            color: Colors.blue,
            dataLabelSettings: const DataLabelSettings(isVisible: false),
          ),
          ColumnSeries<Map<String, dynamic>, String>(
            dataSource: controller.listDataMf,
            xValueMapper: (Map<String, dynamic> data, _) =>
                data['tanggal'] as String,
            yValueMapper: (Map<String, dynamic> data, _) =>
                int.tryParse(data['minuman'] ?? '0'),
            name: 'Minuman Pagi',
            color: Colors.green,
            dataLabelSettings: const DataLabelSettings(isVisible: false),
          ),
          ColumnSeries<Map<String, dynamic>, String>(
            dataSource: controller.listDataAf
              ..sort((a, b) => a['tanggal'].compareTo(b['tanggal'])),
            xValueMapper: (Map<String, dynamic> data, _) =>
                data['tanggal'] as String,
            yValueMapper: (Map<String, dynamic> data, _) =>
                int.tryParse(data['makanan'] ?? '0'),
            name: 'Makanan Sore',
            color: Colors.yellow,
            dataLabelSettings: const DataLabelSettings(isVisible: false),
          ),
          ColumnSeries<Map<String, dynamic>, String>(
            dataSource: controller.listDataAf,
            xValueMapper: (Map<String, dynamic> data, _) =>
                data['tanggal'] as String,
            yValueMapper: (Map<String, dynamic> data, _) =>
                int.tryParse(data['minuman'] ?? '0'),
            name: 'Minuman Sore',
            color: AppColors.primary,
            dataLabelSettings: const DataLabelSettings(isVisible: false),
          ),
        ],
      ),
    );
  }

  Widget buildIoT() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Statistik",
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
    );
  }

  Widget buildStatistikLingkaran() {
    double beratWadah = controller.userData['beratWadah'] ?? 0;
    double volumeMLWadah = controller.userData['volumeMLWadah'] ?? 0;
    double beratWadahPercent = beratWadah / 120;
    double volumeMLWadahPercent = volumeMLWadah / 300;
    String beratWadahScale;
    if (beratWadahPercent < 0.33) {
      beratWadahScale = "Low";
    } else if (beratWadahPercent < 0.66) {
      beratWadahScale = "Medium";
    } else {
      beratWadahScale = "High";
    }
    String volumeMLWadahScale;
    if (volumeMLWadahPercent < 0.33) {
      volumeMLWadahScale = "Low";
    } else if (volumeMLWadahPercent < 0.66) {
      volumeMLWadahScale = "Medium";
    } else {
      volumeMLWadahScale = "High";
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        CircularPercentIndicator(
          radius: 60.0,
          lineWidth: 10.0,
          percent: beratWadahPercent.clamp(0.0, 1.0),
          center: Text(
            "${(beratWadahPercent * 100).round()}%\n$beratWadahScale",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
          progressColor: getProgressColor(beratWadahScale),
          backgroundColor: Colors.grey.shade300,
          footer: const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text(
              "Makanan",
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        CircularPercentIndicator(
          radius: 60.0,
          lineWidth: 10.0,
          percent: volumeMLWadahPercent.clamp(0.0, 1.0),
          center: Text(
            "${(volumeMLWadahPercent * 100).round()}%\n$volumeMLWadahScale",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
          progressColor: getProgressColor(volumeMLWadahScale),
          backgroundColor: Colors.grey.shade300,
          footer: const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text(
              "Minuman",
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color getProgressColor(String scale) {
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
