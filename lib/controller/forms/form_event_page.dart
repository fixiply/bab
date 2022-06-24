import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Internal package
import 'package:bb/models/event_model.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/utils/database.dart';
import 'package:bb/widgets/form_decoration.dart';
import 'package:bb/widgets/forms/carousel_field.dart';
import 'package:bb/widgets/modal_bottom_sheet.dart';

// External package
import 'package:markdown_editable_textinput/format_markdown.dart';
import 'package:markdown_editable_textinput/markdown_text_input.dart';

class FormEventPage extends StatefulWidget {
  final EventModel model;
  FormEventPage(this.model);
  _FormEventPageState createState() => new _FormEventPageState();
}

class _FormEventPageState extends State<FormEventPage> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

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
          Visibility(
            visible: widget.model.uuid != null,
            child: IconButton(
              padding: EdgeInsets.zero,
              tooltip: AppLocalizations.of(context)!.text('remove'),
              icon: const Icon(Icons.delete),
              onPressed: () async {
                // if (await _delete(widget.article)) {
                //   Navigator.pop(context);
                // }
              }
            )
          ),
          Visibility(
            visible: widget.model.uuid != null,
            child: PopupMenuButton<String>(
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
          )
        ]
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(15.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
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

