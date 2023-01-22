import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:jiffy/jiffy.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';
import '../../models/transaction.dart';
import '../../providers/members.dart';
import '../../providers/organization_fees.dart';
import '../../providers/transactions.dart';
import './create_transaction_screen.dart';
import '../../widgets/utils/vertical_space_20.dart';
import '../../widgets/utils/vertical_space_10.dart';
import '../../widgets/transactions/bottom_border_transaction_item.dart';
import '../../widgets/utils/search_not_found.dart';
import '../../widgets/utils/empty_data.dart';
import '../../configs/colors.dart';
import '../../widgets/alerts/two_button_alert.dart';
import '../../widgets/alerts/single_button_alert.dart';
import '../../widgets/inputs/date_picker.dart';
import '../../widgets/utils/loading_page.dart';
import '../../widgets/transactions/transaction_filter.dart';

class TransactionListScreen extends StatefulWidget {
  static const routeName = '/transaction-list';

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  bool _isInit = true;
  bool _isLoading = false;
  bool _isFiltered = false;
  String _filterDateMode = '';
  String _filterTransactionType = '';
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;
  var organizationId = '';
  bool _isDeleteMode = false;
  List<Transaction> transactions = [];
  List<Transaction> _filteredTransaction = [];
  List<String> _selectedId = [];

