import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Internal package
import 'package:bb/helpers/device_helper.dart';
import 'package:bb/helpers/formula_helper.dart';
import 'package:bb/models/equipment_model.dart';
import 'package:bb/models/fermentable_model.dart';
import 'package:bb/models/hop_model.dart';
import 'package:bb/models/receipt_model.dart';
import 'package:bb/models/yeast_model.dart';
import 'package:bb/utils/abv.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/helpers/color_helper.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/utils/database.dart';
import 'package:bb/utils/ibu.dart';
import 'package:bb/widgets/custom_menu_button.dart';
import 'package:bb/widgets/dialogs/confirm_dialog.dart';
import 'package:bb/widgets/form_decoration.dart';
import 'package:bb/widgets/forms/beer_style_field.dart';
import 'package:bb/widgets/forms/image_field.dart';
import 'package:bb/widgets/forms/ingredients_field.dart';
import 'package:bb/widgets/forms/localized_text_field.dart';
import 'package:bb/widgets/forms/mash_field.dart';
import 'package:bb/widgets/forms/switch_field.dart';
import 'package:bb/widgets/paints/gradient_slider_thumb_shape.dart';
import 'package:bb/widgets/paints/gradient_slider_track_shape.dart';
import 'package:bb/widgets/paints/rect_slider_thumb_shape.dart';

// External package
import 'package:intl/intl.dart';
import 'package:markdown_editable_textinput/format_markdown.dart';
import 'package:markdown_editable_textinput/markdown_text_input.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

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
            filtered: false,
            archived: false,
            units: true,
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
              ExpansionTile(
                initiallyExpanded: true,
                backgroundColor: FillColor,
                // childrenPadding: EdgeInsets.all(8.0),
                title: Text(AppLocalizations.of(context)!.text('profile'), style: TextStyle(color: Theme.of(context).primaryColor)),
                children: <Widget>[
                  Row(
                    children: [
                      Expanded(
                        child: _slider(AppLocalizations.of(context)!.text('oiginal_gravity'), widget.model.og ?? 1, 1, 1.2, 0.01,
                          format: NumberFormat("0.000", AppLocalizations.of(context)!.locale.toString())
                        )
                      ),
                      Expanded(
                        child: _slider(AppLocalizations.of(context)!.text('final_gravity'), widget.model.fg ?? 1, 1, 1.2, 0.01,
                          format: NumberFormat("0.000", AppLocalizations.of(context)!.locale.toString())
                        )
                      ),
                      Expanded(
                        child: _slider(AppLocalizations.of(context)!.text('abv'), widget.model.abv ?? 0, 0, MAX_ABV, 0.1,
                            format: NumberFormat("#0.#'%'", AppLocalizations.of(context)!.locale.toString())
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
                                thumbShape: GradientSliderThumbShape(ringColor: Theme.of(context).primaryColor, fillColor: FillColor, selectedValue: 10),
                              ),
                              child: Slider(
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
                        child: _slider(AppLocalizations.of(context)!.text('ibu'), widget.model.ibu ?? 0, 0, MAX_IBU, 0.1,
                          format: NumberFormat("#0.#", AppLocalizations.of(context)!.locale.toString())
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
                      onChanged: (value) => widget.model.style = value
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
              Divider(height: 10),
              IngredientsField(
                context: context,
                ingredient: Ingredient.fermentable,
                data: widget.model.fermentables,
                receipt: widget.model,
                onChanged: (values) {
                  widget.model.fermentables = values;
                  _calculate();
                },
              ),
              Divider(height: 10),
              IngredientsField(
                context: context,
                ingredient: Ingredient.hops,
                data: widget.model.hops,
                receipt: widget.model,
                onChanged: (values) {
                  widget.model.hops = values;
                  _calculate();
                },
              ),
              Divider(height: 10),
              IngredientsField(
                context: context,
                ingredient: Ingredient.yeast,
                data: widget.model.yeasts,
                receipt: widget.model,
                onChanged: (values) {
                  widget.model.yeasts = values;
                  _calculate();
                },
              ),
              Divider(height: 10),
              IngredientsField(
                context: context,
                ingredient: Ingredient.misc,
                data: widget.model.miscellaneous,
                receipt: widget.model,
                onChanged: (values) => widget.model.miscellaneous = values,
              ),
              Divider(height: 10),
              MashField(
                context: context,
                data: widget.model.mash,
                receipt: widget.model,
                onChanged: (values) => widget.model.mash = values,
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
      )
    );
  }

  _initialize() async {
    bool modified = _modified;
    _volumeController.text = AppLocalizations.of(context)!.volumeFormat(widget.model.volume, symbol: false) ?? '';
    _modified = modified ? true : false;
  }

  Widget _slider(String label, double value, double min, double max, double interval, {NumberFormat? format}) {
    bool error = false;
    if (value < min) {
      error = true;
      value = min;
    }
    if (value > max) {
      error = true;
      value = max;
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(label, style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12.0)),
        SfSliderTheme(
          data: SfSliderThemeData(
            activeTrackHeight: 4.0,
            inactiveTrackHeight: 2.0,
            activeTrackColor: error ? Colors.red : null,
            inactiveTrackColor: error ? Colors.red : null,
            tooltipBackgroundColor: Theme.of(context).primaryColor,
          ),
          child: SfSlider(
            enableTooltip: false,
            interval: interval,
            min: min,
            max: max,
            thumbShape: RectSliderThumbShape(format: format),
            minorTicksPerInterval: 1,
            value: value,
            onChanged: (dynamic values) {
              // setState(() {
              //   _thumbValue = values as double;
              // });
            },
          )
        )
      ]
    );
  }

  _calculate() async {
    double og = 0;
    double fg = 0;
    double mcu = 0;
    double ibu = 0;
    double extract = 0;
    List<FermentableModel> fermentables = await Database().getFermentables(quantities: widget.model.fermentables);
    for(FermentableModel item in fermentables) {
      if (item.method == Method.mashed) {
        // double volume = EquipmentModel.preBoilVolume(null, widget.model.volume);
        extract += item.extract(widget.model.efficiency);
        mcu += ColorHelper.mcu(item.ebc, item.amount, widget.model.volume);
      }
    }
    if (extract != 0) {
      og = FormulaHelper.og(extract, widget.model.volume);
    }

    List<YeastModel> yeasts = await Database().getYeasts(quantities: widget.model.yeasts);
    for(YeastModel item in yeasts) {
      fg += item.density(og);
    }

    List<HopModel> hops = await Database().getHops(quantities: widget.model.hops);
    for(HopModel item in hops) {
      if (item.use == Use.boil) {
        ibu += item.ibu(og, widget.model.boil, widget.model.volume);
      }
    }

    setState(() {
      if (og != 0) widget.model.og = og;
      if (fg != 0) widget.model.fg = fg;
      if (og != 0 && fg != 0) widget.model.abv = FormulaHelper.abv(og, fg);
      if (mcu != 0) widget.model.ebc = ColorHelper.ratingEBC(mcu).toInt();
      if (ibu != 0) widget.model.ibu = ibu;
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

