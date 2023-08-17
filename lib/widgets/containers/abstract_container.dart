import 'package:flutter/material.dart';

// Internal package
import 'package:bab/models/product_model.dart';
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/utils/database.dart';
import 'package:bab/utils/rating.dart';
import 'package:bab/widgets/modal_bottom_sheet.dart';

// External package

class AbstractContainer extends StatefulWidget {
  final String? company;
  final String? receipt;
  final int? product;
  AbstractContainer({this.company, this.receipt, this.product});

  @override
  AbstractContainerState createState() => AbstractContainerState();
}


class AbstractContainerState extends State<AbstractContainer> {
  Future<List<ProductModel>>? products;
  Map<String, double> ratings = Map<String, double>();
  Map<String, int> notices = Map<String, int>();

  @override
  void initState() {
    super.initState();
    fetch();
  }

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }

  Widget button(ProductModel model) {
    if (widget.product == Product.booking.index) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(18)),
          child: Text(AppLocalizations.of(context)!.text('select_dates')),
          onPressed: () async {
            ModalBottomSheet.showCalendar(context, model);
          },
        ),
      );
    }
    return SizedBox(
      width: 100,
      child: TextButton(
        child: Text('${model.price!.toStringAsPrecision(3)} €', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        style: TextButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
          side: BorderSide(color: Theme.of(context).primaryColor),
        )),
        onPressed: () {
          ModalBottomSheet.showAddToCart(context, model);
        },
      )
    );
  }

  fetch() async {
    Product product = widget.product != null ? Product.values.elementAt(widget.product!) : Product.article;
    setState(() {
      products = Database().getProducts(product: product, company: widget.company, receipt: widget.receipt, ordered: true);
    });
    calculate();
  }

  calculate() async {
    List<ProductModel>? list = await products;
    notices.clear();
    ratings.clear();
    if (list != null && list.isNotEmpty) {
      for(ProductModel product in list) {
        double rating = 0;
        List<Rating>? values = await Database().getRatings(beer: product.uuid);
        if (values.isNotEmpty) {
          for (Rating model in values) {
            rating += model.rating!;
          }
          rating = rating / values.length;
        }
        setState(() {
          notices[product.uuid!] = values.length;
          ratings[product.uuid!] = rating;
        });
      }
    }
  }
}