import 'package:dues_note/models/http_exception.dart';
import 'package:dues_note/widgets/alerts/single_button_alert.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:email_validator/email_validator.dart';
import '../../providers/auth.dart';
import '../../configs/colors.dart';
import '../../widgets/inputs/text_field_input.dart';
import '../../widgets/utils/vertical_space_10.dart';
import '../../widgets/utils/vertical_space_20.dart';

class ResetPasswordScreen extends StatefulWidget {
  ResetPasswordScreen({Key? key}) : super(key: key);
  static const routeName = '/reset-password-screen';

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  String email = '';
  bool _isLoading = false;
  bool _isEmailSent = false;
  bool _isEmailNotFound = false;

  Future<void> _sendResetPasswordEmail() async {
    setState(() {
      _isEmailNotFound = false;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    _formKey.currentState!.save();

    try {
      await Provider.of<Auth>(context, listen: false).resetPassword(email);
      setState(() {
        _isLoading = false;
        _isEmailSent = true;
      });
    } on HttpException catch (error) {
      if (error.message() == 'EMAIL_NOT_FOUND') {
        _isEmailNotFound = true;
        _formKey.currentState!.validate();
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      showDialog(
        context: context,
        builder: (ctx) => SingleButtonAlert(
          title: 'Warning',
          content: e.toString(),
          buttonText: 'Okay',
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resendEmail() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<Auth>(context, listen: false).resetPassword(email);
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      showDialog(
        context: context,
        builder: (ctx) => SingleButtonAlert(
          title: 'Warning',
          content: e.toString(),
          buttonText: 'Okay',
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Widget> _buildLoading() {
    return [
      Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color.fromRGBO(0, 0, 0, 0.3),
      ),
      Container(
        width: 60,
        height: 60,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const SizedBox(
          height: 2,
          width: 2,
          child: CircularProgressIndicator(
            backgroundColor: AppColors.background,
            color: AppColors.primary,
            strokeWidth: 2,
          ),
        ),
      )
    ];
  }

  Widget _buildForgotPasswordForm() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 0,
        horizontal: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/forgot_password_illustration.png',
            ),
            const Text(
              "Enter your email we'll send you a link to change your password",
              textAlign: TextAlign.center,
            ),
            const VerticalSpace20(),
            TextFieldInput(
              hintText: 'Email address',
              onValidate: (value) {
                if (value!.isEmpty) {
                  return "Please enter the email address";
                }

                if (_isEmailNotFound) {
                  return 'Email address not registered yet';
                }

                if (!EmailValidator.validate(value)) {
                  return 'Email format invalid';
                }

                return null;
              },
              onSaved: (value) {
                email = value!;
              },
            ),
            const VerticalSpace10(),
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _sendResetPasswordEmail,
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
                child: const Text(
                  'Reset Password',
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildEmailSentWidget() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 0,
        horizontal: 16,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/message_sent_illustration.png',
          ),
          Text(
            "Reset password link has been sent to $email.",
            textAlign: TextAlign.center,
          ),
          const VerticalSpace20(),
          const Text(
            "Not receive any email?",
            textAlign: TextAlign.center,
          ),
          const VerticalSpace10(),
          Container(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _resendEmail,
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
              child: const Text(
                'Resend Email',
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.background,
      body: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          if (_isEmailSent) _buildEmailSentWidget(),
          if (!_isEmailSent) _buildForgotPasswordForm(),
          if (_isLoading) ..._buildLoading()
        ],
      ),
    );
  }
}
