import 'package:flutter/material.dart';

// Internal package
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/utils/constants.dart';

class SearchText extends StatelessWidget {
  final TextEditingController controller;
  void Function() onChanged;

  SearchText(this.controller, this.onChanged);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: FillColor
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Flexible(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                  icon: Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: Icon(Icons.search, color: Theme.of(context).primaryColor)
                  ),
                  hintText: AppLocalizations.of(context)!.text('search_hint'),
                  hintStyle: TextStyle(color: Theme.of(context).primaryColor),
                  border: InputBorder.none
              ),
              style: const TextStyle(fontSize: 16.0),
              onChanged: (query) {
                onChanged.call();
              },
            )
          ),
          if (controller.text.isNotEmpty) IconButton(
            icon: Icon(Icons.clear, color: Theme.of(context).primaryColor),
            onPressed: () {
              controller.clear();
              onChanged.call();
            }
          )
        ],
      )
    );
  }
}