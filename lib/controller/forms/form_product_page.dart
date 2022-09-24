import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Internal package
import 'package:bb/models/product_model.dart';
import 'package:bb/models/company_model.dart';
import 'package:bb/models/receipt_model.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/utils/database.dart';
import 'package:bb/widgets/form_decoration.dart';
import 'package:bb/widgets/forms/image_field.dart';
import 'package:bb/widgets/modal_bottom_sheet.dart';

// External package
import 'package:markdown_editable_textinput/format_markdown.dart';
import 'package:markdown_editable_textinput/markdown_text_input.dart';

class FormProductPage extends StatefulWidget {
  final ProductModel model;
  FormProductPage(this.model);
  _FormProductPageState createState() => new _FormProductPageState();
}

class _FormProductPageState extends State<FormProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<List<CompanyModel>>? _companies;
  Future<List<ReceiptModel>>? _receipts;

  @override
  void initState() {
    super.initState();
    _companies = Database().getCompanies(ordered: true);
    _receipts = Database().getReceipts(ordered: true);
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
                ProductModel model = widget.model.copy();
                model.uuid = null;
                model.status = Status.pending;
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return FormProductPage(model);
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
              Divider(height: 10),
              if (widget.model.product == Product.beer) FutureBuilder<List<ReceiptModel>>(
                  future: _receipts,
                  builder: (context, snapshot) {
                    if (snapshot.data != null) {
                      return DropdownButtonFormField<String>(
                          value: widget.model.receipt,
                          decoration: FormDecoration(
                            icon: Icon(Icons.receipt_outlined),
                            labelText: AppLocalizations.of(context)!.text('receipt'),
                          ),
                          items: snapshot.data!.map((ReceiptModel model) {
                            return DropdownMenuItem<String>(
                                value: model.uuid,
                                child: Text(model.title!));
                          }).toList(),
                          onChanged: (value) =>
                              setState(() {
                                widget.model.receipt = value;
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
              if (widget.model.product == Product.beer) Divider(height: 10),
              FutureBuilder<List<CompanyModel>>(
                future: _companies,
                builder: (context, snapshot) {
                  if (snapshot.data != null) {
                    return DropdownButtonFormField<String>(
                      value: widget.model.company,
                      decoration: FormDecoration(
                        icon: Icon(Icons.store_outlined),
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
              Divider(height: 10),
              TextFormField(
                // focusNode: _focusTitle,
                initialValue: widget.model.title,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (text) => setState(() {
                  widget.model.title = text;
                }),
                decoration: FormDecoration(
                  icon: Icon(Icons.title),
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
                initialValue: widget.model.subtitle,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (text) => setState(() {
                  widget.model.subtitle = text;
                }),
                decoration: FormDecoration(
                    icon: const Icon(Icons.subtitles_outlined),
                    labelText: AppLocalizations.of(context)!.text('subtitle'),
                    border: InputBorder.none,
                    fillColor: FillColor, filled: true
                )
              ),
              Divider(height: 10),
              TextFormField(
                initialValue: widget.model.price != null ? widget.model.price.toString() : null,
                keyboardType: TextInputType.number,
                onChanged: (value) => setState(() {
                  widget.model.price = double.tryParse(value);
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
              Divider(height: 10),
              TextFormField(
                initialValue: widget.model.pack != null ? widget.model.pack.toString() : null,
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
              Divider(height: 10),
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

  _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(message),
            duration: Duration(seconds: 10)
        )
    );
  }
}

