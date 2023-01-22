import 'package:flutter/material.dart';

class MemberNotPaidItem extends StatelessWidget {
  final String name;

  MemberNotPaidItem(this.name);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
          const EdgeInsets.only(left: 0, top: 8, bottom: 8, right: 8),
      leading: Container(
        margin: const EdgeInsets.only(
          right: 16,
        ),
        height: 42,
        width: 42,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          color: Theme.of(context).primaryColor,
        ),
        child: Center(
          child: Text(
            name.substring(0, 1),
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ),
      ),
      title: Text(
        name,
        style: const TextStyle(
          fontSize: 16,
        ),
      ),
      trailing: ElevatedButton(
        child: const Text(
          'Pay',
          style: TextStyle(
            fontSize: 12,
          ),
        ),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(
            Theme.of(context).primaryColorLight,
          ),
        ),
        onPressed: () {},
      ),
    );
  }
}
