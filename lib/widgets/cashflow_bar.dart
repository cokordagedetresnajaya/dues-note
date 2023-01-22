import 'package:flutter/material.dart';
import './utils/vertical_space_10.dart';

class CashFlowBar extends StatelessWidget {
  final double income;
  final double expenses;
  final String barText;

  CashFlowBar({
    required this.income,
    required this.expenses,
    required this.barText,
  });

  @override
  Widget build(BuildContext context) {
    double total = 0;
    if (income + expenses == 0) {
      total = 1;
    } else {
      total = income + expenses;
    }

    double incomeHeight = income / total * 172;
    double expensesHeight = expenses / total * 172;

    return Expanded(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                width: 17,
                height: 172,
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(217, 217, 217, 1),
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
              ),
              Container(
                width: 17,
                height: income > expenses ? incomeHeight : expensesHeight,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(10),
                  ),
                  color: income > expenses
                      ? Theme.of(context).primaryColorLight
                      : Theme.of(context).primaryColorDark,
                ),
              ),
              Container(
                width: 17,
                height: income < expenses ? incomeHeight : expensesHeight,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(10),
                  ),
                  color: income < expenses
                      ? Theme.of(context).primaryColorLight
                      : Theme.of(context).primaryColorDark,
                ),
              ),
            ],
          ),
          const VerticalSpace10(),
          Text(
            barText,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          )
        ],
      ),
      flex: 1,
    );
  }
}
