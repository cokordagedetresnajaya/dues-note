import 'package:flutter/material.dart';
import '../../configs/colors.dart';

class SingleButtonAlert extends StatelessWidget {
  final String title;
  final String content;
  final String buttonText;
  final VoidCallback onPressed;

  SingleButtonAlert({
    required this.title,
    required this.content,
    required this.buttonText,
    required this.onPressed,
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
          onPressed: onPressed,
          child: Text(
            buttonText,
            style: const TextStyle(
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
