import 'package:flutter/material.dart';
import '../../configs/colors.dart';

class TwoButtonAlert extends StatelessWidget {
  final String title;
  final String content;
  final String buttonText1;
  final String buttonText2;
  final VoidCallback onPressed1;
  final VoidCallback onPressed2;

  TwoButtonAlert({
    required this.title,
    required this.content,
    required this.buttonText1,
    required this.buttonText2,
    required this.onPressed1,
    required this.onPressed2,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(
        content,
        style: Theme.of(context).textTheme.labelMedium,
      ),
      actions: [
        TextButton(
          onPressed: onPressed1,
          child: Text(
            buttonText1,
            style: const TextStyle(
              color: AppColors.primary,
            ),
          ),
        ),
        TextButton(
          onPressed: onPressed2,
          child: Text(
            buttonText2,
            style: const TextStyle(
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
    ;
  }
}