  @override
  void didChangeDependencies() {
    if (_isInit) {
      // Get organization ID
      organizationId = ModalRoute.of(context)?.settings.arguments as String;
      // Show Loading
      setState(() {
        _isLoading = true;
      });
      // Fetch and Set Transactions
      Provider.of<Transactions>(context)
          .fetchAndSetTransaction(organizationId)
          .catchError(
        (error) {
          _showErrorDialog('Something went wrong');
        },
      ).then((value) {
        // Hide loading
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => SingleButtonAlert(
        title: 'Warning',
        content: message,
        buttonText: 'Okay',
        onPressed: () {
          Navigator.of(ctx).pop();
        },
      ),
    );
  }

  void deleteTransactions() async {
    if (_selectedId.isNotEmpty) {
      // Unset delete mode
      setIsDeleteMode(false);
      // Show loading
      setState(() {
        _isLoading = true;
      });

      for (var i = 0; i < _selectedId.length; i++) {
        try {
          // Delete Transaction
          var data = await Provider.of<Transactions>(
            context,
            listen: false,
          ).deleteTransactions(_selectedId[i]);

          if (data['memberId'] != '' &&
              data['memberId'] != null &&
              data['duesId'] != '' &&
              data['duesId'] != null &&
              data['isDelete'] &&
              data['isDuesType']) {
            try {
              // Cancel member payment that connected with transaction
              await Provider.of<Members>(
                context,
                listen: false,
              ).cancelPayment(data['duesId'], data['memberId']);
              // Get dues by id
              var dues = Provider.of<OrganizationFees>(
                context,
                listen: false,
              ).getOrganizationFeeById(data['duesId']);

              try {
                // Reset Members
                await Provider.of<Members>(
                  context,
                  listen: false,
                ).fetchAndSetMembers(data['duesId']);
                // Get count of paid members
                var paidMembersCount =
                    Provider.of<Members>(context, listen: false)
                        .getCountPaidMembers(dues.amount);
                try {
                  await Provider.of<OrganizationFees>(context, listen: false)
                      .updateOrganizationFeeMember(data['duesId'],
                          dues.numberOfMembers, paidMembersCount);
                } catch (e) {
                  _showErrorDialog(e.toString());
                }
              } catch (e) {
                _showErrorDialog(e.toString());
              }
            } catch (e) {
              _showErrorDialog(e.toString());
            }
          }
        } catch (e) {
          break;
        }
      }
      _selectedId.clear();
      if (_isFiltered) {
        resetFilter();
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  void setIsDeleteMode(bool value) {
    setState(() {
      _isDeleteMode = value;
    });
  }

  bool getDeleteMode() => _isDeleteMode;

  int getSelectedItem() => _selectedId.length;

  void setSelectedItem(String id) {
    _selectedId.add(id);
  }

  void removeSelectedItem(String id) {
    _selectedId.remove(id);
  }

  void resetFilter() {
    setState(() {
      _isFiltered = false;
      _filterDateMode = '';
      _filterTransactionType = '';
      _filterStartDate = null;
      _filterEndDate = null;
      _filteredTransaction.clear();
    });
  }

  void resetDeleteMode() {
    setState(() {
      _isDeleteMode = false;
    });
    _selectedId.clear();
  }

  void setFilter(String? dateOption, DateTime startDate, DateTime endDate,
      String transactionType) {
    setState(() {
      _filteredTransaction.clear();
    });

    if (transactions.isNotEmpty) {
      if (dateOption == '7 days') {
        setState(() {
          _filteredTransaction = _filtering(transactionType, 7, 1);
          _filterStartDate = null;
          _filterEndDate = null;
        });
      } else if (dateOption == '30 days') {
        setState(() {
          _filteredTransaction = _filtering(transactionType, 30, 1);
          _filterStartDate = null;
          _filterEndDate = null;
        });
      } else if (dateOption == 'custom') {
        setState(() {
          _filteredTransaction = _filtering(transactionType, 1, 1,
              isCustom: true, startDate: startDate, endDate: endDate);
          _filterStartDate = startDate;
          _filterEndDate = endDate;
        });
      } else {
        setState(() {
          _filteredTransaction = _filtering(transactionType, 1, 1,
              startDate: startDate, endDate: endDate);
          _filterStartDate = startDate;
          _filterEndDate = endDate;
        });
      }

      setState(() {
        _isFiltered = true;
        _filterDateMode = dateOption as String;
        _filterTransactionType = transactionType;
      });
    }
  }

  List<Transaction> _filtering(
      String transactionType, int subtractDays, int addDays,
      {bool isCustom = false, DateTime? startDate, DateTime? endDate}) {
    List<Transaction> filteredTransaction = [];

    if (isCustom) {
      if (transactionType != '') {
        for (var i = 0; i < transactions.length; i++) {
          if ((transactions[i].date.isAtSameMomentAs(startDate!) ||
                  transactions[i].date.isAfter(startDate)) &&
              transactions[i]
                  .date
                  .isBefore(endDate!.add(const Duration(days: 1))) &&
              (transactions[i].type == transactionType ||
                  (transactions[i].type == 'dues' &&
                      transactionType == 'income'))) {
            filteredTransaction.add(transactions[i]);
          }
        }
      } else {
        for (var i = 0; i < transactions.length; i++) {
          if ((transactions[i].date.isAtSameMomentAs(startDate!) ||
                  transactions[i].date.isAfter(startDate)) &&
              transactions[i]
                  .date
                  .isBefore(endDate!.add(const Duration(days: 1)))) {
            filteredTransaction.add(transactions[i]);
          }
        }
      }
    } else {
      DateTime now = DateTime.now();
      DateTime today = DateTime(now.year, now.month, now.day);
      if (transactionType != '') {
        for (var i = 0; i < transactions.length; i++) {
          if ((transactions[i].date.isAtSameMomentAs(
                      today.subtract(Duration(days: subtractDays - 1))) ||
                  transactions[i].date.isAfter(
                      today.subtract(Duration(days: subtractDays - 1)))) &&
              transactions[i]
                  .date
                  .isBefore(today.add(Duration(days: addDays))) &&
              (transactions[i].type == transactionType ||
                  (transactions[i].type == 'dues' &&
                      transactionType == 'income'))) {
            filteredTransaction.add(transactions[i]);
          }
        }
      } else {
        for (var i = 0; i < transactions.length; i++) {
          if ((transactions[i].date.isAtSameMomentAs(
                      today.subtract(Duration(days: subtractDays - 1))) ||
                  transactions[i].date.isAfter(
                      today.subtract(Duration(days: subtractDays - 1)))) &&
              transactions[i]
                  .date
                  .isBefore(today.add(Duration(days: addDays)))) {
            filteredTransaction.add(transactions[i]);
          }
        }
      }
    }
    return filteredTransaction;
  }

  @override
  Widget build(BuildContext context) {
    transactions = Provider.of<Transactions>(context).items;
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: _isLoading ? Container() : const BackButton(),
        title: _isLoading
            ? Container()
            : Text(
                'Transactions',
                style: Theme.of(context).appBarTheme.titleTextStyle,
              ),
        backgroundColor: AppColors.background,
        centerTitle: true,
        foregroundColor: AppColors.primary,
        actions: _isLoading
            ? []
            : _isDeleteMode
                ? [
                    IconButton(
                      onPressed: () async {
                        bool? dialogValue = await showDialog(
                          context: context,
                          builder: (ctx) => TwoButtonAlert(
                            title: 'Warning',
                            content:
                                'Are you sure you want to delete selected transactions?',
                            buttonText1: 'Yes',
                            buttonText2: 'No',
                            onPressed1: () => Navigator.pop(ctx, true),
                            onPressed2: () => Navigator.pop(ctx, false),
                          ),
                        );

                        if (dialogValue == true) {
                          deleteTransactions();
                        }
                      },
                      icon: const Icon(
                        Icons.delete,
                        color: AppColors.red,
                      ),
                    ),
                  ]
                : [
                    IconButton(
                      onPressed: () {
                        showModalBottomSheet(
                          backgroundColor: AppColors.background,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(10),
                            ),
                          ),
                          isScrollControlled: true,
                          context: context,
                          builder: (context) {
                            bool _isCustom = _filterStartDate != null ||
                                    _filterEndDate != null
                                ? true
                                : false;
                            String _selectedType = _filterTransactionType != ''
                                ? _filterTransactionType
                                : '';
                            bool _filterSet = false;
                            String _filterDate =
                                _filterDateMode != '' ? _filterDateMode : '';
                            DateTime now = DateTime.now();
                            DateTime? _startDate = _filterStartDate ??
                                DateTime(now.year, now.month, now.day).subtract(
                                  const Duration(
                                    days: 1,
                                  ),
                                );
                            DateTime? _endDate = _filterEndDate ??
                                DateTime(now.year, now.month, now.day);

                            return TransactionFilter(
                              isFilterSet: _filterSet,
                              filterDate: _filterDate,
                              initialStartDate: _startDate,
                              initialEndDate: _endDate,
                              isCustom: _isCustom,
                              isFiltered: _isFiltered,
                              filterTransactionType: _selectedType,
                              resetFilterFn: resetFilter,
                              setFilter: setFilter,
                            );
                          },
                        );
                      },
                      icon: const Icon(
                        Icons.filter_list,
                      ),
                    ),
                  ],
      ),
      floatingActionButton: _isLoading
          ? null
          : SpeedDial(
              backgroundColor: AppColors.primary,
              animatedIcon: AnimatedIcons.menu_close,
              overlayColor: AppColors.primary,
              overlayOpacity: 0.4,
              spacing: 15,
              children: [
                SpeedDialChild(
                    backgroundColor: AppColors.lightGreen,
                    child: Image.asset(
                      'assets/images/excel.png',
                      height: 24,
                    ),
                    onTap: () {
                      showModalBottomSheet(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(10),
                          ),
                        ),
                        isScrollControlled: true,
                        context: context,
                        builder: (context) {
                          DateTime startDate =
                              Jiffy().startOf(Units.MONTH).dateTime;
                          DateTime endDate =
                              Jiffy().endOf(Units.MONTH).dateTime;

                          return StatefulBuilder(
                            builder: ((context, setState) {
                              return FractionallySizedBox(
                                heightFactor: 0.5,
                                child: Container(
                                  padding: const EdgeInsets.only(
                                    left: 16,
                                    right: 16,
                                    top: 8,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                      Text(
                                        'Start Date',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                      const VerticalSpace10(),
                                      DatePicker(
                                        dateText: DateFormat.d().format(
                                              startDate,
                                            ) +
                                            ' ' +
                                            DateFormat.MMMM().format(
                                              startDate,
                                            ) +
                                            ' ' +
                                            DateFormat.y().format(
                                              startDate,
                                            ),
                                        onTap: () async {
                                          DateTime? newDate =
                                              await showDatePicker(
                                            context: context,
                                            initialDate: startDate,
                                            firstDate: DateTime(1900),
                                            lastDate: endDate,
                                          );

                                          if (newDate != null) {
                                            setState(
                                              () {
                                                startDate = newDate;
                                              },
                                            );
                                          }
                                        },
                                      ),
                                      const VerticalSpace10(),
                                      Text(
                                        'End Date',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                      const VerticalSpace10(),
                                      DatePicker(
                                        dateText: DateFormat.d().format(
                                              endDate,
                                            ) +
                                            ' ' +
                                            DateFormat.MMMM().format(
                                              endDate,
                                            ) +
                                            ' ' +
                                            DateFormat.y().format(
                                              endDate,
                                            ),
                                        onTap: () async {
                                          DateTime? newDate =
                                              await showDatePicker(
                                            context: context,
                                            initialDate: endDate,
                                            firstDate: startDate,
                                            lastDate: DateTime(2500),
                                          );

                                          if (newDate != null) {
                                            final endDay =
                                                Jiffy().endOf(Units.DAY);
                                            setState(
                                              () {
                                                endDate = newDate.add(
                                                  Duration(
                                                    hours: endDay.hour,
                                                    minutes: endDay.minute,
                                                    seconds: endDay.second,
                                                    milliseconds:
                                                        endDay.millisecond,
                                                    microseconds:
                                                        endDay.millisecond,
                                                  ),
                                                );
                                              },
                                            );
                                          }
                                        },
                                      ),
                                      const VerticalSpace20(),
                                      Container(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          style: ButtonStyle(
                                            padding: MaterialStateProperty.all(
                                              const EdgeInsets.all(16),
                                            ),
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                              AppColors.primary,
                                            ),
                                          ),
                                          child: const Text('Generate Excel'),
                                          onPressed: () {
                                            Provider.of<Transactions>(context,
                                                    listen: false)
                                                .generateExcel(
                                                    startDate, endDate);
                                          },
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            }),
                          );
                        },
                      );
                    }),
                SpeedDialChild(
                    backgroundColor: AppColors.secondaryLight,
                    child: const Icon(
                      Icons.add,
                      color: AppColors.background,
                    ),
                    onTap: () {
                      Navigator.of(context)
                          .pushNamed(CreateTransactionScreen.routeName,
                              arguments: organizationId)
                          .then((value) {
                        resetFilter();
                        resetDeleteMode();
                      });
                    })
              ],
            ),
      body: _isLoading
          ? LoadingPage()
          : Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 0,
              ),
              child: transactions.isEmpty
                  ? EmptyData('You don\'t have any transaction')
                  : _isFiltered && _filteredTransaction.isEmpty
                      ? SearchNotFound('No transactions found')
                      : StickyGroupedListView(
                          elements:
                              _isFiltered ? _filteredTransaction : transactions,
                          groupBy: (dynamic element) => element.date,
                          groupSeparatorBuilder: (dynamic element) => Text(
                            DateFormat.EEEE().format(element.date) +
                                ', ' +
                                DateFormat.d().format(element.date) +
                                ' ' +
                                DateFormat.MMMM().format(element.date) +
                                ' ' +
                                DateFormat.y().format(element.date),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          itemBuilder: (context, dynamic element) =>
                              BottomBorderTransactionItem(
                            element.id,
                            element.title,
                            element.amount,
                            element.type,
                            element.paymentType,
                            element.duesId,
                            setIsDeleteMode,
                            getDeleteMode,
                            getSelectedItem,
                            setSelectedItem,
                            removeSelectedItem,
                            resetFilter,
                            resetDeleteMode,
                          ),
                          stickyHeaderBackgroundColor: AppColors.background,
                          order: StickyGroupedListOrder.DESC,
                        ),
            ),
    );
  }
}
