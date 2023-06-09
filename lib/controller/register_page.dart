import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

// Internal package
import 'package:bab/controller/login_page.dart';
import 'package:bab/models/user_model.dart';
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/utils/constants.dart';
import 'package:bab/utils/database.dart';
import 'package:bab/widgets/dialogs/markdown_dialog.dart';
import 'package:bab/widgets/primary_button.dart';

// External package
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
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
                        child: Text(AppLocalizations.of(context)!.text('register'), style: const TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold))
                    ),
                    InkWell(
                      hoverColor: Colors.white,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(AppLocalizations.of(context)!.text('have_an_account'), style: TextStyle(color: Theme.of(context).primaryColor)),
                          Text(AppLocalizations.of(context)!.text('identify_yourself'), style: TextStyle(color: Theme.of(context).primaryColor)),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) {
                          return const LoginPage();
                        }));
                      },
                    )
                  ]
              ),
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(AppLocalizations.of(context)!.text('full_name'), style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              TextFormField(
                  controller: _fullNameController,
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
                      return AppLocalizations.of(context)!.text('name_required');
                    }
                    return null;
                  }
              ),
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(AppLocalizations.of(context)!.text('email_address'), style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              TextFormField(
                  controller: _emailController,
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
                  obscureText: !passwordVisible,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0)
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.all(12),
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
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerLeft,
                child:Text.rich(
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
              CustomPrimaryButton(
                textValue: AppLocalizations.of(context)!.text('register'),
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
      credential.user!.sendEmailVerification();
      debugPrint('createUserWithEmailAndPassword ${credential.user!.uid}');
      UserModel user = UserModel(
        full_name: _fullNameController.text,
        email: _emailController.text.trim(),
        user: credential.user
      );
      Database().set(credential.user!.uid, user).then((value) async {
        if (value == true) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString(SIGN_IN_KEY, _emailController.text.trim());
          _showSnackbar(AppLocalizations.of(context)!.text('email_confirm_registration'));
          Navigator.pop(context);
        }
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        _showSnackbar(AppLocalizations.of(context)!.text('weak_password'));
      } else if (e.code == 'email-already-in-use') {
        _showSnackbar(AppLocalizations.of(context)!.text('email_already_in_use'));
      }
    } catch (e) {
      print(e);
    }
  }

  _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 10)
        )
    );
  }
}

