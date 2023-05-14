import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Internal package
import 'package:bb/helpers/device_helper.dart';
import 'package:bb/models/brew_model.dart';
import 'package:bb/models/equipment_model.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/constants.dart' as CS;
import 'package:bb/utils/database.dart';
import 'package:bb/utils/localized_text.dart';
import 'package:bb/widgets/custom_menu_button.dart';
import 'package:bb/widgets/dialogs/confirm_dialog.dart';
import 'package:bb/widgets/dialogs/delete_dialog.dart';
import 'package:bb/widgets/form_decoration.dart';
import 'package:bb/widgets/forms/color_field.dart';
import 'package:bb/widgets/forms/datetime_field.dart';
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
          icon: DeviceHelper.isLargeScreen(context) ? Icon(Icons.close) : const BackButtonIcon(),
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
            tooltip: AppLocalizations.of(context)!.text('calculate'),
            icon: const Icon(Icons.calculate_outlined),
            onPressed: () {
              _calculate();
            }
          ),
          IconButton(
            padding: EdgeInsets.zero,
            tooltip: AppLocalizations.of(context)!.text(_modified == true || widget.model.uuid == null ? 'save' : 'duplicate'),
            icon: Icon(_modified == true || widget.model.uuid == null ? Icons.save : Icons.copy),
            onPressed: () {
              if (_modified == true || widget.model.uuid == null) {
                if (_formKey.currentState!.validate()) {
                  Database().update(widget.model).then((value) async {
                    Navigator.pop(context, widget.model);
                  }).onError((e,s) {
                    _showSnackbar(e.toString());
                  });
                }
              } else {
                BrewModel model = widget.model.copy();
                model.uuid = null;
                model.status = Status.pending;
                model.started_at = null;
                model.reference = null;
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return FormBrewPage(model);
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
          CustomMenuButton(
            context: context,
            publish: false,
            measures: true,
            filtered: false,
            archived: false,
            onSelected: (value) {
              if (value is CS.Measure) {
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
              ExpansionTile(
                initiallyExpanded: true,
                backgroundColor: CS.FillColor,
                // childrenPadding: EdgeInsets.all(8.0),
                title: Text(AppLocalizations.of(context)!.text('profile'), style: TextStyle(color: Theme.of(context).primaryColor)),
                children: <Widget>[
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: RichText(
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                              style: DefaultTextStyle.of(context).style,
                              children: <TextSpan>[
                                TextSpan(text: '${AppLocalizations.of(context)!.text('mash_water')} : '),
                                if (widget.model.mash_water != null) TextSpan(text: AppLocalizations.of(context)!.litterVolumeFormat(widget.model.mash_water), style: TextStyle(fontWeight: FontWeight.bold)),
                                if (widget.model.mash_water == null) TextSpan(text: '-'),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: RichText(
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                              style: DefaultTextStyle.of(context).style,
                              children: <TextSpan>[
                                TextSpan(text: '${AppLocalizations.of(context)!.text('sparge_water')} : '),
                                if (widget.model.sparge_water != null) TextSpan(text: AppLocalizations.of(context)!.litterVolumeFormat(widget.model.sparge_water), style: TextStyle(fontWeight: FontWeight.bold)),
                                if (widget.model.sparge_water == null) TextSpan(text: '-')
                              ],
                            ),
                          ),
                        ),
                      ),
                    ]
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: RichText(
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                              style: DefaultTextStyle.of(context).style,
                              children: <TextSpan>[
                                TextSpan(text: '${AppLocalizations.of(context)!.text('mash_efficiency')} : '),
                                TextSpan(text: AppLocalizations.of(context)!.percentFormat(0), style: TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: RichText(
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                              style: DefaultTextStyle.of(context).style,
                              children: <TextSpan>[
                                TextSpan(text: '${AppLocalizations.of(context)!.text('volume_alcohol')} : '),
                                TextSpan(text: AppLocalizations.of(context)!.percentFormat(0), style: TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ]
                  )
                ],
              ),
              if (widget.model.status == Status.pending) DateTimeField(
                context: context,
                datetime: widget.model.inserted_at,
                decoration: FormDecoration(
                    icon: const Icon(Icons.event_available),
                    labelText: AppLocalizations.of(context)!.text('date'),
                    fillColor: CS.FillColor, filled: true
                ),
                onChanged: (value) => setState(() {
                  widget.model.inserted_at = value;
                }),
                validator: (value) {
                  if (value!.isEmpty) {
                    return AppLocalizations.of(context)!.text('validator_field_required');
                  }
                  return null;
                }
              ),
              Divider(height: 10),
              Row(
                children: [
                  ColorField(
                    context: context,
                    initialValue: widget.model.color,
                    onChanged: (value) => setState(() {
                      widget.model.color = value;
                    })
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      // initialValue: widget.model.identifier,
                      controller:  _identifierController,
                      onChanged: (text) => setState(() {
                        widget.model.reference = text;
                      }),
                      readOnly: _autogenerate == true,
                      decoration: FormDecoration(
                        icon: const Icon(Icons.tag),
                        labelText: AppLocalizations.of(context)!.text('reference'),
                        border: InputBorder.none,
                        fillColor: CS.FillColor, filled: true
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
                onChanged: (value) {
                  widget.model.tank = value;
                  _calculate();
                },
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
                  fillColor: CS.FillColor, filled: true
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
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: AppLocalizations.of(context)!.numberFormat(widget.model.mash_ph) ?? '',
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      onChanged: (value) => widget.model.mash_ph = AppLocalizations.of(context)!.decimal(value),
                      decoration: FormDecoration(
                        icon: const Icon(Icons.water_drop_outlined),
                        labelText: 'pH ${AppLocalizations.of(context)!.text('mash').toLowerCase()}',
                        border: InputBorder.none,
                        fillColor: CS.FillColor, filled: true
                      ),
                    )
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      initialValue: AppLocalizations.of(context)!.numberFormat(widget.model.sparge_ph) ?? '',
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      onChanged: (value) => widget.model.sparge_ph = AppLocalizations.of(context)!.decimal(value),
                      decoration: FormDecoration(
                        icon:  RotationTransition(
                          turns: AlwaysStoppedAnimation(90 / 360),
                          child: Icon(Icons.air_outlined),
                        ),
                        labelText: 'pH ${AppLocalizations.of(context)!.text('sparge').toLowerCase()}',
                        border: InputBorder.none,
                        fillColor: CS.FillColor, filled: true
                      ),
                    )
                  ),
                ]
              ),
              Divider(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: AppLocalizations.of(context)!.numberFormat(widget.model.og) ?? '',
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      onChanged: (value) {
                        widget.model.og = AppLocalizations.of(context)!.volume(AppLocalizations.of(context)!.decimal(value));
                      },
                      decoration: FormDecoration(
                        icon: const Icon(Icons.first_page_outlined),
                        labelText: AppLocalizations.of(context)!.text('oiginal_gravity'),
                        suffixIcon: Tooltip(
                          message: AppLocalizations.of(context)!.text('oiginal_gravity_tooltip'),
                          child: Icon(Icons.help_outline, color: Theme.of(context).primaryColor),
                        ),
                        border: InputBorder.none,
                        fillColor: CS.FillColor, filled: true
                      ),
                    )
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      initialValue: AppLocalizations.of(context)!.numberFormat(widget.model.fg) ?? '',
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      onChanged: (value) {
                        widget.model.fg = AppLocalizations.of(context)!.volume(AppLocalizations.of(context)!.decimal(value));
                      },
                      decoration: FormDecoration(
                        icon: const Icon(Icons.last_page_outlined),
                        labelText: AppLocalizations.of(context)!.text('final_gravity'),
                        suffixIcon: Tooltip(
                          message: AppLocalizations.of(context)!.text('final_gravity_tooltip'),
                          child: Icon(Icons.help_outline, color: Theme.of(context).primaryColor),
                        ),
                        border: InputBorder.none,
                        fillColor: CS.FillColor, filled: true
                      ),
                    )
                  ),
                ]
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
      List<BrewModel> brews = await Database().getBrews(user: CS.currentUser!.uuid, ordered: true);
      widget.model.reference = '${newDate.year.toString()}${AppLocalizations.of(context)!.numberFormat(brews.length + 1, pattern: "000")}';
      _identifierController.text = widget.model.reference!;
    }
  }

  _initialize() async {
    bool modified = _modified;
    _volumeController.text = AppLocalizations.of(context)!.volumeFormat(widget.model.volume, symbol: false) ?? '';
    if (widget.model.reference != null) _identifierController.text = widget.model.reference!;
    await _generate();
    _modified = modified ? true : false;
  }

  _calculate() async {
    await widget.model.calculate();
    setState(() {
      widget.model.mash_water = widget.model.mash_water;
      widget.model.sparge_water = widget.model.sparge_water;
    });
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

