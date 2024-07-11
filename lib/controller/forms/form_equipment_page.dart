import 'package:bab/widgets/forms/switch_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Internal package
import 'package:bab/helpers/device_helper.dart';
import 'package:bab/models/equipment_model.dart';
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/utils/constants.dart' as constants;
import 'package:bab/utils/constants.dart';
import 'package:bab/utils/database.dart';
import 'package:bab/widgets/custom_menu_anchor.dart';
import 'package:bab/widgets/custom_state.dart';
import 'package:bab/widgets/dialogs/confirm_dialog.dart';
import 'package:bab/widgets/dialogs/delete_dialog.dart';
import 'package:bab/widgets/form_decoration.dart';
import 'package:bab/widgets/forms/bluetooth_field.dart';
import 'package:bab/widgets/forms/image_field.dart';

// External package
import 'package:markdown_editable_textinput/format_markdown.dart';
import 'package:markdown_editable_textinput/markdown_text_input.dart';

class FormEquipmentPage extends StatefulWidget {
  final EquipmentModel model;
  final Equipment? equipment;
  final String? title;
  FormEquipmentPage(this.model, this.equipment, {this.title});

  @override
  _FormEquipmentPageState createState() => _FormEquipmentPageState();
}

class _FormEquipmentPageState extends CustomState<FormEquipmentPage> {
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
            tooltip: AppLocalizations.of(context)!.text(_modified == true || widget.model.uuid == null ? 'save' : 'duplicate'),
            icon: Icon(_modified == true || widget.model.uuid == null ? Icons.save : Icons.copy),
            onPressed: () {
              if (_modified == true || widget.model.uuid == null) {
                if (_formKey.currentState!.validate()) {
                  Database().update(widget.model, context: context, updateLogs: !currentUser!.isAdmin()).then((value) async {
                    Navigator.pop(context, widget.model);
                  }).onError((e, s) {
                    showSnackbar(e.toString());
                  });
                }
              } else {
                EquipmentModel model = widget.model.copy();
                model.uuid = null;
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return FormEquipmentPage(model, model.type);
                })).then((value) {
                  Navigator.pop(context);
                });
              }
            }
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
            showMeasures: true,
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
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
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
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      // key: UniqueKey(),
                      // initialValue: AppLocalizations.of(context)!.volumeFormat(widget.model.volume, symbol: false) ?? '',
                      controller:  _volumeController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
                      ],
                      onChanged: (value) {
                        widget.model.volume = AppLocalizations.of(context)!.volume(AppLocalizations.of(context)!.decimal(value));
                      },
                      decoration: FormDecoration(
                        icon: const Icon(Icons.waves_outlined),
                        labelText: AppLocalizations.of(context)!.text('boil_volume'),
                        suffixText: AppLocalizations.of(context)!.liquid.toLowerCase(),
                        suffixIcon: Tooltip(
                          message: AppLocalizations.of(context)!.text('total_volume_boil'),
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
                    )
                  ),
                  if (widget.equipment == Equipment.tank) const SizedBox(width: 12),
                  if (widget.equipment == Equipment.tank) Expanded(
                    child: TextFormField(
                    // key: UniqueKey(),
                    // initialValue: AppLocalizations.of(context)!.volumeFormat(widget.model.volume, symbol: false) ?? '',
                      controller:  _sizeController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
                      ],
                      onChanged: (value) {
                        widget.model.mash_volume = AppLocalizations.of(context)!.volume(AppLocalizations.of(context)!.decimal(value));
                      },
                      decoration: FormDecoration(
                        icon: const Icon(Icons.waves_outlined),
                        labelText: AppLocalizations.of(context)!.text('mash_volume'),
                        suffixText: AppLocalizations.of(context)!.liquid.toLowerCase(),
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
                    )
                  ),
                ]
              ),
              if (widget.equipment == Equipment.tank) const Divider(height: 10),
              if (widget.equipment == Equipment.tank) Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(AppLocalizations.of(context)!.text('mash'), style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w600, fontSize: 16.0))
              ),
              if (widget.equipment == Equipment.tank) Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue:  AppLocalizations.of(context)!.numberFormat(widget.model.efficiency) ?? '',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
                      ],
                      onChanged: (value) {
                        widget.model.efficiency = AppLocalizations.of(context)!.decimal(value);
                      },
                      decoration: FormDecoration(
                          icon: _icon('1'),
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
                    )
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      initialValue:  AppLocalizations.of(context)!.numberFormat(widget.model.absorption) ?? '',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
                      ],
                      onChanged: (value) {
                        widget.model.absorption = AppLocalizations.of(context)!.decimal(value);
                      },
                      decoration: FormDecoration(
                        icon: _icon('2'),
                        labelText: AppLocalizations.of(context)!.text('absorption_grains'),
                        suffixText: 'L/Kg',
                        suffixIcon: Tooltip(
                          message: AppLocalizations.of(context)!.text('volume_absorption_grains'),
                          child: Icon(Icons.help_outline, color: Theme.of(context).primaryColor),
                        ),
                        border: InputBorder.none,
                        fillColor: FillColor, filled: true
                      )
                    )
                  ),
                ]
              ),
              if (widget.equipment == Equipment.tank) const SizedBox(height: 10),
              if (widget.equipment == Equipment.tank) Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller:  _lostController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
                      ],
                      onChanged: (value) {
                        widget.model.lost_volume = AppLocalizations.of(context)!.decimal(value);
                      },
                      decoration: FormDecoration(
                          icon: _icon('3'),
                        labelText: AppLocalizations.of(context)!.text('lost_volume'),
                        suffixText: AppLocalizations.of(context)!.liquid.toLowerCase(),
                        suffixIcon: Tooltip(
                          message: AppLocalizations.of(context)!.text('lost_volume_mash'),
                          child: Icon(Icons.help_outline, color: Theme.of(context).primaryColor),
                        ),
                        border: InputBorder.none,
                        fillColor: FillColor, filled: true
                      )
                    )
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      initialValue:  AppLocalizations.of(context)!.numberFormat(widget.model.mash_ratio) ?? '',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
                      ],
                      onChanged: (value) {
                        widget.model.mash_ratio = AppLocalizations.of(context)!.decimal(value);
                      },
                      decoration: FormDecoration(
                          icon: _icon('4'),
                          labelText: AppLocalizations.of(context)!.text('mash_ratio'),
                          suffixText: 'L/Kg',
                          suffixIcon: Tooltip(
                            message: AppLocalizations.of(context)!.text('ratio_mash_tank'),
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
                    )
                  ),
                ]
              ),
              if (widget.equipment == Equipment.tank) const Divider(height: 10),
              if (widget.equipment == Equipment.tank) Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(AppLocalizations.of(context)!.text('boiling'), style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w600, fontSize: 16.0))
              ),
              if (widget.equipment == Equipment.tank) Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue:  AppLocalizations.of(context)!.numberFormat(widget.model.boil_loss) ?? '',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
                      ],
                      onChanged: (value) {
                        widget.model.boil_loss = AppLocalizations.of(context)!.decimal(value);
                      },
                      decoration: FormDecoration(
                          icon: _icon('5'),
                          labelText: AppLocalizations.of(context)!.text('boil_loss'),
                          suffixText: 'L/HR',
                          suffixIcon: Tooltip(
                            message: AppLocalizations.of(context)!.text('volume_boil_loss'),
                            child: Icon(Icons.help_outline, color: Theme.of(context).primaryColor),
                          ),
                          border: InputBorder.none,
                          fillColor: FillColor, filled: true
                      )
                    )
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      initialValue:  AppLocalizations.of(context)!.numberFormat(widget.model.shrinkage) ?? '',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
                      ],
                      onChanged: (value) {
                        widget.model.shrinkage = AppLocalizations.of(context)!.decimal(value);
                      },
                      decoration: FormDecoration(
                        icon: _icon('6'),
                        labelText: AppLocalizations.of(context)!.text('wort_shrinkage'),
                        suffixText: '%',
                        border: InputBorder.none,
                        fillColor: FillColor, filled: true
                      )
                    )
                  ),
                ]
              ),
              const SizedBox(height: 10),
              if (widget.equipment == Equipment.tank) SizedBox(
                width: (MediaQuery.of(context).size.width / 2) - (DeviceHelper.isDesktop ? 170 : 50),
                child: TextFormField(
                  initialValue:  AppLocalizations.of(context)!.numberFormat(widget.model.head_loss) ?? '',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
                  ],
                  onChanged: (value) {
                    widget.model.head_loss = AppLocalizations.of(context)!.decimal(value);
                  },
                  decoration: FormDecoration(
                      icon: _icon('7'),
                    labelText: AppLocalizations.of(context)!.text('head_loss'),
                    suffixText: AppLocalizations.of(context)!.liquid.toLowerCase(),
                    suffixIcon: Tooltip(
                      message: AppLocalizations.of(context)!.text('volume_head_loss'),
                      child: Icon(Icons.help_outline, color: Theme.of(context).primaryColor),
                    ),
                    border: InputBorder.none,
                    fillColor: FillColor, filled: true
                  )
                )
              ),
              const Divider(height: 10),
              SwitchField(
                context: context,
                value: widget.model.bluetooth ?? false,
                icon: const Icon(Icons.bluetooth),
                hintText: 'Bluetooth',
                onChanged: (value) => setState(() {
                  widget.model.bluetooth = value;
                })
              ),
              if (widget.model.bluetooth == true) BluetoothField(
                context: context,
                data: widget.model.controller,
                onChanged: (value) {
                  widget.model.controller = value;
                },
              ),
              const Divider(height: 10),
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
              const Divider(height: 10),
              ImageField(
                context: context,
                image: widget.model.image,
                height: null,
                crop: true,
                memory: !currentUser!.isAdmin() ? true : false,
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

  Widget _icon(String text) {
    return Container(
      width: 16,
      height: 16,
      alignment: Alignment.center,
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(4.0),
        border: Border.all(width: 1.25),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10.0)),
    );
  }
}

