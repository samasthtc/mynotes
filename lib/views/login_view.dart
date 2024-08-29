import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/views/utilities/show_error_dialog.dart';

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
                await FirebaseAuth.instance.signInWithEmailAndPassword(
                  email: email,
                  password: password,
                );
                final user = FirebaseAuth.instance.currentUser;
                if (user?.emailVerified ?? false) {
                  navigator.pushNamedAndRemoveUntil(
                    notesRoute,
                    (route) => false,
                  );
                } else {
                  navigator.pushNamedAndRemoveUntil(
                    verifyEmailRoute,
                    (route) => false,
                  );
                  return;
                }
              } on FirebaseAuthException catch (e) {
                if (e.code == 'user-not-found') {
                  if (!context.mounted) {
                    return;
                  }
                  await showErrorDialog(
                    context,
                    "Email not found. Please enter an existing email or register.",
                  );
                } else if (e.code == 'wrong-password') {
                  if (!context.mounted) {
                    return;
                  }
                  await showErrorDialog(
                    context,
                    "Invalid password. Please try again.",
                  );
                } else if (e.code == 'invalid-email') {
                  if (!context.mounted) {
                    return;
                  }
                  await showErrorDialog(
                    context,
                    "Invalid email. Please enter a valid email.",
                  );
                } else {
                  if (!context.mounted) {
                    return;
                  }
                  await showErrorDialog(
                    context,
                    "${e.code}.",
                  );
                }
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
