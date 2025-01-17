import 'package:flutter/material.dart';
import 'package:ride_app/Auth/auth_service.dart';

class ResetEmailSentPage extends StatefulWidget {
  const ResetEmailSentPage(
      {super.key, required this.title, required this.email});
  final String title;
  final String email;

  @override
  State<ResetEmailSentPage> createState() => _ResetEmailSentPageState();
}

class _ResetEmailSentPageState extends State<ResetEmailSentPage> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        leading: BackButton(onPressed: () {
          Navigator.pop(context);
          Navigator.pop(context);
        }),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IntroWidget(
              title: widget.title,
              text:
                  "We have sent a instructions email to \n${widget.email}. Please check your inbox or spam folder for an email from us.",
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                AuthService().resendEmailRestPassword(widget.email, context,
                    (loading) => setState(() => isLoading = loading));
              },
              child: isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(3.0),
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    )
                  : const Text("Send again"),
            ),
          ],
        ),
      ),
    );
  }
}

class IntroWidget extends StatelessWidget {
  final String title, text;

  const IntroWidget({super.key, required this.title, required this.text});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleLarge!
              .copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(text, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 16),
      ],
    );
  }
}
