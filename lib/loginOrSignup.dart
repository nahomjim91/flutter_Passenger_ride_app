import 'package:flutter/material.dart';
import 'package:ride_app/Pages/Login.dart';
import 'package:ride_app/Pages/Signup.dart';

class LoginOrSignup extends StatefulWidget {
  const LoginOrSignup({super.key});

  @override
  State<LoginOrSignup> createState() => _LoginOrSignupState();
}

class _LoginOrSignupState extends State<LoginOrSignup> {
  bool showLoginPage = false;

  void toggleView() {
    setState(() => showLoginPage = !showLoginPage);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: showLoginPage ? LoginPage(onTap:  toggleView) : SignUpPage(onTap:  toggleView),
    );
  }
}