import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/bloc/auth_bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';
import 'package:mynotes/services/auth/bloc/auth_state.dart';
import 'package:mynotes/utilities/dialogs/error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateRegistering) {
          if (state.exception is WeakPasswordAuthException) {
            setState(() {
              _passwordError = "Provided password is too weak.";
            });
          } else if (state.exception is EmailAlreadyInUseAuthException) {
            setState(() {
              _emailError =
                  "Email is already in use. Please enter another email.";
            });
          } else if (state.exception is InvalidEmailAuthException) {
            setState(() {
              _emailError = "Invalid email. Please enter a valid email.";
            });
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(
              context,
              "Failed to Register. Please try again.",
            );
          } else {
            await showErrorDialog(
              context,
              state.exception.toString(),
            );
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text(
            "Register",
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
                  setState(() {
                    _emailError = null; // Clear previous errors
                    _passwordError = null;
                  });

                  context.read<AuthBloc>().add(
                        AuthEventRegister(
                          email: email,
                          password: password,
                        ),
                      );
                },
                style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                ),
                child: const Text("Register"),
              ),
              TextButton(
                onPressed: () {
                  context.read<AuthBloc>().add(
                        const AuthEventLogout(),
                      );
                },
                style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                ),
                child: const Text("Already Registered? Back to Login!"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
