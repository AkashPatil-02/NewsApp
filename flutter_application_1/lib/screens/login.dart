import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/config/user_database.dart';
import 'package:google_sign_in/google_sign_in.dart';

final _firebase = FirebaseAuth.instance;
final _googleSignIn = GoogleSignIn.instance;

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  var showPass = true;
  final _formKey = GlobalKey<FormState>();
  var _enteredEmail = '';
  var _enteredPass = '';
  var _enteredUsername = '';
  var _isAuth = false;
  var _isLoggedIn = true;

  @override
  void initState() {
    super.initState();
    _initializeGoogleSignIn();
  }

  Future<void> _initializeGoogleSignIn() async {
    try {
      await _googleSignIn.initialize();
    } catch (e) {
      print("Google Sign-In initialization error: $e");
    }
  }

  void _submit() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) return;
    _formKey.currentState!.save();

    setState(() {
      _isAuth = true;
    });

    try {
      UserCredential userCredential;
      if (_isLoggedIn) {
        await _firebase.signInWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPass,
        );
      } else {
        userCredential = await _firebase.createUserWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPass,
        );

        final uid = userCredential.user!.uid;
        await UserDatabase().create(
          path: 'userData/$uid',
          data: {'name': _enteredUsername, 'email': _enteredEmail},
        );
      }
    } on FirebaseAuthException catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message ?? 'Authentication Failed')),
      );
    } finally {
      setState(() {
        _isAuth = false;
      });
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isAuth = true;
    });

    try {
      // Authenticate the user
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      if (googleUser == null) {
        // User canceled the sign-in
        setState(() => _isAuth = false);
        return;
      }

      // Request authorization for scopes
      final GoogleSignInClientAuthorization? authorization = await googleUser
          .authorizationClient
          .authorizeScopes(['email', 'profile']);

      if (authorization == null || authorization.accessToken == null) {
        setState(() => _isAuth = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google authorization failed')),
        );
        return;
      }

      // Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        idToken: googleUser.id, // user ID token
        accessToken: authorization.accessToken,
      );

      // Sign in to Firebase
      await _firebase.signInWithCredential(credential);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signed in with Google successfully')),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Google Sign-In failed')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() {
        _isAuth = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Card(
                margin: const EdgeInsets.all(20),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          decoration: const InputDecoration(
                            hintText: "Enter Email",
                            prefixIcon: Icon(Icons.email),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty ||
                                !value.contains("@")) {
                              return 'Enter a valid Email address';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _enteredEmail = value!;
                          },
                          keyboardType: TextInputType.emailAddress,
                        ),
                        if (!_isLoggedIn)
                          TextFormField(
                            decoration: const InputDecoration(
                              hintText: "Create username",
                              prefixIcon: Icon(Icons.person),
                            ),
                            enableSuggestions: false,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  value.trim().length < 3) {
                                return 'Enter a valid username';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _enteredUsername = value!;
                            },
                          ),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: (_isLoggedIn)
                                ? "Password"
                                : "Create password",
                            prefixIcon: const Icon(Icons.password),
                            suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  showPass = !showPass;
                                });
                              },
                              child: Icon(
                                showPass
                                    ? Icons.remove_red_eye_outlined
                                    : Icons.remove_red_eye,
                              ),
                            ),
                          ),
                          obscureText: showPass,
                          autocorrect: false,
                          textCapitalization: TextCapitalization.none,
                          keyboardType: TextInputType.text,
                          onSaved: (value) {
                            _enteredPass = value!;
                          },
                          validator: (value) {
                            if (value == null || value.trim().length < 6) {
                              return 'Password must be at least 6 characters long';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        if (_isAuth) const CircularProgressIndicator(),
                        if (!_isAuth)
                          ElevatedButton(
                            onPressed: _submit,
                            child: Text(_isLoggedIn ? "Sign In" : "Sign Up"),
                          ),
                        if (!_isAuth)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isLoggedIn = !_isLoggedIn;
                              });
                            },
                            child: Text(
                              _isLoggedIn
                                  ? "Create an account"
                                  : "Already have an account",
                            ),
                          ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _signInWithGoogle,
                          child: const Text("Sign in with Google"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
