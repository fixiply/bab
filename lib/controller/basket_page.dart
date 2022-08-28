import 'package:flutter/material.dart';

// Internal package
import 'package:bb/models/payment_model.dart';
import 'package:bb/models/product_model.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/basket_notifier.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/widgets/containers/empty_container.dart';
import 'package:bb/widgets/image_animate_rotate.dart';

// External package
import 'package:provider/provider.dart';


class BasketPage extends StatefulWidget {
  _BasketPageState createState() => new _BasketPageState();
}

class _BasketPageState extends State<BasketPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: FillColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.text('your_basket')),
        elevation: 0,
        foregroundColor: Theme.of(context).primaryColor,
        backgroundColor: Colors.white
      ),
      body: Consumer<BasketNotifier>(
        builder: (context, snapshot, child)  {
          if (snapshot.products.isEmpty) {
            return EmptyContainer(
              image: Icon(Icons.shopping_cart_outlined, size: 80, color: Theme.of(context).primaryColor),
              message: AppLocalizations.of(context)!.text('basket_empty')
            );
          }
          return ListView.builder(
            controller: _controller,
            itemCount: snapshot.products.length,
            itemBuilder: (context, index) {
              ProductModel model = snapshot.products[index];
              return _item(model, index);
            },
          );
        }
      ),
    );
  }

  Widget _item(ProductModel model, index) {
    return Container();
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

