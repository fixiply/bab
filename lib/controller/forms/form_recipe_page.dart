import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Internal package
import 'package:bab/controller/forms/form_brew_page.dart';
import 'package:bab/helpers/device_helper.dart';
import 'package:bab/models/brew_model.dart';
import 'package:bab/models/fermentable_model.dart' as fm;
import 'package:bab/models/hop_model.dart' as hm;
import 'package:bab/models/misc_model.dart';
import 'package:bab/models/recipe_model.dart';
import 'package:bab/models/yeast_model.dart';
import 'package:bab/utils/abv.dart';
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/utils/constants.dart' as constants;
import 'package:bab/utils/database.dart';
import 'package:bab/utils/ibu.dart';
import 'package:bab/widgets/animated_action_button.dart';
import 'package:bab/widgets/custom_menu_anchor.dart';
import 'package:bab/widgets/custom_slider.dart';
import 'package:bab/widgets/dialogs/confirm_dialog.dart';
import 'package:bab/widgets/dialogs/delete_dialog.dart';
import 'package:bab/widgets/form_decoration.dart';
import 'package:bab/widgets/forms/beer_style_field.dart';
import 'package:bab/widgets/forms/color_field.dart';
import 'package:bab/widgets/forms/duration_field.dart';
import 'package:bab/widgets/forms/fermentation_field.dart';
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

class FormRecipePage extends StatefulWidget {
  final RecipeModel model;
  FormRecipePage(this.model);

  @override
  _FormRecipePageState createState() => _FormRecipePageState();
}

class _FormRecipePageState extends State<FormRecipePage> {
  Key _key = UniqueKey();
  final _formKey = GlobalKey<FormState>();
  bool _modified = false;

  TextEditingController _volumeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _applyChange();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.text('recipe')),
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
            tooltip: AppLocalizations.of(context)!.text('calculate_theoretical_profile'),
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
                RecipeModel model = widget.model.copy();
                model.uuid = null;
                model.title = null;
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return FormRecipePage(model);
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
            onSelected: (value) {
              if (value is constants.Unit) {
                _applyChange(unit: value);
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
                title: Text(AppLocalizations.of(context)!.text('theoretical_profile'), style: TextStyle(color: Theme.of(context).primaryColor)),
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
                            if (value == 0) return AppLocalizations.of(context)!.text('not_applicable');
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
                            if (value == 0) return AppLocalizations.of(context)!.text('not_applicable');
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
                ]
              ),
              const Divider(height: 10),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<Method>(
                      value: widget.model.method,
                      style: DefaultTextStyle.of(context).style.copyWith(overflow: TextOverflow.ellipsis),
                      decoration: FormDecoration(
                        icon: const Icon(Icons.grain),
                        labelText: AppLocalizations.of(context)!.text('method'),
                        fillColor: constants.FillColor,
                        filled: true,
                      ),
                      items: Method.values.map((Method display) {
                        return DropdownMenuItem<Method>(
                            value: display,
                            child: Text(AppLocalizations.of(context)!.text(display.toString().toLowerCase())));
                      }).toList(),
                      onChanged: (value) => widget.model.method = value,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if (value == null) {
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
                  ),
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
                      validator: (value) {
                        if (value == null) {
                          return AppLocalizations.of(context)!.text('validator_field_required');
                        }
                        return null;
                      }
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
                      label: AppLocalizations.of(context)!.text('boiling_time'),
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
                recipe: widget.model,
                onChanged: (values) {
                  widget.model.fermentables = values as List<fm.FermentableModel>;
                  _calculate();
                },
              ),
              const Divider(height: 10),
              IngredientsField(
                context: context,
                ingredient: constants.Ingredient.hops,
                recipe: widget.model,
                onChanged: (values) {
                  widget.model.hops = values as List<hm.HopModel>;
                  _calculate();
                },
              ),
              const Divider(height: 10),
              IngredientsField(
                context: context,
                ingredient: constants.Ingredient.yeast,
                recipe: widget.model,
                onChanged: (values) {
                  widget.model.yeasts = values as List<YeastModel>;
                  _calculate();
                },
              ),
              const Divider(height: 10),
              IngredientsField(
                context: context,
                ingredient: constants.Ingredient.misc,
                recipe: widget.model,
                onChanged: (values) {
                  widget.model.miscellaneous = values as List<MiscModel>;
                  _calculate();
                }
              ),
              const Divider(height: 10),
              MashField(
                context: context,
                data: widget.model.mash,
                recipe: widget.model,
                onChanged: (values) => widget.model.mash = values,
              ),
              const Divider(height: 10),
              FermentationField(
                context: context,
                data: widget.model.fermentation,
                recipe: widget.model,
                onChanged: (values) => widget.model.fermentation = values,
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

  _applyChange({constants.Unit? unit}) async {
    bool modified = _modified;
    _volumeController.text = AppLocalizations.of(context)!.volumeFormat(widget.model.volume, unit: unit, symbol: false) ?? '';
    _modified = modified ? true : false;
  }

  _calculate() async {
    await widget.model.calculate();
    setState(() {
      _key = UniqueKey();
    });
  }

  _new() async {
    BrewModel newModel = BrewModel(
        recipe: widget.model,
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

