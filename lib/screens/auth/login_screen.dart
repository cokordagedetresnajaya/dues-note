import 'dart:io';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:provider/provider.dart';
import '../../providers/auth.dart';
import '../../models/http_exception.dart';
import './register_screen.dart';
import '../../widgets/utils/vertical_space_20.dart';
import '../../widgets/utils/vertical_space_10.dart';
import '../../widgets/alerts/single_button_alert.dart';
import '../../configs/colors.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  var _isLoading = false;
  var _isEmailRegistered = true;
  var _isPasswordValid = true;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };

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

  Future<void> _submit() async {
    setState(() {
      _isEmailRegistered = true;
      _isPasswordValid = true;
    });
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });

    var errorMessage = 'Something went wrong. Please try again later.';

    try {
      await Provider.of<Auth>(context, listen: false)
          .login(_authData['email'], _authData['password']);
    } on HttpException catch (error) {
      if (error.message() == 'EMAIL_NOT_FOUND') {
        setState(() {
          _isEmailRegistered = false;
        });
        _formKey.currentState!.validate();
      } else if (error.message() == 'INVALID_PASSWORD') {
        setState(() {
          _isPasswordValid = false;
        });
        _formKey.currentState!.validate();
      } else if (error.message() == 'USER_DISABLED') {
        errorMessage =
            'The user account has been disabled by an administrator.';
        _showErrorDialog(errorMessage);
      } else if (error.message().contains('TOO_MANY_ATTEMPTS_TRY_LATER')) {
        errorMessage =
            'Access to this account has been temporarily disabled due to many failed login attempts. You can try again later.';
        _showErrorDialog(errorMessage);
      } else {
        _showErrorDialog(errorMessage);
      }
    } on SocketException catch (error) {
      errorMessage =
          'Something went wrong with your network. Please check your network connection';
      _showErrorDialog(errorMessage);
    } catch (e) {
      _showErrorDialog(errorMessage);
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 0,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).viewPadding.top,
                ),
                Container(
                  child: Image.asset(
                    'assets/images/login_illustration.png',
                    height: screenSize.height * 0.35,
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Email',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.left,
                  ),
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
                    hintText: 'Enter your email address',
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
                      return "Please enter the email address";
                    }

                    if (!_isEmailRegistered) {
                      return "This email has not been registered.";
                    }

                    if (!EmailValidator.validate(value)) {
                      return 'Email format invalid';
                    }

                    return null;
                  },
                  onSaved: (value) {
                    _authData['email'] = value!;
                  },
                ),
                const VerticalSpace10(),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Password',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.left,
                  ),
                ),
                const VerticalSpace10(),
                TextFormField(
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                  obscureText: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(16),
                    hintText: 'Enter your password',
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
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
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
                      return "Please enter the password";
                    }

                    if (!_isPasswordValid) {
                      return "The password is invalid";
                    }

                    return null;
                  },
                  onSaved: (value) {
                    _authData['password'] = value!;
                  },
                ),
                const VerticalSpace10(),
                // const Align(
                //   alignment: Alignment.centerRight,
                //   child: Text(
                //     'Forget password?',
                //     style: TextStyle(
                //         color: Color.fromRGBO(
                //           254,
                //           192,
                //           48,
                //           1,
                //         ),
                //         fontSize: 14),
                //     textAlign: TextAlign.left,
                //   ),
                // ),
                const VerticalSpace10(),
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? Container(
                            width: 24,
                            height: 24,
                            child: const CircularProgressIndicator(
                              color: AppColors.background,
                            ),
                          )
                        : const Text(
                            'Login',
                            style: TextStyle(
                              color: AppColors.background,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        AppColors.primary,
                      ),
                      padding: MaterialStateProperty.all(
                        const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                const VerticalSpace10(),
                // const Text(
                //   'OR',
                //   style: TextStyle(
                //     color: Color.fromRGBO(
                //       181,
                //       181,
                //       181,
                //       1,
                //     ),
                //   ),
                // ),
                // const VerticalSpace10(),
                // Container(
                //   width: double.infinity,
                //   child: ElevatedButton(
                //     onPressed: _isLoading
                //         ? null
                //         : () {
                //             print('Login');
                //           },
                //     child: Row(
                //       mainAxisAlignment: MainAxisAlignment.center,
                //       crossAxisAlignment: CrossAxisAlignment.center,
                //       children: [
                //         Container(
                //           width: 24,
                //           height: 24,
                //           margin: const EdgeInsets.only(
                //             right: 16,
                //           ),
                //           child: Image.asset(
                //             'assets/images/google_logo.png',
                //           ),
                //         ),
                //         Text(
                //           'Login with Google',
                //           style:
                //               TextStyle(color: Theme.of(context).primaryColor),
                //         )
                //       ],
                //     ),
                //     style: ButtonStyle(
                //       backgroundColor: MaterialStateProperty.all(
                //         const Color.fromRGBO(
                //           238,
                //           238,
                //           238,
                //           1,
                //         ),
                //       ),
                //       padding: MaterialStateProperty.all(
                //         const EdgeInsets.symmetric(
                //           horizontal: 32,
                //           vertical: 16,
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
                // const VerticalSpace20(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Don\'t have an account?',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.of(
                          context,
                        ).pushReplacementNamed(RegisterScreen.routeName);
                      },
                      child: const Text(
                        'Sign up',
                        style: TextStyle(
                          color: AppColors.secondaryLight,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const VerticalSpace20(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
