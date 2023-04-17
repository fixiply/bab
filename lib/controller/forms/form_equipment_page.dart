import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Internal package
import 'package:bb/helpers/device_helper.dart';
import 'package:bb/models/equipment_model.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/constants.dart' as constants;
import 'package:bb/utils/constants.dart';
import 'package:bb/utils/database.dart';
import 'package:bb/widgets/custom_menu_button.dart';
import 'package:bb/widgets/dialogs/confirm_dialog.dart';
import 'package:bb/widgets/form_decoration.dart';
import 'package:bb/widgets/forms/image_field.dart';

// External package
import 'package:markdown_editable_textinput/format_markdown.dart';
import 'package:markdown_editable_textinput/markdown_text_input.dart';

class FormEquipmentPage extends StatefulWidget {
  final EquipmentModel model;
  final Equipment? equipment;
  final String? title;
  FormEquipmentPage(this.model, this.equipment, {this.title});
  _FormEquipmentPageState createState() => new _FormEquipmentPageState();
}

class _FormEquipmentPageState extends State<FormEquipmentPage> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _modified = false;

  TextEditingController _volumeController = TextEditingController();
  TextEditingController _sizeController = TextEditingController();
  TextEditingController _lostController = TextEditingController();

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
        title: Text(widget.title ?? AppLocalizations.of(context)!.text('equipment')),
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
              TextFormField(
                initialValue: widget.model.name,
                onChanged: (text) => setState(() {
                  widget.model.name = text;
                }),
                decoration: FormDecoration(
                  icon: const Icon(Icons.title),
                  labelText: AppLocalizations.of(context)!.text('name'),
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
              TextFormField(
                // key: UniqueKey(),
                // initialValue: AppLocalizations.of(context)!.volumeFormat(widget.model.volume, symbol: false) ?? '',
                controller:  _volumeController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) {
                  widget.model.volume = AppLocalizations.of(context)!.volume(AppLocalizations.of(context)!.decimal(value));
                  _calculate();
                },
                decoration: FormDecoration(
                  icon: const Icon(Icons.waves_outlined),
                  labelText: AppLocalizations.of(context)!.text('tank_volume'),
                  suffixText: AppLocalizations.of(context)!.liquidUnit.toLowerCase(),
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
              if (widget.equipment == Equipment.tank) Divider(height: 10),
              if (widget.equipment == Equipment.tank) TextFormField(
                // key: UniqueKey(),
                // initialValue: AppLocalizations.of(context)!.volumeFormat(widget.model.volume, symbol: false) ?? '',
                controller:  _sizeController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) {
                  widget.model.mash_volume = AppLocalizations.of(context)!.volume(AppLocalizations.of(context)!.decimal(value));
                  _calculate();
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
              if (widget.equipment == Equipment.tank) Divider(height: 10),
              if (widget.equipment == Equipment.tank) TextFormField(
                initialValue:  AppLocalizations.of(context)!.numberFormat(widget.model.efficiency) ?? '',
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) {
                  widget.model.efficiency = AppLocalizations.of(context)!.decimal(value);
                  _calculate();
                },
                decoration: FormDecoration(
                    icon: const Icon(Icons.propane_tank_outlined),
                    labelText: AppLocalizations.of(context)!.text('mash_efficiency'),
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
              if (widget.equipment == Equipment.tank) Divider(height: 10),
              if (widget.equipment == Equipment.tank) TextFormField(
                initialValue:  AppLocalizations.of(context)!.numberFormat(widget.model.absorption) ?? '',
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) {
                  widget.model.absorption = AppLocalizations.of(context)!.decimal(value);
                  _calculate();
                },
                decoration: FormDecoration(
                    icon: const Icon(Icons.propane_tank_outlined),
                    labelText: AppLocalizations.of(context)!.text('absorption_grains'),
                    suffixText: '%',
                    border: InputBorder.none,
                    fillColor: FillColor, filled: true
                )
              ),
              if (widget.equipment == Equipment.tank) Divider(height: 10),
              if (widget.equipment == Equipment.tank) TextFormField(
                controller:  _lostController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) {
                  widget.model.lost_volume = AppLocalizations.of(context)!.decimal(value);
                  _calculate();
                },
                decoration: FormDecoration(
                  icon: const Icon(Icons.propane_tank_outlined),
                  labelText: AppLocalizations.of(context)!.text('lost_volume'),
                  suffixText: AppLocalizations.of(context)!.liquidUnit.toLowerCase(),
                  border: InputBorder.none,
                  fillColor: FillColor, filled: true
                )
              ),
              if (widget.equipment == Equipment.tank) Divider(height: 10),
              if (widget.equipment == Equipment.tank) TextFormField(
                initialValue:  AppLocalizations.of(context)!.numberFormat(widget.model.boil_loss) ?? '',
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) {
                  widget.model.boil_loss = AppLocalizations.of(context)!.decimal(value);
                  _calculate();
                },
                decoration: FormDecoration(
                    icon: const Icon(Icons.propane_tank_outlined),
                    labelText: AppLocalizations.of(context)!.text('boil_loss'),
                    border: InputBorder.none,
                    fillColor: FillColor, filled: true
                )
              ),
              if (widget.equipment == Equipment.tank) Divider(height: 10),
              if (widget.equipment == Equipment.tank) TextFormField(
                initialValue:  AppLocalizations.of(context)!.numberFormat(widget.model.shrinkage) ?? '',
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) {
                  widget.model.shrinkage = AppLocalizations.of(context)!.decimal(value);
                  _calculate();
                },
                decoration: FormDecoration(
                  icon: const Icon(Icons.propane_tank_outlined),
                  labelText: AppLocalizations.of(context)!.text('wort_shrinkage'),
                  border: InputBorder.none,
                  fillColor: FillColor, filled: true
                )
              ),
              Divider(height: 10),
              MarkdownTextInput((String value) => widget.model.notes = value,
                AppLocalizations.of(context)!.localizedText(widget.model.notes),
                label: AppLocalizations.of(context)!.text('notes'),
                maxLines: 10,
                actions: MarkdownType.values,
                // controller: _controller,
                validators: (value) {
                  return null;
                }
              ),
              Divider(height: 10),
              ImageField(
                context: context,
                image: widget.model.image,
                height: null,
                crop: true,
                onChanged: (images) => widget.model.image = images
              ),
            ]
          ),
        )
      )
    );
  }

  _initialize() async {
    bool modified = _modified;
    _volumeController.text = AppLocalizations.of(context)!.volumeFormat(widget.model.volume, symbol: false) ?? '';
    _sizeController.text = AppLocalizations.of(context)!.volumeFormat(widget.model.mash_volume, symbol: false) ?? '';
    _lostController.text = AppLocalizations.of(context)!.volumeFormat(widget.model.lost_volume, symbol: false) ?? '';
    _modified = modified ? true : false;
  }

  _calculate() async {

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

