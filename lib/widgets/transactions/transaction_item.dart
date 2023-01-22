import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../screens/transactions/transaction_detail_screen.dart';
import '../../providers/organization_fees.dart';

class TransactionItem extends StatelessWidget {
  final String id;
  final String title;
  final String date;
  final String duesId;
  final int amount;
  final String type;

  TransactionItem(
    this.id,
    this.title,
    this.date,
    this.amount,
    this.type,
    this.duesId,
  );

  @override
  Widget build(BuildContext context) {
    final duesTitle = duesId == ''
        ? ''
        : Provider.of<OrganizationFees>(
            context,
            listen: false,
          ).getOrganizationFeeById(duesId).title;

    return InkWell(
      onTap: () => Navigator.of(context).pushNamed(
        TransactionDetailScreen.routeName,
        arguments: id,
      ),
      child: Container(
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title + ' ' + (duesTitle != '' ? '(${duesTitle})' : ''),
                    style: Theme.of(context).textTheme.labelMedium,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).primaryColorLight,
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              flex: 1,
              child: Text(
                (type == 'income' || type == 'dues' ? '+' : '-') +
                    ' Rp. ${NumberFormat.currency(locale: 'it', decimalDigits: 0, symbol: '').format(amount)}',
                style: TextStyle(
                  fontSize: 12,
                  color: type == 'income' || type == 'dues'
                      ? const Color.fromRGBO(39, 207, 147, 1)
                      : const Color.fromRGBO(207, 55, 39, 1),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
