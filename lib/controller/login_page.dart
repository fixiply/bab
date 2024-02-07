import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

// Internal package
import 'package:bab/controller/register_page.dart';
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/utils/constants.dart';
import 'package:bab/widgets/custom_checkbox.dart';
import 'package:bab/widgets/dialogs/markdown_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';

// External package
import 'package:email_validator/email_validator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _email = foundation.kDebugMode ? GUEST : null;
  late TextEditingController _emailController;
  final TextEditingController _passwordController = TextEditingController(text: foundation.kDebugMode ? 'mot2passe' : null);

  bool _rememberMe = false;
  bool _passwordVisible = false;
  void togglePassword() {
    setState(() {
      _passwordVisible = !_passwordVisible;
    });
  }

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: _email);
    _initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon:const Icon(Icons.close),
          onPressed:() async {
            Navigator.pop(context);
          }
        )
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18.0, 18.0, 18.0, 0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(AppLocalizations.of(context)!.text('to_connect'), style: const TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold))
                  ),
                  InkWell(
                    hoverColor: Colors.white,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(AppLocalizations.of(context)!.text('not_registered'), style: TextStyle(color: Theme.of(context).primaryColor)),
                        Text(AppLocalizations.of(context)!.text('sign_up'), style: TextStyle(color: Theme.of(context).primaryColor)),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return RegisterPage();
                      })).then((value) {
                        _initialize();
                        if (value != null) {
                          Navigator.pop(context);
                        }
                      });
                    },
                  )
                ]
              ),
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(AppLocalizations.of(context)!.text('email_address'), style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0)
                  ),
                  isDense: true,
                  contentPadding: const EdgeInsets.all(12),
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value!.isEmpty) {
                    return AppLocalizations.of(context)!.text('email_required');
                  }
                  return null;
                }
              ),
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(AppLocalizations.of(context)!.text('password'), style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              TextFormField(
                controller: _passwordController,
                obscureText: !_passwordVisible,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0)
                  ),
                  isDense: true,
                  contentPadding: const EdgeInsets.all(12),
                  suffixIcon: IconButton(
                    color: TextGrey,
                    icon: Icon(_passwordVisible
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined, size: 24, color: Theme.of(context).primaryColor),
                    onPressed: togglePassword,
                  ),
                ),
                onEditingComplete: () async {
                  if (_formKey.currentState!.validate()) {
                    await _signInWithEmailAndPassword();
                  }
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value!.isEmpty) {
                    return AppLocalizations.of(context)!.text('password_required');
                  }
                  return null;
                }
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (foundation.kIsWeb) Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CustomCheckbox(
                        checked: _rememberMe,
                        onChanged: (value) {
                          setState(() {
                            _rememberMe = value;
                          });
                        },
                      ),
                      SizedBox(
                        width: 12,
                      ),
                      Text(AppLocalizations.of(context)!.text('remember_me')),
                    ],
                  ),
                  InkWell(
                    hoverColor: Colors.white,
                    child: Text(AppLocalizations.of(context)!.text('forgot_password'), style: TextStyle(color: Theme.of(context).primaryColor)),
                    onTap: EmailValidator.validate(_emailController.text) ? () async {
                      FirebaseAuth.instance.sendPasswordResetEmail(email: _emailController.text);
                      _showSnackbar(AppLocalizations.of(context)!.text('password_reset'));
                    } : null,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerLeft,
                child: Text.rich(
                  TextSpan(
                    text:  AppLocalizations.of(context)!.text('cgu_1'),
                    style: regular14pt.copyWith(color: TextGrey),
                    children: <TextSpan>[
                      TextSpan(
                        text: AppLocalizations.of(context)!.text('terms_of_use'),
                        style: regular14pt.copyWith(color: Theme.of(context).primaryColor),
                        recognizer: TapGestureRecognizer()..onTap = () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return const MarkdownDialog(filename: TERMS_CONDITIONS);
                              }
                          );
                        }
                      ),
                      TextSpan(
                        text: AppLocalizations.of(context)!.text('cgu_2'),
                        style: regular14pt.copyWith(color: TextGrey),
                        children: <TextSpan>[
                          TextSpan(
                            text: '${AppLocalizations.of(context)!.text('privacy_policy')}.',
                            style: regular14pt.copyWith(color: Theme.of(context).primaryColor),
                            recognizer: TapGestureRecognizer()..onTap = () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return const MarkdownDialog(filename: PRIVACY_POLICY);
                                  }
                              );
                            }
                          )
                        ]
                      )
                    ]
                  )
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(18)),
                  child: Text(AppLocalizations.of(context)!.text('to_connect')),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await _signInWithEmailAndPassword();
                    }
                  },
                ),
              ),
            ],
          ),
        )
      ),
    );
  }

  _initialize() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString(SIGN_IN_KEY);
    if (email != null) {
      _emailController.text = email;
    }
    bool? remember = prefs.getBool(REMEMBER_ME);
    if (remember != null) {
      setState(() {
        _rememberMe = remember;
      });
    }
  }

  _signInWithEmailAndPassword() async {
    if (!mounted) return;
    try {
      if (foundation.kIsWeb && !_rememberMe) {
        await FirebaseAuth.instance.setPersistence(Persistence.SESSION);
      }
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(SIGN_IN_KEY, _emailController.text.trim());
      if (!credential.user!.emailVerified) {
        _showSnackbar(AppLocalizations.of(context)!.text('email_validate_registration'),
          action: SnackBarAction(
            textColor: Colors.white,
            label: AppLocalizations.of(context)!.text('resend'),
            onPressed: () async {
              await credential.user!.sendEmailVerification();
            }
          ),
          onClosed: () async {
            await FirebaseAuth.instance.signOut();
          }
        );
      } else {
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _showSnackbar(AppLocalizations.of(context)!.text('no_user_found'));
      } else if (e.code == 'wrong-password') {
        _showSnackbar(AppLocalizations.of(context)!.text('wrong_password'));
      } else {
        _showSnackbar(e.message!);
      }
    }
  }

  _showSnackbar(String message, {SnackBarAction? action, VoidCallback? onClosed}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 10),
        action: action,
      )
    ).closed.then((value) => onClosed?.call());
  }
}

