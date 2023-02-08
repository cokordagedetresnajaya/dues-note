import 'package:dues_note/configs/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jiffy/jiffy.dart';
import '../../widgets/utils/vertical_space_10.dart';
import '../../widgets/utils/vertical_space_20.dart';
import '../../models/organization_fee.dart';
import '../../providers/organization_fees.dart';
import '../../providers/members.dart';
import '../../widgets/alerts/single_button_alert.dart';
import '../../widgets/utils/loading_page.dart';
import '../../widgets/inputs/text_field_input.dart';
import '../../widgets/inputs/custom_date_picker.dart';

class EditOrganizationFeeScreen extends StatefulWidget {
  static const routeName = '/edit-dues';

  @override
  State<EditOrganizationFeeScreen> createState() =>
      _EditOrganizationFeeScreenState();
}

class _EditOrganizationFeeScreenState extends State<EditOrganizationFeeScreen> {
  final _formKey = GlobalKey<FormState>();
  var organizationFeeId;
  var _isLoading = false;
  OrganizationFee? organizationFee;
  var firstDate = Jiffy().startOf(Units.MONTH).dateTime;
  var lastDate = Jiffy().endOf(Units.MONTH).dateTime;
  var _formValue = OrganizationFee(
    id: '',
    title: '',
    isActive: true,
    amount: 0,
    startDate: DateTime.now(),
    endDate: DateTime.now(),
    organizationId: '',
    numberOfMembers: 0,
    numberOfPaidMembers: 0,
  );

  @override
  void didChangeDependencies() {
    organizationFeeId = ModalRoute.of(context)!.settings.arguments;
    organizationFee = Provider.of<OrganizationFees>(
      context,
    ).getOrganizationFeeById(organizationFeeId);
    _formValue = OrganizationFee(
      id: organizationFee!.id,
      title: organizationFee!.title,
      isActive: organizationFee!.isActive,
      amount: organizationFee!.amount,
      startDate: organizationFee!.startDate,
      endDate: organizationFee!.endDate,
      organizationId: organizationFee!.organizationId,
      numberOfMembers: organizationFee!.numberOfMembers,
      numberOfPaidMembers: organizationFee!.numberOfPaidMembers,
    );
    super.didChangeDependencies();
  }

  void showErrorMessage(String errorMessage) {
    showDialog(
      context: context,
      builder: (ctx) => SingleButtonAlert(
        title: 'Warning',
        content: errorMessage,
        buttonText: 'Okay',
        onPressed: () {
          Navigator.of(ctx).pop();
        },
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    final members = Provider.of<Members>(
      context,
      listen: false,
    ).items;
    var countPaidMembers = 0;
    members.forEach((element) {
      if (element.organizationFeeAmount >= _formValue.amount) {
        countPaidMembers++;
      }
    });

    _formValue.numberOfPaidMembers = countPaidMembers;

    try {
      await Provider.of<OrganizationFees>(
        context,
        listen: false,
      ).updateOrganizationFee(_formValue);
      Navigator.of(context).pop();
    } catch (error) {
      showErrorMessage('Something went wrong');
    }
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
                'Edit Dues',
                style: Theme.of(context).appBarTheme.titleTextStyle,
              ),
        centerTitle: true,
        foregroundColor: AppColors.primary,
        backgroundColor: AppColors.background,
      ),
      body: _isLoading
          ? LoadingPage()
          : Container(
              padding: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 16,
              ),
              width: double.infinity,
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dues Title',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      const VerticalSpace10(),
                      TextFieldInput(
                        initialValue: _formValue.title,
                        hintText: 'Enter dues title',
                        onValidate: (value) {
                          if (value!.isEmpty) {
                            return "Please enter the dues title";
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _formValue = OrganizationFee(
                            id: _formValue.id,
                            title: value!,
                            isActive: _formValue.isActive,
                            amount: _formValue.amount,
                            startDate: _formValue.startDate,
                            endDate: _formValue.endDate,
                            organizationId: _formValue.organizationId,
                            numberOfMembers: _formValue.numberOfMembers,
                            numberOfPaidMembers: _formValue.numberOfPaidMembers,
                          );
                        },
                      ),
                      const VerticalSpace10(),
                      Text(
                        'Date Period',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      const VerticalSpace10(),
                      Row(
                        children: [
                          Flexible(
                            child: CustomDatePicker(
                              text: 'from',
                              date: _formValue.startDate,
                              onTap: () async {
                                DateTime? newStartDate = await showDatePicker(
                                  context: context,
                                  initialDate: _formValue.startDate,
                                  firstDate: DateTime(1900),
                                  lastDate: _formValue.endDate,
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

                                if (newStartDate == null) return;

                                setState(() {
                                  firstDate = newStartDate;
                                });
                                _formValue = OrganizationFee(
                                  id: _formValue.id,
                                  title: _formValue.title,
                                  isActive: _formValue.isActive,
                                  amount: _formValue.amount,
                                  startDate: firstDate,
                                  endDate: _formValue.endDate,
                                  organizationId: _formValue.organizationId,
                                  numberOfMembers: _formValue.numberOfMembers,
                                  numberOfPaidMembers:
                                      _formValue.numberOfPaidMembers,
                                );
                              },
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Flexible(
                            child: CustomDatePicker(
                              text: 'to',
                              date: _formValue.endDate,
                              onTap: () async {
                                DateTime? newLastDate = await showDatePicker(
                                  context: context,
                                  initialDate: _formValue.endDate,
                                  firstDate: _formValue.startDate,
                                  lastDate: DateTime(2500),
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

                                if (newLastDate == null) return;

                                setState(() {
                                  lastDate = newLastDate;
                                });

                                _formValue = OrganizationFee(
                                  id: _formValue.id,
                                  title: _formValue.title,
                                  isActive: _formValue.isActive,
                                  amount: _formValue.amount,
                                  startDate: _formValue.startDate,
                                  endDate: lastDate,
                                  organizationId: _formValue.organizationId,
                                  numberOfMembers: _formValue.numberOfMembers,
                                  numberOfPaidMembers:
                                      _formValue.numberOfPaidMembers,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const VerticalSpace10(),
                      const Text(
                        'Dues Amount',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 16,
                        ),
                      ),
                      const VerticalSpace10(),
                      TextFieldInput(
                        initialValue: _formValue.amount.toInt().toString(),
                        keyboardType: TextInputType.number,
                        onValidate: (value) {
                          if (value!.isEmpty) {
                            return "Please enter the dues amount";
                          }

                          if (value.contains(',') ||
                              value.contains(' ') ||
                              value.contains('.')) {
                            return 'Format number not valid';
                          }

                          if (double.parse(value) <= 0) {
                            return "You can't input number smaller than 1";
                          }

                          return null;
                        },
                        hintText: 'Enter dues amount',
                        onSaved: (value) {
                          _formValue = OrganizationFee(
                            id: _formValue.id,
                            title: _formValue.title,
                            isActive: _formValue.isActive,
                            amount: double.parse(value!),
                            startDate: _formValue.startDate,
                            endDate: _formValue.endDate,
                            organizationId: _formValue.organizationId,
                            numberOfMembers: _formValue.numberOfMembers,
                            numberOfPaidMembers: _formValue.numberOfPaidMembers,
                          );
                        },
                      ),
                      const VerticalSpace20(),
                      Container(
                        width: double.infinity,
                        child: ElevatedButton(
                          child: const Text('SAVE'),
                          onPressed: _save,
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
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
