import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/organization_categories.dart';
import '../../providers/organizations.dart';
import '../../screens/cashflow_overview_screen.dart';
import '../../configs/colors.dart';

class OrganizationItem extends StatefulWidget {
  final String id;
  final String name;
  final String categoryId;
  final int members;
  final Function resetScreen;

  OrganizationItem(
    this.id,
    this.name,
    this.categoryId,
    this.members,
    this.resetScreen,
  );

  @override
  State<OrganizationItem> createState() => _OrganizationItemState();
}

class _OrganizationItemState extends State<OrganizationItem> {
  @override
  Widget build(BuildContext context) {
    final category = Provider.of<OrganizationCategories>(
      context,
      listen: false,
    ).findById(widget.categoryId);

    bool _isCheck =
        Provider.of<Organizations>(context).selectedOrganization == widget.id;

    return InkWell(
      splashColor: AppColors.gray,
      onTap: _isCheck
          ? () {
              Provider.of<Organizations>(
                context,
                listen: false,
              ).selectedOrganization = null;
            }
          : () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => CashFlowOverviewScreen(),
                  transitionsBuilder: (_, a, __, c) => FadeTransition(
                    opacity: a,
                    child: c,
                  ),
                  settings: RouteSettings(
                    arguments: widget.id,
                  ),
                ),
              ).then((value) {
                return widget.resetScreen();
              });
            },
      onLongPress: () {
        Provider.of<Organizations>(
          context,
          listen: false,
        ).selectedOrganization = widget.id;
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
