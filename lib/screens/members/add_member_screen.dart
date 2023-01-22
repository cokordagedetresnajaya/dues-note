import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../configs/colors.dart';
import '../../models/organization_fee.dart';
import '../../providers/organization_fees.dart';
import '../../providers/members.dart';
import '../../providers/organizations.dart';
import '../../widgets/utils/empty_data.dart';
import '../../widgets/members/member_item.dart';
import '../../widgets/members/add_member_bottom_sheet_form.dart';
import '../../widgets/utils/loading_page.dart';
import '../../widgets/alerts/single_button_alert.dart';
import '../../widgets/alerts/two_button_alert.dart';

class AddMemberScreen extends StatefulWidget {
  static const routeName = '/add-members';
  const AddMemberScreen({Key? key}) : super(key: key);

  @override
  State<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  var organizationFeeData;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  List<Map<String, dynamic>> _memberNames = [];
  String _memberName = '';
  bool _isInit = true;

  var organizationFee = OrganizationFee(
    id: '',
    title: '',
    amount: 0,
    startDate: DateTime.now(),
    endDate: DateTime.now(),
    isActive: false,
    organizationId: '',
  );

  @override
  void initState() {
    super.initState();
    if (_isInit) {
      Future.delayed(Duration.zero, () {
        organizationFeeData = ModalRoute.of(
          context,
        )?.settings.arguments as Map<String, dynamic>;
      });
    }
    _isInit = false;
  }

  void _showErrorDialog(title, content, buttonText) async {
    var dialogValue = await showDialog(
      context: context,
      builder: (ctx) => SingleButtonAlert(
        title: title,
        content: content.toString(),
        buttonText: buttonText,
        onPressed: () => Navigator.pop(ctx, true),
      ),
    );
  }

  void _addMember() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _formKey.currentState!.save();

    setState(() {
      _memberNames.add({
        'id': DateTime.now(),
        'name': _memberName,
      });
    });

    Navigator.of(context).pop();
  }

  void removeMember(index) {
    setState(() {
      _memberNames.removeAt(index);
    });
  }

  Future<void> save() async {
    if (_memberNames.isEmpty) {
      var dialogValue = await showDialog(
        context: context,
        builder: (ctx) => SingleButtonAlert(
          title: 'Info',
          content: 'Minimum add 1 member',
          buttonText: 'Okay',
          onPressed: () => Navigator.pop(ctx, true),
        ),
      );
      return;
    }

    final organizationFees = Provider.of<OrganizationFees>(
      context,
      listen: false,
    ).items;

    if (organizationFees.isEmpty) {
      setState(() {
        _isLoading = true;
      });

      organizationFee = OrganizationFee(
        id: organizationFee.id,
        title: organizationFeeData['title'],
        startDate: organizationFeeData['startDate'],
        endDate: organizationFeeData['endDate'],
        amount: organizationFeeData['duesAmount'],
        isActive: true,
        organizationId: organizationFeeData['organizationId'],
        numberOfPaidMembers: 0,
        numberOfMembers: _memberNames.length,
      );
    } else {
      var dialogValue = await showDialog(
        context: context,
        builder: (ctx) => TwoButtonAlert(
          title: 'Info',
          content: 'Do you want to set this dues as active dues?',
          buttonText1: 'Yes',
          buttonText2: 'No',
          onPressed1: () => Navigator.pop(ctx, true),
          onPressed2: () => Navigator.pop(ctx, false),
        ),
      );

      if (dialogValue == null) {
        return;
      } else {
        var isActive = false;

        setState(() {
          _isLoading = true;
        });

        if (dialogValue) {
          try {
            await Provider.of<OrganizationFees>(
              context,
              listen: false,
            ).deactivateCurrentActiveOrganizationFee();
          } catch (e) {
            setState(() {
              _isLoading = false;
            });
            _showErrorDialog('Info', e, 'Okay');
            return;
          }
          isActive = true;
        }

        organizationFee = OrganizationFee(
          id: organizationFee.id,
          title: organizationFeeData['title'],
          startDate: organizationFeeData['startDate'],
          endDate: organizationFeeData['endDate'],
          amount: organizationFeeData['duesAmount'],
          isActive: isActive,
          organizationId: organizationFeeData['organizationId'],
          numberOfPaidMembers: 0,
          numberOfMembers: _memberNames.length,
        );
      }
    }

    var organizationFeeId = '';
    // update organization member
    if (organizationFee.isActive) {
      try {
        await Provider.of<Organizations>(
          context,
          listen: false,
        ).updateTotalOrganizationMember(
          organizationFee.organizationId,
          _memberNames.length,
        );
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog('Info', e, 'Okay');
        return;
      }
    }

    // Add organization fee process
    try {
      organizationFeeId = await Provider.of<OrganizationFees>(
        context,
        listen: false,
      ).createOrganizationFee(organizationFee);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Info', e, 'Okay');
      return;
    }

    // Add member process
    try {
      await Provider.of<Members>(
        context,
        listen: false,
      ).createMembers(
        _memberNames,
        organizationFeeId,
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Info', e, 'Okay');
      return;
    }

    setState(() {
      _isLoading = false;
    });

    int count = 0;
    Navigator.of(context).popUntil((route) => count++ >= 2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: _isLoading
            ? Container()
            : Text(
                'Add Members',
                style: Theme.of(context).appBarTheme.titleTextStyle,
              ),
        leading: _isLoading ? Container() : const BackButton(),
        centerTitle: true,
        foregroundColor: AppColors.primary,
        backgroundColor: AppColors.background,
        actions: _isLoading
            ? []
            : [
                IconButton(
                  icon: const Icon(
                    Icons.group_add,
                    color: AppColors.primary,
                  ),
                  onPressed: () {
                    showModalBottomSheet(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(10),
                        ),
                      ),
                      isScrollControlled: true,
                      context: context,
                      builder: (context) {
                        return AddMemberBottomSheetForm(
                          formKey: _formKey,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Please enter the member name";
                            }

                            return null;
                          },
                          onSavedFn: (value) {
                            _memberName = value!;
                          },
                          addMemberFn: _addMember,
                        );
                      },
                    );
                  },
                ),
                IconButton(
                  onPressed: () {
                    save();
                  },
                  icon: const Icon(
                    Icons.save,
                    color: AppColors.primary,
                  ),
                ),
              ],
      ),
      body: _isLoading
          ? LoadingPage()
          : _memberNames.isEmpty
              ? EmptyData('No members added')
              : ListView.builder(
                  itemBuilder: (context, index) => MemberItem(
                    index,
                    _memberNames[index]['id'].toString(),
                    _memberNames[index]['name'] as String,
                    removeMember,
                  ),
                  itemCount: _memberNames.length,
                ),
    );
  }
}
