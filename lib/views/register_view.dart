import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/views/utilities/show_error_dialog.dart';

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
                await FirebaseAuth.instance.createUserWithEmailAndPassword(
                  email: email,
                  password: password,
                );
                final user = FirebaseAuth.instance.currentUser;
                await user?.sendEmailVerification();
                navigator.pushNamed(verifyEmailRoute);
              } on FirebaseAuthException catch (e) {
                if (e.code == 'weak-password') {
                  if (!context.mounted) {
                    return;
                  }
                  await showErrorDialog(
                    context,
                    "Provided password is too weak.",
                  );
                } else if (e.code == 'email-already-in-use') {
                  if (!context.mounted) {
                    return;
                  }
                  await showErrorDialog(
                    context,
                    "Email is already in use. Please enter another email.",
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
