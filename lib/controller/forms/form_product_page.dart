import 'package:flutter/material.dart';

// Internal package
import 'package:bab/helpers/device_helper.dart';
import 'package:bab/models/company_model.dart';
import 'package:bab/models/product_model.dart';
import 'package:bab/models/recipe_model.dart';
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/utils/constants.dart';
import 'package:bab/utils/database.dart';
import 'package:bab/utils/localized_text.dart';
import 'package:bab/widgets/dialogs/confirm_dialog.dart';
import 'package:bab/widgets/form_decoration.dart';
import 'package:bab/widgets/forms/image_field.dart';
import 'package:bab/widgets/forms/localized_text_field.dart';
import 'package:bab/widgets/forms/period_field.dart';
import 'package:bab/widgets/forms/text_input_field.dart';
import 'package:bab/widgets/forms/weekdays_field.dart';

class FormProductPage extends StatefulWidget {
  final ProductModel model;
  FormProductPage(this.model);

  @override
  _FormProductPageState createState() => _FormProductPageState();
}

class _FormProductPageState extends State<FormProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _modified = false;

  Future<List<CompanyModel>>? _companies;
  Future<List<RecipeModel>>? _recipes;

  @override
  void initState() {
    super.initState();
    _companies = Database().getCompanies(ordered: true);
    _recipes = Database().getRecipes(ordered: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.text('product')),
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
              DropdownButtonFormField<Product>(
                value: widget.model.product,
                decoration: FormDecoration(
                  icon: const Icon(Icons.article_outlined),
                  labelText: AppLocalizations.of(context)!.text('product')
                ),
                items: Product.values.map((Product display) {
                  return DropdownMenuItem<Product>(
                    value: display,
                    child: Text(AppLocalizations.of(context)!.text(display.toString().toLowerCase())));
                }).toList(),
                onChanged: (value) => setState(() {
                  widget.model.product = value;
                }),
                validator: (value) {
                  if (value == null) {
                    return AppLocalizations.of(context)!.text('required_field');
                  }
                  return null;
                }
              ),
              const Divider(height: 10),
              if (widget.model.product == Product.article) FutureBuilder<List<RecipeModel>>(
                future: _recipes,
                builder: (context, snapshot) {
                  if (snapshot.data != null) {
                    return DropdownButtonFormField<String>(
                      value: snapshot.data!.contains(widget.model.recipe) ? widget.model.recipe : null,
                      style: DefaultTextStyle.of(context).style.copyWith(overflow: TextOverflow.ellipsis),
                      decoration: FormDecoration(
                        icon: const Icon(Icons.receipt_outlined),
                        labelText: AppLocalizations.of(context)!.text('recipe'),
                      ),
                      items: snapshot.data!.map((RecipeModel model) {
                        return DropdownMenuItem<String>(
                          value: model.uuid,
                          child: Text(AppLocalizations.of(context)!.localizedText(model.title)));
                      }).toList(),
                      onChanged: (value) =>
                        setState(() {
                          widget.model.recipe = value;
                        }
                      ),
                    );
                  }
                  return Container();
                }
              ),
              if (widget.model.product == Product.article) const Divider(height: 10),
              FutureBuilder<List<CompanyModel>>(
                future: _companies,
                builder: (context, snapshot) {
                  if (snapshot.data != null) {
                    return DropdownButtonFormField<String>(
                      value: widget.model.company,
                      style: DefaultTextStyle.of(context).style.copyWith(overflow: TextOverflow.ellipsis),
                      decoration: FormDecoration(
                        icon: const Icon(Icons.store_outlined),
                        labelText: AppLocalizations.of(context)!.text('company'),
                      ),
                      items: snapshot.data!.map((CompanyModel model) {
                        return DropdownMenuItem<String>(
                            value: model.uuid,
                            child: Text(model.name!));
                      }).toList(),
                      onChanged: (value) =>
                          setState(() {
                            widget.model.company = value;
                          }),
                      validator: (value) {
                        if (value == null) {
                          return AppLocalizations.of(context)!.text('required_field');
                        }
                        return null;
                      }
                    );
                  }
                  return Container();
                }
              ),
              const Divider(height: 10),
              LocalizedTextField(
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
              const Divider(height: 10),
              LocalizedTextField(
                context: context,
                initialValue: widget.model.subtitle,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (value) => widget.model.subtitle = value,
                decoration: FormDecoration(
                  icon: const Icon(Icons.subtitles_outlined),
                  labelText: AppLocalizations.of(context)!.text('subtitle'),
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
              const Divider(height: 10),
              TextFormField(
                initialValue: widget.model.price?.toString(),
                keyboardType: TextInputType.number,
                onChanged: (value) => setState(() {
                  widget.model.price = AppLocalizations.of(context)!.decimal(value);
                }),
                decoration: FormDecoration(
                  icon: const Icon(Icons.euro),
                  labelText: AppLocalizations.of(context)!.text('price'),
                  border: InputBorder.none,
                  fillColor: FillColor, filled: true
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return AppLocalizations.of(context)!.text('validator_field_required');
                  }
                  return null;
                }
              ),
              const Divider(height: 10),
              TextFormField(
                initialValue: widget.model.pack?.toString(),
                keyboardType: TextInputType.number,
                onChanged: (value) => setState(() {
                  widget.model.pack = int.tryParse(value);
                }),
                decoration: FormDecoration(
                  icon: const Icon(Icons.production_quantity_limits_outlined),
                  labelText: AppLocalizations.of(context)!.text('pack'),
                  border: InputBorder.none,
                  fillColor: FillColor, filled: true
                ),
              ),
              const Divider(height: 10),
              FormField(
                builder: (FormFieldState<int> state) {
                  return InputDecorator(
                    decoration: FormDecoration(
                      icon: const Icon(Icons.backpack_outlined),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: widget.model.min != null ?  widget.model.min.toString() :  '',
                            keyboardType: const TextInputType.numberWithOptions(decimal: false),
                            onChanged: (value) => widget.model.min = int.parse(value),
                            decoration: FormDecoration(
                                labelText: 'min',
                                border: InputBorder.none,
                                suffixIcon: Tooltip(
                                  message:  'Vendu par X au minimum',
                                  child: Icon(Icons.help_outline, color: Theme.of(context).primaryColor),
                                ),
                                fillColor: FillColor, filled: true,
                                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width / 2.2)
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            initialValue: widget.model.max != null ?  widget.model.max.toString() :  '',
                            keyboardType: const TextInputType.numberWithOptions(decimal: false),
                            onChanged: (value) => widget.model.max = int.parse(value),
                            decoration: FormDecoration(
                                labelText: 'max',
                                border: InputBorder.none,
                                suffixIcon: Tooltip(
                                  message:  'Vendu par X au maximum',
                                  child: Icon(Icons.help_outline, color: Theme.of(context).primaryColor),
                                ),
                                fillColor: FillColor, filled: true,
                                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width / 2.5)
                            ),
                          )
                        ),
                      ],
                    )
                  );
                }
              ),
              if (widget.model.product == Product.booking) const Divider(height: 10),
              if (widget.model.product == Product.booking) WeekdaysField(
                context: context,
                value: widget.model.weekdays!,
                onChanged: (values) => setState(() {
                  widget.model.weekdays = values;
                }),
              ),
              if (widget.model.product == Product.booking) PeriodField(
                context: context,
                value: widget.model.term!,
                onChanged: (value) => setState(() {
                  widget.model.term = value;
                }),
              ),
              if (widget.model.product == Product.booking) const Divider(height: 10),
              TextInputField(
                context: context,
                initialValue: widget.model.text,
                title: AppLocalizations.of(context)!.text('text'),
                onChanged: (locale, value) {
                  LocalizedText text =  widget.model.text is LocalizedText ? widget.model.text : LocalizedText();
                  text.add(locale, value);
                  widget.model.text = text.size() > 0 ? text : value;
                },
              ),
              const Divider(height: 10),
              ImageField(
                context: context,
                image: widget.model.image,
                height: null,
                crop: true,
                onChanged: (images) => setState(() {
                  widget.model.image = images;
                })
              ),
            ]
          ),
        )
      )
    );
  }
}

