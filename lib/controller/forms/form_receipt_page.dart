import 'package:bab/widgets/duration_picker.dart';
import 'package:bab/widgets/forms/duration_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Internal package
import 'package:bab/controller/forms/form_brew_page.dart';
import 'package:bab/helpers/device_helper.dart';
import 'package:bab/models/brew_model.dart';
import 'package:bab/models/fermentable_model.dart';
import 'package:bab/models/hop_model.dart' as hm;
import 'package:bab/models/misc_model.dart';
import 'package:bab/models/receipt_model.dart';
import 'package:bab/models/yeast_model.dart';
import 'package:bab/utils/abv.dart';
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/utils/constants.dart' as constants;
import 'package:bab/utils/database.dart';
import 'package:bab/utils/ibu.dart';
import 'package:bab/widgets/animated_action_button.dart';
import 'package:bab/widgets/custom_menu_button.dart';
import 'package:bab/widgets/custom_slider.dart';
import 'package:bab/widgets/dialogs/confirm_dialog.dart';
import 'package:bab/widgets/dialogs/delete_dialog.dart';
import 'package:bab/widgets/form_decoration.dart';
import 'package:bab/widgets/forms/color_field.dart';
import 'package:bab/widgets/forms/beer_style_field.dart';
import 'package:bab/widgets/forms/image_field.dart';
import 'package:bab/widgets/forms/ingredients_field.dart';
import 'package:bab/widgets/forms/localized_text_field.dart';
import 'package:bab/widgets/forms/mash_field.dart';
import 'package:bab/widgets/forms/switch_field.dart';
import 'package:bab/widgets/paints/gradient_slider_thumb_shape.dart';
import 'package:bab/widgets/paints/gradient_slider_track_shape.dart';

// External package
import 'package:markdown_editable_textinput/format_markdown.dart';
import 'package:markdown_editable_textinput/markdown_text_input.dart';

class FormReceiptPage extends StatefulWidget {
  final ReceiptModel model;
  FormReceiptPage(this.model);

