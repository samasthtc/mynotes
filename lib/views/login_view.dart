import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/utilities/show_error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Login"),
      ),
      body: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: _email,
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: "Enter your email",
            ),
          ),
          TextField(
            controller: _password,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(
              hintText: "Enter your password",
            ),
          ),
          TextButton(
            onPressed: () async {
              final email = _email.text;
              final password = _password.text;
              final navigator = Navigator.of(context);

              try {
                await AuthService.firebase().login(
                  email: email,
                  password: password,
                );
                final user = AuthService.firebase().currentUser;
                if (user?.isEmailVerified ?? false) {
                  navigator.pushNamedAndRemoveUntil(
                    notesRoute,
                    (route) => false,
                  );
                } else {
                  // await AuthService.firebase().sendEmailVerification();
                  navigator.pushNamedAndRemoveUntil(
                    verifyEmailRoute,
                    (route) => false,
                  );
                  return;
                }
              } on UserNotFoundAuthException {
                if (!context.mounted) {
                  return;
                }
                await showErrorDialog(
                  context,
                  "Email not found. Please enter an existing email or register.",
                );
              } on WrongPasswordAuthException {
                if (!context.mounted) {
                  return;
                }
                await showErrorDialog(
                  context,
                  "Invalid password. Please try again.",
                );
              } on InvalidEmailAuthException {
                if (!context.mounted) {
                  return;
                }
                await showErrorDialog(
                  context,
                  "Invalid email. Please enter a valid email.",
                );
              } on GenericAuthException {
                if (!context.mounted) {
                  return;
                }
                await showErrorDialog(
                  context,
                  "Authentication failed. Please try again.",
                );
              } catch (e) {
                if (!context.mounted) {
                  return;
                }
                await showErrorDialog(
                  context,
                  e.toString(),
                );
              }
            },
            style: TextButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            ),
            child: const Text("Login"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                registerRoute,
                (route) => false,
              );
            },
            style: TextButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            ),
            child: const Text("Not registered? Register here!"),
          )
        ],
      ),
    );
  }
}
