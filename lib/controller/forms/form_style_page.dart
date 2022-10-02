import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Internal package
import 'package:bb/models/style_model.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/utils/database.dart';
import 'package:bb/utils/srm.dart';
import 'package:bb/widgets/form_decoration.dart';
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

  @override
  void initState() {
    super.initState();
    _textMinSRMController = TextEditingController(text: widget.model.min_ebc != null ?  widget.model.min_ebc.toString() :  null);
    _textMaxSRMController = TextEditingController(text: widget.model.max_ebc != null ?  widget.model.max_ebc.toString() :  null);
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
        actions: <Widget> [
          IconButton(
            padding: EdgeInsets.zero,
            tooltip: AppLocalizations.of(context)!.text('save'),
            icon: const Icon(Icons.save),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                Database().update(widget.model).then((value) async {
                  Navigator.pop(context, widget.model);
                }).onError((e,s) {
                  _showSnackbar(e.toString());
                });
              }
            }
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
                model.status = Status.pending;
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
          child: Column(
            children: <Widget>[
              DropdownButtonFormField<Fermentation>(
                  value: widget.model.fermentation,
                  decoration: FormDecoration(
                      icon: const Icon(Icons.aspect_ratio),
                      labelText: AppLocalizations.of(context)!.text('fermentation')
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
              TextFormField(
                initialValue: widget.model.title,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (text) => setState(() {
                  widget.model.title = text;
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
                initialValue: widget.model.category,
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
                    return Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextFormField(
                            initialValue: widget.model.min_ibu != null ?  widget.model.min_ibu.toString() :  '',
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            onChanged: (value) => setState(() {
                              widget.model.min_ibu = double.parse(value);
                            }),
                            decoration: FormDecoration(
                                icon: const Text('IBU'),
                                labelText: 'min',
                                border: InputBorder.none,
                                fillColor: FillColor, filled: true,
                                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width / 2.5)
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return AppLocalizations.of(context)!.text('validator_field_required');
                              }
                              return null;
                            }
                        ),
                        const SizedBox(width: 8),
                        TextFormField(
                            initialValue: widget.model.max_ibu != null ?  widget.model.max_ibu.toString() :  '',
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            onChanged: (value) => setState(() {
                              widget.model.max_ibu = double.parse(value);
                            }),
                            decoration: FormDecoration(
                                labelText: 'max',
                                border: InputBorder.none,
                                fillColor: FillColor, filled: true,
                                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width / 2.5)
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return AppLocalizations.of(context)!.text('validator_field_required');
                              }
                              return null;
                            }
                        ),
                      ],
                    );
                  }
              ),
              Divider(height: 10),
              FormField(
                builder: (FormFieldState<int> state) {
                  return Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextFormField(
                        initialValue: widget.model.min_abv != null ?  widget.model.min_abv.toString() :  '',
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        onChanged: (value) => setState(() {
                          widget.model.min_abv = double.parse(value);
                        }),
                        decoration: FormDecoration(
                          icon: const Text('ABV'),
                          labelText: 'min',
                          border: InputBorder.none,
                          fillColor: FillColor, filled: true,
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width / 2.5)
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return AppLocalizations.of(context)!.text('validator_field_required');
                          }
                          return null;
                        }
                      ),
                      const SizedBox(width: 8),
                      TextFormField(
                        initialValue: widget.model.max_abv != null ?  widget.model.max_abv.toString() :  '',
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        onChanged: (value) => setState(() {
                          widget.model.max_abv = double.parse(value);
                        }),
                        decoration: FormDecoration(
                          labelText: 'max',
                          border: InputBorder.none,
                          fillColor: FillColor, filled: true,
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width / 2.5)
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return AppLocalizations.of(context)!.text('validator_field_required');
                          }
                          return null;
                          }
                      ),
                    ],
                  );
                }
              ),
              Divider(height: 10),
              FormField(
                builder: (FormFieldState<int> state) {
                  return Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width / 2.5,
                        child: Row(
                         mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _textMinSRMController,
                                keyboardType: TextInputType.numberWithOptions(decimal: false),
                                onChanged: (value) => setState(() {
                                  widget.model.min_ebc = double.parse(value);
                                }),
                                decoration: FormDecoration(
                                    icon: const Text('EBC'),
                                    labelText: 'min',
                                    border: InputBorder.none,
                                    fillColor: FillColor, filled: true,
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return AppLocalizations.of(context)!.text('validator_field_required');
                                  }
                                  return null;
                                }
                             ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.calculate_outlined),
                              tooltip: 'SRM calculator',
                              onPressed: widget.model.min_ebc != null ? () {
                                setState(() {
                                  _textMinSRMController.text = SRM.toEBC(widget.model.min_ebc!).toString();
                                  widget.model.min_ebc = double.parse(_textMinSRMController.text);
                                });
                              } : null,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width / 2.5,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _textMaxSRMController,
                                keyboardType: TextInputType.numberWithOptions(decimal: false),
                                onChanged: (value) => setState(() {
                                  widget.model.max_ebc = double.parse(value);
                                }),
                                decoration: FormDecoration(
                                    labelText: 'max',
                                    border: InputBorder.none,
                                    fillColor: FillColor, filled: true,
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return AppLocalizations.of(context)!.text('validator_field_required');
                                  }
                                  return null;
                                },
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.calculate_outlined),
                              tooltip: 'SRM calculator',
                              onPressed: widget.model.max_ebc != null ? () {
                               setState(() {
                                 _textMaxSRMController.text = SRM.toEBC(widget.model.max_ebc!).toString();
                                 widget.model.max_ebc = double.parse(_textMaxSRMController.text);
                               });
                              } : null,
                            ),
                          ]
                        )
                      )
                    ],
                  );
                }
              ),
              Divider(height: 10),
              MarkdownTextInput(
                (String value) => setState(() {
                  widget.model.text = value;
                }),
                widget.model.text ?? '',
                label: AppLocalizations.of(context)!.text('text'),
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

