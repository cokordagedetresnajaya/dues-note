import 'package:flutter/material.dart';

class EmptyData extends StatelessWidget {
  final String text;
  EmptyData(this.text);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 300,
            child: Image.asset(
              'assets/images/empty_data.png',
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 0,
              horizontal: 16,
            ),
            child: Text(
              text,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
          )
        ],
      ),
    ));
  }
}
