import 'package:flutter/material.dart';import 'package:flutter/services.dart';
import 'package:flutter/services.dart';

// Internal package
import 'package:bab/helpers/device_helper.dart';
import 'package:bab/models/equipment_model.dart';
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/utils/constants.dart' as constants;
import 'package:bab/utils/constants.dart';
import 'package:bab/utils/database.dart';
import 'package:bab/widgets/custom_menu_button.dart';
import 'package:bab/widgets/dialogs/confirm_dialog.dart';
import 'package:bab/widgets/dialogs/delete_dialog.dart';
import 'package:bab/widgets/form_decoration.dart';
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
          icon: DeviceHelper.isLargeScreen(context) ? const Icon(Icons.close) : const BackButtonIcon(),
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
              if (await DeleteDialog.model(context, widget.model)) {
                Navigator.pop(context);
              }
            }
          ),
          CustomMenuButton(
            context: context,
            publish: false,
            measures: true,
            filtered: false,
            archived: false,
            onSelected: (value) {
              if (value is constants.Measure) {
                // setState(() {
                //   AppLocalizations.of(context)!.measure = value;
                // });
                _initialize();
              }
            },
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
              const Divider(height: 10),
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
                        _calculate();
                      },
                      decoration: FormDecoration(
                        icon: const Icon(Icons.waves_outlined),
                        labelText: AppLocalizations.of(context)!.text('tank_volume'),
                        suffixText: AppLocalizations.of(context)!.liquid.toLowerCase(),
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
                        _calculate();
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
                        _calculate();
                      },
                      decoration: FormDecoration(
                        icon: const Icon(Icons.looks_one_outlined),
                        labelText: AppLocalizations.of(context)!.text('absorption_grains'),
                        suffixText: 'L/Kg',
                        border: InputBorder.none,
                        fillColor: FillColor, filled: true
                      )
                    )
                  ),
                ]
              ),
              if (widget.equipment == Equipment.tank) const Divider(height: 10),
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
                        _calculate();
                      },
                      decoration: FormDecoration(
                        icon: const Icon(Icons.looks_two_outlined),
                        labelText: AppLocalizations.of(context)!.text('lost_volume'),
                        suffixText: AppLocalizations.of(context)!.liquid.toLowerCase(),
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
                        _calculate();
                      },
                      decoration: FormDecoration(
                          icon: const Icon(Icons.looks_3_outlined),
                          labelText: AppLocalizations.of(context)!.text('mash_ratio'),
                          suffixText: 'L/Kg',
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
                        _calculate();
                      },
                      decoration: FormDecoration(
                          icon: const Icon(Icons.looks_4_outlined),
                          labelText: AppLocalizations.of(context)!.text('boil_loss'),
                          suffixText: 'L/HR',
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
                        _calculate();
                      },
                      decoration: FormDecoration(
                        icon: const Icon(Icons.looks_5_outlined),
                        labelText: AppLocalizations.of(context)!.text('wort_shrinkage'),
                        suffixText: '%',
                        border: InputBorder.none,
                        fillColor: FillColor, filled: true
                      )
                    )
                  ),
                ]
              ),
              const Divider(height: 10),
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
                    _calculate();
                  },
                  decoration: FormDecoration(
                    icon: const Icon(Icons.looks_6_outlined),
                    labelText: AppLocalizations.of(context)!.text('head_loss'),
                      suffixText: AppLocalizations.of(context)!.liquid.toLowerCase(),
                    border: InputBorder.none,
                    fillColor: FillColor, filled: true
                  )
                )
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
            duration: const Duration(seconds: 10)
        )
    );
  }
}

