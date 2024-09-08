import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/bloc/auth_bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';
import 'package:mynotes/services/auth/bloc/auth_state.dart';
import 'package:mynotes/utilities/dialogs/error_dialog.dart';

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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateLoggedOut) {
          if (state.exception is UserNotFoundAuthException ||
              state.exception is WrongPasswordAuthException) {
            setState(() {
              _emailError = "Wrong credentials. Please try again.";
              _passwordError = "Wrong credentials. Please try again.";
            });
          } else if (state.exception is InvalidEmailAuthException) {
            setState(() {
              _emailError = "Invalid email. Please enter a valid email.";
            });
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(
              context,
              "Authentication failed. Please try again.",
            );
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          centerTitle: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(24.0),
            ),
          ),
          title: const Text(
            "Login",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          elevation: 8,
          shadowColor: const Color.fromARGB(120, 0, 0, 0),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  text: 'Welcome to ',
                  style: const TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.w700,
                  ),
                  children: [
                    TextSpan(
                      text: 'MyNotes!',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Center(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: TextField(
                        controller: _email,
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
                    TextField(
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
                    TextButton(
                      onPressed: () {
                        context.read<AuthBloc>().add(
                              const AuthEventForgotPassword(),
                            );
                      },
                      // style: TextButton.styleFrom(
                      //   backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                      // ),
                      child: const Text("Forgot my password"),
                    ),
                    TextButton(
                      onPressed: () async {
                        final email = _email.text;
                        final password = _password.text;
                        setState(() {
                          _emailError = null;
                          _passwordError = null;
                        });

                        context.read<AuthBloc>().add(
                              AuthEventLogin(
                                email: email,
                                password: password,
                              ),
                            );
                      },
                      style: TextButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.inversePrimary,
                      ),
                      child: const Text("Login"),
                    ),
                    TextButton(
                      onPressed: () {
                        context.read<AuthBloc>().add(
                              const AuthEventShouldRegister(),
                            );
                      },
                      style: TextButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.inversePrimary,
                      ),
                      child: const Text("Not registered? Register here!"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
