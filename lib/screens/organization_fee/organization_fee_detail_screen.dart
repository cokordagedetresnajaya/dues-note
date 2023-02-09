import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/member.dart';
import '../../providers/organization_fees.dart';
import '../../providers/members.dart';
import '../../providers/transactions.dart';
import '../../providers/organizations.dart';
import '../../configs/colors.dart';
import './edit_organization_fee_screen.dart';
import '../members/edit_member_screen.dart';
import '../../widgets/utils/vertical_space_20.dart';
import '../../widgets/utils/vertical_space_10.dart';
import '../../widgets/organization_fees/organization_fee_member_item.dart';
import '../../widgets/alerts/single_button_alert.dart';
import '../../widgets/utils/loading_page.dart';

class OrganizationFeeDetailScreen extends StatefulWidget {
  static const routeName = '/dues-detail';
  const OrganizationFeeDetailScreen({Key? key}) : super(key: key);

  @override
  State<OrganizationFeeDetailScreen> createState() =>
      _OrganizationFeeDetailScreenState();
}

class _OrganizationFeeDetailScreenState
    extends State<OrganizationFeeDetailScreen> {
  bool _isInit = true;
  bool _isLoading = false;
  bool _buttonLoading = false;
  bool _organizationFeeStatus = false;
  var organizationFee;
  String id = '';
  List<Member> members = [];

  @override
  void didChangeDependencies() async {
    if (_isInit) {
      // Show loading
      setState(() {
        _isLoading = true;
      });
      // Get current organization fee id
      id = ModalRoute.of(context)?.settings.arguments as String;
      // Get organization fee by ID
      organizationFee = Provider.of<OrganizationFees>(
        context,
        listen: false,
      ).getOrganizationFeeById(id);
      // Get organization fee status
      _organizationFeeStatus = organizationFee.isActive;
      // Set Members and Transactions
      try {
        await Provider.of<Members>(
          context,
          listen: false,
        ).fetchAndSetMembers(id);

        await Provider.of<Transactions>(
          context,
          listen: false,
        ).fetchAndSetTransaction(organizationFee.organizationId);

        setState(() {
          _isLoading = false;
        });
      } catch (e) {
        showErrorDialog(e.toString());
      }
    }
    _isInit = false;
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

  Future<void> activateDues() async {
    setState(() {
      _buttonLoading = true;
    });

    try {
      await Provider.of<OrganizationFees>(
        context,
        listen: false,
      ).deactivateCurrentActiveOrganizationFee();

      await Provider.of<OrganizationFees>(
        context,
        listen: false,
      ).updateOrganizationFeeStatus(
        id,
        true,
      );

      await Provider.of<Organizations>(
        context,
        listen: false,
      ).updateTotalOrganizationMember(
        organizationFee.organizationId,
        organizationFee.numberOfMembers,
      );

      setState(() {
        _buttonLoading = false;
        _organizationFeeStatus = true;
      });
    } catch (e) {
      showErrorDialog(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get current organization fee id
    id = ModalRoute.of(context)?.settings.arguments as String;
    // Get organization fee by ID
    organizationFee = Provider.of<OrganizationFees>(
      context,
    ).getOrganizationFeeById(id);
    // Get organization fee members
    members = Provider.of<Members>(context).items;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: _isLoading ? Container() : const BackButton(),
        title: _isLoading
            ? Container()
            : Text(
                'Dues Detail',
                style: Theme.of(context).appBarTheme.titleTextStyle,
              ),
        centerTitle: true,
        actions: _isLoading
            ? []
            : [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) =>
                            EditOrganizationFeeScreen(),
                        transitionsBuilder: (_, a, __, c) => FadeTransition(
                          opacity: a,
                          child: c,
                        ),
                        settings: RouteSettings(
                          arguments: id,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.edit_note_sharp,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => EditMemberScreen(),
                        transitionsBuilder: (_, a, __, c) => FadeTransition(
                          opacity: a,
                          child: c,
                        ),
                        settings: RouteSettings(
                          arguments: id,
                        ),
                      ),
                    ).then((_) async {
                      try {
                        await Provider.of<Transactions>(
                          context,
                          listen: false,
                        ).fetchAndSetTransaction(
                            organizationFee.organizationId);
                      } catch (e) {
                        showErrorDialog(e.toString());
                      }
                    });
                  },
                  icon: const Icon(
                    Icons.person,
                  ),
                ),
              ],
      ),
      body: _isLoading
          ? LoadingPage()
          : SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: AppColors.primary,
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.gray,
                              blurRadius: 2, // soften the shadow
                              spreadRadius: 0, //extend the shadow
                              offset: Offset(
                                0, // Move to right 10  horizontally
                                3, // Move to bottom 10 Vertically
                              ),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Dues Status',
                              style: TextStyle(
                                color: AppColors.background,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const Text(
                              'Dues status shows currently active dues and the dues will be displayed on the cashflow overview screen',
                              overflow: TextOverflow.clip,
                              style: TextStyle(
                                color: AppColors.background,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.justify,
                            ),
                            const VerticalSpace10(),
                            Container(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                    _organizationFeeStatus
                                        ? AppColors.gray
                                        : AppColors.secondaryLight,
                                  ),
                                  padding: MaterialStateProperty.all(
                                    EdgeInsets.all(
                                      _buttonLoading ? 8 : 16,
                                    ),
                                  ),
                                ),
                                onPressed:
                                    _organizationFeeStatus || _buttonLoading
                                        ? null
                                        : activateDues,
                                child: _buttonLoading
                                    ? Transform.scale(
                                        scale: 0.3,
                                        child: const CircularProgressIndicator(
                                          color: AppColors.background,
                                        ),
                                      )
                                    : const Text(
                                        'Set Active',
                                        style: TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                              ),
                            )
                          ],
                        ),
                      ),
                      const VerticalSpace20(),
                      const Text(
                        'Member List',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const VerticalSpace10(),
                      Container(
                        child: Column(
                          children: members
                              .map(
                                (item) => OrganizationFeeMemberItem(
                                  item,
                                  organizationFee,
                                ),
                              )
                              .toList(),
                        ),
                      )
                    ]),
              ),
            ),
    );
  }
}
