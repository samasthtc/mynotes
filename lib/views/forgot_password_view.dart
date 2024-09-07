import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';
import 'package:mynotes/services/auth/bloc/auth_state.dart';
import 'package:mynotes/utilities/dialogs/error_dialog.dart';
import 'package:mynotes/utilities/dialogs/password_reset_email_sent_dialog.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  late final TextEditingController _controller;
  String? _emailError;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateForgotPassword) {
          if (state.hasSentEmail) {
            _controller.clear();
            await showPasswordResetEmailSentDialog(context);
          }
          if (state.exception != null) {
            if (!context.mounted) {
              return;
            }
            await showErrorDialog(context,
                'Your request could not be completed. Please make sure you are a registered user.');
            setState(() {
              _emailError =
                  'Invalid email. Please enter a valid and registered email.';
            });
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text(
            "Forgot Password",
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 16.0),
                child: Text(
                  "If you've forgotten your password, enter your email address below and we'll send you a link to reset your password.",
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: "Enter your email",
                    border: const OutlineInputBorder(),
                    labelText: "Email",
                    labelStyle: const TextStyle(color: Colors.black),
                    errorText: _emailError,
                    // focusedBorder: OutlineInputBorder(
                    //   borderSide: BorderSide(color: Colors.black),
                    // ),
                  ),
                ),
              ),
              TextButton(
                  onPressed: () {
                    final email = _controller.text;
                    context.read<AuthBloc>().add(
                          AuthEventForgotPassword(email: email),
                        );
                  },
                  style: TextButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.inversePrimary,
                  ),
                  child: const Text("Send Password Reset Email")),
              TextButton(
                onPressed: () async {
                  context.read<AuthBloc>().add(
                        const AuthEventLogout(),
                      );
                },
                style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                ),
                child: const Text("Back to login page"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
