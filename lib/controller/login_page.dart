import 'package:flutter/foundation.dart' as Foundation;
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

// Internal package
import 'package:bb/controller/register_page.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/widgets/dialogs/markdown_dialog.dart';
import 'package:bb/widgets/primary_button.dart';
import 'package:firebase_auth/firebase_auth.dart';

// External package
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _email = Foundation.kDebugMode ? RECIPIENT : null;
  late TextEditingController _emailController;
  final TextEditingController _passwordController = TextEditingController();

  bool passwordVisible = false;
  void togglePassword() {
    setState(() {
      passwordVisible = !passwordVisible;
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
          icon:Icon(Icons.close),
          onPressed:() async {
            Navigator.pop(context);
          }
        )
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(18.0, 18.0, 18.0, 0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text('Se connecter', style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold))
                  ),
                  GestureDetector(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('Pas encore inscrit ?', style: TextStyle(color: Theme.of(context).primaryColor)),
                        Text('Inscrivez-vous', style: TextStyle(color: Theme.of(context).primaryColor)),
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
              SizedBox(height: 18),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(AppLocalizations.of(context)!.text('email_address'), style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0)
                  ),
                  isDense: true,
                  contentPadding: EdgeInsets.all(12),
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value!.isEmpty) {
                    return AppLocalizations.of(context)!.text('email_required');
                  }
                  return null;
                }
              ),
              SizedBox(height: 18),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(AppLocalizations.of(context)!.text('password'), style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              TextFormField(
                controller: _passwordController,
                obscureText: !passwordVisible,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0)
                  ),
                  isDense: true,
                  contentPadding: EdgeInsets.all(12),
                  suffixIcon: IconButton(
                    color: TextGrey,
                    icon: Icon(passwordVisible
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined, size: 24, color: Theme.of(context).primaryColor),
                    onPressed: togglePassword,
                  ),
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value!.isEmpty) {
                    return AppLocalizations.of(context)!.text('password_required');
                  }
                  return null;
                }
              ),
              SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Mot de passe oublié ?', style: TextStyle(color: Theme.of(context).primaryColor)),
              ),
              SizedBox(height: 18),
              Text.rich(
                  TextSpan(
                      text:  'En cliquant sur l\'une des réponses ci-après, j\'accepte les ',
                      style: regular14pt.copyWith(color: TextGrey),
                      children: <TextSpan>[
                        TextSpan(
                            text: 'Conditions Générales d\'Utilisation',
                            style: regular14pt.copyWith(color: Theme.of(context).primaryColor),
                            recognizer: TapGestureRecognizer()..onTap = () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return MarkdownDialog(filename: TERMS_CONDITIONS);
                                  }
                              );
                            }
                        ),
                        TextSpan(
                          text: ' et je reconnais avoir lu la ',
                          style: regular14pt.copyWith(color: TextGrey),
                          children: <TextSpan>[
                            TextSpan(
                              text: 'Politique de Confidentalié.',
                              style: regular14pt.copyWith(color: Theme.of(context).primaryColor),
                              recognizer: TapGestureRecognizer()..onTap = () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return MarkdownDialog(filename: PRIVACY_POLICY);
                                    }
                                );
                              }
                            )
                          ]
                        )
                      ]
                  )
              ),
              SizedBox(height: 18),
              CustomPrimaryButton(
                textValue: 'Se connecter',
                onTap: () async {
                  if (_formKey.currentState!.validate()) {
                    await _signInWithEmailAndPassword();
                  }
                },
              )
            ],
          ),
        )
      ),
    );
  }

  _initialize() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? value = prefs.getString(SIGN_IN_KEY);
    if (value != null) {
      _emailController.text = value;
    }
  }

  _signInWithEmailAndPassword() async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(SIGN_IN_KEY, _emailController.text.trim());
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _showSnackbar('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        _showSnackbar('Wrong password provided for that user.');
      }
    }
  }

  _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(message),
            duration: Duration(seconds: 10)
        )
    );
  }
}

