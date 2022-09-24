import 'package:flutter/material.dart';

// Internal package
import 'package:bb/models/product_model.dart';
import 'package:bb/models/model.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/helpers/date_helper.dart';
import 'package:bb/widgets/form_decoration.dart';
import 'package:bb/models/basket_model.dart';
import 'package:bb/utils/basket_notifier.dart';

// External package
import 'package:provider/provider.dart';
import 'package:sprintf/sprintf.dart';

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

  static Future showAddToCart(BuildContext context, ProductModel product, {BasketModel? basket}) async {
    bool update = basket != null;
    int quantity = basket != null ? basket.quantity! : product.pack ?? 1;
    BasketModel newBasket = basket ??  BasketModel(
      product: product.uuid,
      price: product.price
    );
    return showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
          return Container(
              height: 200,
              padding: EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: quantity > (product.pack ?? 1) ? () {
                            setState(() {
                              quantity -= product.pack ?? 1;
                            });
                          } : null,
                          child: Icon(Icons.remove, color: Colors.black),
                          style: ElevatedButton.styleFrom(
                            shape: CircleBorder(),
                            padding: EdgeInsets.all(12),
                            primary: Colors.white, // <-- Button color
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(sprintf(
                            AppLocalizations.of(context)!.text('bottles'), [quantity]),
                            style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              quantity += product.pack ?? 1;
                            });
                          },
                          child: Icon(Icons.add, color: Colors.black),
                          style: ElevatedButton.styleFrom(
                            shape: CircleBorder(),
                            padding: EdgeInsets.all(12),
                            primary: Colors.white, // <-- Button color
                          ),
                        )
                      ]
                    )
                  ),
                  Column(
                    children: [
                      Text('${product.price!.toStringAsPrecision(3)} € / ${AppLocalizations.of(context)!.text('bottle').toLowerCase()}'),
                      Text('${AppLocalizations.of(context)!.text('total')} ${(quantity * product.price!).toStringAsPrecision(3)} €'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        child: Text(AppLocalizations.of(context)!.text('cancel'),
                            style: TextStyle(color: Colors.red)),
                        style: TextButton.styleFrom(backgroundColor: Colors.transparent),
                        onPressed: () async {
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(width: 30),
                      ElevatedButton(
                        child: Text(update ? AppLocalizations.of(context)!.text('edit_cart') : AppLocalizations.of(context)!.text('add_to_cart')),
                        style: TextButton.styleFrom(backgroundColor: Theme.of(context) .primaryColor,
                          shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: BorderSide(color: Theme.of(context).primaryColor),
                        )),
                        onPressed: () async {
                          newBasket.quantity = quantity;
                          if (update) Provider.of<BasketNotifier>(context, listen: false).set(newBasket);
                          else Provider.of<BasketNotifier>(context, listen: false).add(newBasket);
                          Navigator.pop(context);
                        },
                      )
                    ]
                  )
                ]
              ),
            );
          }
        );
      }
    );
  }
}
