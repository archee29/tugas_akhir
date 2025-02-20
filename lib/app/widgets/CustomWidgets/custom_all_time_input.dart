import 'package:flutter/material.dart';
import './../../styles/app_colors.dart';

class CustomAllTimeInput extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool disabled;
  final EdgeInsetsGeometry margin;
  final bool obsecureText;
  final Widget? suffixIcon;
  final void Function() onTap;
  final ValueChanged<String> onTimeChanged;

  const CustomAllTimeInput({
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
  State<CustomAllTimeInput> createState() => _CustomTimeInputState();
}

class _CustomTimeInputState extends State<CustomAllTimeInput> {
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
              onChanged: (value) {
                widget.onTimeChanged(value);
              },
              decoration: InputDecoration(
                suffixIcon: widget.suffixIcon ?? const SizedBox(),
                labelText: widget.label,
                labelStyle: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
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
          ],
        ),
      ),
    );
  }
}
