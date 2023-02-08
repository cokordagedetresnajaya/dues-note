import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/organization_fee.dart';
import '../../providers/organization_fees.dart';
import '../../providers/members.dart';
import '../../providers/organizations.dart';
import '../../providers/transactions.dart';
import '../../configs/colors.dart';
import './create_organization_fee_screen.dart';
import '../../widgets/utils/empty_data.dart';
import '../../widgets/organization_fees/organization_fee_list_item.dart';
import '../../widgets/alerts/single_button_alert.dart';
import '../../widgets/alerts/two_button_alert.dart';
import '../../widgets/utils/loading_page.dart';

class OrganizationFeeListScreen extends StatefulWidget {
  static const routeName = '/dues-list';
  const OrganizationFeeListScreen({Key? key}) : super(key: key);

  @override
  State<OrganizationFeeListScreen> createState() =>
      _OrganizationFeeListScreenState();
}

class _OrganizationFeeListScreenState extends State<OrganizationFeeListScreen> {
  var organizationId = '';
  bool _isInit = true;
  bool _isLoading = false;
  bool _isDeleteMode = false;
  OrganizationFee? _selectedOrganizationFee;

  @override
  void didChangeDependencies() async {
    if (_isInit) {
      organizationId = ModalRoute.of(context)?.settings.arguments as String;
      setState(() {
        _isLoading = true;
      });

      try {
        await Provider.of<OrganizationFees>(
          context,
          listen: false,
        ).fetchAndSetOrganizationFees(organizationId);
      } catch (e) {
        _showErrorDialog(e.toString());
      }

      setState(() {
        _isLoading = false;
      });
    }
    _isInit = false;
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

  bool isDeleteMode() {
    return _isDeleteMode;
  }

  void setDeleteMode(value) {
    setState(() {
      _isDeleteMode = value;
    });
  }

  void setSelectedOrganizationFee(OrganizationFee organizationFee) {
    setState(() {
      _selectedOrganizationFee = organizationFee;
    });
  }

  OrganizationFee? getSelectedOrganizationFee() {
    return _selectedOrganizationFee;
  }

  void clearSelectedOrganizationFee() {
    _selectedOrganizationFee = null;
  }

  Future<void> _onDelete({bool isOnlyOneFee = false}) async {
    var dialogValue = await showDialog(
      context: context,
      builder: (ctx) => TwoButtonAlert(
        title: 'Info',
        content: 'Are you sure you want to delete this dues?',
        buttonText1: 'Yes',
        buttonText2: 'No',
        onPressed1: () => Navigator.pop(ctx, true),
        onPressed2: () => Navigator.pop(ctx, false),
      ),
    );

    if (dialogValue != null) {
      if (dialogValue) {
        setState(() {
          _isLoading = true;
        });

        try {
          print(_selectedOrganizationFee!.id);
          var organizationFeeId = await Provider.of<OrganizationFees>(
            context,
            listen: false,
          ).deleteOrganizationFee(_selectedOrganizationFee!.id);

          print(organizationFeeId);

          await Provider.of<Members>(
            context,
            listen: false,
          ).fetchAndSetMembers(organizationFeeId);

          var transactionId = await Provider.of<Members>(
            context,
            listen: false,
          ).deleteOrganizationFeeMembers(organizationFeeId);

          transactionId.forEach((element) async {
            await Provider.of<Transactions>(
              context,
              listen: false,
            ).deleteTransactions(element);
          });

          if (isOnlyOneFee) {
            await Provider.of<Organizations>(
              context,
              listen: false,
            ).updateTotalOrganizationMember(
              _selectedOrganizationFee!.organizationId,
              0,
            );
          }

          setState(() {
            _isLoading = false;
            _isDeleteMode = false;
          });
        } catch (e) {
          setState(() {
            _isLoading = false;
            _isDeleteMode = false;
          });
          _showErrorDialog(e.toString());
        }
      }
    }
  }

  Future<void> _deleteOrganizationFee() async {
    List<OrganizationFee> organizationFees = Provider.of<OrganizationFees>(
      context,
      listen: false,
    ).items;

    // If organization fees are more than 1
    if (organizationFees.length > 1) {
      if (_selectedOrganizationFee!.isActive) {
        var dialogValue = await showDialog(
          context: context,
          builder: (ctx) => SingleButtonAlert(
            title: 'Info',
            content: 'You can\'t delete this dues',
            buttonText: 'Okay',
            onPressed: () => Navigator.pop(ctx, true),
          ),
        );
      } else {
        _onDelete();
      }
    } else {
      _onDelete(isOnlyOneFee: true);
    }
  }

  Future<void> _refreshData() async {
    await Provider.of<OrganizationFees>(
      context,
      listen: false,
    ).fetchAndSetOrganizationFees(organizationId);
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
                'Dues List',
                style: Theme.of(context).appBarTheme.titleTextStyle,
              ),
        centerTitle: true,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.primary,
        actions: _isLoading
            ? []
            : _isDeleteMode
                ? [
                    IconButton(
                      onPressed: _deleteOrganizationFee,
                      icon: const Icon(
                        Icons.delete,
                      ),
                      color: AppColors.red,
                    ),
                  ]
                : [
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed(
                          CreateOrganizationFeeScreen.routeName,
                          arguments: organizationId,
                        );
                      },
                      icon: const Icon(
                        Icons.playlist_add,
                      ),
                    ),
                  ],
      ),
      body: _isLoading
          ? LoadingPage()
          : RefreshIndicator(
              onRefresh: _refreshData,
              color: AppColors.primary,
              strokeWidth: 2,
              displacement: 20,
              child: Consumer<OrganizationFees>(
                builder: (context, organizationFees, _) =>
                    organizationFees.items.isEmpty
                        ? EmptyData('You don\'t have any dues')
                        : Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 16,
                            ),
                            width: double.infinity,
                            child: ListView.builder(
                              itemBuilder: (context, index) =>
                                  OrganizationFeeListItem(
                                organizationFees.items.reversed.toList()[index],
                                isDeleteMode,
                                setDeleteMode,
                                setSelectedOrganizationFee,
                                clearSelectedOrganizationFee,
                                getSelectedOrganizationFee,
                              ),
                              itemCount: organizationFees.items.length,
                            ),
                          ),
              ),
            ),
    );
  }
}
