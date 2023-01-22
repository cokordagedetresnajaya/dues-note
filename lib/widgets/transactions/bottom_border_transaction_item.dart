import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/organization_fees.dart';
import '../../screens/transactions/transaction_detail_screen.dart';

class BottomBorderTransactionItem extends StatefulWidget {
  final String id;
  final String title;
  final int amount;
  final String type;
  final String paymentType;
  final String duesId;
  final Function setDeleteMode;
  final Function getDeleteMode;
  final Function getSelectedItemLength;
  final Function setSelectedItem;
  final Function removeSelectedItem;
  final Function resetFilter;
  final Function resetDeleteMode;

  BottomBorderTransactionItem(
    this.id,
    this.title,
    this.amount,
    this.type,
    this.paymentType,
    this.duesId,
    this.setDeleteMode,
    this.getDeleteMode,
    this.getSelectedItemLength,
    this.setSelectedItem,
    this.removeSelectedItem,
    this.resetFilter,
    this.resetDeleteMode,
  );

  @override
  State<BottomBorderTransactionItem> createState() =>
      _BottomBorderTransactionItemState();
}

class _BottomBorderTransactionItemState
    extends State<BottomBorderTransactionItem> {
  bool _isCheck = false;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    bool _isDeleteMode = widget.getDeleteMode();
    final duesTitle = widget.duesId == ''
        ? ''
        : Provider.of<OrganizationFees>(
            context,
            listen: false,
          ).getOrganizationFeeById(widget.duesId).title;

    return InkWell(
      onTap: () {
        if (widget.getDeleteMode() && widget.getSelectedItemLength() > 0) {
          setState(() {
            _isCheck = !_isCheck;
          });
          if (_isCheck) {
            widget.setSelectedItem(widget.id);
          } else {
            widget.removeSelectedItem(widget.id);
          }

          if (widget.getSelectedItemLength() < 1) {
            widget.setDeleteMode(false);
          }
        } else {
          Navigator.of(context)
              .pushNamed(
            TransactionDetailScreen.routeName,
            arguments: widget.id,
          )
              .then(
            (value) {
              widget.resetFilter();
              widget.resetDeleteMode();
            },
          );
        }
      },
      onLongPress: () {
        if (widget.getSelectedItemLength() < 1) {
          setState(() {
            _isCheck = true;
          });
          widget.setSelectedItem(widget.id);
          widget.setDeleteMode(true);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: width * 0.65,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title +
                        ' ' +
                        (widget.duesId != '' ? '(${duesTitle})' : ''),
                    style: Theme.of(context).textTheme.labelMedium,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Text(
                    widget.paymentType,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).primaryColorLight,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            _isCheck && _isDeleteMode
                ? const Icon(
                    Icons.check_circle,
                    color: Color.fromRGBO(
                      39,
                      207,
                      147,
                      1,
                    ),
                  )
                : Text(
                    (widget.type == 'income' || widget.type == 'dues'
                            ? '+'
                            : '-') +
                        ' Rp. ${NumberFormat.currency(locale: 'it', decimalDigits: 0, symbol: '').format(widget.amount)}',
                    style: TextStyle(
                      color: widget.type == 'income' || widget.type == 'dues'
                          ? const Color.fromRGBO(39, 207, 147, 1)
                          : const Color.fromRGBO(207, 55, 39, 1),
                      fontSize: 12,
                    ),
                  )
          ],
        ),
      ),
    );
  }
}
