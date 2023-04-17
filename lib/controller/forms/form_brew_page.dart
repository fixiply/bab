import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Internal package
import 'package:bb/helpers/device_helper.dart';
import 'package:bb/models/brew_model.dart';
import 'package:bb/models/equipment_model.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/constants.dart' as constants;
import 'package:bb/utils/constants.dart';
import 'package:bb/utils/database.dart';
import 'package:bb/utils/localized_text.dart';
import 'package:bb/widgets/custom_menu_button.dart';
import 'package:bb/widgets/dialogs/confirm_dialog.dart';
import 'package:bb/widgets/form_decoration.dart';
import 'package:bb/widgets/forms/equipment_field.dart';
import 'package:bb/widgets/forms/receipt_field.dart';
import 'package:bb/widgets/forms/switch_field.dart';
import 'package:bb/widgets/forms/text_input_field.dart';

class FormBrewPage extends StatefulWidget {
  final BrewModel model;
  FormBrewPage(this.model);
  _FormBrewPageState createState() => new _FormBrewPageState();
}

class _FormBrewPageState extends State<FormBrewPage> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _modified = false;
  bool _autogenerate = true;

  TextEditingController _identifierController = TextEditingController();
  TextEditingController _volumeController = TextEditingController();

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
        title: Text(AppLocalizations.of(context)!.text('brew')),
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
              if (value is constants.Unit) {
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
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      // initialValue: widget.model.identifier,
                      controller:  _identifierController,
                      onChanged: (text) => setState(() {
                        widget.model.identifier = text;
                      }),
                      readOnly: _autogenerate == true,
                      decoration: FormDecoration(
                        icon: const Icon(Icons.bookmark_outline_outlined),
                        labelText: AppLocalizations.of(context)!.text('identifier'),
                        border: InputBorder.none,
                        fillColor: constants.FillColor, filled: true
                      ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if (!_autogenerate && value!.isEmpty) {
                          return AppLocalizations.of(context)!.text('validator_field_required');
                        }
                        return null;
                      }
                    ),
                  ),
                  SizedBox(width: 12),
                  SizedBox(
                    width: 140,
                    child: SwitchField(
                      context: context,
                      value: _autogenerate,
                      icon: null,
                      hintText: AppLocalizations.of(context)!.text('auto_generated'),
                      onChanged: (value) => setState(() {
                        _autogenerate = value;
                        _generate();
                      })
                    )
                  )
                ]
              ),
              Divider(height: 10),
              ReceiptField(
                context: context,
                initialValue: widget.model.receipt,
                title: AppLocalizations.of(context)!.text('receipt'),
                onChanged: (value) => widget.model.receipt = value
              ),
              Divider(height: 10),
              EquipmentField(
                context: context,
                type: Equipment.tank,
                icon: Icon(Icons.delete_outline),
                initialValue: widget.model.tank,
                title: AppLocalizations.of(context)!.text('equipment'),
                onChanged: (value) => widget.model.tank = value,
                validator: (value) {
                  if (value == null) {
                    return AppLocalizations.of(context)!.text('validator_field_required');
                  }
                  return null;
                }
              ),
              Divider(height: 10),
              EquipmentField(
                context: context,
                type: Equipment.fermenter,
                icon: Icon(Icons.propane_tank_outlined),
                initialValue: widget.model.fermenter,
                title: AppLocalizations.of(context)!.text('fermenter'),
                onChanged: (value) => widget.model.fermenter = value
              ),
              Divider(height: 10),
              TextFormField(
                // key: UniqueKey(),
                // initialValue: AppLocalizations.of(context)!.volumeFormat(widget.model.volume, symbol: false) ?? '',
                controller:  _volumeController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) {
                  widget.model.volume = AppLocalizations.of(context)!.volume(AppLocalizations.of(context)!.decimal(value));
                },
                decoration: FormDecoration(
                  icon: const Icon(Icons.waves_outlined),
                  labelText: AppLocalizations.of(context)!.text('mash_volume'),
                  suffixText: AppLocalizations.of(context)!.liquidUnit.toLowerCase(),
                  suffixIcon: Tooltip(
                    message: AppLocalizations.of(context)!.text('final_volume'),
                    child: Icon(Icons.help_outline, color: Theme.of(context).primaryColor),
                  ),
                  border: InputBorder.none,
                  fillColor: constants.FillColor, filled: true
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
                initialValue: AppLocalizations.of(context)!.numberFormat(widget.model.ph) ?? '',
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) => widget.model.ph = AppLocalizations.of(context)!.decimal(value),
                decoration: FormDecoration(
                  icon: const Icon(Icons.scatter_plot_outlined),
                  labelText: 'pH',
                  border: InputBorder.none,
                  fillColor: constants.FillColor, filled: true
                ),
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

  _generate() async {
    if (_autogenerate && widget.model.uuid == null) {
      var newDate = DateTime.now();
      List<BrewModel> brews = await Database().getBrews(user: currentUser!.uuid, ordered: true);
      widget.model.identifier = '${newDate.year.toString().substring(2)}${AppLocalizations.of(context)!.numberFormat(brews.length + 1, newPattern: "000")}';
      _identifierController.text = widget.model.identifier!;
    }
  }

  _initialize() async {
    bool modified = _modified;
    _volumeController.text = AppLocalizations.of(context)!.volumeFormat(widget.model.volume, symbol: false) ?? '';
    if (widget.model.identifier != null) _identifierController.text = widget.model.identifier!;
    await _generate();
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

