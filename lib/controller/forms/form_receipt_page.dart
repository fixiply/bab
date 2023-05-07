import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Internal package
import 'package:bb/controller/forms/form_brew_page.dart';
import 'package:bb/helpers/device_helper.dart';
import 'package:bb/models/brew_model.dart';
import 'package:bb/models/fermentable_model.dart';
import 'package:bb/models/hop_model.dart' as hop;
import 'package:bb/models/misc_model.dart';
import 'package:bb/models/receipt_model.dart';
import 'package:bb/models/yeast_model.dart';
import 'package:bb/utils/abv.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/constants.dart' as CS;
import 'package:bb/utils/database.dart';
import 'package:bb/utils/ibu.dart';
import 'package:bb/widgets/custom_menu_button.dart';
import 'package:bb/widgets/custom_slider.dart';
import 'package:bb/widgets/dialogs/confirm_dialog.dart';
import 'package:bb/widgets/dialogs/delete_dialog.dart';
import 'package:bb/widgets/form_decoration.dart';
import 'package:bb/widgets/forms/beer_style_field.dart';
import 'package:bb/widgets/forms/image_field.dart';
import 'package:bb/widgets/forms/ingredients_field.dart';
import 'package:bb/widgets/forms/localized_text_field.dart';
import 'package:bb/widgets/forms/mash_field.dart';
import 'package:bb/widgets/forms/switch_field.dart';
import 'package:bb/widgets/paints/gradient_slider_thumb_shape.dart';
import 'package:bb/widgets/paints/gradient_slider_track_shape.dart';

// External package
import 'package:intl/intl.dart';
import 'package:markdown_editable_textinput/format_markdown.dart';
import 'package:markdown_editable_textinput/markdown_text_input.dart';

class FormReceiptPage extends StatefulWidget {
  final ReceiptModel model;
  FormReceiptPage(this.model);
  _FormReceiptPageState createState() => new _FormReceiptPageState();
}