  @override
  _FormReceiptPageState createState() => _FormReceiptPageState();
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
                  Database().update(widget.model, context: context).then((value) async {
                    Navigator.pop(context, widget.model);
                  }).onError((e, s) {
                    _showSnackbar(e.toString());
                  });
                }
              } else {
                ReceiptModel model = widget.model.copy();
                model.uuid = null;
                model.title = null;
                model.status = constants.Status.disabled;
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
              if (value is constants.Measure) {
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
              ExpansionTile(
                initiallyExpanded: true,
                backgroundColor: constants.FillColor,
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
                                trackShape: const GradientRectSliderTrackShape(darkenInactive: false),
                                thumbColor: Theme.of(context).primaryColor,
                                overlayColor: Theme.of(context).primaryColor.withOpacity(.1),
                                thumbShape: GradientSliderThumbShape(ringColor: Theme.of(context).primaryColor, fillColor: constants.FillColor, selectedValue: 10, max: AppLocalizations.of(context)!.maxColor),
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
                  ColorField(
                    context: context,
                    initialValue: widget.model.color,
                    onChanged: (value) => setState(() {
                      widget.model.color = value;
                    })
                  ),
                  const SizedBox(width: 12),
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
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 80,
                    child: SwitchField(
                      context: context,
                      value: widget.model.shared!,
                      icon: Tooltip(
                        message: AppLocalizations.of(context)!.text('visibility'),
                        child: Icon(widget.model.shared == true ? Icons.lock_open_outlined : Icons.lock),
                      ),
                      // hintText: AppLocalizations.of(context)!.text('share'),
                      onChanged: (value) => widget.model.shared = value,
                    )
                  )
                ]
              ),
              const Divider(height: 10),
              Row(
                children: [
                  Expanded(
                    child: BeerStyleField(
                      context: context,
                      initialValue: widget.model.style,
                      title: AppLocalizations.of(context)!.text('style'),
                      onChanged: (value) => widget.model.style = value,
                    ),
                  ),
                  const SizedBox(width: 12),
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
                        labelText: AppLocalizations.of(context)!.text('pasting_efficiency'),
                        suffixText: '%',
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
                    )
                  ),
                ]
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
                        labelText: AppLocalizations.of(context)!.text('mash_volume'),
                        suffixText: AppLocalizations.of(context)!.liquid.toLowerCase(),
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
                    )
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DurationField(
                      value: widget.model.boil ?? 0,
                      onChanged: (value) {
                        widget.model.boil = value;
                        _calculate();
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return AppLocalizations.of(context)!.text('validator_field_required');
                        }
                        return null;
                      }
                    ),
                  ),
                ]
              ),
              const Divider(height: 10),
              IngredientsField(
                context: context,
                ingredient: constants.Ingredient.fermentable,
                receipt: widget.model,
                onChanged: (values) {
                  widget.model.fermentables = values as List<FermentableModel>;
                  _calculate();
                },
              ),
              const Divider(height: 10),
              IngredientsField(
                context: context,
                ingredient: constants.Ingredient.hops,
                receipt: widget.model,
                onChanged: (values) {
                  widget.model.hops = values as List<hm.HopModel>;
                  _calculate();
                },
              ),
              const Divider(height: 10),
              IngredientsField(
                context: context,
                ingredient: constants.Ingredient.yeast,
                receipt: widget.model,
                onChanged: (values) {
                  widget.model.yeasts = values as List<YeastModel>;
                  _calculate();
                },
              ),
              const Divider(height: 10),
              IngredientsField(
                context: context,
                ingredient: constants.Ingredient.misc,
                receipt: widget.model,
                onChanged: (values) => widget.model.miscellaneous = values as List<MiscModel>
              ),
              const Divider(height: 10),
              MashField(
                context: context,
                data: widget.model.mash,
                receipt: widget.model,
                onChanged: (values) => widget.model.mash = values,
              ),
              const Divider(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      // initialValue: AppLocalizations.of(context)!.numberFormat(widget.model.primaryday) ?? '',
                      controller: _primarydayController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: false),
                      onChanged: (value) {
                        widget.model.primaryday = int.parse(value);
                      },
                      decoration: FormDecoration(
                          icon: const Icon(Icons.looks_one_outlined),
                          labelText: AppLocalizations.of(context)!.text('primary_fermentation'),
                          suffixText: AppLocalizations.of(context)!.text('days').toLowerCase(),
                          border: InputBorder.none,
                          fillColor: constants.FillColor, filled: true
                      ),
                    )
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      // initialValue:  AppLocalizations.of(context)!.numberFormat(widget.model.primarytemp) ?? '',
                      controller: _primarytempController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
                      ],
                      onChanged: (value) {
                        widget.model.primarytemp = AppLocalizations.of(context)!.decimal(value);
                      },
                      decoration: FormDecoration(
                          icon: const Icon(Icons.device_thermostat_outlined),
                          labelText: AppLocalizations.of(context)!.text('temperature'),
                          suffixText: AppLocalizations.of(context)!.tempMeasure,
                          border: InputBorder.none,
                          fillColor: constants.FillColor, filled: true
                      ),
                    )
                  ),
                ]
              ),
              const Divider(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      // initialValue: AppLocalizations.of(context)!.numberFormat(widget.model.secondaryday) ?? '',
                      controller: _secondarydayController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: false),
                      onChanged: (value) {
                        widget.model.secondaryday = int.parse(value);
                      },
                      decoration: FormDecoration(
                        icon: const Icon(Icons.looks_two_outlined),
                        labelText: AppLocalizations.of(context)!.text('secondary_fermentation'),
                        suffixText: AppLocalizations.of(context)!.text('days').toLowerCase(),
                        border: InputBorder.none,
                        fillColor: constants.FillColor, filled: true
                      ),
                    )
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      // initialValue:  AppLocalizations.of(context)!.numberFormat(widget.model.secondarytemp) ?? '',
                      controller: _secondarytempController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
                      ],
                      onChanged: (value) {
                        widget.model.secondarytemp = AppLocalizations.of(context)!.decimal(value);
                      },
                      decoration: FormDecoration(
                        icon: const Icon(Icons.device_thermostat_outlined),
                        labelText: AppLocalizations.of(context)!.text('temperature'),
                        suffixText: AppLocalizations.of(context)!.tempMeasure,
                        border: InputBorder.none,
                        fillColor: constants.FillColor, filled: true
                      ),
                    )
                  ),
                ]
              ),
              const Divider(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: AppLocalizations.of(context)!.numberFormat(widget.model.tertiaryday) ?? '',
                      keyboardType: const TextInputType.numberWithOptions(decimal: false),
                      onChanged: (value) {
                        widget.model.tertiaryday = int.parse(value);
                      },
                      decoration: FormDecoration(
                          icon: const Icon(Icons.looks_3_outlined),
                          labelText: AppLocalizations.of(context)!.text('tertiary_fermentation'),
                          suffixText: AppLocalizations.of(context)!.text('days').toLowerCase(),
                          border: InputBorder.none,
                          fillColor: constants.FillColor, filled: true
                      ),
                    )
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      initialValue:  AppLocalizations.of(context)!.numberFormat(widget.model.tertiarytemp) ?? '',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
                      ],
                      onChanged: (value) {
                        widget.model.tertiarytemp = AppLocalizations.of(context)!.decimal(value);
                      },
                      decoration: FormDecoration(
                          icon: const Icon(Icons.device_thermostat_outlined),
                          labelText: AppLocalizations.of(context)!.text('temperature'),
                          suffixText: AppLocalizations.of(context)!.tempMeasure,
                          border: InputBorder.none,
                          fillColor: constants.FillColor, filled: true
                      ),
                    )
                  ),
                ]
              ),
              const Divider(height: 10),
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
      ),
      floatingActionButton: Visibility(
        visible: widget.model.uuid != null && _modified == false,
        child: AnimatedActionButton(
          title: AppLocalizations.of(context)!.text('new_brew'),
          icon: const Icon(Icons.add),
          onPressed: _new,
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
          duration: const Duration(seconds: 10)
      )
    );
  }
}

