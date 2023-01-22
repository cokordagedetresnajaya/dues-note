import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/transaction.dart';
import '../../models/organization_fee.dart';
import '../../models/member.dart';
import '../../providers/members.dart';
import '../../providers/organization_fees.dart';
import '../../providers/transactions.dart';
import '../../configs/colors.dart';
import '../utils/vertical_space_10.dart';
import '../utils/vertical_space_20.dart';
import '../inputs/text_field_input.dart';
import '../inputs/dropdown_input.dart';
import '../alerts/two_button_alert.dart';
import '../alerts/single_button_alert.dart';

class OrganizationFeeMemberItem extends StatefulWidget {
  final Member member;
  final OrganizationFee organizationFee;
  OrganizationFeeMemberItem(
    this.member,
    this.organizationFee,
  );

  @override
  State<OrganizationFeeMemberItem> createState() =>
      _OrganizationFeeMemberItemState();
}

class _OrganizationFeeMemberItemState extends State<OrganizationFeeMemberItem> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _selectedPaymentType;
  int amount = 0;
  String? paymentType;

  @override
  void initState() {
    amount = widget.member.organizationFeeAmount.toInt();

    if (widget.member.transactionId != '') {
      final transaction = Provider.of<Transactions>(
        context,
        listen: false,
      ).getTransactionById(
        widget.member.transactionId,
      );

      paymentType = transaction.paymentType;
      _selectedPaymentType = paymentType;
    }
    super.initState();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => SingleButtonAlert(
        title: 'Info',
        content: message,
        buttonText: 'Okay',
        onPressed: () {
          Navigator.of(ctx).pop();
        },
      ),
    );
  }

  Widget _buildBottomSheetForm() {
    return Form(
      key: _formKey,
      child: FractionallySizedBox(
        heightFactor: 0.6,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
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
              Text(
                'Amount (IDR)',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const VerticalSpace10(),
              TextFieldInput(
                initialValue: amount != 0 ? amount.toString() : '',
                hintText: 'Enter amount',
                keyboardType: TextInputType.number,
                onValidate: (value) {
                  if (value!.isEmpty) {
                    return "Please enter payment amount";
                  }

                  if (value.contains(',') ||
                      value.contains(' ') ||
                      value.contains('.')) {
                    return 'Number format not valid';
                  }

                  if (int.parse(value) < 0) {
                    return "Amount value cannot smaller than 0";
                  }

                  return null;
                },
                onSaved: (value) {
                  amount = int.parse(value!);
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
                },
              ),
              const VerticalSpace20(),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(bottom: 16),
                child: ElevatedButton(
                  child: const Text(
                    'PAY DUES',
                    style: TextStyle(
                      color: AppColors.background,
                    ),
                  ),
                  onPressed: payDues,
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
              widget.member.transactionId != ''
                  ? Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        child: const Text(
                          'CANCEL DUES PAYMENT',
                          style: TextStyle(
                            color: AppColors.background,
                          ),
                        ),
                        onPressed: cancelPayment,
                        style: ButtonStyle(
                          padding: MaterialStateProperty.all(
                            const EdgeInsets.symmetric(
                              vertical: 18,
                              horizontal: 16,
                            ),
                          ),
                          backgroundColor: MaterialStateProperty.all(
                            AppColors.secondaryLight,
                          ),
                        ),
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> showModal({String type = 'pay'}) async {
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(10),
        ),
      ),
      isScrollControlled: true,
      context: context,
      builder: (context) {
        _selectedPaymentType = paymentType;
        return _buildBottomSheetForm();
      },
    );
  }

  Future<void> payDues() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _formKey.currentState!.save();
    Navigator.of(context).pop();

    setState(() {
      _isLoading = true;
    });

    var transactionId = '';

    if (widget.member.transactionId == '' ||
        widget.member.transactionId == null) {
      final newTransaction = Transaction(
        id: "",
        title: '${widget.member.name} pay dues',
        type: 'dues',
        amount: amount,
        date: DateTime.now(),
        paymentType: _selectedPaymentType!,
        description: '',
        organizationId: widget.organizationFee.organizationId,
        duesId: widget.organizationFee.id,
        memberId: widget.member.id,
        createdAt: DateTime.now(),
      );

      try {
        // Add Transaction
        transactionId = await Provider.of<Transactions>(
          context,
          listen: false,
        ).createTransaction(newTransaction);

        // Update Member Dues Status, Organization Fee Amount, & Transaction ID
        await Provider.of<Members>(context, listen: false).payDues(
          widget.member.id,
          widget.organizationFee.id,
          amount,
          transactionId,
        );
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog(e.toString());
        return;
      }
    } else {
      try {
        await Provider.of<Members>(context, listen: false).payDues(
          widget.member.id,
          widget.organizationFee.id,
          amount,
        );
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog(e.toString());
        return;
      }

      final transaction = Provider.of<Transactions>(
        context,
        listen: false,
      ).getTransactionById(
        widget.member.transactionId,
      );

      final updatedTransaction = Transaction(
        id: transaction.id,
        title: transaction.title,
        type: transaction.type,
        amount: amount,
        date: transaction.date,
        paymentType: _selectedPaymentType!,
        description: transaction.description,
        organizationId: transaction.organizationId,
        duesId: transaction.duesId,
        memberId: transaction.memberId,
        createdAt: DateTime.now(),
      );

      try {
        await Provider.of<Transactions>(
          context,
          listen: false,
        ).updateTransaction(
          updatedTransaction,
        );
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog(e.toString());
        return;
      }
    }

    // Count
    var count = Provider.of<Members>(
      context,
      listen: false,
    ).getCountPaidMembers(
      widget.organizationFee.amount,
    );

    try {
      // Update Paid Member Value
      await Provider.of<OrganizationFees>(
        context,
        listen: false,
      ).updateOrganizationFeePaidMember(
        widget.organizationFee.id,
        count,
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog(e.toString());
      return;
    }

    setState(() {
      widget.member.transactionId =
          transactionId == '' ? widget.member.transactionId : transactionId;
      paymentType = _selectedPaymentType;
      _isLoading = false;
    });
  }

  Future<void> cancelPayment() async {
    var dialogValue = await showDialog(
      context: context,
      builder: (ctx) => TwoButtonAlert(
        title: 'Info',
        content: 'Do you want to cancel this member dues payment',
        buttonText1: 'Yes',
        buttonText2: 'No',
        onPressed1: () => Navigator.pop(ctx, true),
        onPressed2: () => Navigator.pop(ctx, false),
      ),
    );

    if (dialogValue != null && dialogValue == true) {
      Navigator.of(context).pop();
      // Start loading
      setState(() {
        _isLoading = true;
      });

      try {
        // Delete transaction
        await Provider.of<Transactions>(
          context,
          listen: false,
        ).deleteTransactions(widget.member.transactionId);

        await Provider.of<Members>(
          context,
          listen: false,
        ).cancelPayment(widget.organizationFee.id, widget.member.id);
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog(e.toString());
        return;
      }

      // Count
      var count = Provider.of<Members>(
        context,
        listen: false,
      ).getCountPaidMembers(
        widget.organizationFee.amount,
      );

      try {
        // Update Paid Member Value
        await Provider.of<OrganizationFees>(
          context,
          listen: false,
        ).updateOrganizationFeePaidMember(
          widget.organizationFee.id,
          count,
        );
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog(e.toString());
        return;
      }

      setState(() {
        _isLoading = false;
        amount = 0;
        _selectedPaymentType = null;
        paymentType = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.only(
        left: 0,
        top: 8,
        bottom: 8,
        right: 8,
      ),
      leading: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.only(
              right: 16,
            ),
            height: 42,
            width: 42,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
              color: AppColors.primary,
            ),
            child: Center(
              child: Text(
                widget.member.name.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.background,
                ),
              ),
            ),
          ),
        ],
      ),
      title: Text(
        widget.member.name,
        style: const TextStyle(
          fontSize: 16,
        ),
      ),
      subtitle:
          widget.member.organizationFeeAmount == widget.organizationFee.amount
              ? const Text(
                  'Paid',
                  style: TextStyle(
                    color: AppColors.lightGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : widget.member.organizationFeeAmount == 0
                  ? const Text(
                      'Unpaid',
                      style: TextStyle(
                        color: AppColors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : widget.member.organizationFeeAmount >
                          widget.organizationFee.amount
                      ? Text(
                          '+ Rp. ${NumberFormat.currency(locale: 'it', decimalDigits: 0, symbol: '').format((widget.member.organizationFeeAmount - widget.organizationFee.amount).toInt())}',
                          style: const TextStyle(
                            color: AppColors.lightGreen,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : Text(
                          '- Rp. ${NumberFormat.currency(locale: 'it', decimalDigits: 0, symbol: '').format((widget.organizationFee.amount - widget.member.organizationFeeAmount).toInt())}',
                          style: const TextStyle(
                            color: AppColors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
      trailing: ElevatedButton(
        child: _isLoading
            ? Transform.scale(
                scale: 0.3,
                child: const CircularProgressIndicator(
                  color: AppColors.background,
                ),
              )
            : Text(
                widget.member.organizationFeeAmount <
                        widget.organizationFee.amount
                    ? 'Pay'
                    : 'Edit',
                style: const TextStyle(
                  fontSize: 12,
                ),
              ),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(
            widget.member.organizationFeeAmount < widget.organizationFee.amount
                ? AppColors.secondaryLight
                : AppColors.primary,
          ),
        ),
        onPressed: _isLoading ? null : showModal,
      ),
    );
  }
}
