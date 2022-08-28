import 'package:flutter/material.dart';

// Internal package
import 'package:bb/controller/forms/form_style_page.dart';
import 'package:bb/models/style_model.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/utils/database.dart';
import 'package:bb/widgets/containers/empty_container.dart';
import 'package:bb/widgets/containers/error_container.dart';
import 'package:bb/widgets/dialogs/delete_dialog.dart';

class StylesPage extends StatefulWidget {
  _StylesPageState createState() => new _StylesPageState();
}

class _StylesPageState extends State<StylesPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController? _controller;
  Future<List<StyleModel>>? _styles;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: FillColor,
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.text('styles')),
          elevation: 0,
          foregroundColor: Theme.of(context).primaryColor,
          backgroundColor: Colors.white
        ),
        body: Container(
          child: RefreshIndicator(
            onRefresh: () => _fetch(),
            child: FutureBuilder<List<StyleModel>>(
              future: _styles,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data!.length == 0) {
                    return EmptyContainer(message: AppLocalizations.of(context)!.text('no_result'));
                  }
                  return ListView.builder(
                    controller: _controller,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: snapshot.hasData ? snapshot.data!.length : 0,
                    itemBuilder: (context, index) {
                      StyleModel model = snapshot.data![index];
                      return ListTile(
                        contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        // title: Text(alert.title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).buttonColor)),
                        title: Text(model.title!),
                        subtitle: model.text != null ? Text(model.text!) : null,
                        trailing: PopupMenuButton<String>(
                            icon: Icon(Icons.more_vert),
                            tooltip: AppLocalizations.of(context)!.text('options'),
                            onSelected: (value) {
                              if (value == 'edit') {
                                _edit(model);
                              } else if (value == 'remove') {
                                DeleteDialog.model(context, model, forced: true);
                              }
                            },
                            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                              PopupMenuItem(
                                value: 'edit',
                                child: Text(AppLocalizations.of(context)!.text('edit')),
                              ),
                              PopupMenuItem(
                                value: 'remove',
                                child: Text(AppLocalizations.of(context)!.text('remove')),
                              ),
                            ]
                        )
                      );
                    }
                  );
                }
                if (snapshot.hasError) {
                  return ErrorContainer(snapshot.error.toString());
                }
                return Center(child: CircularProgressIndicator(strokeWidth: 2.0, valueColor:AlwaysStoppedAnimation<Color>(Colors.black38)));
              }
            )
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _new,
          backgroundColor: Theme.of(context).primaryColor,
          tooltip: AppLocalizations.of(context)!.text('new'),
          child: const Icon(Icons.add)
        )
    );
  }

  _fetch() async {
    setState(() {
      _styles = Database().getStyles(ordered: true);
    });
  }

  _new() {
    StyleModel newStyle = StyleModel();
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return FormStylePage(newStyle);
    })).then((value) { _fetch(); });
  }

  _edit(StyleModel model) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return FormStylePage(model);
    })).then((value) { _fetch(); });
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

