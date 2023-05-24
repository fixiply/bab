import 'package:flutter/material.dart';

// Internal package
import 'package:bb/controller/forms/form_address_page.dart';
import 'package:bb/controller/payments_page.dart';
import 'package:bb/models/basket_model.dart';
import 'package:bb/models/product_model.dart';
import 'package:bb/models/receipt_model.dart';
import 'package:bb/models/style_model.dart';
import 'package:bb/utils/adress.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/basket_notifier.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/utils/database.dart';
import 'package:bb/utils/payment.dart';
import 'package:bb/widgets/containers/empty_container.dart';
import 'package:bb/widgets/custom_image.dart';
import 'package:bb/widgets/modal_bottom_sheet.dart';

// External package
import 'package:provider/provider.dart';
import 'package:sprintf/sprintf.dart';


class BasketPage extends StatefulWidget {
  @override
  _BasketPageState createState() => _BasketPageState();
}

class _BasketPageState extends State<BasketPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController? _controller;
  List<StyleModel>? _styles;

  final double _tax = 0;
  final double _delivery = 0;
  bool _populate = false;
  Payments _payment = Payments.credit_card;


  @override
  void initState() {
    super.initState();
    final provider = Provider.of<BasketNotifier>(context, listen: false);
    _populate = provider.size > 0;
    provider.addListener(() {
      setState(() {
        _populate = provider.size > 0;
      });
    });
    _controller = ScrollController();
    _fetch();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Adress>? addresses = currentUser != null ? currentUser!.addresses : [];
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: FillColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.text('your_basket')),
        elevation: 0,
        foregroundColor: Theme.of(context).primaryColor,
        backgroundColor: Colors.white
      ),
      body: SingleChildScrollView(
        child: Consumer<BasketNotifier>(
          builder: (context, snapshot, child)  {
            if (snapshot.baskets.isEmpty) {
              return EmptyContainer(
                image: Icon(Icons.shopping_cart_outlined, size: 80, color: Theme.of(context).primaryColor),
                message: AppLocalizations.of(context)!.text('basket_empty')
              );
            }
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start ,
              children: <Widget>[
                ListView.builder(
                  controller: _controller,
                  itemCount: snapshot.baskets.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    BasketModel model = snapshot.baskets[index];
                    return _item(model, index);
                  },
                ),
                const Divider(height: 10),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(AppLocalizations.of(context)!.text('delivery_addresses'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
                ),
                for(Adress address in addresses!) ListTileTheme(
                  tileColor: Colors.white,
                  child: RadioListTile<Adress>(
                    contentPadding: EdgeInsets.zero,
                    value: address,
                    groupValue: address,
                    title: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding:  const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                if (address.name != null) Text(address.name!),
                                if (address.address != null) Text(address.address!),
                                if (address.city != null) Text('${address.city!}, ${address.zip!}'),
                                if (address.phone != null) Text(address.phone!)
                              ],
                            )
                          )
                        ),
                        Container(
                          color: Colors.white,
                          child: TextButton(
                            child: Text(AppLocalizations.of(context)!.text('modify'), style: TextStyle(color: Theme.of(context).primaryColor)),
                            onPressed: () {
                              _modifyAdress(address);
                            }
                          ),
                        )
                      ]
                    ),
                    onChanged: (Adress? value) {
                    },
                  ),
                ),
                const Divider(height: 10),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(AppLocalizations.of(context)!.text('payment_method'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
                ),
                for(Payment payment in Payment.currentPlatform) ListTileTheme(
                  tileColor: Colors.white,
                  child: RadioListTile<Payments>(
                    contentPadding: EdgeInsets.zero,
                    value: payment.payment,
                    groupValue: _payment,
                    title: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            child: Text(AppLocalizations.of(context)!.text(payment.payment.toString().toLowerCase()))
                          )
                        ),
                        if (payment.payment == Payments.credit_card) Container(
                          color: Colors.white,
                          child: TextButton(
                            child: Text(AppLocalizations.of(context)!.text('add'), style: TextStyle(color: Theme.of(context).primaryColor)),
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) {
                                return PaymentsPage();
                              }));
                            },
                          ),
                        )
                      ]
                    ),
                    onChanged: (Payments? value) {
                      setState(() {
                        _payment = value!;
                      });
                    },
                  ),
                ),
                const Divider(height: 10),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(AppLocalizations.of(context)!.text('order_summary'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
                ),
                Container(
                  color : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppLocalizations.of(context)!.text('delivery'), style: const TextStyle(fontSize: 16)),
                      _delivery > 0 ? Text('${_delivery.toStringAsPrecision(3)} €', style: const TextStyle(fontSize: 16)) : Text(AppLocalizations.of(context)!.text('free'), style: TextStyle(fontSize: 15, color: Theme.of(context).primaryColor))
                    ],
                  )
                ),
                Container(
                  color : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppLocalizations.of(context)!.text('tax'), style: const TextStyle(fontSize: 16)),
                      _tax > 0 ? Text('${_tax.toStringAsPrecision(3)} €', style: const TextStyle(fontSize: 16)) : Text(AppLocalizations.of(context)!.text('included'), style: TextStyle(fontSize: 15, color: Theme.of(context).primaryColor))
                    ],
                  )
                ),
                Container(
                  color : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppLocalizations.of(context)!.text('total_price'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      snapshot.total > 0 ? Text('${snapshot.total.toStringAsPrecision(3)} €', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)) : Text(AppLocalizations.of(context)!.text('free'), style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor))
                    ],
                  )
                )
              ]
            );
          }
        )
      ),
      bottomNavigationBar: _populate ? Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: TextButton(
          child: Text(sprintf(AppLocalizations.of(context)!.text('continue_with'), [AppLocalizations.of(context)!.text(_payment.toString().toLowerCase())])),
          style:  TextButton.styleFrom(
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
          onPressed: () {
          },
        ),
      ) : null
    );
  }

  Widget _item(BasketModel model, index) {
    return FutureBuilder<ProductModel?>(
      future: Database().getProduct(model.product!),
      builder: (BuildContext context, AsyncSnapshot snapshot1) {
        Widget image = Image.asset('assets/images/no_image.png');
        if (snapshot1.hasData) {
          if (snapshot1.data.image != null && snapshot1.data.image.url != null) {
            image = CustomImage.network(snapshot1.data.image.url!, height: 60, width: 50, fit: BoxFit.cover,
              cache: currentUser != null && currentUser!.isAdmin() == false
            );
          }
          return ListTile(
            tileColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            leading: image,
            title: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                snapshot1.data.name,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                FutureBuilder<ReceiptModel?>(
                  future: Database().getReceipt(snapshot1.data.receipt!),
                  builder: (BuildContext context, AsyncSnapshot snapshot2) {
                    if (snapshot2.hasData) {
                      return RichText(
                        textAlign: TextAlign.left,
                        text: TextSpan(
                          style: DefaultTextStyle.of(context).style,
                          children: <TextSpan>[
                            TextSpan(text: _style(snapshot2.data.style), style: const TextStyle(fontWeight: FontWeight.bold)),
                            const TextSpan(text: ' - '),
                            TextSpan(
                              style: DefaultTextStyle.of(context).style,
                              children: <TextSpan>[
                                const TextSpan(text: ' IBU: '),
                                TextSpan(text: snapshot2.data.localizedIBU(AppLocalizations.of(context)!.locale) ),
                                TextSpan(text: '    ${snapshot2.data.localizedABV(AppLocalizations.of(context)!.locale)}%')
                              ]
                            )
                          ],
                        ),
                      );
                    }
                    return Container();
                  },
                ),
                Text('${snapshot1.data.price!.toStringAsPrecision(3)} €', style: TextStyle(color: Theme.of(context).primaryColor)),
              ]
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 45,
                  height: 45,
                  // padding: EdgeInsets.all(12),
                  decoration: ShapeDecoration(
                    shape: CircleBorder(
                        side: BorderSide(width: 1, color: Theme.of(context).primaryColor)
                    ),
                  ),
                  child: Center(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: DefaultTextStyle.of(context).style,
                        children: <TextSpan>[
                          const TextSpan(text: '×', style: TextStyle(fontSize: 16)),
                          TextSpan(text: model.quantity!.toString(), style: const TextStyle(fontSize: 16)),
                        ]
                      )
                    )
                  )
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  tooltip: AppLocalizations.of(context)!.text('options'),
                  onSelected: (value) {
                    if (value == 'modify') {
                      ModalBottomSheet.showAddToCart(context, snapshot1.data, basket: model);
                    } else if (value == 'remove') {
                      Provider.of<BasketNotifier>(context, listen: false).remove(model);
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    PopupMenuItem(
                      value: 'modify',
                      child: Text(AppLocalizations.of(context)!.text('modify')),
                    ),
                    PopupMenuItem(
                      value: 'remove',
                      child: Text(AppLocalizations.of(context)!.text('remove')),
                    ),
                  ]
                )
              ]
            ),
          );
        }
        return Container();
      }
    );
  }

  _fetch() async {
    _styles  = await Database().getStyles( ordered: true);
  }

  String _style(String? uuid) {
    for (StyleModel model in _styles!) {
      if (model.uuid == uuid) {
        return AppLocalizations.of(context)!.localizedText(model.name);
      }
    }
    return '';
  }

  _modifyAdress(Adress model) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return FormAddressPage(model);
    })).then((value) {
      if (value != null) {
        setState(() {
          Database().update(currentUser).then((value) async {
            _showSnackbar(AppLocalizations.of(context)!.text('saved_address'));
          }).onError((e,s) {
            _showSnackbar(e.toString());
          });
        });
      }
    });
  }

  _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 10)
      )
    );
  }
}

