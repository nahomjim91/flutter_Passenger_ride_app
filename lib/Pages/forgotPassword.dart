import 'package:flutter/material.dart';
import 'package:ride_app/Auth/auth_service.dart';
import 'package:ride_app/compont/buttons.dart';
import 'package:ride_app/compont/inputFiled.dart';

class Forgotpassword extends StatefulWidget {
  const Forgotpassword({Key? key}) : super(key: key);

  @override
  State<Forgotpassword> createState() => _ForgotpasswordState();
}

class _ForgotpasswordState extends State<Forgotpassword> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Forgot Password"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Enter your email address to reset your password.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              CustomInputFiled(_emailController, 'Email', ValueNotifier(false),
                  Icons.email, 'email'),
              const SizedBox(height: 20),
              ButtonsPrimary(
                isLoading,
                'Send Reset Email',
                isLoading
                    ? () {}
                    : () {
                        if (_formKey.currentState!.validate()) {
                          AuthService().resetPassword(
                              isForgotPassword: true,
                              _emailController.text.trim(),
                              context,
                              (loading) => setState(() => isLoading = loading));
                        }
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
