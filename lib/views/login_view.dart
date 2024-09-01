import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/utilities/show_error_dialog.dart';
import 'package:mynotes/services/crud/notes_service.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  String? _emailError;
  String? _passwordError;

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
        title: const Text(
          "Login",
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: TextField(
                controller: _email,
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
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: TextField(
                controller: _password,
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                decoration: InputDecoration(
                  hintText: "Enter your password",
                  border: const OutlineInputBorder(),
                  labelText: "Password",
                  labelStyle: const TextStyle(color: Colors.black),
                  errorText: _passwordError,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                final email = _email.text;
                final password = _password.text;
                final navigator = Navigator.of(context);
                setState(() {
                  _emailError = null; // Clear previous errors
                  _passwordError = null;
                });

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
                  setState(() {
                    _emailError =
                        "Email not found. Please enter an existing email or register.";
                  });
                } on InvalidEmailAuthException {
                  setState(() {
                    _emailError = "Invalid email. Please enter a valid email.";
                  });
                } on WrongPasswordAuthException {
                  setState(() {
                    _passwordError = "Invalid password. Please try again.";
                  });
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
      ),
    );
  }
}
