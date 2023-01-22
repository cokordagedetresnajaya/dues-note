import 'package:flutter/material.dart';
import '../../configs/colors.dart';

class DatePicker extends StatelessWidget {
  final void Function()? onTap;
  final String dateText;

  DatePicker({
    required this.onTap,
    required this.dateText,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(
            Radius.circular(
              10,
            ),
          ),
          border: Border.all(
            color: AppColors.gray,
            width: 0.5,
            style: BorderStyle.solid,
          ),
        ),
        child: Text(dateText),
      ),
    );
  }
}
