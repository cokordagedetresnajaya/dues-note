import 'package:flutter/material.dart';
import '../../configs/colors.dart';

class DropdownInput extends StatelessWidget {
  final String? currentValue;
  final String hintText;
  final List<DropdownMenuItem<String>>? items;
  final String? Function(String?)? validator;
  final Function(String?)? onChanged;

  DropdownInput({
    required this.currentValue,
    required this.hintText,
    required this.items,
    this.validator,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField(
      value: currentValue,
      hint: Text(hintText),
      style: Theme.of(context).textTheme.labelMedium,
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
          borderSide: BorderSide(
            color: AppColors.gray,
            style: BorderStyle.solid,
            width: 0.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(
            color: AppColors.gray,
            style: BorderStyle.solid,
            width: 0.5,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
          borderSide: BorderSide(
            color: AppColors.gray,
            style: BorderStyle.solid,
            width: 0.5,
          ),
        ),
      ),
      items: items,
      validator: validator,
      onChanged: onChanged,
    );
  }
}
