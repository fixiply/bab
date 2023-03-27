import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Internal package
import 'package:bb/helpers/device_helper.dart';
import 'package:bb/models/style_model.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/utils/database.dart';
import 'package:bb/widgets/dialogs/confirm_dialog.dart';
import 'package:bb/widgets/form_decoration.dart';
import 'package:bb/widgets/forms/color_field.dart';
import 'package:bb/widgets/forms/localized_text_field.dart';
import 'package:bb/widgets/modal_bottom_sheet.dart';

// External package
import 'package:markdown_editable_textinput/format_markdown.dart';
import 'package:markdown_editable_textinput/markdown_text_input.dart';

class FormStylePage extends StatefulWidget {
  final StyleModel model;
  FormStylePage(this.model);
  _FormStylePageState createState() => new _FormStylePageState();
}

class _FormStylePageState extends State<FormStylePage> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late TextEditingController _textMinSRMController;
  late TextEditingController _textMaxSRMController;
  bool _modified = false;

  @override
  void initState() {
    super.initState();
    _textMinSRMController = TextEditingController(text: widget.model.min_srm != null ?  widget.model.min_srm.toString() :  null);
    _textMaxSRMController = TextEditingController(text: widget.model.max_srm != null ?  widget.model.max_srm.toString() :  null);
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
          if (widget.model.uuid != null) PopupMenuButton<String>(
            padding: EdgeInsets.zero,
            tooltip: AppLocalizations.of(context)!.text('tools'),
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              if (value == 'information') {
                await ModalBottomSheet.showInformation(context, widget.model);
              } else if (value == 'duplicate') {
                StyleModel model = widget.model.copy();
                model.uuid = null;
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return FormStylePage(model);
                })).then((value) {
                  Navigator.pop(context);
                });
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem(
                value: 'information',
                child: Text(AppLocalizations.of(context)!.text('information')),
              ),
              PopupMenuItem(
                value: 'duplicate',
                child: Text(AppLocalizations.of(context)!.text('duplicate')),
              )
            ]
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
              DropdownButtonFormField<Fermentation>(
                value: widget.model.fermentation,
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
                onChanged: (value) => setState(() {
                  widget.model.fermentation = value;
                })
              ),
              Divider(height: 10),
              LocalizedTextField(
                context: context,
                initialValue: widget.model.name,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (text) => setState(() {
                  widget.model.name = text;
                }),
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
              Divider(height: 10),
              TextFormField(
                initialValue: widget.model.localizedCategory(AppLocalizations.of(context)!.locale),
                textCapitalization: TextCapitalization.sentences,
                onChanged: (text) => setState(() {
                  widget.model.category = text;
                }),
                decoration: FormDecoration(
                  icon: const Icon(Icons.category),
                  labelText: AppLocalizations.of(context)!.text('category'),
                  border: InputBorder.none,
                  fillColor: FillColor, filled: true
                )
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
                            initialValue: widget.model.min_ibu != null ?  widget.model.min_ibu.toString() :  '',
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            onChanged: (value) => setState(() {
                              widget.model.min_ibu = double.parse(value);
                            }),
                            decoration: FormDecoration(
                              labelText: 'min',
                              border: InputBorder.none,
                              suffixIcon: Tooltip(
                                message: 'Amertume minimum',
                                child: Icon(Icons.help_outline, color: Theme.of(context).primaryColor),
                              ),
                              fillColor: FillColor, filled: true,
                            ),
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
                            initialValue: widget.model.max_ibu != null ?  widget.model.max_ibu.toString() :  '',
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            onChanged: (value) => setState(() {
                              widget.model.max_ibu = double.parse(value);
                            }),
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
                            initialValue: widget.model.min_abv != null ?  widget.model.min_abv.toString() :  '',
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            onChanged: (value) => setState(() {
                              widget.model.min_abv = double.parse(value);
                            }),
                            decoration: FormDecoration(
                              labelText: 'min',
                              border: InputBorder.none,
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
                            initialValue: widget.model.max_abv != null ?  widget.model.max_abv.toString() :  '',
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            onChanged: (value) => setState(() {
                              widget.model.max_abv = double.parse(value);
                            }),
                            decoration: FormDecoration(
                              labelText: 'max',
                              border: InputBorder.none,
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
              ColorField(
                context: context,
                value: widget.model.min_srm,
                icon: Icon(Icons.color_lens_outlined),
                onChanged: (value) => setState(() {
                  widget.model.min_srm = value;
                }),
              ),
              ColorField(
                context: context,
                value: widget.model.max_srm,
                icon: Icon(Icons.color_lens),
                onChanged: (value) => setState(() {
                  widget.model.max_srm = value;
                }),
              ),
              Divider(height: 10),
              MarkdownTextInput(
                (String value) => setState(() {
                  widget.model.text = value;
                }),
                widget.model.localizedText(AppLocalizations.of(context)!.locale) ?? '',
                label: AppLocalizations.of(context)!.text('notes'),
                maxLines: 10,
                actions: MarkdownType.values,
                // controller: _controller,
                validators: (value) {
                  return null;
                }
              ),
            ]
          ),
        )
      )
    );
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

