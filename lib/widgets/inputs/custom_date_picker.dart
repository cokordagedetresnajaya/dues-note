import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../configs/colors.dart';

class CustomDatePicker extends StatelessWidget {
  final DateTime date;
  final Color boxColor;
  final String text;
  final Function()? onTap;

  CustomDatePicker({
    required this.date,
    required this.onTap,
    required this.text,
    this.boxColor = AppColors.background,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: boxColor,
          border: Border.all(
            color: AppColors.transparentGray,
          ),
          borderRadius: const BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
            Text(
              DateFormat.yMMMd().format(date),
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
      ),
      onTap: onTap,
    );
  }
}
