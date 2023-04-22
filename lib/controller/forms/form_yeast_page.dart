import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Internal package
import 'package:bb/helpers/device_helper.dart';
import 'package:bb/models/yeast_model.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/utils/database.dart';
import 'package:bb/utils/localized_text.dart';
import 'package:bb/widgets/dialogs/confirm_dialog.dart';
import 'package:bb/widgets/form_decoration.dart';
import 'package:bb/widgets/forms/localized_text_field.dart';
import 'package:bb/widgets/forms/text_input_field.dart';
import 'package:bb/widgets/custom_menu_button.dart';

class FormYeastPage extends StatefulWidget {
  final YeastModel model;
  FormYeastPage(this.model);
  _FormYeastPageState createState() => new _FormYeastPageState();
}

class _FormYeastPageState extends State<FormYeastPage> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _modified = false;

  TextEditingController _tempminController = TextEditingController();
  TextEditingController _tempmaxController = TextEditingController();

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
        title: Text(AppLocalizations.of(context)!.text('yeast')),
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
                initialValue: widget.model.reference ?? '',
                onChanged: (value) => widget.model.reference = value,
                decoration: FormDecoration(
                  icon: const Icon(Icons.tag),
                  labelText: AppLocalizations.of(context)!.text('reference'),
                  border: InputBorder.none,
                  fillColor: FillColor, filled: true
                ),
              ),
              Divider(height: 10),
              TextFormField(
                initialValue: widget.model.laboratory ?? '',
                onChanged: (value) => widget.model.laboratory = value,
                decoration: FormDecoration(
                  icon: const Icon(Icons.biotech_outlined),
                  labelText: AppLocalizations.of(context)!.text('laboratory'),
                  border: InputBorder.none,
                  fillColor: FillColor, filled: true
                ),
              ),
              Divider(height: 10),
              DropdownButtonFormField<Fermentation>(
                value: widget.model.type,
                style: TextStyle(overflow: TextOverflow.ellipsis),
                decoration: FormDecoration(
                  icon: const Icon(Icons.aspect_ratio),
                  labelText: AppLocalizations.of(context)!.text('fermentation'),
                  fillColor: FillColor,
                  filled: true,
                ),
                items: Fermentation.values.map((Fermentation display) {
                  return DropdownMenuItem<Fermentation>(
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
                initialValue: AppLocalizations.of(context)!.numberFormat(widget.model.cells) ?? '',
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) => widget.model.cells = AppLocalizations.of(context)!.decimal(value),
                decoration: FormDecoration(
                    icon: const Icon(Icons.scatter_plot_outlined),
                    labelText: AppLocalizations.of(context)!.text('cells'),
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
              FormField(
                builder: (FormFieldState<int> state) {
                  return InputDecorator(
                    decoration: FormDecoration(
                      icon: const Icon(Icons.device_thermostat_outlined),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            // initialValue: widget.model.tempmin != null ?  widget.model.tempmin.toString() :  '',
                            controller: _tempminController,
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            onChanged: (value) => widget.model.tempmin = AppLocalizations.of(context)!.decimal(value),
                            decoration: FormDecoration(
                              labelText: 'min',
                              suffixText: AppLocalizations.of(context)!.tempUnit,
                              border: InputBorder.none,
                              suffixIcon: Tooltip(
                                message: 'Température minimum',
                                child: Icon(Icons.help_outline, color: Theme.of(context).primaryColor),
                              ),
                              fillColor: FillColor, filled: true,
                            ),
                          )
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            // initialValue: widget.model.tempmax != null ?  widget.model.tempmax.toString() :  '',
                            controller: _tempmaxController,
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            onChanged: (value) => widget.model.tempmax = AppLocalizations.of(context)!.decimal(value),
                            decoration: FormDecoration(
                              labelText: 'max',
                              suffixText: AppLocalizations.of(context)!.tempUnit,
                              border: InputBorder.none,
                              suffixIcon: Tooltip(
                                message:  'Température maximale',
                                child: Icon(Icons.help_outline, color: Theme.of(context).primaryColor),
                              ),
                              fillColor: FillColor, filled: true,
                            ),
                          )
                        ),
                      ],
                    )
                  );
                }
              ),
              Divider(height: 10),
              FormField(
                builder: (FormFieldState<int> state) {
                  return InputDecorator(
                    decoration: FormDecoration(
                      icon: const Text('IBU'),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: widget.model.attmin != null ?  widget.model.attmin.toString() :  '',
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            onChanged: (value) => widget.model.attmin = AppLocalizations.of(context)!.decimal(value),
                            decoration: FormDecoration(
                              labelText: 'min',
                              border: InputBorder.none,
                              suffixIcon: Tooltip(
                                message: 'Atténuation minimum',
                                child: Icon(Icons.help_outline, color: Theme.of(context).primaryColor),
                              ),
                              fillColor: FillColor, filled: true,
                            ),
                          )
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            initialValue: widget.model.attmax != null ?  widget.model.attmax.toString() :  '',
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            onChanged: (value) => widget.model.attmax = AppLocalizations.of(context)!.decimal(value),
                            decoration: FormDecoration(
                              labelText: 'max',
                              border: InputBorder.none,
                              suffixIcon: Tooltip(
                                message:  'Atténuation maximale',
                                child: Icon(Icons.help_outline, color: Theme.of(context).primaryColor),
                              ),
                              fillColor: FillColor, filled: true,
                            ),
                          )
                        ),
                      ],
                    )
                  );
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
    _tempminController.text = AppLocalizations.of(context)!.colorFormat(widget.model.tempmin) ?? '';
    _tempmaxController.text = AppLocalizations.of(context)!.colorFormat(widget.model.tempmax) ?? '';
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

