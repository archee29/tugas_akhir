import 'package:flutter/material.dart';
import './../../styles/app_colors.dart';

class CustomInput extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool disabled;
  final EdgeInsetsGeometry margin;
  final bool obsecureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final double? width;

  const CustomInput({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.disabled = false,
    this.margin = const EdgeInsets.only(bottom: 16),
    this.obsecureText = false,
    this.suffixIcon,
    this.keyboardType,
    this.width,
  });

  @override
  State<CustomInput> createState() => _CustomInputState();
}

class _CustomInputState extends State<CustomInput> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      margin: widget.margin,
      child: Material(
        color: Colors.white,
        child: Container(
          padding: const EdgeInsets.only(left: 14, right: 14, top: 4),
          decoration: BoxDecoration(
            color: (widget.disabled == false)
                ? Colors.transparent
                : AppColors.primaryExtraSoft,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(width: 1, color: AppColors.secondaryExtraSoft),
          ),
          child: TextField(
            readOnly: widget.disabled,
            obscureText: widget.obsecureText,
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'poppins',
            ),
            maxLines: 1,
            controller: widget.controller,
            keyboardType: widget.keyboardType,
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
        ),
      ),
    );
  }
}
