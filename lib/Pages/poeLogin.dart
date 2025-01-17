import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ride_app/compont/buttons.dart';
import 'package:ride_app/compont/inputFiled.dart';
import 'package:ride_app/Pages/forgotPassword.dart';

class LoginPage extends StatefulWidget {
  final Function onTap;
  const LoginPage({super.key, required this.onTap});
  @override
  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool obscurePassword = true;
  bool isLoading = false;
  bool isLoadingSignupWithGoogle = false;
  // ignore: unused_field
  final _obscureTextNotifier = ValueNotifier<bool>(true);

  void toggleLoading() {
    setState(() {
      isLoadingSignupWithGoogle = !isLoadingSignupWithGoogle;
    });
  }

  // Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Firebase Auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Email Sign In Method
  Future<void> _signInWithEmail() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        final UserCredential userCredential =
            await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        // Handle successful login
        if (userCredential.user != null) {
          // Navigate to home page or dashboard
          debugPrint("Successfully logged in");
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage = 'An error occurred';

        if (e.code == 'user-not-found') {
          errorMessage = 'No user found for that email.';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Wrong password provided.';
        }
        // ignore: prefer_interpolation_to_compose_strings
        debugPrint("Error: " + e.code);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }


  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
                  const SizedBox(height: 40),
                  // App Icon
                 const Icon(
                    Icons.directions_car_rounded,
                    size: 80,
                    color: Color(0xFF0C3B2E),
                  ),
                  const SizedBox(height: 20),
                 const Text(
                    'Welcome Back!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0C3B2E),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Sign in to continue',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  // Email Field
                  CustomInputFiled(_emailController, 'Email',
                      ValueNotifier(false), Icons.email, 'email'),
                  const SizedBox(height: 16),
                  // Password Field
                  CustomInputFiled(_passwordController, 'Password',
                      ValueNotifier(true), Icons.lock, 'password'),
                  const SizedBox(height: 12),
                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // Navigate to forgot password page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>const Forgotpassword(),
                          ),
                        );
                      },
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Color(0xFF0C3B2E),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Login Button
                  ButtonsPrimary(isLoading, "Login", _signInWithEmail),

                  const SizedBox(height: 16),
                  // Google Login Button
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

                  // Sign Up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Don\'t have an account? ',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      TextButton(
                        onPressed: () {
                          widget.onTap();
                        },
                        child: const Text(
                          'Sign Up',
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
