import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/utilities/show_error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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
        title: const Text("Register"),
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
                await AuthService.firebase().createUser(
                  email: email,
                  password: password,
                );
                await AuthService.firebase().sendEmailVerification();
                navigator.pushNamed(verifyEmailRoute);
              } on WeakPasswordAuthException {
                if (!context.mounted) {
                  return;
                }
                await showErrorDialog(
                  context,
                  "Provided password is too weak.",
                );
              } on EmailAlreadyInUseAuthException {
                if (!context.mounted) {
                  return;
                }
                await showErrorDialog(
                  context,
                  "Email is already in use. Please enter another email.",
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
                  "An error occurred. Please try again.",
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
            child: const Text("Register"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).restorablePushNamedAndRemoveUntil(
                loginRoute,
                (route) => false,
              );
            },
            style: TextButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            ),
            child: const Text("Registered? Back to Login!"),
          )
        ],
      ),
    );
  }
}
