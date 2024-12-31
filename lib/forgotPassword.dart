import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

  Future<void> _resetPassword(String email) async {
    try {
      setState(() => isLoading = true);
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      setState(() => isLoading = false);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password reset email sent!")),
      );
    } on FirebaseAuthException catch (e) {
      setState(() => isLoading = false);
      String message = "An error occurred";
      if (e.code == 'user-not-found') {
        message = "No user found with this email";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An unexpected error occurred")),
      );
    }
  }

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
                          _resetPassword(_emailController.text.trim());
                        }
                      },
              ),
              // ElevatedButton(
              //   onPressed: isLoading
              //       ? null
              //       : () {
              //           if (_formKey.currentState!.validate()) {
              //             _resetPassword(_emailController.text.trim());
              //           }
              //         },
              //   style: ElevatedButton.styleFrom(
              //     padding: const EdgeInsets.symmetric(vertical: 16),
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(12),
              //     ),
              //   ),
              //   child: isLoading
              //       ? const CircularProgressIndicator(
              //           color: Color(0xff0C3B2E),
              //           strokeWidth: 2,
              //         )
              //       : const Text("Send Reset Email"),
              // ),
              
            ],
          ),
        ),
      ),
    );
  }
}
