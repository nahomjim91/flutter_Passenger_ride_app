import 'package:flutter/material.dart';
import 'package:ride_app/Auth/auth_service.dart';
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
  bool _mounted = true;

  void toggleLoading() {
    if (_mounted) {
      setState(() {
        isLoadingSignupWithGoogle = !isLoadingSignupWithGoogle;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _mounted = true;
  }

  @override
  void dispose() {
    _mounted = false;
    _obscureTextNotifier.dispose();
    _firstNamecontroller.dispose();
    _lastNamecontroller.dispose();
    _emailcontroller.dispose();
    _passwordcontroller.dispose();
    _passwordConfirmcontroller.dispose();
    _phonecontroller.dispose();
    super.dispose();
  }

  void _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      if (_mounted) {
        setState(() {
          isLoading = true;
        });
      }

      try {
        await AuthService().signUpWithEmailLaravel(
          _emailcontroller.text,
          _passwordcontroller.text,
          _firstNamecontroller.text,
          _lastNamecontroller.text,
          _phonecontroller.text,
          () {
            if (_mounted) {
              setState(() {
                isLoading = !isLoading;
              });
            }
          },
        );
        debugPrint("_signUpWithEmail");
      } catch (e) {
        // Handle any errors here
        if (_mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    }
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
                  const Icon(
                    Icons.directions_car_rounded,
                    size: 80,
                    color: Color(0xFF0C3B2E),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0C3B2E),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
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
                  CustomInputFiled(_emailcontroller, 'Email',
                      ValueNotifier(false), Icons.email, 'email'),
                  const SizedBox(height: 16),
                  CustomInputFiled(
                    _phonecontroller,
                    'Phone',
                    ValueNotifier(false),
                    Icons.phone,
                    'phone',
                  ),
                  const SizedBox(height: 16),
                  CustomInputFiled(_passwordcontroller, 'Password',
                      ValueNotifier(true), Icons.lock, 'password'),
                  const SizedBox(height: 16),
                  CustomInputFiled(
                      _passwordConfirmcontroller,
                      'Confirm Password',
                      ValueNotifier(true),
                      Icons.lock,
                      'passwordConfirm',
                      password: _passwordcontroller),
                  const SizedBox(height: 16),
                  ButtonsPrimary(
                    isLoading,
                    'Sign up',
                    _handleSignUp,
                  ),
                  const SizedBox(height: 16),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      TextButton(
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
