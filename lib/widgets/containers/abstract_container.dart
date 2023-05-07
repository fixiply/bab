import 'package:flutter/material.dart';

// Internal package
import 'package:bb/utils/constants.dart';
import 'package:bb/controller/product_page.dart';
import 'package:bb/models/product_model.dart';
import 'package:bb/utils/rating.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/database.dart';
import 'package:bb/widgets/custom_image.dart';
import 'package:bb/widgets/modal_bottom_sheet.dart';

// External package
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:parallax_animation/parallax_area.dart';

class AbstractContainer extends StatefulWidget {
  final String? company;
  final String? receipt;
  final int? product;
  AbstractContainer({this.company, this.receipt, this.product});

  AbstractContainerState createState() => new AbstractContainerState();
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
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: TextButton(
          child: Text(AppLocalizations.of(context)!.text('select_dates')),
          style:  TextButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Theme.of(context).primaryColor,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
          onPressed: () {
            ModalBottomSheet.showCalendar(context, model);
          },
        ),
      );
    }
    return SizedBox(
      width: 100,
      child: TextButton(
        child: Text('${model.price!.toStringAsPrecision(3)} €', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
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
    if (list != null && list.length > 0) {
      for(ProductModel product in list) {
        double rating = 0;
        List<Rating>? values = await Database().getRatings(beer: product.uuid);
        if (values != null && values.length > 0) {
          for (Rating model in values) {
            rating += model.rating!;
          }
          rating = rating / values.length;
        }
        setState(() {
          notices[product.uuid!] = values != null ? values.length : 0;
          ratings[product.uuid!] = rating;
        });
      }
    }
  }
}