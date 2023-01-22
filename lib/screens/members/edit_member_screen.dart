import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../configs/colors.dart';
import '../../models/member.dart';
import '../../models/organization_fee.dart';
import '../../providers/members.dart';
import '../../providers/organization_fees.dart';
import '../../providers/organizations.dart';
import '../../widgets/members/member_item.dart';
import '../../widgets/utils/vertical_space_10.dart';
import '../../widgets/utils/vertical_space_20.dart';
import '../../widgets/utils/empty_data.dart';
import '../../widgets/alerts/single_button_alert.dart';
import '../../widgets/utils/loading_page.dart';

class EditMemberScreen extends StatefulWidget {
  static const routeName = '/edit-member';

  @override
  State<EditMemberScreen> createState() => _EditMemberScreenState();
}

class _EditMemberScreenState extends State<EditMemberScreen> {
  var _isLoading = false;
  List<Map<String, dynamic>> _newMembers = [];
  List<Map<String, dynamic>> _deletedMembers = [];
  List<Member> _members = [];
  final _formKey = GlobalKey<FormState>();
  String _memberName = '';
  List<Map<String, dynamic>> _memberNames = [];
  String organizationFeeId = '';
  OrganizationFee organizationFee = OrganizationFee(
    id: '',
    title: '',
    isActive: true,
    amount: 0,
    startDate: DateTime.now(),
    endDate: DateTime.now(),
    organizationId: '',
  );

  @override
  void didChangeDependencies() {
    organizationFeeId = ModalRoute.of(context)?.settings.arguments as String;
    organizationFee = Provider.of<OrganizationFees>(
      context,
      listen: false,
    ).getOrganizationFeeById(organizationFeeId);
    _members = Provider.of<Members>(context, listen: false).items;
    _members.forEach((element) {
      _memberNames.add({
        'id': element.id,
        'name': element.name,
      });
    });
    super.didChangeDependencies();
  }

  void removeMember(index) {
    _deletedMembers.add(_memberNames[index]);
    setState(() {
      _memberNames.removeAt(index);
    });
  }

  void addMember() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _formKey.currentState!.save();

    setState(() {
      _memberNames.add({
        'id': DateTime.now().toString(),
        'name': _memberName,
      });
    });
    Navigator.of(context).pop();
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

  void save() async {
    if (_memberNames.isEmpty) {
      _showErrorDialog('Info', 'Minimum add 1 member', 'Okay');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<Members>(context, listen: false).updateMembers(
        _memberNames,
        organizationFeeId,
        _deletedMembers,
      );

      final countPaidMembers = Provider.of<Members>(
        context,
        listen: false,
      ).getCountPaidMembers(organizationFee.amount);

      await Provider.of<OrganizationFees>(context, listen: false)
          .updateOrganizationFeeMember(
        organizationFeeId,
        _memberNames.length,
        countPaidMembers,
      );

      if (organizationFee.isActive) {
        await Provider.of<Organizations>(
          context,
          listen: false,
        ).updateTotalOrganizationMember(
          organizationFee.organizationId,
          _memberNames.length,
        );
      }
      Navigator.of(context).pop();
    } catch (e) {
      _showErrorDialog('Info', e.toString(), 'Okay');
    }
  }

  Widget _buildBottomSheetForm() {
    return Form(
      key: _formKey,
      child: FractionallySizedBox(
        heightFactor: 0.4,
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
                'Member Name',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const VerticalSpace10(),
              TextFormField(
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(16),
                  hintText: 'Enter member name',
                  hintStyle: Theme.of(context).textTheme.labelSmall,
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(
                      color: AppColors.gray,
                      style: BorderStyle.solid,
                      width: 0.5,
                    ),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(
                      color: AppColors.gray,
                      style: BorderStyle.solid,
                      width: 0.5,
                    ),
                  ),
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.gray,
                      style: BorderStyle.solid,
                      width: 1,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please enter the member name";
                  }

                  return null;
                },
                onSaved: (value) {
                  _memberName = value!;
                },
              ),
              const VerticalSpace20(),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(bottom: 16),
                child: ElevatedButton(
                  child: const Text(
                    'ADD MEMBER',
                    style: TextStyle(
                      color: AppColors.background,
                    ),
                  ),
                  onPressed: addMember,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        centerTitle: true,
        foregroundColor: AppColors.primary,
        leading: _isLoading ? Container() : const BackButton(),
        title: _isLoading
            ? Container()
            : Text(
                'Edit Member',
                style: Theme.of(context).appBarTheme.titleTextStyle,
              ),
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
                        return _buildBottomSheetForm();
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
                    _memberNames[index]['id'],
                    _memberNames[index]['name'],
                    removeMember,
                  ),
                  itemCount: _memberNames.length,
                ),
    );
  }
}
