import 'package:flutter/material.dart';

// Internal package
import 'package:bb/controller/forms/form_company_page.dart';
import 'package:bb/models/company_model.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/utils/database.dart';
import 'package:bb/widgets/containers/empty_container.dart';
import 'package:bb/widgets/containers/error_container.dart';
import 'package:bb/widgets/dialogs/delete_dialog.dart';

class CompaniesPage extends StatefulWidget {
  _CompaniesPageState createState() => new _CompaniesPageState();
}

class _CompaniesPageState extends State<CompaniesPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController? _controller;
  Future<List<CompanyModel>>? _companies;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: FillColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.text('companies')),
        elevation: 0,
        foregroundColor: Theme.of(context).primaryColor,
        backgroundColor: Colors.white
      ),
      body: Container(
        child: RefreshIndicator(
          onRefresh: () => _fetch(),
          child: FutureBuilder<List<CompanyModel>>(
            future: _companies,
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
                      CompanyModel model = snapshot.data![index];
                      return ListTile(
                        contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        // title: Text(alert.title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).buttonColor)),
                        title: Text(model.name!),
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

  _initialize() async {
    _fetch();
  }

  _fetch() async {
    setState(() {
      _companies = Database().getCompanies(ordered: true);
    });
  }

  _new() {
    CompanyModel newStyle = CompanyModel();
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return FormCompanyPage(newStyle);
    })).then((value) { _fetch(); });
  }

  _edit(CompanyModel model) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return FormCompanyPage(model);
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

