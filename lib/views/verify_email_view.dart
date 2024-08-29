import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_service.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Verify Email"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Text("We've sent an email verification to your email address."
              " Please check it to verify your email."),
          const Text(
              "If you haven't recieved an email, press the button below."),
          TextButton(
              onPressed: () async {
                await AuthService.firebase().sendEmailVerification();
              },
              style: TextButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              ),
              child: const Text("Resend Email Verifiation")),
          TextButton(
              onPressed: () async {
                await AuthService.firebase().logout();
                if (!context.mounted) {
                  return;
                }
                Navigator.of(context).pushNamedAndRemoveUntil(
                  registerRoute,
                  (_) => false,
                );
              },
              style: TextButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              ),
              child: const Text("Restart")),
        ],
      ),
    );
  }
}
