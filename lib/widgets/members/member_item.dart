import 'package:flutter/material.dart';

class MemberItem extends StatefulWidget {
  final int index;
  final String id;
  final String name;
  final Function removeMember;
  String? type;
  MemberItem(
    this.index,
    this.id,
    this.name,
    this.removeMember, [
    this.type = 'add',
  ]);

  @override
  State<MemberItem> createState() => _MemberItemState();
}

class _MemberItemState extends State<MemberItem> {
  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(widget.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: AlignmentDirectional.centerEnd,
        color: Colors.red,
        child: const Padding(
          padding: EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
          child: Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
      ),
      onDismissed: (direction) {
        if (widget.type == 'edit') {
          widget.removeMember(widget.id);
        } else {
          widget.removeMember(widget.index);
        }
      },
      child: ListTile(
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(
                Icons.person,
                color: Colors.white,
              ),
            ),
          ],
        ),
        title: Container(
            padding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 10,
            ),
            child: Text(widget.name)),
      ),
    );
  }
}
