import 'package:flutter/material.dart';
import './../../styles/app_colors.dart';

class CustomTimeInput extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool disabled;
  final EdgeInsetsGeometry margin;
  final bool obsecureText;
  final Widget? suffixIcon;
  final void Function() onTap;
  final ValueChanged<String> onTimeChanged;

  const CustomTimeInput({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.onTap,
    required this.onTimeChanged,
    this.disabled = true,
    this.margin = const EdgeInsets.only(bottom: 16),
    this.obsecureText = false,
    this.suffixIcon,
  });

  @override
  State<CustomTimeInput> createState() => _CustomTimeInputState();
}

class _CustomTimeInputState extends State<CustomTimeInput> {
  String _selectedTime = '';

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.only(left: 14, right: 14, top: 4, bottom: 10),
        margin: widget.margin,
        decoration: BoxDecoration(
          color: (widget.disabled == false)
              ? Colors.transparent
              : AppColors.primaryExtraSoft,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(width: 1, color: AppColors.secondaryExtraSoft),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              onTap: widget.onTap,
              readOnly: widget.disabled,
              obscureText: widget.obsecureText,
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'poppins',
              ),
              maxLines: 1,
              controller: widget.controller,
              decoration: InputDecoration(
                suffixIcon: widget.suffixIcon ?? const SizedBox(),
                label: Text(
                  widget.label,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                  ),
                ),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                border: InputBorder.none,
                hintText: widget.hint,
                hintStyle: TextStyle(
                  fontSize: 14,
                  fontFamily: 'poppins',
                  fontWeight: FontWeight.w500,
                  color: AppColors.secondarySoft,
                ),
              ),
            ),
            Row(
              children: [
                Radio<String>(
                  value: '07:00',
                  groupValue: _selectedTime,
                  onChanged: (value) {
                    setState(() {
                      _selectedTime = value!;
                      widget.controller.text = '07:00';
                    });
                    widget.onTimeChanged(value!);
                  },
                ),
                const Text("Jadwal Pagi (07:00)"),
              ],
            ),
            Row(
              children: [
                Radio<String>(
                  value: '17:00',
                  groupValue: _selectedTime,
                  onChanged: (value) {
                    setState(() {
                      _selectedTime = value!;
                      widget.controller.text = '17:00';
                    });
                    widget.onTimeChanged(value!);
                  },
                ),
                const Text("Jadwal Sore (17:00)"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}