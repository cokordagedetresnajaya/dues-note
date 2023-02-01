import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../configs/colors.dart';
import '../../models/organization.dart';
import '../../models/organization_category.dart';
import '../../providers/organizations.dart';
import '../../providers/organization_categories.dart';
import '../../widgets/utils/loading_page.dart';
import '../../widgets/utils/vertical_space_10.dart';
import '../../widgets/utils/vertical_space_20.dart';
import '../../widgets/inputs/text_field_input.dart';
import '../../widgets/inputs/dropdown_input.dart';
import '../../widgets/alerts/single_button_alert.dart';

class EditOrganizationScreen extends StatefulWidget {
  const EditOrganizationScreen({Key? key}) : super(key: key);
  static const routeName = '/edit-organization';

  @override
  State<EditOrganizationScreen> createState() => _EditOrganizationScreenState();
}

class _EditOrganizationScreenState extends State<EditOrganizationScreen> {
  bool _isLoading = false;
  bool _isInit = true;
  final _formKey = GlobalKey<FormState>();
  String organizationId = '';
  Organization? _formValue;
  String? _selectedValue;
  List<OrganizationCategory> categories = [];

  @override
  void didChangeDependencies() {
    if (_isInit) {
      organizationId = ModalRoute.of(context)!.settings.arguments.toString();

      _formValue = Provider.of<Organizations>(
        context,
        listen: false,
      ).getOrganizationById(organizationId);

      categories = Provider.of<OrganizationCategories>(
        context,
        listen: false,
      ).items;

      _selectedValue = _formValue!.category;
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  Future<void> _saveForm() async {
    final isValid = _formKey.currentState?.validate();
    if (!isValid!) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    _formKey.currentState?.save();

    FocusScope.of(context).unfocus();

    _formValue = Organization(
      id: _formValue!.id,
      name: _formValue!.name,
      category: _selectedValue!,
      userId: _formValue!.userId,
      description: _formValue!.description,
    );

    try {
      await Provider.of<Organizations>(
        context,
        listen: false,
      ).updateOrganization(_formValue!);
    } catch (e) {
      await showDialog(
        context: context,
        builder: (ctx) => SingleButtonAlert(
          title: 'An error occured!',
          content: 'Something went wrong!',
          buttonText: 'Okay',
          onPressed: () {
            Navigator.of(ctx).pop();
          },
        ),
      );
    }

    Navigator.of(context).pop();
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
                'Edit Organization',
                style: Theme.of(context).appBarTheme.titleTextStyle,
              ),
        centerTitle: true,
        foregroundColor: AppColors.primary,
        backgroundColor: AppColors.background,
        elevation: Theme.of(context).appBarTheme.elevation,
      ),
      body: _isLoading
          ? LoadingPage()
          : Padding(
              padding: EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Organization Name",
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        const VerticalSpace10(),
                        TextFieldInput(
                          hintText: 'Input organization name',
                          initialValue: _formValue!.name,
                          onValidate: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please input organization name';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _formValue = Organization(
                              id: _formValue!.id,
                              name: value!,
                              category: _formValue!.category,
                              userId: _formValue!.userId,
                              description: _formValue!.description,
                            );
                          },
                        ),
                        const VerticalSpace10(),
                        Text(
                          "Category",
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        const VerticalSpace10(),
                        DropdownInput(
                          currentValue: _selectedValue,
                          hintText: 'Select Category',
                          items: categories.map(
                            (item) {
                              return DropdownMenuItem<String>(
                                value: item.id,
                                child: Text(item.name),
                              );
                            },
                          ).toList(),
                          validator: (value) {
                            if (value == null) {
                              return 'Please choose organization category';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              _selectedValue = value as String?;
                            });
                          },
                        ),
                        const VerticalSpace10(),
                        Text(
                          "Description",
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        const VerticalSpace10(),
                        TextFieldInput(
                          hintText: 'Input description',
                          initialValue: _formValue?.description == null
                              ? ''
                              : _formValue!.description!,
                          onSaved: (value) {
                            _formValue = Organization(
                              id: _formValue!.id,
                              name: _formValue!.name,
                              category: _formValue!.category,
                              userId: _formValue!.userId,
                              description: value,
                            );
                          },
                          maxLines: 5,
                        ),
                        const VerticalSpace20(),
                        ElevatedButton(
                          onPressed: _saveForm,
                          child: Container(
                            width: double.infinity,
                            height: 50,
                            child: const Center(
                              child: Text(
                                'SAVE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                              AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
