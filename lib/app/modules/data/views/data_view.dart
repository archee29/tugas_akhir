import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';

import '../../../styles/app_colors.dart';
import '../../../widgets/CustomWidgets/custom_data_widget.dart';
import '../controllers/data_controller.dart';

class DataView extends GetView<DataController> {
  const DataView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Text(
          'Data Penjadwalan',
          style: TextStyle(
            color: AppColors.secondary,
            fontSize: 14,
          ),
        ),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: SvgPicture.asset('assets/icons/arrow-left.svg'),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        bottom: TabBar(
          controller: controller.dataTabController,
          tabs: controller.dataTabs,
        ),
      ),
      body: TabBarView(
        controller: controller.dataTabController,
        physics: const BouncingScrollPhysics(),
        children: [DataJadwalPagi(), DataJadwalSore()],
      ),
    );
  }
}
