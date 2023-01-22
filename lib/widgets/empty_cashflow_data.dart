import 'package:flutter/material.dart';
import './utils/vertical_space_10.dart';

class EmptyCashflowData extends StatelessWidget {
  final String text;
  final String buttonText;
  final String routeName;
  final String organizationId;
  EmptyCashflowData(
    this.text,
    this.buttonText,
    this.routeName,
    this.organizationId,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).primaryColor,
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(181, 181, 181, 1),
            blurRadius: 2, // soften the shadow
            spreadRadius: 0, //extend the shadow
            offset: Offset(
              0, // Move to right 10  horizontally
              3, // Move to bottom 10 Vertically
            ),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
          const VerticalSpace10(),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context)
                  .pushNamed(routeName, arguments: organizationId);
            },
            child: Text(
              buttonText,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                Theme.of(context).primaryColorLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
