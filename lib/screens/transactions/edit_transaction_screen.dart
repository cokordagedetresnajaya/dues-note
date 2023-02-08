import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/transaction.dart';
import '../../providers/transactions.dart';
import '../../configs/colors.dart';
import '../../widgets/utils/vertical_space_10.dart';
import '../../widgets/utils/vertical_space_20.dart';
import '../../widgets/utils/loading_page.dart';
import '../../widgets/inputs/text_field_input.dart';
import '../../widgets/inputs/dropdown_input.dart';
import '../../widgets/inputs/custom_option.dart';
import '../../widgets/alerts/single_button_alert.dart';

class EditTransactionScreen extends StatefulWidget {
  static const routeName = '/edit-transaction';

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  var _transactionId;
  Transaction? _transaction;
  String _selectedType = '';
  String? _selectedPaymentType;
  DateTime _transactionDate = DateTime.now();
  bool _isLoading = false;
  var _formValue;

  @override
  void didChangeDependencies() {
    _transactionId = ModalRoute.of(context)!.settings.arguments;
    _transaction = Provider.of<Transactions>(
      context,
    ).getTransactionById(_transactionId);

    _selectedType = _transaction!.type;
    _selectedPaymentType = _transaction!.paymentType;
    _transactionDate = _transaction!.date;

    _formValue = Transaction(
      id: _transactionId,
      title: _transaction!.title,
      type: _transaction!.type,
      amount: _transaction!.amount,
      date: _transaction!.date,
      paymentType: _transaction!.paymentType,
      description: _transaction!.description,
      organizationId: _transaction!.organizationId,
      duesId: _transaction!.duesId,
      memberId: _transaction!.memberId,
      createdAt: _transaction!.createdAt,
    );
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });

    var errorMessage = 'Something went wrong. Please try again later.';

    try {
      await Provider.of<Transactions>(
        context,
        listen: false,
      ).updateTransaction(_formValue);

      Navigator.of(context).pop();
    } on SocketException catch (error) {
      errorMessage =
          'Something went wrong with your network. Please check your network connection';
      _showErrorDialog(errorMessage);
    } catch (e) {
      _showErrorDialog(errorMessage);
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: _isLoading ? Container() : const BackButton(),
        title: _isLoading
            ? Container()
            : Text(
                'Edit Transaction',
                style: Theme.of(context).appBarTheme.titleTextStyle,
              ),
        centerTitle: true,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.primary,
      ),
      body: _isLoading
          ? LoadingPage()
          : SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Transaction Title',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      const VerticalSpace10(),
                      TextFieldInput(
                        initialValue: _formValue.title,
                        hintText: 'Enter transaction title',
                        onValidate: (value) {
                          if (value!.isEmpty) {
                            return "Please enter the transaction title";
                          }

                          return null;
                        },
                        onSaved: (value) {
                          _formValue = Transaction(
                            id: _formValue.id,
                            title: value!,
                            type: _formValue.type,
                            amount: _formValue.amount,
                            date: _formValue.date,
                            paymentType: _formValue.paymentType,
                            description: _formValue.description,
                            organizationId: _formValue.organizationId,
                            duesId: _formValue.duesId,
                            memberId: _formValue.memberId,
                            createdAt: _formValue.createdAt,
                          );
                        },
                      ),
                      const VerticalSpace10(),
                      Text(
                        'Type',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      const VerticalSpace10(),
                      CustomOption(
                        optionText: 'Income',
                        currentSelectedType: _selectedType,
                        typeValue: 'income',
                        activeColor: AppColors.lightGreen,
                        onTap: () {
                          setState(() {
                            _selectedType = 'income';
                          });
                          _formValue = Transaction(
                            id: _formValue.id,
                            title: _formValue.id,
                            type: _selectedType,
                            amount: _formValue.amount,
                            date: _formValue.date,
                            paymentType: _formValue.paymentType,
                            description: _formValue.description,
                            organizationId: _formValue.organizationId,
                            duesId: _formValue.duesId,
                            memberId: _formValue.memberId,
                            createdAt: _formValue.createdAt,
                          );
                        },
                        onChange: (value) {
                          setState(() {
                            _selectedType = value.toString();
                          });
                          _formValue = Transaction(
                            id: _formValue.id,
                            title: _formValue.id,
                            type: _selectedType,
                            amount: _formValue.amount,
                            date: _formValue.date,
                            paymentType: _formValue.paymentType,
                            description: _formValue.description,
                            organizationId: _formValue.organizationId,
                            duesId: _formValue.duesId,
                            memberId: _formValue.memberId,
                            createdAt: _formValue.createdAt,
                          );
                        },
                      ),
                      const VerticalSpace10(),
                      CustomOption(
                        optionText: 'Expenses',
                        currentSelectedType: _selectedType,
                        typeValue: 'expenses',
                        activeColor: AppColors.red,
                        onTap: () {
                          setState(() {
                            _selectedType = 'expenses';
                          });
                          _formValue = Transaction(
                            id: _formValue.id,
                            title: _formValue.id,
                            type: _selectedType,
                            amount: _formValue.amount,
                            date: _formValue.date,
                            paymentType: _formValue.paymentType,
                            description: _formValue.description,
                            organizationId: _formValue.organizationId,
                            duesId: _formValue.duesId,
                            memberId: _formValue.memberId,
                            createdAt: _formValue.createdAt,
                          );
                        },
                        onChange: (value) {
                          setState(() {
                            _selectedType = value.toString();
                          });
                          _formValue = Transaction(
                            id: _formValue.id,
                            title: _formValue.title,
                            type: _selectedType,
                            amount: _formValue.amount,
                            date: _formValue.date,
                            paymentType: _formValue.paymentType,
                            description: _formValue.description,
                            organizationId: _formValue.organizationId,
                            duesId: _formValue.duesId,
                            memberId: _formValue.memberId,
                            createdAt: _formValue.createdAt,
                          );
                        },
                      ),
                      const VerticalSpace10(),
                      Text(
                        'Transaction Date',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      const VerticalSpace10(),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () async {
                          DateTime? _newDate = await showDatePicker(
                            context: context,
                            initialDate: _transactionDate,
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: AppColors.primary,
                                    onPrimary: AppColors.background,
                                  ),
                                  textButtonTheme: TextButtonThemeData(
                                    style: TextButton.styleFrom(
                                      primary: AppColors.secondaryLight, // button text color
                                    ),
                                  ),
                                ),
                                child: child!,
                              )
                            }
                          );

                          if (_newDate == null) return;

                          setState(() {
                            _transactionDate = _newDate;
                          });
                          _formValue = Transaction(
                            id: _formValue.id,
                            title: _formValue.title,
                            type: _formValue.type,
                            amount: _formValue.amount,
                            date: _transactionDate,
                            paymentType: _formValue.paymentType,
                            description: _formValue.description,
                            organizationId: _formValue.organizationId,
                            duesId: _formValue.duesId,
                            memberId: _formValue.memberId,
                            createdAt: _formValue.createdAt,
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(
                                10,
                              ),
                            ),
                            border: Border.all(
                              color: AppColors.gray,
                              width: 0.5,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Text(
                            DateFormat.yMMMEd().format(_transactionDate),
                          ),
                        ),
                      ),
                      const VerticalSpace10(),
                      Text(
                        'Amount',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      const VerticalSpace10(),
                      TextFieldInput(
                        initialValue: _formValue.amount.toString(),
                        hintText: 'Enter transaction amount',
                        keyboardType: TextInputType.number,
                        onValidate: (value) {
                          if (value!.isEmpty) {
                            return "Please enter the transaction amount";
                          }

                          if (value.contains(',') ||
                              value.contains(' ') ||
                              value.contains('.')) {
                            return 'Format number not valid';
                          }

                          if (double.parse(value) < 0) {
                            return "You can't input negative number";
                          }

                          return null;
                        },
                        onSaved: (value) {
                          _formValue = Transaction(
                            id: _formValue.id,
                            title: _formValue.title,
                            type: _formValue.type,
                            amount: int.parse(
                              value.toString(),
                            ),
                            date: _formValue.date,
                            paymentType: _formValue.paymentType,
                            description: _formValue.description,
                            organizationId: _formValue.organizationId,
                            duesId: _formValue.duesId,
                            memberId: _formValue.memberId,
                            createdAt: _formValue.createdAt,
                          );
                        },
                      ),
                      const VerticalSpace10(),
                      Text(
                        'Payment Type',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      const VerticalSpace10(),
                      DropdownInput(
                        currentValue: _selectedPaymentType,
                        hintText: 'Select Payment Type',
                        items: const [
                          DropdownMenuItem(
                            value: 'Cash',
                            child: Text('Cash'),
                          ),
                          DropdownMenuItem(
                            value: 'Bank Transfer',
                            child: Text('Bank Transfer'),
                          ),
                          DropdownMenuItem(
                            value: 'E-Wallet',
                            child: Text('E-Wallet'),
                          ),
                          DropdownMenuItem(
                            value: 'Credit Card',
                            child: Text('Credit Card'),
                          ),
                          DropdownMenuItem(
                            value: 'Debit Card',
                            child: Text('Debit Card'),
                          )
                        ],
                        validator: (value) {
                          if (value == null) {
                            return "Please choose payment type";
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            _selectedPaymentType = value.toString();
                          });
                          _formValue = Transaction(
                            id: _formValue.id,
                            title: _formValue.title,
                            type: _formValue.type,
                            amount: _formValue.amount,
                            date: _formValue.date,
                            paymentType: value.toString(),
                            description: _formValue.description,
                            organizationId: _formValue.organizationId,
                            duesId: _formValue.duesId,
                            memberId: _formValue.memberId,
                            createdAt: _formValue.createdAt,
                          );
                        },
                      ),
                      const VerticalSpace10(),
                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      const VerticalSpace10(),
                      TextFieldInput(
                        initialValue: _formValue.description,
                        hintText: 'Enter transaction description',
                        maxLines: 5,
                        onSaved: (value) {
                          _formValue = Transaction(
                            id: _formValue.id,
                            title: _formValue.title,
                            type: _formValue.type,
                            amount: _formValue.amount,
                            date: _formValue.date,
                            paymentType: _formValue.paymentType,
                            description: value.toString(),
                            organizationId: _formValue.organizationId,
                            duesId: _formValue.duesId,
                            memberId: _formValue.memberId,
                            createdAt: _formValue.createdAt,
                          );
                        },
                      ),
                      const VerticalSpace20(),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(bottom: 16),
                        child: ElevatedButton(
                          child: const Text('SAVE'),
                          onPressed: _submit,
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
              ),
            ),
    );
  }
}
