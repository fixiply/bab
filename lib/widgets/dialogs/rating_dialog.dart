import 'package:flutter/material.dart';

// Internal package
import 'package:bb/utils/rating.dart';
import 'package:bb/widgets/dialogs/confirm_dialog.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RatingDialog extends StatefulWidget {
  Rating model;
  final String? title;
  final String? hintText;
  final int? maxLines;
  RatingDialog(this.model, {this.title, this.hintText, this.maxLines});

  @override
  State<StatefulWidget> createState() {
    return _RatingDialogState();
  }
}

class _RatingDialogState extends State<RatingDialog> {
  late TextEditingController _textFieldController;

  bool _modified = false;

  @override
  void initState() {
    super.initState();
    _textFieldController = TextEditingController();
    _textFieldController.addListener(() {
      setState(() {
        widget.model.comment = _textFieldController.value.text;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConfirmDialog(
      title: widget.title,
      ok: AppLocalizations.of(context)!.text('validate'),
      enabled: _modified,
      content: SizedBox(
        height: 180,
        width: 400,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Quelle note attribuez-vous ?'),
            RatingBar.builder(
              initialRating: widget.model.rating!,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemSize: 36,
              itemPadding: EdgeInsets.zero,
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) async {
                setState(() {
                  _modified = true;
                });
                widget.model.rating = rating;
              },
            ),
            const SizedBox(height: 12),
            const Text('Et donnez votre avis :'),
            TextField(
              maxLines: widget.maxLines,
              controller: _textFieldController,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                hintText: widget.hintText,
                border: const OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0)
                ),
              )
            ),
          ]
        ),
      ),
      onOk: () {
        Navigator.pop(context, widget.model);
      },
      onCancel: () {
        Navigator.pop(context, null);
      },
    );
  }
}
