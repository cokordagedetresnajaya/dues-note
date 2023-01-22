import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/transaction.dart';
import '../../providers/transactions.dart';
import '../../configs/colors.dart';
import './edit_transaction_screen.dart';
import '../../widgets/utils/vertical_space_10.dart';
import '../../widgets/utils/vertical_space_20.dart';

class TransactionDetailScreen extends StatelessWidget {
  static const routeName = '/transaction-detail';

  @override
  Widget build(BuildContext context) {
    var transactionId = ModalRoute.of(context)?.settings.arguments as String;
    final Transaction transaction = Provider.of<Transactions>(
      context,
    ).getTransactionById(
      transactionId,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.background,
        centerTitle: true,
        foregroundColor: AppColors.primary,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        width: double.infinity,
        child: Column(
          children: [
            const Text(
              'Transaction Amount',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const VerticalSpace10(),
            Text(
              'Rp. ${NumberFormat.currency(
                locale: 'it',
                decimalDigits: 0,
                symbol: '',
              ).format(transaction.amount)}',
              style: TextStyle(
                color:
                    transaction.type == 'income' || transaction.type == 'dues'
                        ? AppColors.lightGreen
                        : AppColors.red,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const VerticalSpace20(),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Detail Transaksi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const VerticalSpace20(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Title',
                    style: TextStyle(
                      color: AppColors.gray,
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: Text(
                    transaction.title,
                    style: const TextStyle(
                      color: AppColors.gray,
                      overflow: TextOverflow.ellipsis,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
            const VerticalSpace10(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Payment Method',
                  style: TextStyle(
                    color: AppColors.gray,
                  ),
                ),
                Text(
                  transaction.paymentType,
                  style: const TextStyle(
                    color: AppColors.gray,
                  ),
                ),
              ],
            ),
            const VerticalSpace10(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Date',
                  style: TextStyle(
                    color: AppColors.gray,
                  ),
                ),
                Text(
                  DateFormat.E().format(transaction.date) +
                      ', ' +
                      DateFormat.d().format(transaction.date) +
                      ' ' +
                      DateFormat.MMMM().format(transaction.date) +
                      ' ' +
                      DateFormat.y().format(transaction.date),
                  style: const TextStyle(
                    color: AppColors.gray,
                  ),
                ),
              ],
            ),
            const VerticalSpace10(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Type',
                  style: TextStyle(
                    color: AppColors.gray,
                  ),
                ),
                Text(
                  transaction.type == 'income'
                      ? 'Income'
                      : transaction.type == 'dues'
                          ? 'Dues Payment'
                          : 'Expenses',
                  style: const TextStyle(
                    color: AppColors.gray,
                  ),
                ),
              ],
            ),
            const VerticalSpace10(),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Description / Note',
                style: TextStyle(
                  color: AppColors.gray,
                ),
              ),
            ),
            const VerticalSpace10(),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                transaction.description == '' ? '-' : transaction.description,
                style: const TextStyle(
                  color: AppColors.gray,
                ),
              ),
            ),
            const VerticalSpace20(),
            const VerticalSpace10(),
            transaction.type == 'dues'
                ? Container()
                : Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed(
                          EditTransactionScreen.routeName,
                          arguments: transactionId,
                        );
                      },
                      child: const Text(
                        'Edit Transaction',
                        style: TextStyle(
                          color: AppColors.background,
                        ),
                      ),
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all(
                          const EdgeInsets.symmetric(
                            vertical: 18,
                            horizontal: 16,
                          ),
                        ),
                        backgroundColor: MaterialStateProperty.all(
                          AppColors.primary,
                        ),
                      ),
                    ),
                  ),
            const VerticalSpace10(),
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Back',
                  style: TextStyle(
                    color: AppColors.background,
                  ),
                ),
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(
                    const EdgeInsets.symmetric(
                      vertical: 18,
                      horizontal: 16,
                    ),
                  ),
                  backgroundColor: MaterialStateProperty.all(
                    AppColors.gray,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
