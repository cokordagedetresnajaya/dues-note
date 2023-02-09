import 'package:dues_note/widgets/alerts/single_button_alert.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../configs/colors.dart';
import '../models/organization.dart';
import '../models/organization_fee.dart';
import '../models/transaction.dart';
import '../providers/organizations.dart';
import '../providers/transactions.dart';
import '../providers/organization_fees.dart';
import './organization_fee/organization_fee_list_screen.dart';
import './organization_fee/create_organization_fee_screen.dart';
import './transactions/create_transaction_screen.dart';
import './transactions/transaction_list_screen.dart';
import '../widgets/cashflow_bar.dart';
import '../widgets/utils/vertical_space_20.dart';
import '../widgets/utils/vertical_space_10.dart';
import '../widgets/transactions/transaction_item.dart';
import '../widgets/cashflow_active_dues_item.dart';
import '../../widgets/empty_cashflow_data.dart';
import '../widgets/utils/loading_page.dart';

class CashFlowOverviewScreen extends StatefulWidget {
  static const routeName = '/cashflow-overview';
  const CashFlowOverviewScreen({Key? key}) : super(key: key);

  @override
  State<CashFlowOverviewScreen> createState() => _CashFlowOverviewState();
}

class _CashFlowOverviewState extends State<CashFlowOverviewScreen> {
  var _isInit = false;
  var _isLoading = false;
  var _organizationId = '';
  var months = [
    'JAN',
    'FEB',
    'MAR',
    'APR',
    'MAY',
    'JUN',
    'JUL',
    'AUG',
    'SEP',
    'OCT',
    'NOV',
    'DEC'
  ];

  @override
  void didChangeDependencies() async {
    if (!_isInit) {
      setState(() {
        _isLoading = true;
      });

      _organizationId = ModalRoute.of(context)?.settings.arguments as String;

      try {
        await Provider.of<Transactions>(context, listen: false)
            .fetchAndSetTransaction(_organizationId);

        await Provider.of<OrganizationFees>(context, listen: false)
            .fetchAndSetOrganizationFees(_organizationId);

        setState(() {
          _isLoading = false;
        });
      } catch (e) {
        showErrorDialog(e.toString());
      }
    }
    _isInit = true;
    super.didChangeDependencies();
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) {
        return SingleButtonAlert(
          title: 'Warning',
          content: message,
          buttonText: 'Okay',
          onPressed: () {
            Navigator.of(ctx).pop();
          },
        );
      },
    );
  }

  Future<void> _refreshData() async {
    await Provider.of<Transactions>(
      context,
      listen: false,
    ).fetchAndSetTransaction(_organizationId);

    await Provider.of<OrganizationFees>(
      context,
      listen: false,
    ).fetchAndSetOrganizationFees(_organizationId);
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> _cashflowDetail =
        Provider.of<Transactions>(context).get7MonthsBeforeCashflowDetail();
    OrganizationFee? activeDues =
        Provider.of<OrganizationFees>(context).getActiveOrganizationFee();
    List<Transaction> _latestTransactions =
        Provider.of<Transactions>(context).getLatestTransactions();
    Organization organization = Provider.of<Organizations>(context)
        .getOrganizationById(_organizationId);

    return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: _isLoading
              ? Container()
              : Text(
                  organization.name,
                  style: Theme.of(context).appBarTheme.titleTextStyle,
                ),
          leading: _isLoading ? Container() : const BackButton(),
          centerTitle: Theme.of(context).appBarTheme.centerTitle,
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.primary,
        ),
        body: _isLoading
            ? LoadingPage()
            : Padding(
                padding: const EdgeInsets.only(
                  left: 32,
                  right: 32,
                ),
                child: RefreshIndicator(
                  onRefresh: _refreshData,
                  color: AppColors.primary,
                  displacement: 20,
                  strokeWidth: 2,
                  child: SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.only(
                        bottom: 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Balance',
                            style: Theme.of(context).textTheme.titleMedium,
                            textAlign: TextAlign.left,
                          ),
                          Text(
                            'Rp. ${NumberFormat.currency(locale: 'it', decimalDigits: 0, symbol: '').format(Provider.of<Transactions>(context).getBalance())}',
                            style: const TextStyle(
                              color: AppColors.secondaryLight,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.left,
                          ),
                          const VerticalSpace20(),
                          Row(
                            children: _cashflowDetail.reversed
                                .map(
                                  (element) => CashFlowBar(
                                    barText: months[element['month'] - 1],
                                    income: element['income'].toDouble(),
                                    expenses: element['expenses'].toDouble(),
                                  ),
                                )
                                .toList(),
                          ),
                          const VerticalSpace20(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                child: Row(
                                  children: [
                                    Container(
                                      width: 20,
                                      height: 10,
                                      color: AppColors.secondaryLight,
                                      margin: const EdgeInsets.only(
                                        right: 16,
                                      ),
                                    ),
                                    Text(
                                      'INCOME',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall,
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                child: Row(
                                  children: [
                                    Container(
                                      width: 20,
                                      height: 10,
                                      color: AppColors.secondaryDark,
                                      margin: const EdgeInsets.only(
                                        right: 16,
                                      ),
                                    ),
                                    Text(
                                      'EXPENSES',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall,
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                          const VerticalSpace20(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Active Dues',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (_, __, ___) =>
                                          OrganizationFeeListScreen(),
                                      transitionsBuilder: (_, a, __, c) =>
                                          FadeTransition(
                                        opacity: a,
                                        child: c,
                                      ),
                                      settings: RouteSettings(
                                        arguments: _organizationId,
                                      ),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'View all',
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                              )
                            ],
                          ),
                          const VerticalSpace10(),
                          activeDues == null
                              ? EmptyCashflowData(
                                  'You don\'t have any dues yet',
                                  'Create Dues',
                                  CreateOrganizationFeeScreen.routeName,
                                  _organizationId,
                                )
                              : CashflowActiveDuesItem(activeDues),
                          const VerticalSpace20(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Latest Transactions',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              InkWell(
                                splashColor: AppColors.gray,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (_, __, ___) =>
                                          TransactionListScreen(),
                                      transitionsBuilder: (_, a, __, c) =>
                                          FadeTransition(
                                        opacity: a,
                                        child: c,
                                      ),
                                      settings: RouteSettings(
                                        arguments: _organizationId,
                                      ),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'View all',
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                              )
                            ],
                          ),
                          const VerticalSpace10(),
                          _latestTransactions.isEmpty
                              ? EmptyCashflowData(
                                  'You don’t have any transactions yet',
                                  'Add Transaction',
                                  CreateTransactionScreen.routeName,
                                  _organizationId,
                                )
                              : Container(
                                  child: Column(
                                    children: _latestTransactions
                                        .map(
                                          (element) => TransactionItem(
                                            element.id,
                                            element.title,
                                            '${DateFormat.EEEE().format(element.date)}, ${DateFormat.d().format(element.date)} ${DateFormat.MMMM().format(element.date)} ${DateFormat.y().format(element.date)}',
                                            element.amount,
                                            element.type,
                                            element.duesId,
                                          ),
                                        )
                                        .toList(),
                                  ),
                                )
                        ],
                      ),
                    ),
                  ),
                ),
              ));
  }
}
