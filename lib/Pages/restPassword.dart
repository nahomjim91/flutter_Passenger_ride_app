import 'package:flutter/material.dart';
import 'package:ride_app/Auth/auth_service.dart';
import 'package:ride_app/compont/inputFiled.dart';

// ignore: must_be_immutable
class RestPassword extends StatefulWidget {
  TextEditingController emailController;

  RestPassword({super.key, required this.emailController});

  @override
  State<RestPassword> createState() => _RestPasswordState();
}

class _RestPasswordState extends State<RestPassword> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        leading: BackButton(onPressed: () {
          Navigator.pop(context);
          // Navigator.pop(context);
        }),
      ),
      backgroundColor: Colors.white,
      body: LogoWithTitle(
        title: 'Reset Password',
        subText: "Enter your email address to reset your password.",
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Form(
              key: _formKey,
              child: CustomInputFiled(widget.emailController, 'Email',
                  ValueNotifier(false), Icons.email, 'email'),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                AuthService().resetPassword(widget.emailController.text.trim(),
                    context, (loading) => setState(() => isLoading = loading));
              }
            },
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: const StadiumBorder(),
            ),
            child: isLoading
                ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                : const Text("Next"),
          ),
        ],
      ),
    );
  }
}

class LogoWithTitle extends StatelessWidget {
  final String title, subText;
  final List<Widget> children;

  const LogoWithTitle(
      {super.key,
      required this.title,
      this.subText = '',
      required this.children});
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              SizedBox(height: constraints.maxHeight * 0.1),
              Image.network(
                "https://i.postimg.cc/nz0YBQcH/Logo-light.png",
                height: 100,
              ),
              SizedBox(
                height: constraints.maxHeight * 0.1,
                width: double.infinity,
              ),
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  subText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    height: 1.5,
                    color: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .color!
                        .withOpacity(0.64),
                  ),
                ),
              ),
              ...children,
            ],
          ),
        );
      }),
    );
  }
}
