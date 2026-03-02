import 'package:flutter/material.dart';
import '../../../shared/theme/app_colors.dart';

Widget scoreInputField({
  required String hintText,
  required TextEditingController controller,
  required ValueChanged<String> onChanged,
  required bool isEditable,
}) {
  return SizedBox(
    width: 140,
    height: 40,
    child: TextField(
      onChanged: onChanged,
      readOnly: !isEditable,

      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        fontFamily: 'Pretendard',
      ),
      keyboardType: TextInputType.number,
      controller: controller,

      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: AppColors.gray700,
          fontWeight: FontWeight.w400,
          fontSize: 16,
        ),
        filled: true,
        fillColor: AppColors.gray100,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.gray300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary700),
        ),
      ),
    ),
  );
}