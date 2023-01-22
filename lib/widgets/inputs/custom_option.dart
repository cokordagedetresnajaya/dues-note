import 'package:flutter/material.dart';
import '../../configs/colors.dart';

class CustomOption extends StatelessWidget {
  final VoidCallback onTap;
  final String optionText;
  final String currentSelectedType;
  final String typeValue;
  final Color activeColor;
  final Function(String?)? onChange;

  CustomOption({
    required this.onTap,
    required this.optionText,
    required this.currentSelectedType,
    required this.typeValue,
    required this.activeColor,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: 4,
          horizontal: 16,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            width: currentSelectedType == typeValue ? 1 : 0.5,
            style: BorderStyle.solid,
            color:
                currentSelectedType == typeValue ? activeColor : AppColors.gray,
          ),
          borderRadius: const BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              optionText,
              style: TextStyle(
                color: currentSelectedType == typeValue
                    ? activeColor
                    : AppColors.primary,
              ),
            ),
            Transform.scale(
              scale: 1,
              child: Radio(
                activeColor: activeColor,
                value: typeValue,
                groupValue: currentSelectedType,
                onChanged: onChange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
