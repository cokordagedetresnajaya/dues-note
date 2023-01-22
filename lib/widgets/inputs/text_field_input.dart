import 'package:flutter/material.dart';
import '../../configs/colors.dart';

class TextFieldInput extends StatelessWidget {
  final String hintText;
  final String? Function(String?)? onValidate;
  final Function(String?)? onSaved;
  final int maxLines;
  final TextInputType? keyboardType;
  final String initialValue;

  TextFieldInput({
    required this.hintText,
    this.onValidate,
    required this.onSaved,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.initialValue = '',
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      maxLines: maxLines,
      style: Theme.of(context).textTheme.labelMedium,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(16),
        hintText: hintText,
        hintStyle: Theme.of(context).textTheme.labelSmall,
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: AppColors.gray,
            style: BorderStyle.solid,
            width: 1,
          ),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
          borderSide: BorderSide(
            color: AppColors.gray,
            style: BorderStyle.solid,
            width: 0.5,
          ),
        ),
        border: const OutlineInputBorder(
          borderSide: BorderSide(
            color: AppColors.gray,
            style: BorderStyle.solid,
            width: 1,
          ),
        ),
      ),
      validator: onValidate,
      onSaved: onSaved,
      keyboardType: keyboardType,
    );
  }
}
