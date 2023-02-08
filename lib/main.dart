import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './screens/organizations/organizations_list_screen.dart';
import './providers/organization_categories.dart';
import './providers/organizations.dart';
import './providers/auth.dart';
import './providers/transactions.dart';
import './providers/organization_fees.dart';
import './providers/members.dart';
import './screens/organizations/create_organization_screen.dart';
import './screens/cashflow_overview_screen.dart';
import './screens/transactions/transaction_list_screen.dart';
import './screens/auth/login_screen.dart';
import './screens/auth/register_screen.dart';
import './screens/splash_screen.dart';
import './screens/transactions/create_transaction_screen.dart';
import './screens/transactions/transaction_detail_screen.dart';
import './screens/transactions/edit_transaction_screen.dart';
import './screens/organization_fee/organization_fee_list_screen.dart';
import './screens/organization_fee/create_organization_fee_screen.dart';
import './screens/members/add_member_screen.dart';
import './screens/organization_fee/organization_fee_detail_screen.dart';
import './screens/organization_fee/edit_organization_fee_screen.dart';
import './screens/members/edit_member_screen.dart';
import './screens/organizations/edit_organization_screen.dart';
import './screens/auth/reset_password_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Organizations>(
          create: (ctx) => Organizations('', '', []),
          update: (ctx, auth, previousOrganizations) => Organizations(
            auth.token,
            auth.userId,
            previousOrganizations!.items == null
                ? []
                : previousOrganizations.items,
          ),
        ),
        ChangeNotifierProxyProvider<Auth, Transactions>(
          create: (ctx) => Transactions('', []),
          update: (ctx, auth, previousTransactions) => Transactions(
            auth.token,
            previousTransactions!.items == null
                ? []
                : previousTransactions.items,
          ),
        ),
        ChangeNotifierProxyProvider<Auth, OrganizationFees>(
          create: (ctx) => OrganizationFees('', []),
          update: (ctx, auth, previousDues) => OrganizationFees(
            auth.token,
            previousDues!.items == null ? [] : previousDues.items,
          ),
        ),
        ChangeNotifierProxyProvider<Auth, Members>(
          create: (ctx) => Members('', []),
          update: (ctx, auth, previousMembers) => Members(
            auth.token,
            previousMembers!.items == null ? [] : previousMembers.items,
          ),
        ),
        ChangeNotifierProvider(
          create: (ctx) => OrganizationCategories(),
        )
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) {
          var isAuth = auth.isAuth;
          return MaterialApp(
            key: Key('auth_${auth.isAuth}'),
            debugShowCheckedModeBanner: false,
            title: 'Dues Note',
            theme: ThemeData(
              primaryColor: const Color.fromRGBO(34, 40, 49, 1),
              primaryColorLight: const Color.fromRGBO(252, 192, 48, 1),
              primaryColorDark: const Color.fromRGBO(254, 135, 48, 1),
              backgroundColor: Colors.white,
              fontFamily: 'Poppins',
              textTheme: const TextTheme(
                titleMedium: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                labelMedium: TextStyle(
                  fontSize: 16,
                ),
                labelSmall: TextStyle(
                  color: Color.fromRGBO(181, 181, 181, 1),
                  fontSize: 14,
                ),
                headlineSmall: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.transparent,
                centerTitle: true,
                foregroundColor: Color.fromRGBO(34, 40, 49, 1),
                elevation: 0,
                titleTextStyle: TextStyle(
                  color: Color.fromRGBO(34, 40, 49, 1),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            home: isAuth
                ? OrganizationsListScreen()
                : FutureBuilder(
                    future: auth.tryAutoLogin(),
                    builder: (ctx, authResultSnapshot) =>
                        authResultSnapshot.connectionState ==
                                ConnectionState.waiting
                            ? SplashScreen()
                            : LoginScreen(),
                  ),
            routes: {
              OrganizationsListScreen.routeName: (ctx) =>
                  OrganizationsListScreen(),
              CreateOrganizationScreen.routeName: (ctx) =>
                  CreateOrganizationScreen(),
              CashFlowOverviewScreen.routeName: (ctx) =>
                  CashFlowOverviewScreen(),
              TransactionListScreen.routeName: (ctx) => TransactionListScreen(),
              RegisterScreen.routeName: (ctx) => RegisterScreen(),
              LoginScreen.routeName: (ctx) => LoginScreen(),
              CreateTransactionScreen.routeName: (ctx) =>
                  CreateTransactionScreen(),
              TransactionDetailScreen.routeName: (ctx) =>
                  TransactionDetailScreen(),
              EditTransactionScreen.routeName: (ctx) => EditTransactionScreen(),
              OrganizationFeeListScreen.routeName: (ctx) =>
                  OrganizationFeeListScreen(),
              CreateOrganizationFeeScreen.routeName: (ctx) =>
                  CreateOrganizationFeeScreen(),
              AddMemberScreen.routeName: (ctx) => AddMemberScreen(),
              OrganizationFeeDetailScreen.routeName: (ctx) =>
                  OrganizationFeeDetailScreen(),
              EditOrganizationFeeScreen.routeName: (ctx) =>
                  EditOrganizationFeeScreen(),
              EditMemberScreen.routeName: (ctx) => EditMemberScreen(),
              EditOrganizationScreen.routeName: (ctx) =>
                  EditOrganizationScreen(),
              ResetPasswordScreen.routeName: (ctx) => ResetPasswordScreen(),
            },
            onGenerateRoute: (settings) {
              print(settings.name);
              if (settings.name == '/organization-list') {
                return PageRouteBuilder(
                  settings: settings,
                  pageBuilder: (_, __, ___) => OrganizationsListScreen(),
                  transitionsBuilder: (_, a, __, c) => FadeTransition(
                    opacity: a,
                    child: c,
                  ),
                );
              }

              if (settings.name == '/create-organization') {
                return PageRouteBuilder(
                  settings: settings,
                  pageBuilder: (_, __, ___) => CreateOrganizationScreen(),
                  transitionsBuilder: (_, a, __, c) => FadeTransition(
                    opacity: a,
                    child: c,
                  ),
                );
              }

              if (settings.name == '/cashflow-overview') {
                return PageRouteBuilder(
                  settings: settings,
                  pageBuilder: (_, __, ___) => CashFlowOverviewScreen(),
                  transitionsBuilder: (_, a, __, c) => FadeTransition(
                    opacity: a,
                    child: c,
                  ),
                );
              }

              if (settings.name == '/transaction-list') {
                return PageRouteBuilder(
                  settings: settings,
                  pageBuilder: (_, __, ___) => TransactionListScreen(),
                  transitionsBuilder: (_, a, __, c) => FadeTransition(
                    opacity: a,
                    child: c,
                  ),
                );
              }

              if (settings.name == '/register') {
                return PageRouteBuilder(
                  settings: settings,
                  pageBuilder: (_, __, ___) => RegisterScreen(),
                  transitionsBuilder: (_, a, __, c) => FadeTransition(
                    opacity: a,
                    child: c,
                  ),
                );
              }

              if (settings.name == '/login') {
                return PageRouteBuilder(
                  settings: settings,
                  pageBuilder: (_, __, ___) => LoginScreen(),
                  transitionsBuilder: (_, a, __, c) => FadeTransition(
                    opacity: a,
                    child: c,
                  ),
                );
              }

              if (settings.name == '/create-transaction') {
                return PageRouteBuilder(
                  settings: settings,
                  pageBuilder: (_, __, ___) => CreateTransactionScreen(),
                  transitionsBuilder: (_, a, __, c) => FadeTransition(
                    opacity: a,
                    child: c,
                  ),
                );
              }

              if (settings.name == '/transaction-detail') {
                return PageRouteBuilder(
                  settings: settings,
                  pageBuilder: (_, __, ___) => TransactionDetailScreen(),
                  transitionsBuilder: (_, a, __, c) => FadeTransition(
                    opacity: a,
                    child: c,
                  ),
                );
              }

              if (settings.name == '/edit-transaction') {
                return PageRouteBuilder(
                  settings: settings,
                  pageBuilder: (_, __, ___) => EditTransactionScreen(),
                  transitionsBuilder: (_, a, __, c) => FadeTransition(
                    opacity: a,
                    child: c,
                  ),
                );
              }

              if (settings.name == '/dues-list') {
                return PageRouteBuilder(
                  settings: settings,
                  pageBuilder: (_, __, ___) => OrganizationFeeListScreen(),
                  transitionsBuilder: (_, a, __, c) => FadeTransition(
                    opacity: a,
                    child: c,
                  ),
                );
              }

              if (settings.name == '/create-dues') {
                return PageRouteBuilder(
                  settings: settings,
                  pageBuilder: (_, __, ___) => CreateOrganizationFeeScreen(),
                  transitionsBuilder: (_, a, __, c) => FadeTransition(
                    opacity: a,
                    child: c,
                  ),
                );
              }

              if (settings.name == '/add-members') {
                return PageRouteBuilder(
                  settings: settings,
                  pageBuilder: (_, __, ___) => AddMemberScreen(),
                  transitionsBuilder: (_, a, __, c) => FadeTransition(
                    opacity: a,
                    child: c,
                  ),
                );
              }

              if (settings.name == '/dues-detail') {
                return PageRouteBuilder(
                  settings: settings,
                  pageBuilder: (_, __, ___) => OrganizationFeeDetailScreen(),
                  transitionsBuilder: (_, a, __, c) => FadeTransition(
                    opacity: a,
                    child: c,
                  ),
                );
              }

              if (settings.name == '/edit-dues') {
                return PageRouteBuilder(
                  settings: settings,
                  pageBuilder: (_, __, ___) => EditOrganizationFeeScreen(),
                  transitionsBuilder: (_, a, __, c) => FadeTransition(
                    opacity: a,
                    child: c,
                  ),
                );
              }

              if (settings.name == '/edit-member') {
                return PageRouteBuilder(
                  settings: settings,
                  pageBuilder: (_, __, ___) => EditMemberScreen(),
                  transitionsBuilder: (_, a, __, c) => FadeTransition(
                    opacity: a,
                    child: c,
                  ),
                );
              }

              if (settings.name == '/edit-organization') {
                return PageRouteBuilder(
                  settings: settings,
                  pageBuilder: (_, __, ___) => EditOrganizationScreen(),
                  transitionsBuilder: (_, a, __, c) => FadeTransition(
                    opacity: a,
                    child: c,
                  ),
                );
              }

              if (settings.name == '/reset-password-screen') {
                return PageRouteBuilder(
                  settings: settings,
                  pageBuilder: (_, __, ___) => ResetPasswordScreen(),
                  transitionsBuilder: (_, a, __, c) => FadeTransition(
                    opacity: a,
                    child: c,
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}
