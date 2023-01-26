import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/organization_categories.dart';
import '../../screens/cashflow_overview_screen.dart';
import '../../configs/colors.dart';

class OrganizationItem extends StatefulWidget {
  final String id;
  final String name;
  final String categoryId;
  final int members;
  final Function resetScreen;
  final Function setEditMode;
  final Function selectOrganization;

  OrganizationItem(
    this.id,
    this.name,
    this.categoryId,
    this.members,
    this.resetScreen,
    this.setEditMode,
    this.selectOrganization,
  );

  @override
  State<OrganizationItem> createState() => _OrganizationItemState();
}

class _OrganizationItemState extends State<OrganizationItem> {
  bool _isCheck = false;
  @override
  Widget build(BuildContext context) {
    final category = Provider.of<OrganizationCategories>(
      context,
      listen: false,
    ).findById(widget.categoryId);

    return InkWell(
      splashColor: AppColors.gray,
      onTap: _isCheck
          ? () {
              setState(() {
                _isCheck = false;
              });
              widget.setEditMode(false);
            }
          : () {
              Navigator.of(context)
                  .pushNamed(
                CashFlowOverviewScreen.routeName,
                arguments: widget.id,
              )
                  .then((value) {
                return widget.resetScreen();
              });
            },
      onLongPress: () {
        widget.setEditMode(true);
        widget.selectOrganization(widget.id);
        setState(() {
          _isCheck = true;
        });
      },
      child: ListTile(
        leading: CircleAvatar(
          radius: 35,
          backgroundColor: category.color,
          child: Container(
            height: 36,
            width: 36,
            child: Image.asset('${category.image}'),
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            widget.name,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ),
        subtitle: Text('${widget.members} Members'),
        trailing: _isCheck
            ? const Icon(
                Icons.check_circle,
                color: AppColors.lightGreen,
              )
            : null,
      ),
    );
  }
}
