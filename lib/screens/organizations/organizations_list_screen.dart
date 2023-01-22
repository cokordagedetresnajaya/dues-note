import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../configs/colors.dart';
import '../../providers/organizations.dart';
import '../../providers/auth.dart';
import '../../models/organization.dart';
import './create_organization_screen.dart';
import '../../widgets/organizations/organization_item.dart';
import '../../widgets/utils/empty_data.dart';
import '../../widgets/utils/search_not_found.dart';
import '../../widgets/alerts/single_button_alert.dart';
import '../../widgets/alerts/two_button_alert.dart';
import '../../widgets/utils/loading_page.dart';

class OrganizationsListScreen extends StatefulWidget {
  static const routeName = '/organization-list';

  @override
  State<OrganizationsListScreen> createState() =>
      _OrganizationsListScreenState();
}

class _OrganizationsListScreenState extends State<OrganizationsListScreen> {
  var _isInit = false;
  var _isLoading = false;
  var _isSearching = false;
  List<Organization> _searchResult = [];
  List<Organization> _userOrganizations = [];

  @override
  void didChangeDependencies() {
    if (!_isInit) {
      // show loading
      setState(() {
        _isLoading = true;
      });

      Provider.of<Organizations>(context)
          .fetchAndSetOrganization()
          .catchError((error) {
        showDialog(
          context: context,
          builder: (ctx) => SingleButtonAlert(
            title: 'An error occured',
            content: 'Something went wrong!',
            buttonText: 'Okay',
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        );
      }).then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = true;
    super.didChangeDependencies();
  }

  void searchOrganizations(String keyword) {
    setState(() {
      _searchResult.clear();
    });

    if (_isSearching) {
      for (int i = 0; i < _userOrganizations.length; i++) {
        if (_userOrganizations[i]
            .name
            .toLowerCase()
            .contains(keyword.toLowerCase())) {
          setState(() {
            _searchResult.add(_userOrganizations[i]);
          });
        }
      }
    }
  }

  void resetScreen() {
    setState(() {
      _isSearching = false;
      _searchResult = _userOrganizations;
    });
  }

  @override
  Widget build(BuildContext context) {
    _userOrganizations = Provider.of<Organizations>(context).items;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: _isLoading
            ? Container()
            : _isSearching
                ? BackButton(
                    onPressed: () {
                      _searchResult = _userOrganizations;
                      setState(() {
                        _isSearching = false;
                      });
                    },
                    color: AppColors.primary,
                  )
                : Container(),
        title: _isLoading
            ? Container()
            : _isSearching
                ? TextField(
                    autofocus: true,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Search your organizations',
                      hintStyle: Theme.of(context).textTheme.labelMedium,
                      border: InputBorder.none,
                    ),
                    style: Theme.of(context).textTheme.labelMedium,
                    onChanged: searchOrganizations,
                  )
                : Text(
                    'Your Organizations',
                    style: Theme.of(context).appBarTheme.titleTextStyle,
                  ),
        centerTitle: true,
        actions: _isLoading
            ? []
            : _isSearching
                ? []
                : [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _isSearching = true;
                          _searchResult = _userOrganizations;
                        });
                      },
                      icon: const Icon(Icons.search),
                      color: AppColors.primary,
                    ),
                    PopupMenuButton(
                      icon: const Icon(Icons.more_vert),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: Text(
                            'Logout',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 16,
                          ),
                          value: 0,
                        ),
                      ],
                      onSelected: (result) async {
                        if (result == 0) {
                          var selectedValue = await showDialog(
                            context: context,
                            builder: (ctx) => TwoButtonAlert(
                              title: 'Warning',
                              content: 'Are you sure you want to log out?',
                              buttonText1: 'Yes',
                              buttonText2: 'No',
                              onPressed1: () {
                                Navigator.pop(ctx, true);
                              },
                              onPressed2: () {
                                Navigator.pop(ctx, false);
                              },
                            ),
                          );

                          if (selectedValue == true) {
                            setState(() {
                              _isLoading = true;
                            });
                            await Provider.of<Auth>(
                              context,
                              listen: false,
                            ).logout();
                          }
                        }
                      },
                    )
                  ],
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: _isLoading
          ? LoadingPage()
          : _userOrganizations.isEmpty
              ? EmptyData('You don\'t have any organization yet')
              : _isSearching
                  ? (_searchResult.length <= 0
                      ? SearchNotFound('Organization not found')
                      : ListView.builder(
                          itemCount: _searchResult.length,
                          itemBuilder: (ctx, i) {
                            return OrganizationItem(
                                _searchResult[i].id,
                                _searchResult[i].name,
                                _searchResult[i].category,
                                _searchResult[i].numberOfMembers,
                                resetScreen);
                          },
                        ))
                  : ListView.builder(
                      itemCount: _userOrganizations.length,
                      itemBuilder: (ctx, i) {
                        return OrganizationItem(
                          _userOrganizations[i].id,
                          _userOrganizations[i].name,
                          _userOrganizations[i].category,
                          _userOrganizations[i].numberOfMembers,
                          resetScreen,
                        );
                      },
                    ),
      floatingActionButton: _isLoading
          ? null
          : FloatingActionButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamed(CreateOrganizationScreen.routeName)
                    .then(
                      (value) => resetScreen(),
                    );
              },
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
