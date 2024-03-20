import 'package:flutter/material.dart';

// Internal package
import 'package:bab/controller/forms/form_product_page.dart';
import 'package:bab/models/image_model.dart';
import 'package:bab/models/product_model.dart';
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/utils/constants.dart';
import 'package:bab/utils/database.dart';
import 'package:bab/widgets/containers/empty_container.dart';
import 'package:bab/widgets/containers/error_container.dart';
import 'package:bab/widgets/custom_image.dart';
import 'package:bab/widgets/custom_menu_anchor.dart';
import 'package:bab/widgets/dialogs/delete_dialog.dart';

class ProductsPage extends StatefulWidget {
  @override
  _ProductsPageState createState() => _ProductsPageState();
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
    super.build(context);
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: FillColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.text('products')),
        elevation: 0,
        foregroundColor: Theme.of(context).primaryColor,
        backgroundColor: Colors.white,
        actions: [
          CustomMenuAnchor()
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _fetch(),
        child: FutureBuilder<List<ProductModel>>(
          future: _data,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!.isEmpty) {
                return EmptyContainer(message: AppLocalizations.of(context)!.text('no_result'));
              }
              return ListView.builder(
                controller: _controller,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: snapshot.hasData ? snapshot.data!.length : 0,
                itemBuilder: (context, index) {
                  ProductModel model = snapshot.data![index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    leading: Stack(
                      children: [
                        _image(model.image),
                        if (model.status == Status.pending) Positioned(
                          top: 4.0,
                          right: 4.0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: Theme.of(context).primaryColor
                            ),
                            child: const Icon(Icons.hourglass_empty, size: 14, color: Colors.white),
                          )
                        )
                      ]
                    ),
                    // title: Text(alert.title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).buttonColor)),
                    title: Text(AppLocalizations.of(context)!.localizedText(model.title)),
                    subtitle: model.subtitle != null ? Text(AppLocalizations.of(context)!.localizedText(model.subtitle)) : null,
                    trailing: PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
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
            return const Center(child: CircularProgressIndicator(strokeWidth: 2.0, valueColor:AlwaysStoppedAnimation<Color>(Colors.black38)));
          }
        )
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
}

