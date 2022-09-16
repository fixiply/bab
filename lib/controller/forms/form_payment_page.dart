import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Internal package
import 'package:bb/models/payment_model.dart';
import 'package:bb/models/company_model.dart';
import 'package:bb/models/receipt_model.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/utils/database.dart';
import 'package:bb/widgets/form_decoration.dart';

class FormPaymentPage extends StatefulWidget {
  final PaymentModel model;
  FormPaymentPage(this.model);
  _FormPaymentPageState createState() => new _FormPaymentPageState();
}

class _FormPaymentPageState extends State<FormPaymentPage> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<List<CompanyModel>>? _companies;
  Future<List<ReceiptModel>>? _receipts;

  @override
  void initState() {
    super.initState();
    _companies = Database().getCompanies(ordered: true);
    _receipts = Database().getReceipts(ordered: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.text('add_credit_card')),
        elevation: 0,
        foregroundColor: Theme.of(context).primaryColor,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Container(
                  color: FillColor,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(AppLocalizations.of(context)!.text('payment_information'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
                  )
                ),
                TextFormField(
                  initialValue: widget.model.name,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: (text) => setState(() {
                    widget.model.name = text;
                  }),
                  decoration: FormDecoration(
                      labelText: AppLocalizations.of(context)!.text('name'),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(8)
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return AppLocalizations.of(context)!.text('validator_field_required');
                    }
                    return null;
                  }
                ),
                Divider(height: 10),
                TextFormField(
                  initialValue: widget.model.number != null ? widget.model.number.toString() : null,
                  keyboardType: TextInputType.number,
                  onChanged: (value) => setState(() {
                    widget.model.number = int.tryParse(value);
                  }),
                  decoration: FormDecoration(
                    labelText: AppLocalizations.of(context)!.text('card_number'),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(8)
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return AppLocalizations.of(context)!.text('validator_field_required');
                    }
                    return null;
                  }
                ),
                Divider(height: 10),
                TextFormField(
                  initialValue: widget.model.date,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: (text) => setState(() {
                    widget.model.date = text;
                  }),
                  decoration: FormDecoration(
                      labelText: AppLocalizations.of(context)!.text('validity_date'),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(8)
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return AppLocalizations.of(context)!.text('validator_field_required');
                    }
                    return null;
                  }
                ),
                Divider(height: 10),
                TextFormField(
                  initialValue: widget.model.security != null ? widget.model.security.toString() : null,
                  keyboardType: TextInputType.number,
                  onChanged: (value) => setState(() {
                    widget.model.security = int.tryParse(value);
                  }),
                  decoration: FormDecoration(
                      labelText: AppLocalizations.of(context)!.text('security_code'),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(8)
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return AppLocalizations.of(context)!.text('validator_field_required');
                    }
                    return null;
                  }
                ),
                Container(
                  color: FillColor,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(AppLocalizations.of(context)!.text('billing_address'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
                  )
                ),
                TextFormField(
                  initialValue: widget.model.address,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: (text) => setState(() {
                    widget.model.address = text;
                  }),
                  decoration: FormDecoration(
                      labelText: AppLocalizations.of(context)!.text('address'),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(8)
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return AppLocalizations.of(context)!.text('validator_field_required');
                    }
                    return null;
                  }
                ),
                Divider(height: 10),
                TextFormField(
                  initialValue: widget.model.zip != null ? widget.model.zip.toString() : null,
                  keyboardType: TextInputType.number,
                  onChanged: (value) => setState(() {
                    widget.model.zip = int.tryParse(value);
                  }),
                  decoration: FormDecoration(
                      labelText: AppLocalizations.of(context)!.text('zip_code'),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(8)
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return AppLocalizations.of(context)!.text('validator_field_required');
                    }
                    return null;
                  }
                ),
                Divider(height: 10),
                TextFormField(
                  initialValue: widget.model.city,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: (text) => setState(() {
                    widget.model.city = text;
                  }),
                  decoration: FormDecoration(
                      labelText: AppLocalizations.of(context)!.text('city'),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(8)
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return AppLocalizations.of(context)!.text('validator_field_required');
                    }
                    return null;
                  }
                ),
                if (widget.model.uuid != null) TextButton.icon(
                  icon: Icon(Icons.delete_outline),
                  label: Text(AppLocalizations.of(context)!.text('remove_card')),
                  style: TextButton.styleFrom(
                    primary: Colors.red,
                    backgroundColor: Colors.white,
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                  }
                ),
                if (widget.model.uuid != null) const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: TextButton.icon(
                    icon: Icon(Icons.save),
                    label: Text(AppLocalizations.of(context)!.text('save').toUpperCase()),
                    style: TextButton.styleFrom(
                      primary: Theme.of(context).primaryColor,
                      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.pop(context, widget.model);
                      }
                    }
                  )
                )
              ]
            ),
          )
        )
      )
    );
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
