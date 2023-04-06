import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Internal package
import 'package:bb/helpers/device_helper.dart';
import 'package:bb/models/style_model.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/utils/database.dart';
import 'package:bb/utils/localized_text.dart';
import 'package:bb/widgets/custom_menu_button.dart';
import 'package:bb/widgets/dialogs/confirm_dialog.dart';
import 'package:bb/widgets/form_decoration.dart';
import 'package:bb/widgets/forms/localized_text_field.dart';
import 'package:bb/widgets/forms/text_input_field.dart';

// External package

class FormStylePage extends StatefulWidget {
  final StyleModel model;
  FormStylePage(this.model);
  _FormStylePageState createState() => new _FormStylePageState();
}

class _FormStylePageState extends State<FormStylePage> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _modified = false;

  TextEditingController _ebcminController = TextEditingController();
  TextEditingController _ebcmaxController = TextEditingController();

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
        title: Text(AppLocalizations.of(context)!.text('style')),
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
              Row(
                children: [
                  Expanded(
                    child: LocalizedTextField(
                      context: context,
                      initialValue: widget.model.name,
                      textCapitalization: TextCapitalization.sentences,
                      onChanged: (value) => widget.model.name = value,
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
                    )
                  ),
                  SizedBox(width: 12),
                  SizedBox(
                    width: 140,
                    child: TextFormField(
                      initialValue: widget.model.number != null ?  widget.model.number.toString() :  '',
                      onChanged: (value) => widget.model.number = value,
                      decoration: FormDecoration(
                        icon: const Text('ID'),
                        border: InputBorder.none,
                        fillColor: FillColor, filled: true
                      )
                    ),
                  )
                ]
              ),
              Divider(height: 10),
              Row(
                children: [
                  Expanded(
                    child: LocalizedTextField(
                      context: context,
                      initialValue: widget.model.category,
                      textCapitalization: TextCapitalization.sentences,
                      onChanged: (value) => widget.model.category = value,
                      decoration: FormDecoration(
                          icon: const Icon(Icons.category),
                          labelText: AppLocalizations.of(context)!.text('category'),
                          border: InputBorder.none,
                          fillColor: FillColor, filled: true
                      ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    )
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<Fermentation>(
                      value: widget.model.fermentation,
                      style: TextStyle(overflow: TextOverflow.ellipsis),
                      decoration: FormDecoration(
                        icon: const Icon(Icons.aspect_ratio),
                        labelText: AppLocalizations.of(context)!.text('fermentation'),
                        fillColor: FillColor,
                        filled: true,
                      ),
                      items: Fermentation.values.map((Fermentation display) {
                        return DropdownMenuItem<Fermentation>(
                            value: display,
                            child: Text(AppLocalizations.of(context)!.text(display.toString().toLowerCase())));
                      }).toList(),
                      onChanged: (value) {
                        widget.model.fermentation = value;
                      }
                  )
                  ),
                ]
              ),
              Divider(height: 10),
              FormField(
                builder: (FormFieldState<int> state) {
                  return InputDecorator(
                    decoration: FormDecoration(
                      icon: const Text('IBU'),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: widget.model.ibumin != null ?  widget.model.ibumin.toString() :  '',
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            onChanged: (value) => widget.model.ibumin = AppLocalizations.of(context)!.decimal(value),
                            decoration: FormDecoration(
                              labelText: 'min',
                              border: InputBorder.none,
                              suffixIcon: Tooltip(
                                message: 'Amertume minimum',
                                child: Icon(Icons.help_outline, color: Theme.of(context).primaryColor),
                              ),
                              fillColor: FillColor, filled: true,
                            ),
                          )
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            initialValue: widget.model.ibumax != null ?  widget.model.ibumax.toString() :  '',
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            onChanged: (value) => widget.model.ibumax = AppLocalizations.of(context)!.decimal(value),
                            decoration: FormDecoration(
                              labelText: 'max',
                              border: InputBorder.none,
                              suffixIcon: Tooltip(
                                message:  'Amertume maximale',
                                child: Icon(Icons.help_outline, color: Theme.of(context).primaryColor),
                              ),
                              fillColor: FillColor, filled: true,
                            ),
                          )
                        ),
                      ],
                    )
                  );
                }
              ),
              Divider(height: 10),
              FormField(
                builder: (FormFieldState<int> state) {
                  return InputDecorator(
                    decoration: FormDecoration(
                      icon: const Text('ABV'),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: widget.model.abvmin != null ?  widget.model.abvmin.toString() :  '',
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            onChanged: (value) => widget.model.abvmin = AppLocalizations.of(context)!.decimal(value),
                            decoration: FormDecoration(
                              labelText: 'min',
                              border: InputBorder.none,
                              suffixText: '%',
                              suffixIcon: Tooltip(
                                message:  'Alcool minimum',
                                child: Icon(Icons.help_outline, color: Theme.of(context).primaryColor),
                              ),
                              fillColor: FillColor, filled: true,
                              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width / 2.2)
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            initialValue: widget.model.abvmax != null ?  widget.model.abvmax.toString() :  '',
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            onChanged: (value) => widget.model.abvmax = AppLocalizations.of(context)!.decimal(value),
                            decoration: FormDecoration(
                              labelText: 'max',
                              border: InputBorder.none,
                              suffixText: '%',
                              suffixIcon: Tooltip(
                                message:  'Alcool maximum',
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
              Divider(height: 10),
              FormField(
                builder: (FormFieldState<int> state) {
                  return InputDecorator(
                      decoration: FormDecoration(
                        icon: Text(AppLocalizations.of(context)!.colorUnit),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              // key: UniqueKey(),
                              // initialValue: widget.model.ebcmin != null ?  widget.model.ebcmin.toString() :  '',
                              controller:  _ebcminController,
                              keyboardType: TextInputType.numberWithOptions(decimal: false),
                              onChanged: (value) => widget.model.ebcmin = AppLocalizations.of(context)!.fromSRM(int.parse(value)),
                              decoration: FormDecoration(
                                  labelText: 'min',
                                  border: InputBorder.none,
                                  suffixIcon: Tooltip(
                                    message:  'Couleur minimum',
                                    child: Icon(Icons.help_outline, color: Theme.of(context).primaryColor),
                                  ),
                                  fillColor: FillColor, filled: true,
                                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width / 2.2)
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              // key: UniqueKey(),
                              // initialValue: widget.model.ebcmax != null ?  widget.model.ebcmax.toString() :  '',
                              controller:  _ebcmaxController,
                              keyboardType: TextInputType.numberWithOptions(decimal: false),
                              onChanged: (value) => widget.model.ebcmax = AppLocalizations.of(context)!.fromSRM(int.parse(value)),
                              decoration: FormDecoration(
                                labelText: 'max',
                                border: InputBorder.none,
                                suffixIcon: Tooltip(
                                  message:  'Couleur maximum',
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
              Divider(height: 10),
              TextInputField(
                context: context,
                initialValue: widget.model.overallimpression,
                title: AppLocalizations.of(context)!.text('overall_impression'),
                onChanged: (locale, value) {
                  LocalizedText text =  widget.model.overallimpression is LocalizedText ? widget.model.overallimpression : LocalizedText();
                  text.add(locale, value);
                  widget.model.overallimpression = text.size() > 0 ? text : value;
                },
              ),
              Divider(height: 10),
              TextInputField(
                context: context,
                initialValue: widget.model.aroma,
                title: AppLocalizations.of(context)!.text('aroma'),
                onChanged: (locale, value) {
                  LocalizedText text =  widget.model.aroma is LocalizedText ? widget.model.aroma : LocalizedText();
                  text.add(locale, value);
                  widget.model.aroma = text.size() > 0 ? text : value;
                },
              ),
              Divider(height: 10),
              TextInputField(
                context: context,
                initialValue: widget.model.flavor,
                title: AppLocalizations.of(context)!.text('flavor'),
                onChanged: (locale, value) {
                  LocalizedText text =  widget.model.flavor is LocalizedText ? widget.model.flavor : LocalizedText();
                  text.add(locale, value);
                  widget.model.flavor = text.size() > 0 ? text : value;
                },
              ),
              Divider(height: 10),
              TextInputField(
                context: context,
                initialValue: widget.model.mouthfeel,
                title: AppLocalizations.of(context)!.text('mouthfeel'),
                onChanged: (locale, value) {
                  LocalizedText text =  widget.model.mouthfeel is LocalizedText ? widget.model.mouthfeel : LocalizedText();
                  text.add(locale, value);
                  widget.model.mouthfeel = text.size() > 0 ? text : null;
                },
              ),
              Divider(height: 10),
              TextInputField(
                context: context,
                initialValue: widget.model.comments,
                title: AppLocalizations.of(context)!.text('comments'),
                onChanged: (locale, value) {
                  LocalizedText text =  widget.model.comments is LocalizedText ? widget.model.comments : LocalizedText();
                  text.add(locale, value);
                  widget.model.comments = text.size() > 0 ? text : value;
                },
              ),
            ]
          ),
        )
      )
    );
  }

  _initialize() async {
    bool modified = _modified;
    _ebcminController.text = AppLocalizations.of(context)!.colorFormat(widget.model.ebcmin) ?? '';
    _ebcmaxController.text = AppLocalizations.of(context)!.colorFormat(widget.model.ebcmax) ?? '';
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

