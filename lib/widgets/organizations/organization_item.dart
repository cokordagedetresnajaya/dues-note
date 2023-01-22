import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/organization_categories.dart';
import '../../screens/cashflow_overview_screen.dart';

class OrganizationItem extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final category = Provider.of<OrganizationCategories>(
      context,
      listen: false,
    ).findById(categoryId);

    return InkWell(
      splashColor: const Color.fromRGBO(
        181,
        181,
        181,
        1,
      ),
      onTap: () {
        Navigator.of(context)
            .pushNamed(
          CashFlowOverviewScreen.routeName,
          arguments: id,
        )
            .then((value) {
          return resetScreen();
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
            name,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ),
        subtitle: Text('$members Members'),
      ),
    );
  }
}
