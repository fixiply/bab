import 'package:flutter/material.dart';

// Internal package
import 'package:bb/controller/forms/form_product_page.dart';
import 'package:bb/models/image_model.dart';
import 'package:bb/models/product_model.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/utils/database.dart';
import 'package:bb/widgets/containers/empty_container.dart';
import 'package:bb/widgets/containers/error_container.dart';
import 'package:bb/widgets/custom_image.dart';
import 'package:bb/widgets/custom_menu_button.dart';
import 'package:bb/widgets/dialogs/delete_dialog.dart';

class ProductsPage extends StatefulWidget {
  _ProductsPageState createState() => new _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> with AutomaticKeepAliveClientMixin<ProductsPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController? _controller;
  Future<List<ProductModel>>? _data;

  @override
  bool get wantKeepAlive => true;

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
        title: Text(AppLocalizations.of(context)!.text('products')),
        elevation: 0,
        foregroundColor: Theme.of(context).primaryColor,
        backgroundColor: Colors.white,
        actions: [
          CustomMenuButton(
            context: context,
            publish: false,
            filtered: false,
            archived: false,
          )
        ],
      ),
      body: Container(
        child: RefreshIndicator(
          onRefresh: () => _fetch(),
          child: FutureBuilder<List<ProductModel>>(
            future: _data,
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
                    ProductModel model = snapshot.data![index];
                    return ListTile(
                      contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      leading: Stack(
                        children: [
                          _image(model.image),
                          if (model.status == Status.pending) Positioned(
                            top: 4.0,
                            right: 4.0,
                            child: Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: Theme.of(context).primaryColor
                              ),
                              child: Icon(Icons.hourglass_empty, size: 14, color: Colors.white),
                            )
                          )
                        ]
                      ),
                      // title: Text(alert.title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).buttonColor)),
                      title: Text(model.title!),
                      subtitle: model.subtitle != null ? Text(model.subtitle!) : null,
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
      _data = Database().getProducts(company: currentUser!.company, ordered: true);
    });
  }

  Widget _image(ImageModel? image) {
    if (image != null && image.url != null) {
      return CustomImage.network(image.url!, height: 70, width: 70, fit: BoxFit.contain, cache: false,
          emptyImage: Image.asset('assets/images/logo.png', height: 70, width: 70)
      );
    }
    return Image.asset('assets/images/logo.png', height: 70, width: 70);
  }

  _new() {
    ProductModel newModel = ProductModel(
      company: currentUser!.company
    );
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return FormProductPage(newModel);
    })).then((value) { _fetch(); });
  }

  _edit(ProductModel model) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return FormProductPage(model);
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

