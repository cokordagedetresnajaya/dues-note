import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import '../../configs/colors.dart';
import '../members/add_member_screen.dart';
import '../../widgets/utils/vertical_space_10.dart';
import '../../widgets/utils/vertical_space_20.dart';
import '../../widgets/inputs/text_field_input.dart';
import '../../widgets/inputs/custom_date_picker.dart';

class CreateOrganizationFeeScreen extends StatefulWidget {
  static const routeName = '/create-dues';

  @override
  State<CreateOrganizationFeeScreen> createState() =>
      _CreateOrganizationFeeScreenState();
}

class _CreateOrganizationFeeScreenState
    extends State<CreateOrganizationFeeScreen> {
  final _formKey = GlobalKey<FormState>();
  var _organizationId = '';
  var _firstDate = Jiffy().startOf(Units.MONTH).dateTime;
  var _lastDate = Jiffy().endOf(Units.MONTH).dateTime;
  var _formValue = {
    'title': '',
    'duesAmount': 0,
    'startDate': DateTime.now(),
    'endDate': DateTime.now(),
    'organizationId': ''
  };

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      _organizationId = ModalRoute.of(context)?.settings.arguments as String;
    });
    super.initState();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    FocusScope.of(context).unfocus();
    Navigator.of(context).pushNamed(
      AddMemberScreen.routeName,
      arguments: _formValue,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Create Dues',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        centerTitle: true,
        foregroundColor: AppColors.primary,
        backgroundColor: AppColors.background,
      ),
      body: Container(
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
                  hintText: 'Enter dues title',
                  onValidate: (value) {
                    if (value!.isEmpty) {
                      return "Please enter the dues title";
                    }

                    return null;
                  },
                  onSaved: (value) {
                    _formValue['title'] = value.toString();
                    _formValue['duesAmount'] = _formValue['duesAmount']!;
                    _formValue['startDate'] = _firstDate;
                    _formValue['endDate'] = _formValue['endDate']!;
                    _formValue['organizationId'] = _organizationId;
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
                        date: _firstDate,
                        onTap: () async {
                          DateTime? newStartDate = await showDatePicker(
                            context: context,
                            initialDate: _firstDate,
                            firstDate: DateTime(1900),
                            lastDate: _lastDate,
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
                            _firstDate = newStartDate;
                          });

                          _formValue['title'] = _formValue['title']!;
                          _formValue['duesAmount'] = _formValue['duesAmount']!;
                          _formValue['startDate'] = _firstDate;
                          _formValue['endDate'] = _formValue['endDate']!;
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Flexible(
                      child: CustomDatePicker(
                        text: 'to',
                        date: _lastDate,
                        onTap: () async {
                          DateTime? newLastDate = await showDatePicker(
                            context: context,
                            initialDate: _lastDate,
                            firstDate: _firstDate,
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
                            _lastDate = newLastDate;
                          });

                          _formValue['title'] = _formValue['title']!;
                          _formValue['duesAmount'] = _formValue['duesAmount']!;
                          _formValue['startDate'] = _formValue['startDate']!;
                          _formValue['endDate'] = _lastDate;
                        },
                      ),
                    ),
                  ],
                ),
                const VerticalSpace10(),
                const Text(
                  'Dues Amount (IDR)',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 16,
                  ),
                ),
                const VerticalSpace10(),
                TextFieldInput(
                  hintText: 'Enter dues amount',
                  onValidate: (value) {
                    if (value!.isEmpty) {
                      return "Please enter the dues amount";
                    }

                    if (value.contains(',') || value.contains(' ')) {
                      return 'Format number not valid';
                    }

                    if (double.parse(value) <= 0) {
                      return "You can't input number smaller than 1";
                    }

                    return null;
                  },
                  onSaved: (value) {
                    _formValue['title'] = _formValue['title']!;
                    _formValue['duesAmount'] = double.parse(value.toString());
                    _formValue['startDate'] = _firstDate;
                    _formValue['endDate'] = _lastDate;
                  },
                  keyboardType: TextInputType.number,
                ),
                const VerticalSpace20(),
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    child: const Text('NEXT'),
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
