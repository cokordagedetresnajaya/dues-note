import 'dart:io';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/transaction.dart';
import '../../providers/transactions.dart';
import '../../widgets/utils/vertical_space_20.dart';
import '../../widgets/utils/vertical_space_10.dart';
import '../../widgets/utils/loading_page.dart';
import '../../widgets/inputs/text_field_input.dart';
import '../../configs/colors.dart';
import '../../widgets/inputs/custom_option.dart';
import '../../widgets/inputs/dropdown_input.dart';
import '../../widgets/alerts/single_button_alert.dart';

class CreateTransactionScreen extends StatefulWidget {
  static const routeName = '/create-transaction';
  const CreateTransactionScreen({Key? key}) : super(key: key);

  @override
  State<CreateTransactionScreen> createState() =>
      _CreateTransactionScreenState();
}

class _CreateTransactionScreenState extends State<CreateTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedType = 'income';
  String? _selectedPaymentType;
  DateTime _transactionDate = DateTime.now();
  bool _isLoading = false;
  String organizationId = '';

  var _formValue = Transaction(
    id: "",
    title: "",
    type: "income",
    amount: 0,
    date: DateTime.now(),
    paymentType: "",
    description: "",
    organizationId: "",
    createdAt: DateTime.now(),
  );

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      organizationId = ModalRoute.of(context)!.settings.arguments.toString();
    });
    super.initState();
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
      var transactionId = await Provider.of<Transactions>(
        context,
        listen: false,
      ).createTransaction(_formValue);

      setState(() {
        _isLoading = false;
        Navigator.of(context).pop();
      });
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
                'Create Transaction',
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
                        hintText: 'Entar Transaction Title',
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
                            organizationId: organizationId,
                            createdAt: DateTime.now(),
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
                            createdAt: DateTime.now(),
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
                            createdAt: DateTime.now(),
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
                            createdAt: DateTime.now(),
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
                            createdAt: DateTime.now(),
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
                            createdAt: DateTime.now(),
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
                        hintText: 'Enter transaction amount',
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
                            createdAt: DateTime.now(),
                          );
                        },
                        keyboardType: TextInputType.number,
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
                            createdAt: DateTime.now(),
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
                            createdAt: DateTime.now(),
                          );
                        },
                      ),
                      const VerticalSpace20(),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(bottom: 16),
                        child: ElevatedButton(
                          child: const Text('ADD TRANSACTION'),
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
