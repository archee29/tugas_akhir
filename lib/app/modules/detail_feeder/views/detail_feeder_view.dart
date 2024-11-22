import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import 'package:get/get.dart';

import '../../../styles/app_colors.dart';
import '../../../widgets/CustomWidgets/custom_data_feeder_widget.dart';
import '../controllers/detail_feeder_controller.dart';

class DetailFeederView extends GetView<DetailFeederController> {
  const DetailFeederView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Data Feeder',
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
        actions: [
          Container(
            width: 44,
            height: 44,
            margin: const EdgeInsets.only(bottom: 8, top: 8, right: 8),
            child: ElevatedButton(
              onPressed: () {
                Get.dialog(
                  Dialog(
                    child: SizedBox(
                      height: 372,
                      child: SfDateRangePicker(
                        headerHeight: 50,
                        headerStyle: const DateRangePickerHeaderStyle(
                            textAlign: TextAlign.center),
                        monthViewSettings:
                            const DateRangePickerMonthViewSettings(
                                firstDayOfWeek: 1),
                        selectionMode: DateRangePickerSelectionMode.range,
                        selectionColor: AppColors.primary,
                        rangeSelectionColor: AppColors.primary.withOpacity(0.2),
                        viewSpacing: 10,
                        showActionButtons: true,
                        onCancel: () => Get.back(),
                        onSubmit: (data) {
                          if (data != null) {
                            PickerDateRange range = data as PickerDateRange;
                            if (range.endDate != null) {
                              controller.pickDate(
                                  range.startDate!, range.endDate!);
                            }
                          }
                        },
                      ),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                elevation: 0,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: SvgPicture.asset('assets/icons/filter-feeder.svg'),
            ),
          )
        ],
        bottom: TabBar(
          controller: controller.dataTabController,
          tabs: controller.dataTabs,
        ),
      ),
      body: TabBarView(
        controller: controller.dataTabController,
        physics: const BouncingScrollPhysics(),
        children: [DataFeederPagi(), DataFeederSore()],
      ),
    );
  }
}
