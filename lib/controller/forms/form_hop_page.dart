import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Internal package
import 'package:bab/helpers/device_helper.dart';
import 'package:bab/models/hop_model.dart';
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/utils/constants.dart';
import 'package:bab/utils/database.dart';
import 'package:bab/utils/localized_text.dart';
import 'package:bab/widgets/custom_menu_anchor.dart';
import 'package:bab/widgets/custom_state.dart';
import 'package:bab/widgets/dialogs/confirm_dialog.dart';
import 'package:bab/widgets/dialogs/delete_dialog.dart';
import 'package:bab/widgets/form_decoration.dart';
import 'package:bab/widgets/forms/localized_text_field.dart';
import 'package:bab/widgets/forms/text_input_field.dart';

// External package
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class FormHopPage extends StatefulWidget {
  final HopModel model;
  const FormHopPage(this.model);

  @override
  _FormHopPageState createState() => _FormHopPageState();
}

class _FormHopPageState extends CustomState<FormHopPage> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _modified = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.text('hop')),
        elevation: 0,
        foregroundColor: Theme.of(context).primaryColor,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: DeviceHelper.isLargeScreen ? const Icon(Icons.close) : const BackButtonIcon(),
          onPressed:() async {
            bool confirm = _modified ? await showDialog(
              context: context,
              builder: (BuildContext context) {
                return ConfirmDialog(
                  content: Text(AppLocalizations.of(context)!.text('without_saving')),
                );
              }
            ) : true;
            if (confirm) {
              Navigator.pop(context);
            }
          }
        ),
        actions: <Widget> [
          IconButton(
            padding: EdgeInsets.zero,
            tooltip: AppLocalizations.of(context)!.text('save'),
            icon: const Icon(Icons.save),
            onPressed: _modified == true ? () {
              if (_formKey.currentState!.validate()) {
                Database().update(widget.model, context: context, updateLogs: !currentUser!.isAdmin()).then((value) async {
                  Navigator.pop(context, widget.model);
                }).onError((e,s) {
                  showSnackbar(e.toString());
                });
              }
            } : null
          ),
          if (widget.model.uuid != null) IconButton(
            padding: EdgeInsets.zero,
            tooltip: AppLocalizations.of(context)!.text('remove'),
            icon: const Icon(Icons.delete),
            onPressed: () async {
              if (await DeleteDialog.model(context, widget.model)) {
                Navigator.pop(context);
              }
            }
          ),
          CustomMenuAnchor(
            model: widget.model,
          )
        ]
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15.0),
        child: Form(
          key: _formKey,
          onChanged: () {
            setState(() {
              _modified = true;
            });
          },
          child: Column(
            children: <Widget>[
              LocalizedTextField(
                context: context,
                initialValue: widget.model.name,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (value) => widget.model.name = value,
                decoration: FormDecoration(
                  icon: const Icon(Icons.title),
                  labelText: AppLocalizations.of(context)!.text('name'),
                  border: InputBorder.none,
                  fillColor: FillColor, filled: true
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value!.isEmpty) {
                    return AppLocalizations.of(context)!.text('validator_field_required');
                  }
                  return null;
                }
              ),
              const Divider(height: 10),
              TextFormField(
                initialValue: widget.model.origin ?? '',
                maxLength: 2,
                inputFormatters: [
                  UpperCaseTextFormatter(),
                ],
                onChanged: (value) => widget.model.origin = value,
                decoration: FormDecoration(
                    icon: const Icon(Icons.flag_outlined),
                    labelText: AppLocalizations.of(context)!.text('origin'),
                    border: InputBorder.none,
                    fillColor: FillColor, filled: true
                ),
              ),
              const Divider(height: 10),
              TextFormField(
                initialValue:  AppLocalizations.of(context)!.numberFormat(widget.model.alpha) ?? '',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
                ],
                onChanged: (value) => widget.model.alpha = AppLocalizations.of(context)!.decimal(value),
                decoration: FormDecoration(
                    icon: const Text('α ', style: TextStyle(fontSize: 18, color: Colors.black45)),
                    labelText: AppLocalizations.of(context)!.text('alpha_acid'),
                    suffixText: '%',
                    border: InputBorder.none,
                    fillColor: FillColor, filled: true
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value!.isEmpty) {
                    return AppLocalizations.of(context)!.text('validator_field_required');
                  }
                  return null;
                }
              ),
              const Divider(height: 10),
              TextFormField(
                initialValue:  AppLocalizations.of(context)!.numberFormat(widget.model.beta) ?? '',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) => widget.model.beta = AppLocalizations.of(context)!.decimal(value),
                decoration: FormDecoration(
                    icon: const Text('β ', style: TextStyle(fontSize: 18, color: Colors.black45)),
                    labelText: AppLocalizations.of(context)!.text('beta_acide'),
                    suffixText: '%',
                    border: InputBorder.none,
                    fillColor: FillColor, filled: true
                ),
              ),
              const Divider(height: 10),
              DropdownButtonFormField<Hop>(
                  value: widget.model.form,
                  style: DefaultTextStyle.of(context).style.copyWith(overflow: TextOverflow.ellipsis),
                  decoration: FormDecoration(
                    icon: const Icon(Icons.grass_outlined),
                    labelText: AppLocalizations.of(context)!.text('form'),
                    fillColor: FillColor,
                    filled: true,
                  ),
                  items: Hop.values.map((Hop display) {
                    return DropdownMenuItem<Hop>(
                        value: display,
                        child: Text(AppLocalizations.of(context)!.text(display.toString().toLowerCase())));
                  }).toList(),
                  onChanged: (value) => widget.model.form = value,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value == null) {
                      return AppLocalizations.of(context)!.text('validator_field_required');
                    }
                    return null;
                  }
              ),
              const Divider(height: 10),
              DropdownButtonFormField<Type>(
                value: widget.model.type,
                style: DefaultTextStyle.of(context).style.copyWith(overflow: TextOverflow.ellipsis),
                decoration: FormDecoration(
                  icon: const Icon(Icons.type_specimen_outlined),
                  labelText: AppLocalizations.of(context)!.text('type'),
                  fillColor: FillColor,
                  filled: true,
                ),
                items: Type.values.map((Type display) {
                  return DropdownMenuItem<Type>(
                      value: display,
                      child: Text(AppLocalizations.of(context)!.text(display.toString().toLowerCase())));
                }).toList(),
                onChanged: (value) => widget.model.type = value,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value == null) {
                    return AppLocalizations.of(context)!.text('validator_field_required');
                  }
                  return null;
                }
              ),
              const Divider(height: 10),
              TextInputField(
                context: context,
                initialValue: widget.model.notes,
                title: AppLocalizations.of(context)!.text('notes'),
                onChanged: (locale, value) {
                  LocalizedText text =  widget.model.notes is LocalizedText ? widget.model.notes : LocalizedText();
                  text.add(locale, value);
                  widget.model.notes = text.size() > 0 ? text : value;
                },
              ),
            ]
          ),
        )
      )
    );
  }
}

