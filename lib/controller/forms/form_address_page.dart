import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Internal package
import 'package:bb/utils/adress.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/widgets/form_decoration.dart';

class FormAddressPage extends StatefulWidget {
  final Adress model;
  FormAddressPage(this.model);
  _FormAddressPageState createState() => new _FormAddressPageState();
}

class _FormAddressPageState extends State<FormAddressPage> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.text('add_address')),
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
                      child: Text(AppLocalizations.of(context)!.text('new_address'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
                  )
                ),
                TextFormField(
                  // focusNode: _focusTitle,
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
                Divider(height: 10),
                TextFormField(
                  initialValue: widget.model.information,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: (text) => setState(() {
                    widget.model.information = text;
                  }),
                  decoration: FormDecoration(
                      labelText: AppLocalizations.of(context)!.text('additional_address'),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(8)
                  )
                ),
                Divider(height: 10),
                TextFormField(
                  initialValue: widget.model.phone,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: (text) => setState(() {
                    widget.model.phone = text;
                  }),
                  decoration: FormDecoration(
                      labelText: AppLocalizations.of(context)!.text('phone'),
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
                  label: Text(AppLocalizations.of(context)!.text('remove_address')),
                  style: TextButton.styleFrom(
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

