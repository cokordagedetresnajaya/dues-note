import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../configs/colors.dart';
import '../utils/vertical_space_10.dart';
import '../utils/vertical_space_20.dart';
import '../inputs/date_filter_item.dart';
import '../inputs/custom_date_picker.dart';

class TransactionFilter extends StatefulWidget {
  bool isFilterSet;
  bool isFiltered;
  bool isCustom;
  String filterDate;
  String filterTransactionType;
  DateTime? initialStartDate;
  DateTime? initialEndDate;
  final Function resetFilterFn;
  final Function setFilter;

  TransactionFilter({
    required this.isFilterSet,
    required this.isFiltered,
    required this.filterDate,
    required this.initialStartDate,
    required this.initialEndDate,
    required this.resetFilterFn,
    required this.isCustom,
    required this.filterTransactionType,
    required this.setFilter,
  });
  @override
  State<TransactionFilter> createState() => _TransactionFilterState();
}

class _TransactionFilterState extends State<TransactionFilter> {
  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.9,
      child: Container(
        padding: const EdgeInsets.only(
          left: 16,
          right: 16,
          top: 8,
        ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: 40,
                  height: 6,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                    color: AppColors.primary,
                  ),
                ),
              ),
              const VerticalSpace20(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Transaction Date',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                    splashFactory: NoSplash.splashFactory,
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    side: BorderSide(
                      color: widget.isFilterSet || widget.isFiltered ? AppColors.red : AppColors.gray,
                    ),
                  ),
                  onPressed: !widget.isFilterSet && !widget.isFiltered ? 
                    null : 
                    () {
                      DateTime now = DateTime.now();
                      setState(() {
                        widget.filterDate = '';
                        widget.isFilterSet = false;
                        widget.isFiltered = false;
                        widget.isCustom = false;
                        widget.filterTransactionType = '';
                        widget.initialStartDate = DateTime(now.year, now.month, now.day).subtract(
                          const Duration(
                            days: 1,
                          ),
                        );
                        widget.initialEndDate = DateTime(now.year, now.month, now.day);
                      });
                      widget.resetFilterFn();
                    },
                  child: Text(
                    'Delete',
                    style: TextStyle(
                      color: widget.isFilterSet || widget.isFiltered
                      ? AppColors.red
                      : AppColors.gray,
                    ),
                  ),
                ),
              ],
            ),
            const VerticalSpace20(),
            DateFilterItem(
              label: 'Last 7 Days',
              value: '7 days',
              groupValue: widget.filterDate,
              dateRangeText: DateFormat.yMMMEd().format(
                DateTime.now().subtract(
                  const Duration(
                    days: 6,
                  ),
                ),
              ) + ' - ' +
              DateFormat.yMMMEd().format(
                DateTime.now(),
              ),
              onTap: () {
                setState(() {
                  widget.filterDate = '7 days';
                  widget.isFilterSet = true;
                  widget.isCustom = false;
                });
              },
              onChanged: (value) {
                setState(() {
                  widget.filterDate = value.toString();
                  widget.isFilterSet = true;
                  widget.isCustom = false;
                });
              },
            ),
            const VerticalSpace10(),
            DateFilterItem(
              label: 'Last 30 Days',
              value: '30 days',
              groupValue: widget.filterDate,
              dateRangeText: DateFormat.yMMMEd().format(
                DateTime.now().subtract(
                  const Duration(
                    days: 29,
                  ),
                ),
              ) + ' - ' +
              DateFormat.yMMMEd().format(
                DateTime.now(),
              ),
              onTap: () {
                setState(() {
                  widget.filterDate = '30 days';
                  widget.isFilterSet = true;
                  widget.isCustom = false;
                });
              },
              onChanged: (value) {
                setState(() {
                  widget.filterDate = value.toString();
                  widget.isFilterSet = true;
                  widget.isCustom = false;
                });
              },
            ),
            const VerticalSpace10(),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                setState(() {
                  widget.filterDate = 'custom';
                  widget.isFilterSet = true;
                  widget.isCustom = true;
                });
              },
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Custom Date',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                          Transform.scale(
                            scale: 1.3,
                            child: Radio(
                              activeColor: AppColors.secondaryLight,
                              value: 'custom',
                              groupValue: widget.filterDate,
                              onChanged: (value) {
                                setState(() {
                                  widget.filterDate = value.toString();
                                  widget.isFilterSet = true;
                                  widget.isCustom = true;
                                });
                              },
                            ),
                          )
                        ],
                      ),
                      const VerticalSpace10(),
                        Row(
                          children: [
                            Flexible(
                              flex: 1,
                              child: CustomDatePicker(
                              text: 'from',
                              date: widget.initialStartDate!,
                              boxColor: widget.isCustom
                                ? AppColors.background
                                : AppColors.lightGray,
                              onTap: () async {
                                DateTime? newStartDate = await showDatePicker(
                                  context: context,
                                  initialDate: widget.initialStartDate!,
                                  firstDate:
                                    DateTime(1900),
                                  lastDate: widget.initialEndDate!,
                                );

                                if (newStartDate == null)
                                  return;

                                setState(() {
                                  widget.filterDate = 'custom';
                                  widget.isFilterSet = true;
                                  widget.isCustom = true;
                                  widget.initialStartDate = newStartDate;
                                });
                              },
                            ), 
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Flexible(
                            flex: 1,
                            child: CustomDatePicker(
                              text: 'to',
                              boxColor: widget.isCustom
                                ? AppColors.background
                                : AppColors.lightGray,
                              date: widget.initialEndDate!,
                              onTap: () async {
                                DateTime? newEndDate = await showDatePicker(
                                  context: context,
                                  initialDate: widget.initialEndDate!,
                                  firstDate: widget.initialStartDate!
                                  lastDate:DateTime.now(),
                                );

                                if (newEndDate == null)
                                  return;

                                setState(() {
                                  widget.filterDate = 'custom';
                                  widget.isFilterSet = true;
                                  widget.isCustom = true;
                                  widget.initialEndDate = newEndDate;
                                });
                              },
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
              const VerticalSpace20(),
                Text(
                  'Transaction Type',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const VerticalSpace20(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 10,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.gray,
                      style: BorderStyle.solid,
                      width: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: DropdownButton(
                    value: widget.filterTransactionType,
                    icon: const Visibility(
                      visible: false,
                      child: Icon(
                        Icons.arrow_downward,
                      ),
                    ),
                    underline: Container(
                      color: AppColors.background,
                    ),
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(
                        child: Text(
                          'All Transaction',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        value: '',
                      ),
                      DropdownMenuItem(
                        child: Text(
                          'Income',
                          style: TextStyle(
                            color: AppColors.lightGreen,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        value: 'income',
                      ),
                      DropdownMenuItem(
                        child: Text(
                          'Expenses',
                          style: TextStyle(
                            color: AppColors.red,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        value: 'expenses',
                      )
                    ],
                    onChanged: (value) {
                      if ((value == 'expenses' || value == 'income') && widget.isFilterSet == false) {
                        setState(() {
                          widget.isFilterSet = true;
                        });
                      }

                      if (value == '' && widget.filterDate == '') {
                        setState(() {
                          widget.isFilterSet = false;
                        });
                      }

                      setState(() {
                        widget.filterTransactionType = value.toString();
                      });
                    },
                  ),
                )
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(bottom: 16,),
              child: ElevatedButton(
                child: const Text(
                  'APPLY FILTER',
                  style: TextStyle(
                    color: AppColors.background
                  ),
                ),
                onPressed: !widget.isFilterSet && !widget.isFiltered
                  ? () => Navigator.of(context).pop()
                  : () {
                    widget.setFilter(
                      widget.filterDate,
                      widget.initialStartDate!,
                      widget.initialEndDate!,
                      widget.filterTransactionType,
                    );

                    Navigator.of(context).pop();
                  },
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
            )
          ],
        ),
      ),
    );
  }
}