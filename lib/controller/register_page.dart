import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' as foundation;

// Internal package
import 'package:bab/controller/login_page.dart';
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/utils/constants.dart';
import 'package:bab/widgets/dialogs/markdown_dialog.dart';
import 'package:bab/widgets/custom_state.dart';

// External package
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:g_recaptcha_v3/g_recaptcha_v3.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends CustomState<RegisterPage> {
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
  void initState() {
    super.initState();
    if (foundation.kIsWeb && !foundation.kDebugMode) {
      GRecaptchaV3.showBadge();
    }
  }

  @override
  void dispose() {
    if (foundation.kIsWeb && !foundation.kDebugMode) {
      GRecaptchaV3.hideBadge();
    }
    super.dispose();
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
              // if (foundation.kIsWeb) WebViewX(
              //   height: 100,
              //   width: 400,
              //   javascriptMode: JavascriptMode.unrestricted,
              //   onWebViewCreated: (controller) {
              //     controller.loadContent("assets/html/recaptcha.html", sourceType: SourceType.html, fromAssets: true);
              //   },
              //   dartCallBacks: {
              //     DartCallback(
              //       name: 'Captcha',
              //       callBack: (msg) {
              //         debugPrint('Captcha ${msg.message}');
              //         setState(() {
              //           _isVerified = true;
              //         });
              //       },
              //     )
              //   },
              // ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(18)),
                  child: Text(AppLocalizations.of(context)!.text('register')),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await _createUserWithEmailAndPassword();
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

  _createUserWithEmailAndPassword() async {
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      EasyLoading.showInfo(AppLocalizations.of(context)!.text('email_confirm_registration'),
          dismissOnTap: true,
          duration: Duration(seconds: 10)
      );
      credential.user!.sendEmailVerification();
      credential.user!.updateDisplayName(_fullNameController.text);
      debugPrint('createUserWithEmailAndPassword ${credential.user!.uid}');
      await FirebaseAuth.instance.signOut();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        showSnackbar(AppLocalizations.of(context)!.text('weak_password'), success: false);
      } else if (e.code == 'email-already-in-use') {
        showSnackbar(AppLocalizations.of(context)!.text('email_already_in_use'), success: false);
      }
    } catch (e) {
      print(e);
    }
  }
}

