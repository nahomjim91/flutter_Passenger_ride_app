import 'package:flutter/material.dart';
import 'package:ride_app/auth_service.dart';
import 'package:ride_app/compont/buttons.dart';
import 'package:ride_app/compont/inputFiled.dart';

class SignUpPage extends StatefulWidget {
  final Function onTap;

  const SignUpPage({Key? key, required this.onTap}) : super(key: key);
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  String? selectedGender;
  bool obscurePassword = true;
  final _firstNamecontroller = TextEditingController();
  final _lastNamecontroller = TextEditingController();
  final _emailcontroller = TextEditingController();
  final _passwordcontroller = TextEditingController();
  final _passwordConfirmcontroller = TextEditingController();
  final _phonecontroller = TextEditingController();
  final _obscureTextNotifier = ValueNotifier<bool>(true);
  bool isLoading = false;
  bool isLoadingSignupWithGoogle = false;

  void toggleLoading() {
    setState(() {
      isLoadingSignupWithGoogle = !isLoadingSignupWithGoogle;
    });
  }

  @override
  void dispose() {
    _obscureTextNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  // App Icon
                const  Icon(
                    Icons.directions_car_rounded,
                    size: 80,
                    color: Color(0xFF0C3B2E),
                  ),
                  const SizedBox(height: 20),
                const  Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0C3B2E),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  // First Name & Last Name
                  Row(
                    children: [
                      Expanded(
                        child: CustomInputFiled(
                            _firstNamecontroller,
                            'First Name',
                            ValueNotifier(false),
                            Icons.person_outline,
                            'name'),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomInputFiled(
                            _lastNamecontroller,
                            'Last Name',
                            ValueNotifier(false),
                            Icons.person_outline,
                            'name'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Email
                  CustomInputFiled(_emailcontroller, 'Email',
                      ValueNotifier(false), Icons.email, 'email'),
                  const SizedBox(height: 16),
                  // Phone
                  CustomInputFiled(
                    _phonecontroller,
                    'Phone',
                    ValueNotifier(false),
                    Icons.phone,
                    'phone',
                  ),
                  const SizedBox(height: 16),
                  // Password
                  CustomInputFiled(_passwordcontroller, 'Password',
                      ValueNotifier(true), Icons.lock, 'password'),
                  const SizedBox(height: 16),
                  // Confirm Password
                  CustomInputFiled(
                      _passwordConfirmcontroller,
                      'Confirm Password',
                      ValueNotifier(true),
                      Icons.lock,
                      'passwordConfirm',
                      password: _passwordcontroller),
                  const SizedBox(height: 16),
                  // Gender
                  // Sign Up Button
                  ButtonsPrimary(
                    isLoading,
                    'Sign up',
                    () {
                      if (_formKey.currentState!.validate()) {
                        AuthService().signUpWithEmail(
                          _emailcontroller.text,
                          _passwordcontroller.text,
                          _firstNamecontroller.text,
                          _lastNamecontroller.text,
                          _phonecontroller.text,
                          () => setState(() {
                            isLoading = !isLoading;
                          }),
                        );
                        debugPrint("_signUpWithEmail");
                      }
                    },
                  ),
                
                  const SizedBox(height: 16),
                  // Google Sign Up Button
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Colors.grey[400],
                          thickness: 1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'OR',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Divider(
                          color: Colors.grey[400],
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ButtonWitGoogle(isLoadingSignupWithGoogle, toggleLoading),
                  const SizedBox(height: 24),
                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigate to login page
                        },
                        child: TextButton(
                          onPressed: () {
                            widget.onTap();
                          },
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              color: Color(0xFF0C3B2E),
                              fontWeight: FontWeight.bold,
                            ),
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
      ),
    );
  }
}
