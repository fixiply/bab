import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Internal package
import 'package:bb/helpers/device_helper.dart';
import 'package:bb/models/fermentable_model.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/utils/database.dart';
import 'package:bb/utils/localized_text.dart';
import 'package:bb/widgets/dialogs/confirm_dialog.dart';
import 'package:bb/widgets/form_decoration.dart';
import 'package:bb/widgets/forms/localized_text_field.dart';
import 'package:bb/widgets/forms/text_input_field.dart';
import 'package:bb/widgets/custom_menu_button.dart';

class FormFermentablePage extends StatefulWidget {
  final FermentableModel model;
  FormFermentablePage(this.model);
  _FormFermentablePageState createState() => new _FormFermentablePageState();
}

class _FormFermentablePageState extends State<FormFermentablePage> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _modified = false;

  TextEditingController _ebcController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.text('fermentable')),
        elevation: 0,
        foregroundColor: Theme.of(context).primaryColor,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: DeviceHelper.isDesktop ? Icon(Icons.close) : const BackButtonIcon(),
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
                Database().update(widget.model).then((value) async {
                  Navigator.pop(context, widget.model);
                }).onError((e,s) {
                  _showSnackbar(e.toString());
                });
              }
            } : null
          ),
          if (widget.model.uuid != null) IconButton(
            padding: EdgeInsets.zero,
            tooltip: AppLocalizations.of(context)!.text('remove'),
            icon: const Icon(Icons.delete),
            onPressed: () async {
              // if (await _delete(widget.article)) {
              //   Navigator.pop(context);
              // }
            }
          ),
          CustomMenuButton(
            context: context,
            publish: false,
            units: true,
            filtered: false,
            archived: false,
            onSelected: (value) {
              if (value is Unit) {
                setState(() {
                  AppLocalizations.of(context)!.unit = value;
                });
                _initialize();
              }
            },
          )
        ]
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(15.0),
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
              Divider(height: 10),
              TextFormField(
                initialValue: widget.model.origin ?? '',
                textCapitalization: TextCapitalization.characters,
                onChanged: (value) => widget.model.origin = value,
                decoration: FormDecoration(
                    icon: const Icon(Icons.flag_outlined),
                    labelText: AppLocalizations.of(context)!.text('origin'),
                    border: InputBorder.none,
                    fillColor: FillColor, filled: true
                ),
              ),
              Divider(height: 10),
              DropdownButtonFormField<Type>(
                value: widget.model.type,
                style: TextStyle(overflow: TextOverflow.ellipsis),
                decoration: FormDecoration(
                  icon: const Icon(Icons.grain),
                  labelText: AppLocalizations.of(context)!.text('fermentation'),
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
              Divider(height: 10),
              TextFormField(
                initialValue:  AppLocalizations.of(context)!.numberFormat(widget.model.efficiency) ?? '',
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) => widget.model.efficiency = AppLocalizations.of(context)!.decimal(value),
                decoration: FormDecoration(
                    icon: const Icon(Icons.propane_tank_outlined),
                    labelText: AppLocalizations.of(context)!.text('yield'),
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
              Divider(height: 10),
              TextFormField(
                // initialValue:  AppLocalizations.of(context)!.numberFormat(widget.model.ebc) ?? '',
                controller: _ebcController,
                keyboardType: TextInputType.numberWithOptions(decimal: false),
                onChanged: (value) => widget.model.ebc = AppLocalizations.of(context)!.fromSRM(int.parse(value)),
                decoration: FormDecoration(
                  icon: Text(AppLocalizations.of(context)!.colorUnit, style: TextStyle(color: Colors.black45)),
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
              Divider(height: 10),
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

  _initialize() async {
    bool modified = _modified;
    _ebcController.text = AppLocalizations.of(context)!.colorFormat(widget.model.ebc) ?? '';
    _modified = modified ? true : false;
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
