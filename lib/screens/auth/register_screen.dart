import 'dart:io';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:provider/provider.dart';
import '../../widgets/utils/vertical_space_10.dart';
import '../../widgets/utils/vertical_space_20.dart';
import './login_screen.dart';
import '../../providers/auth.dart';
import '../../models/http_exception.dart';
import '../../widgets/alerts/single_button_alert.dart';
import '../../configs/colors.dart';

class RegisterScreen extends StatefulWidget {
  static const routeName = '/register';

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  var _isLoading = false;
  var _isEmailExists = false;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };

  Future<void> _showDialog(String message) async {
    await showDialog(
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
    if (_isEmailExists) {
      setState(() {
        _isEmailExists = false;
      });
    }

    // validate form input
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // trigger on save
    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    var message = 'Something went wrong. Please try again later';
    try {
      await Provider.of<Auth>(
        context,
        listen: false,
      ).register(_authData['email'], _authData['password']);
    } on HttpException catch (error) {
      if (error.message() == 'EMAIL_EXISTS') {
        message = 'The email address is already in use by another account.';

        setState(() {
          _isEmailExists = true;
          _isLoading = false;
        });

        if (!_formKey.currentState!.validate()) {
          return;
        }
      } else if (error.message() == 'OPERATION_NOT_ALLOWED') {
        message = 'Operation not allowed. Please try again later';
        _showDialog(message);
      } else if (error.message() == 'TOO_MANY_ATTEMPTS_TRY_LATER') {
        message =
            'We have blocked all requests from this device due to unusual activity. Try again later.';
        _showDialog(message);
      } else {
        message = error.message();
        _showDialog(message);
      }
    } on SocketException catch (error) {
      message =
          "Something went wrong with your network. Please check your network connection";
      _showDialog(message);
    } catch (error) {
      _showDialog(message);
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
                  height: MediaQuery.of(context).viewPadding.top + 16,
                ),
                Container(
                  child: Image.asset(
                    'assets/images/register_illustration.png',
                    height: screenSize.height * 0.3,
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
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
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
                    // Check email value is empty or not
                    if (value!.isEmpty) {
                      return "Please enter the email address";
                    }

                    // Check if email value already registered
                    if (_isEmailExists) {
                      return "The email address is already in use.";
                    }

                    // Check email value is valid or not
                    if (!EmailValidator.validate(value)) {
                      return 'Email format invalid';
                    }

                    return null;
                  },
                  onSaved: (value) {
                    // Save email value to authData variable
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
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
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
                    // Check password value is empty
                    if (value!.isEmpty) {
                      return "Please enter the password";
                    }

                    // Check password value length less than 6
                    if (value.length < 6) {
                      return "Password must be at least 6 characters long";
                    }

                    if (!value.contains(RegExp(r'[A-Z]'))) {
                      return "Password must contain upper case letter";
                    }

                    if (!value.contains(RegExp(r'[a-z]'))) {
                      return "Password must contain lower case letter";
                    }

                    // Check password value not contain number
                    if (!value.contains(RegExp(r'[0-9]'))) {
                      return "Password must contain a number";
                    }

                    return null;
                  },
                  onSaved: (value) {
                    // Save password value to authData variable
                    _authData['password'] = value!;
                  },
                ),
                const VerticalSpace20(),
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : _submit, // if loading, disabled button and if not, assign function to do register account
                    child:
                        _isLoading // if loading show circular progress indicator and if not show register text
                            ? Container(
                                height: 24,
                                width: 24,
                                child: const CircularProgressIndicator(
                                  color: AppColors.background,
                                ),
                              )
                            : const Text(
                                'Register',
                                style: TextStyle(
                                  color: AppColors.background,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(AppColors.primary),
                      padding: MaterialStateProperty.all(
                        const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                // const VerticalSpace10(),
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
                //           'Continue with Google',
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
                const VerticalSpace20(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have account?',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    InkWell(
                      onTap: () => Navigator.of(
                        context,
                      ).pushReplacementNamed(LoginScreen.routeName),
                      child: const Text(
                        'Sign in',
                        style: TextStyle(
                          color: AppColors.secondaryLight,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
