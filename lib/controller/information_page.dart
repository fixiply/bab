import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// Internal package
import 'package:bab/utils/database.dart';
import 'package:bab/controller/forms/form_payment_page.dart';
import 'package:bab/models/payment_model.dart';
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/utils/constants.dart';

// External package
import 'package:uuid/uuid.dart';

class InformationPage extends StatefulWidget {
  @override
  _InformationPageState createState() => _InformationPageState();
}

class _InformationPageState extends State<InformationPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _globaley = GlobalKey<FormState>();
  final GlobalKey<FormState> _emailKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _passwordKey = GlobalKey<FormState>();


  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _confirmEmailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _newPpasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool changeEmail = false;
  bool changePassword = false;

  bool passwordVisible = false;
  void togglePassword() {
    setState(() {
      passwordVisible = !passwordVisible;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<PaymentModel>? payments = currentUser != null ? currentUser!.payments : [];
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: FillColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.text('my_information')),
        elevation: 0,
        foregroundColor: Theme.of(context).primaryColor,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start ,
          children: <Widget>[
            const SizedBox(height: 18),
            Form(
              key: _globaley,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start ,
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(AppLocalizations.of(context)!.text('full_name'), style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  TextFormField(
                      controller: _fullNameController..text = FirebaseAuth.instance.currentUser!.displayName ?? '',
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
                  const SizedBox(height: 6),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(18)),
                    child: Text(AppLocalizations.of(context)!.text('validate')),
                    onPressed: () async {
                      if (_globaley.currentState!.validate()) {
                        FirebaseAuth.instance.currentUser!.updateDisplayName(_fullNameController.text);
                        _showSnackbar(AppLocalizations.of(context)!.text('information_recorded'));
                      }
                    },
                  ),
                ]
              )
            ),
            const SizedBox(height: 18),
            Form(
              key: _emailKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start ,
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(AppLocalizations.of(context)!.text('email_address'), style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  TextFormField(
                      controller: _emailController..text = FirebaseAuth.instance.currentUser!.email ?? '',
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0)
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.all(12),
                      ),
                      // autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return AppLocalizations.of(context)!.text('email_required');
                        }
                        return null;
                      }
                  ),
                  if (changeEmail) const SizedBox(height: 6),
                  if (changeEmail) Align(
                    alignment: Alignment.centerLeft,
                    child: Text(AppLocalizations.of(context)!.text('confirm_mail'), style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  if (changeEmail) TextFormField(
                      controller: _confirmEmailController,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0)
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.all(12),
                      ),
                      // autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return AppLocalizations.of(context)!.text('email_required');
                        }
                        if (value != _emailController.text) {
                          return AppLocalizations.of(context)!.text('invalid_email');
                        }
                        return null;
                      }
                  ),
                  const SizedBox(height: 6),
                  if (!changeEmail) InkWell(
                    hoverColor: Colors.white,
                    child: Text(AppLocalizations.of(context)!.text('change_mail'), style: TextStyle(color: Theme.of(context).primaryColor)),
                    onTap: EmailValidator.validate(_emailController.text) ? () async {
                      setState(() {
                        changeEmail = true;
                      });
                    } : null,
                  ) else Row(
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(18), backgroundColor: FillColor),
                          child: Text(MaterialLocalizations.of(context).cancelButtonLabel, style: TextStyle(color : Colors.black87)),
                          onPressed: () async {
                            setState(() {
                              changeEmail = false;
                            });
                          },
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(18)),
                          child: Text(AppLocalizations.of(context)!.text('validate')),
                          onPressed: () async {
                            if (_emailKey.currentState!.validate()) {
                              FirebaseAuth.instance.currentUser!.updateEmail(_confirmEmailController.text);
                              _showSnackbar(AppLocalizations.of(context)!.text('email_changed'));
                              setState(() {
                                changeEmail = false;
                              });
                            }
                          },
                        )
                      ]
                  ),
                ]
              )
            ),
            const SizedBox(height: 18),
            Form(
              key: _passwordKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start ,
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(AppLocalizations.of(context)!.text(changePassword ? 'old_password' : 'password'), style: const TextStyle(fontWeight: FontWeight.bold)),
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
                      // autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return AppLocalizations.of(context)!.text('password_required');
                        }
                        return null;
                      }
                  ),
                  if (changePassword) const SizedBox(height: 6),
                  if (changePassword) Align(
                    alignment: Alignment.centerLeft,
                    child: Text(AppLocalizations.of(context)!.text('new_password'), style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  if (changePassword) TextFormField(
                      controller: _newPpasswordController,
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
                      // autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return AppLocalizations.of(context)!.text('password_required');
                        }
                        return null;
                      }
                  ),
                  if (changePassword) const SizedBox(height: 6),
                  if (changePassword) Align(
                    alignment: Alignment.centerLeft,
                    child: Text(AppLocalizations.of(context)!.text('password_confirmation'), style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  if (changePassword) TextFormField(
                      controller: _confirmPasswordController,
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
                      // autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return AppLocalizations.of(context)!.text('password_required');
                        }
                        if (value != _newPpasswordController.text) {
                          return AppLocalizations.of(context)!.text('invalid_password');
                        }
                        return null;
                      }
                  ),
                  const SizedBox(height: 6),
                  if (!changePassword) InkWell(
                    hoverColor: Colors.white,
                    child: Text(AppLocalizations.of(context)!.text('change_password'), style: TextStyle(color: Theme.of(context).primaryColor)),
                    onTap: () async {
                      setState(() {
                        changePassword = true;
                      });
                    },
                  ) else Row(
                    children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(18), backgroundColor: FillColor),
                          child: Text(MaterialLocalizations.of(context).cancelButtonLabel, style: TextStyle(color : Colors.black87)),
                          onPressed: () async {
                            setState(() {
                              changePassword = false;
                            });
                          },
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(18)),
                          child: Text(AppLocalizations.of(context)!.text('validate')),
                          onPressed: () async {
                            if (_passwordKey.currentState!.validate()) {
                              await FirebaseAuth.instance.signInWithEmailAndPassword(
                                email: _emailController.text.trim(),
                                password: _passwordController.text.trim(),
                              ).then((value) {
                                FirebaseAuth.instance.currentUser!.updatePassword(_confirmPasswordController.text);
                                _showSnackbar(AppLocalizations.of(context)!.text('password_changed'));
                              });
                            }
                          },
                        )
                      ]
                  ),
                ]
              )
            ),
          ]
        )
      )
    );
  }

  _new() async {
    PaymentModel newModel = PaymentModel();
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return FormPaymentPage(newModel);
    })).then((value) {
      if (value != null) {
        setState(() {
          newModel.uuid = const Uuid().v4();
          currentUser!.payments!.add(newModel);
          Database().update(currentUser).then((value) async {
            _showSnackbar(AppLocalizations.of(context)!.text('saved_credit_card'));
          }).onError((e,s) {
            _showSnackbar(e.toString());
          });
        });
      }
    });
  }

  _edit(PaymentModel model) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return FormPaymentPage(model);
    })).then((value) {
      if (value != null) {
        setState(() {
          Database().update(currentUser).then((value) async {
            _showSnackbar(AppLocalizations.of(context)!.text('saved_credit_card'));
          }).onError((e,s) {
            _showSnackbar(e.toString());
          });
        });
      }
    });
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

