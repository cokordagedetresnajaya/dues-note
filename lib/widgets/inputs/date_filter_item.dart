import 'package:flutter/material.dart';
import '../../configs/colors.dart';

class DateFilterItem extends StatelessWidget {
  final void Function()? onTap;
  final String label;
  final String dateRangeText;
  final String value;
  final String groupValue;
  final void Function(String?)? onChanged;

  DateFilterItem({
    required this.onTap,
    required this.label,
    required this.dateRangeText,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  Text(
                    dateRangeText,
                  ),
                ],
              ),
            ),
            Transform.scale(
              scale: 1.3,
              child: Radio(
                activeColor: AppColors.secondaryLight,
                value: value,
                groupValue: groupValue,
                onChanged: onChanged,
              ),
            )
          ],
        ),
      ),
    );
  }
}
