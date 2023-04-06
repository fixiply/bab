import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

// Internal package
import 'package:bb/controller/login_page.dart';
import 'package:bb/models/user_model.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/utils/database.dart';
import 'package:bb/widgets/dialogs/markdown_dialog.dart';
import 'package:bb/widgets/primary_button.dart';

// External package
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({Key? key}) : super(key: key);
  _RegisterPageState createState() => new _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool passwordVisible = false;
  void togglePassword() {
    setState(() {
      passwordVisible = !passwordVisible;
    });
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
                        child: Text('S\'inscrire', style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold))
                    ),
                    InkWell(
                      hoverColor: Colors.white,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('Vous avez un compte ?', style: TextStyle(color: Theme.of(context).primaryColor)),
                          Text('Identifiez-vous', style: TextStyle(color: Theme.of(context).primaryColor)),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) {
                          return LoginPage();
                        }));
                      },
                    )
                  ]
              ),
              SizedBox(height: 18),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(AppLocalizations.of(context)!.text('full_name'), style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              TextFormField(
                  controller: _fullNameController,
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
                      return AppLocalizations.of(context)!.text('name_required');
                    }
                    return null;
                  }
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
                      splashRadius: 1,
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
                textValue: 'S\'inscrire',
                onTap: () async {
                  if (_formKey.currentState!.validate()) {
                    await _createUserWithEmailAndPassword();
                  }
                },
              )
            ],
          ),
        )
      ),
    );
  }

  _createUserWithEmailAndPassword() async {
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      debugPrint('createUserWithEmailAndPassword ${credential.user!.uid}');
      UserModel user = UserModel(
        full_name: _fullNameController.text,
        email: _emailController.text.trim(),
        user: credential.user
      );
      if (Database().set(credential.user!.uid, user) == true) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString(SIGN_IN_KEY, _emailController.text.trim());
        Navigator.pop(context, user);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        _showSnackbar('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        _showSnackbar('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
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