class _FormReceiptPageState extends State<FormReceiptPage> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _modified = false;

  TextEditingController _volumeController = TextEditingController();
  TextEditingController _primarydayController = TextEditingController();
  TextEditingController _primarytempController = TextEditingController();
  TextEditingController _secondarydayController = TextEditingController();
  TextEditingController _secondarytempController = TextEditingController();

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
        title: Text(AppLocalizations.of(context)!.text('receipt')),
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
                  }).onError((e, s) {
                    _showSnackbar(e.toString());
                  });
                }
              } else {
                ReceiptModel model = widget.model.copy();
                model.uuid = null;
                model.title = null;
                model.status = CS.Status.disabled;
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return FormReceiptPage(model);
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
            filtered: false,
            archived: false,
            measures: true,
            onSelected: (value) {
              if (value is CS.Measure) {
                setState(() {
                  AppLocalizations.of(context)!.measure = value;
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
              ExpansionTile(
                initiallyExpanded: true,
                backgroundColor: CS.FillColor,
                // childrenPadding: EdgeInsets.all(8.0),
                title: Text(AppLocalizations.of(context)!.text('profile'), style: TextStyle(color: Theme.of(context).primaryColor)),
                children: <Widget>[
                  Row(
                    children: [
                      Expanded(
                        child: CustomSlider(AppLocalizations.of(context)!.text('oiginal_gravity'), widget.model.og ?? 1, 1, 1.2, 0.01,
                          onFormatted: (double value) {
                            return AppLocalizations.of(context)!.gravityFormat(value);
                          },
                        )
                      ),
                      Expanded(
                        child: CustomSlider(AppLocalizations.of(context)!.text('final_gravity'), widget.model.fg ?? 1, 1, 1.2, 0.01,
                          onFormatted: (double value) {
                            return AppLocalizations.of(context)!.gravityFormat(value);
                          },
                        )
                      ),
                      Expanded(
                        child: CustomSlider(AppLocalizations.of(context)!.text('abv'), widget.model.abv ?? 0, 0, MAX_ABV, 0.1,
                          onFormatted: (double value) {
                            return AppLocalizations.of(context)!.numberFormat(value, pattern: "#0.#'%'");
                          },
                        )
                      )
                    ]
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('${AppLocalizations.of(context)!.colorUnit} - ${AppLocalizations.of(context)!.text('color')}', style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12.0)),
                            SliderTheme(
                              data: SliderThemeData(
                                trackHeight: 5,
                                trackShape: GradientRectSliderTrackShape(darkenInactive: false),
                                thumbColor: Theme.of(context).primaryColor,
                                overlayColor: Theme.of(context).primaryColor.withOpacity(.1),
                                thumbShape: GradientSliderThumbShape(ringColor: Theme.of(context).primaryColor, fillColor: CS.FillColor, selectedValue: 10, max: AppLocalizations.of(context)!.maxColor),
                              ),
                              child: Slider(
                                label: '${widget.model.ebc}',
                                value: AppLocalizations.of(context)!.color(widget.model.ebc)?.toDouble() ?? 0,
                                min: 0,
                                max: AppLocalizations.of(context)!.maxColor.toDouble(),
                                divisions: AppLocalizations.of(context)!.maxColor,
                                onChanged: (values) {
                                },
                              )
                            )
                          ]
                        )
                      ),
                      Expanded(
                        child: CustomSlider(AppLocalizations.of(context)!.text('ibu'), widget.model.ibu ?? 0, 0, MAX_IBU, 0.1,
                          onFormatted: (double value) {
                            return AppLocalizations.of(context)!.numberFormat(value);
                          },
                        )
                      ),
                    ]
                  )
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: LocalizedTextField(
                      context: context,
                      initialValue: widget.model.title,
                      textCapitalization: TextCapitalization.sentences,
                      onChanged: (value) => widget.model.title = value,
                      decoration: FormDecoration(
                        icon: const Icon(Icons.title),
                        labelText: AppLocalizations.of(context)!.text('title'),
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
                  ),
                  SizedBox(width: 12),
                  SizedBox(
                    width: 140,
                    child: SwitchField(
                      context: context,
                      value: widget.model.shared!,
                      icon: null,
                      hintText: AppLocalizations.of(context)!.text('public'),
                      onChanged: (value) => widget.model.shared = value,
                    )
                  )
                ]
              ),
              Divider(height: 10),
              Row(
                children: [
                  Expanded(
                    child: BeerStyleField(
                      context: context,
                      initialValue: widget.model.style,
                      title: AppLocalizations.of(context)!.text('style'),
                      onChanged: (value) => widget.model.style = value,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return AppLocalizations.of(context)!.text('validator_field_required');
                        }
                        return null;
                      }
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      initialValue:  AppLocalizations.of(context)!.numberFormat(widget.model.efficiency) ?? '',
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      onChanged: (value) {
                        widget.model.efficiency = AppLocalizations.of(context)!.decimal(value);
                        _calculate();
                      },
                      decoration: FormDecoration(
                        icon: const Icon(Icons.propane_tank_outlined),
                        labelText: AppLocalizations.of(context)!.text('pasting_efficiency'),
                        suffixText: '%',
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
                    )
                  ),
                ]
              ),
              Divider(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
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
                    )
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      initialValue: AppLocalizations.of(context)!.numberFormat(widget.model.boil) ?? '',
                      keyboardType: TextInputType.numberWithOptions(decimal: false),
                      onChanged: (value) {
                        widget.model.boil = int.parse(value);
                        _calculate();
                      },
                      decoration: FormDecoration(
                        icon: const Icon(Icons.timer_outlined),
                        labelText: AppLocalizations.of(context)!.text('boiling_time'),
                        suffixText: 'minutes',
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
                    )
                  ),
                ]
              ),
              Divider(height: 10),
              IngredientsField(
                context: context,
                ingredient: CS.Ingredient.fermentable,
                receipt: widget.model,
                onChanged: (values) {
                  widget.model.fermentables = values as List<FermentableModel>;
                  _calculate();
                },
              ),
              Divider(height: 10),
              IngredientsField(
                context: context,
                ingredient: CS.Ingredient.hops,
                receipt: widget.model,
                onChanged: (values) {
                  widget.model.hops = values as List<hop.HopModel>;
                  _calculate();
                },
              ),
              Divider(height: 10),
              IngredientsField(
                context: context,
                ingredient: CS.Ingredient.yeast,
                receipt: widget.model,
                onChanged: (values) {
                  widget.model.yeasts = values as List<YeastModel>;
                  _calculate();
                },
              ),
              Divider(height: 10),
              IngredientsField(
                context: context,
                ingredient: CS.Ingredient.misc,
                receipt: widget.model,
                onChanged: (values) => widget.model.miscellaneous = values as List<MiscModel>
              ),
              Divider(height: 10),
              MashField(
                context: context,
                data: widget.model.mash,
                receipt: widget.model,
                onChanged: (values) => widget.model.mash = values,
              ),
              Divider(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      // initialValue: AppLocalizations.of(context)!.numberFormat(widget.model.primaryday) ?? '',
                      controller: _primarydayController,
                      keyboardType: TextInputType.numberWithOptions(decimal: false),
                      onChanged: (value) {
                        widget.model.primaryday = int.parse(value);
                      },
                      decoration: FormDecoration(
                          icon: const Icon(Icons.looks_one_outlined),
                          labelText: AppLocalizations.of(context)!.text('primary_fermentation'),
                          suffixText: AppLocalizations.of(context)!.text('days').toLowerCase(),
                          border: InputBorder.none,
                          fillColor: CS.FillColor, filled: true
                      ),
                    )
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      // initialValue:  AppLocalizations.of(context)!.numberFormat(widget.model.primarytemp) ?? '',
                      controller: _primarytempController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      onChanged: (value) {
                        widget.model.primarytemp = AppLocalizations.of(context)!.decimal(value);
                      },
                      decoration: FormDecoration(
                          icon: const Icon(Icons.device_thermostat_outlined),
                          labelText: AppLocalizations.of(context)!.text('temperature'),
                          suffixText: AppLocalizations.of(context)!.tempMeasure,
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
                      // initialValue: AppLocalizations.of(context)!.numberFormat(widget.model.secondaryday) ?? '',
                      controller: _secondarydayController,
                      keyboardType: TextInputType.numberWithOptions(decimal: false),
                      onChanged: (value) {
                        widget.model.secondaryday = int.parse(value);
                      },
                      decoration: FormDecoration(
                        icon: const Icon(Icons.looks_two_outlined),
                        labelText: AppLocalizations.of(context)!.text('secondary_fermentation'),
                        suffixText: AppLocalizations.of(context)!.text('days').toLowerCase(),
                        border: InputBorder.none,
                        fillColor: CS.FillColor, filled: true
                      ),
                    )
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      // initialValue:  AppLocalizations.of(context)!.numberFormat(widget.model.secondarytemp) ?? '',
                      controller: _secondarytempController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      onChanged: (value) {
                        widget.model.secondarytemp = AppLocalizations.of(context)!.decimal(value);
                      },
                      decoration: FormDecoration(
                        icon: const Icon(Icons.device_thermostat_outlined),
                        labelText: AppLocalizations.of(context)!.text('temperature'),
                        suffixText: AppLocalizations.of(context)!.tempMeasure,
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
                      initialValue: AppLocalizations.of(context)!.numberFormat(widget.model.tertiaryday) ?? '',
                      keyboardType: TextInputType.numberWithOptions(decimal: false),
                      onChanged: (value) {
                        widget.model.tertiaryday = int.parse(value);
                      },
                      decoration: FormDecoration(
                          icon: const Icon(Icons.looks_3_outlined),
                          labelText: AppLocalizations.of(context)!.text('tertiary_fermentation'),
                          suffixText: AppLocalizations.of(context)!.text('days').toLowerCase(),
                          border: InputBorder.none,
                          fillColor: CS.FillColor, filled: true
                      ),
                    )
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      initialValue:  AppLocalizations.of(context)!.numberFormat(widget.model.tertiarytemp) ?? '',
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      onChanged: (value) {
                        widget.model.tertiarytemp = AppLocalizations.of(context)!.decimal(value);
                      },
                      decoration: FormDecoration(
                          icon: const Icon(Icons.device_thermostat_outlined),
                          labelText: AppLocalizations.of(context)!.text('temperature'),
                          suffixText: AppLocalizations.of(context)!.tempMeasure,
                          border: InputBorder.none,
                          fillColor: CS.FillColor, filled: true
                      ),
                    )
                  ),
                ]
              ),
              Divider(height: 10),
              MarkdownTextInput((String value) => widget.model.text = value,
                AppLocalizations.of(context)!.localizedText(widget.model.text),
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
      ),
      floatingActionButton: Visibility(
        visible: widget.model.uuid != null && _modified == false,
        child:  FloatingActionButton(
          onPressed: _new,
          backgroundColor: Theme.of(context).primaryColor,
          tooltip: AppLocalizations.of(context)!.text('new_brew'),
          child: const Icon(Icons.add)
        )
      )
    );
  }

  _initialize() async {
    bool modified = _modified;
    _volumeController.text = AppLocalizations.of(context)!.volumeFormat(widget.model.volume, symbol: false) ?? '';
    _primarydayController.text = AppLocalizations.of(context)!.numberFormat(widget.model.primaryday) ?? '';
    _primarytempController.text = AppLocalizations.of(context)!.numberFormat(widget.model.primarytemp) ?? '';
    _secondarydayController.text = AppLocalizations.of(context)!.numberFormat(widget.model.secondaryday) ?? '';
    _secondarytempController.text = AppLocalizations.of(context)!.numberFormat(widget.model.secondarytemp) ?? '';
    _modified = modified ? true : false;
  }

  _calculate() async {
    await widget.model.calculate();
    _primarydayController.text = widget.model.primaryday != null ? AppLocalizations.of(context)!.numberFormat(widget.model.primaryday) ?? '' : '';
    _primarytempController.text = widget.model.primarytemp != null ? AppLocalizations.of(context)!.numberFormat(widget.model.primarytemp) ?? '' : '';
    _secondarydayController.text = widget.model.secondaryday != null ? AppLocalizations.of(context)!.numberFormat(widget.model.secondaryday) ?? '' : '';
    _secondarytempController.text = widget.model.secondarytemp != null ? AppLocalizations.of(context)!.numberFormat(widget.model.secondarytemp) ?? '' : '';
  }

  _new() async {
    BrewModel newModel = BrewModel(
        receipt: widget.model,
        volume: widget.model.volume
    );
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return FormBrewPage(newModel);
    }));
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

