import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Internal package
import 'package:bb/utils/rating.dart';
import 'package:bb/widgets/dialogs/confirm_dialog.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RatingDialog extends StatefulWidget {
  Rating model;
  final String? hintText;
  final int? maxLines;
  RatingDialog(this.model, {this.hintText, this.maxLines});

  @override
  State<StatefulWidget> createState() {
    return _RatingDialogState();
  }
}

class _RatingDialogState extends State<RatingDialog> {
  late TextEditingController _textFieldController;

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

  Widget build(BuildContext context) {
    return ConfirmDialog(
      title: 'Qu\'en pensez-vous ?',
      content: Container(
        height: 150,
        child: Column(
          children: [
            RatingBar.builder(
              initialRating: widget.model.rating!,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemSize: 26,
              itemPadding: EdgeInsets.zero,
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) async {
                widget.model.rating = rating;
              },
            ),
            const SizedBox(height: 12),
            TextField(
              maxLines: widget.maxLines,
              controller: _textFieldController,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                hintText: widget.hintText,
                border: OutlineInputBorder(),
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
