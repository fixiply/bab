import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Internal package
import 'package:bb/models/event_model.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/utils/database.dart';
import 'package:bb/widgets/dialogs/confirm_dialog.dart';
import 'package:bb/widgets/form_decoration.dart';
import 'package:bb/widgets/forms/carousel_field.dart';
import 'package:bb/widgets/forms/code_editor_field.dart';
import 'package:bb/widgets/forms/switch_field.dart';
import 'package:bb/widgets/forms/text_format_field.dart';
import 'package:bb/widgets/forms/widgets_field.dart';
import 'package:bb/widgets/modal_bottom_sheet.dart';

// External package

class FormEventPage extends StatefulWidget {
  final EventModel model;
  FormEventPage(this.model);
  _FormEventPageState createState() => new _FormEventPageState();
}

class _FormEventPageState extends State<FormEventPage> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _modified = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.text('event')),
        elevation: 0,
        foregroundColor: Theme.of(context).primaryColor,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const BackButtonIcon(),
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
                EventModel model = widget.model.copy();
                model.uuid = null;
                model.status = Status.pending;
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return FormEventPage(model);
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
              DropdownButtonFormField<Axis>(
                value: widget.model.axis,
                decoration: FormDecoration(
                    icon: const Icon(Icons.directions),
                    labelText: AppLocalizations.of(context)!.text('direction')
                ),
                items: Axis.values.map((Axis display) {
                  return DropdownMenuItem<Axis>(
                      value: display,
                      child: Text(AppLocalizations.of(context)!.text(display.toString().toLowerCase())));
                }).toList(),
                onChanged: (value) => setState(() {
                  widget.model.axis = value;
                })
              ),
              Divider(height: 10),
              SwitchField(
                context: context,
                value: widget.model.sliver!,
                icon: Icon(Icons.expand),
                hintText: AppLocalizations.of(context)!.text('show_sliver'),
                onChanged: (value) => setState(() {
                  widget.model.sliver = value;
                })
              ),
              Divider(height: 10),
              TextFormatField(
                context: context,
                initialValue: widget.model.top_left,
                onChanged: (text) => setState(() {
                  widget.model.top_left = text;
                }),
                decoration: FormDecoration(
                  icon: Icon(Icons.border_left),
                  labelText: AppLocalizations.of(context)!.text('top_left'),
                  border: InputBorder.none,
                  fillColor: FillColor, filled: true
                )
              ),
              Divider(height: 10),
              TextFormatField(
                context: context,
                initialValue: widget.model.top_right,
                onChanged: (text) => setState(() {
                  widget.model.top_right = text;
                }),
                decoration: FormDecoration(
                  icon: Icon(Icons.border_right),
                  labelText: AppLocalizations.of(context)!.text('top_right'),
                  border: InputBorder.none,
                  fillColor: FillColor, filled: true
                )
              ),
              Divider(height: 10),
              TextFormatField(
                context: context,
                initialValue: widget.model.bottom_left,
                onChanged: (text) => setState(() {
                  widget.model.bottom_left = text;
                }),
                decoration: FormDecoration(
                  icon: const Icon(Icons.border_bottom),
                  labelText: AppLocalizations.of(context)!.text('bottom_left'),
                  border: InputBorder.none,
                  fillColor: FillColor, filled: true
                )
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
                // autovalidateMode: AutovalidateMode.onUserInteraction,
                // validator: (value) {
                //   if (value!.isEmpty) {
                //     return AppLocalizations.of(context)!.text('validator_field_required');
                //   }
                //   return null;
                // }
              ),
              Divider(height: 10),
              TextFormField(
                initialValue: widget.model.subtitle,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (text) => setState(() {
                  widget.model.subtitle = text;
                }),
                decoration: FormDecoration(
                  icon: const Icon(Icons.subtitles),
                  labelText: AppLocalizations.of(context)!.text('subtitle'),
                  border: InputBorder.none,
                  fillColor: FillColor, filled: true
                )
              ),
              Divider(height: 10),
              CodeEditorField(
                context: context,
                initialValue: widget.model.page,
                title: AppLocalizations.of(context)!.text('page'),
                onChanged: (text) => setState(() {
                  widget.model.page = text;
                }),
              ),
              Divider(height: 10),
              WidgetsField(
                context: context,
                widgets: widget.model.widgets,
                maxLines: 20,
                onChanged: (text) => setState(() {
                  widget.model.widgets = text;
                }),
              ),
              Divider(height: 10),
              CarouselField(
                context: context,
                images: widget.model.images,
                crop: true,
                onChanged: (value) => setState(() {
                  widget.model.images = value;
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

