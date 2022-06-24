import 'package:flutter/material.dart';

// Internal package
import 'package:bb/models/model.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/date_helper.dart';
import 'package:bb/widgets/form_decoration.dart';

class ModalBottomSheet {
  static Future showInformation(BuildContext context, Model model) async {
    return showModalBottomSheet(
      context: context,
      // isScrollControlled: true,
      builder: (BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            titleSpacing: 15,
            centerTitle: true,
            iconTheme: new IconThemeData(color: Theme.of(context).primaryColor),
            backgroundColor: Colors.transparent,
            bottomOpacity: 0.0,
            elevation: 0.0,
            leading: IconButton(
                icon:Icon(Icons.clear),
                onPressed:() async {
                  Navigator.pop(context);
                }
            ),
            title: Text(AppLocalizations.of(context)!.text('information'),
                style: TextStyle(color: Theme.of(context).primaryColor)
            ),
          ),
          body: Container(
            height: 200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  initialValue: model.uuid,
                  readOnly: true,
                  decoration: FormDecoration(
                    prefixIcon: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text('ID :', style: TextStyle(fontSize: 16.0)),
                    ),
                    prefixIconConstraints: BoxConstraints(
                        minWidth: 0, minHeight:0
                    ),
                  ),
                ),
                TextFormField(
                  initialValue: DateHelper.formatDateTime(context, model.inserted_at),
                  readOnly: true,
                  decoration: FormDecoration(
                    prefixIcon: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(AppLocalizations.of(context)!.text('create') + ' :', style: TextStyle(fontSize: 16.0)),
                    ),
                    prefixIconConstraints: BoxConstraints(
                        minWidth: 0, minHeight:0
                    ),
                  ),
                ),
                TextFormField(
                  initialValue: DateHelper.formatDateTime(context, model.updated_at),
                  readOnly: true,
                  decoration: FormDecoration(
                    prefixIcon: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(AppLocalizations.of(context)!.text('updated') + ' :', style: TextStyle(fontSize: 16.0)),
                    ),
                    prefixIconConstraints: BoxConstraints(
                        minWidth: 0, minHeight:0
                    ),
                  ),
                ),
                TextFormField(
                  initialValue: model.creator,
                  readOnly: true,
                  decoration: FormDecoration(
                    prefixIcon: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(AppLocalizations.of(context)!.text('creator') + ' :', style: TextStyle(fontSize: 16.0)),
                    ),
                    prefixIconConstraints: BoxConstraints(
                        minWidth: 0, minHeight:0
                    ),
                  ),
                ),
              ]
            )
          ),
        );
      }
    );
  }
}
