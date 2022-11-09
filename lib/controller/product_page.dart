import 'package:flutter/material.dart';

// Internal package
import 'package:bb/controller/basket_page.dart';
import 'package:bb/utils/basket_notifier.dart';
import 'package:bb/controller/forms/form_product_page.dart';
import 'package:bb/helpers/date_helper.dart';
import 'package:bb/models/product_model.dart';
import 'package:bb/models/rating_model.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/utils/database.dart';
import 'package:bb/utils/edition_notifier.dart';
import 'package:bb/widgets/containers/image_container.dart';
import 'package:bb/widgets/modal_bottom_sheet.dart';
import 'package:bb/widgets/paints/bezier_clipper.dart';
import 'package:bb/widgets/paints/circle_clipper.dart';
import 'package:flutter/rendering.dart';

// External package
import 'package:badges/badges.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:sprintf/sprintf.dart';

class ProductPage extends StatefulWidget {
  final ProductModel model;
  ProductPage(this.model);
  _ProductPageState createState() => new _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  GlobalKey _keyReviews = GlobalKey();
  final ScrollController _controller = ScrollController();
  int _baskets = 0;

  // Edition mode
  bool _editable = false;
  bool _features = true;
  bool _reviews = true;

  double _rating = 0;
  int _notices = 0;
  Future<List<RatingModel>>? _ratings;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _controller,
        slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            expandedHeight: 250.0,
            foregroundColor: Colors.white,
            backgroundColor: Theme.of(context).primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: EdgeInsets.only(left: 140),
              title: Text(widget.model.title!),
              background: Stack(
                children: [
                  Opacity( //semi red clippath with more height and with 0.5 opacity
                    opacity: 0.5,
                    child: ClipPath(
                      clipper: BezierClipper(), //set our custom wave clipper
                      child:Container(
                        color: Colors.black,
                        height: 200,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.only(left: 30),
                        child: ImageContainer(widget.model.image, width: null, height: null, color: Colors.transparent),
                      ),
                      Expanded(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            ClipPath(
                              clipper: CircleClipper(), //set our custom wave clipper
                              child: Container(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_rating > 0) Text(_rating.toStringAsPrecision(2), style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white)),
                                RatingBar.builder(
                                  initialRating: _rating,
                                  direction: Axis.horizontal,
                                  allowHalfRating: true,
                                  itemCount: 5,
                                  itemSize: 18,
                                  itemPadding: EdgeInsets.zero,
                                  itemBuilder: (context, _) => Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                  ),
                                  tapOnlyMode: true,
                                  ignoreGestures: false,
                                  onRatingUpdate: (rating) async {
                                    RenderBox box = _keyReviews.currentContext!.findRenderObject() as RenderBox;
                                    Offset position = box.localToGlobal(Offset.zero); //this is global position
                                    _controller.animateTo(
                                      position.dy,
                                      duration: Duration(seconds: 1),
                                      curve: Curves.fastOutSlowIn,
                                    );
                                    // dynamic? rating = await showDialog(
                                    //     context: context,
                                    //     builder: (BuildContext context) {
                                    //       return RatingDialog(
                                    //           RatingModel(
                                    //               creator: currentUser!.user!.uid,
                                    //               name: currentUser!.user!.displayName,
                                    //               beer: widget.model.uuid,
                                    //               rating: 0
                                    //           ),
                                    //           maxLines: 3
                                    //       );
                                    //     }
                                    // );
                                    // if (rating != null) {
                                    //   Database().update(rating).then((value) async {
                                    //     _showSnackbar(AppLocalizations.of(context)!.text('saved_review'));
                                    //     _fetch();
                                    //   }).onError((e,s) {
                                    //     _showSnackbar(e.toString());
                                    //   });
                                    // }
                                  },
                                ),
                                Text('${_notices} ${AppLocalizations.of(context)!.text('reviews')}', style: TextStyle(color: Colors.white)),
                                const SizedBox(height: 10),
                                Stack(
                                  children: [
                                    Image.asset('assets/images/sale.png', width: 80, color: Colors.black38),
                                    Positioned(
                                        left: 22,
                                        top: 9,
                                        child: Text('${widget.model.price!.toStringAsPrecision(3)} €', style: TextStyle(fontSize: 16, color: Colors.white))
                                    )
                                  ],
                                )
                              ],
                            ),
                          ]
                        ),
                      )
                    ]
                  )
                ]
              ),
            ),
            actions: <Widget> [
              Badge(
                position: BadgePosition.topEnd(top: 0, end: 3),
                animationDuration: Duration(milliseconds: 300),
                animationType: BadgeAnimationType.slide,
                showBadge: _baskets > 0,
                badgeContent: _baskets > 0 ? Text(
                  _baskets.toString(),
                  style: TextStyle(color: Colors.white),
                ) : null,
                child: IconButton(
                  icon: Icon(Icons.shopping_cart_outlined),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return BasketPage();
                    }));
                  },
                ),
              ),
              if (_editable && currentUser != null && currentUser!.isAdmin()) IconButton(
                icon: Icon(Icons.edit_note),
                onPressed: () {
                  _edit(widget.model);
                },
              ),
            ],
          ),
          if (widget.model.text!.isNotEmpty) SliverToBoxAdapter(
            child: ExpansionPanelList(
              elevation: 1,
              expansionCallback: (int index, bool isExpanded) {
                setState(() {
                  _features = !isExpanded;
                });
              },
              children: [
                ExpansionPanel(
                  isExpanded: _features,
                  canTapOnHeader: true,
                  headerBuilder: (context, isExpanded) {
                    return ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                      title: Text(AppLocalizations.of(context)!.text('features'), style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                    );
                  },
                  body: Container(
                    padding: EdgeInsets.only(bottom: 12, left: 12, right: 12),
                    child: MarkdownBody(data: widget.model.text!, softLineBreak: true,
                      styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
                          .copyWith(textScaleFactor: 1.2, textAlign: WrapAlignment.start),)
                  ),
                )
              ]
            )
          ),
          FutureBuilder<List<RatingModel>>(
            future: _ratings,
            builder: (context, snapshot) {
              if (snapshot.data != null && snapshot.data!.isNotEmpty) {
                return SliverToBoxAdapter(
                  child: ExpansionPanelList(
                    elevation: 1,
                    expansionCallback: (int index, bool isExpanded) {
                      setState(() {
                        _reviews = !isExpanded;
                      });
                    },
                    children: [
                      ExpansionPanel(
                        isExpanded: _reviews,
                        canTapOnHeader: true,
                        headerBuilder: (context, isExpanded) {
                          return ListTile(
                            key: _keyReviews,
                            dense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                            title: Text(AppLocalizations.of(context)!.text('customer_reviews'), style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                          );
                        },
                        body: Container(
                          padding: EdgeInsets.only(bottom: 12, left: 12, right: 12),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text(_rating.toStringAsPrecision(2), style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                                  Padding(padding: EdgeInsets.only(left: 12),
                                    child: Column(
                                      children: [
                                        RatingBar.builder(
                                          initialRating: _rating,
                                          direction: Axis.horizontal,
                                          allowHalfRating: true,
                                          itemCount: 5,
                                          itemSize: 18,
                                          itemPadding: EdgeInsets.zero,
                                          itemBuilder: (context, _) => Icon(
                                            Icons.star,
                                            color: Colors.amber,
                                          ),
                                          ignoreGestures: false,
                                          onRatingUpdate: (rating) async {
                                          },
                                        ),
                                        Text('${_notices} ${AppLocalizations.of(context)!.text(_notices > 1 ? 'ratings' : 'rating')}'),
                                      ],
                                    )
                                  )
                                ],
                              ),
                              ListView(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                children: [
                                  for(RatingModel model in snapshot.data!) Container(
                                    padding: EdgeInsets.all(8),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ListTile(
                                          dense: true,
                                          contentPadding : EdgeInsets.zero,
                                          leading: CircleAvatar(
                                            backgroundColor: Colors.black12,
                                            child: Text(model.name![0], style: TextStyle(color: Colors.black)),
                                          ),
                                          title: Text(model.name ?? '?', style: TextStyle(fontWeight: FontWeight.bold)),
                                          subtitle: Row(
                                            children: [
                                              RatingBar.builder(
                                                initialRating: model.rating!,
                                                direction: Axis.horizontal,
                                                allowHalfRating: true,
                                                itemCount: 5,
                                                itemSize: 18,
                                                itemPadding: EdgeInsets.zero,
                                                itemBuilder: (context, _) => Icon(
                                                  Icons.star,
                                                  color: Colors.amber,
                                                ),
                                                ignoreGestures: false,
                                                onRatingUpdate: (rating) async {
                                                },
                                              ),
                                              Text(' - ', style: TextStyle(fontWeight: FontWeight.bold)),
                                              Text('${AppLocalizations.of(context)!.text('the')} ${DateHelper.formatShortDate(context, model.inserted_at)}'),
                                            ],
                                          ),
                                        ),
                                        if (model.comment != null) Text(model.comment!),
                                      ]
                                    )
                                  )
                                ]
                              )
                            ],
                          ),
                        ),
                      )
                    ]
                  )
                );
              }
              return SliverToBoxAdapter();
            }
          ),
        ]
      ),
      bottomNavigationBar: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: TextButton(
          child: Text(AppLocalizations.of(context)!.text('buy_now')),
          style:  TextButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Theme.of(context).primaryColor,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
          onPressed: () {
            ModalBottomSheet.showAddToCart(context, widget.model);
          },
        ),
      ),
    );
  }

  _initialize() async {
    final editionProvider = Provider.of<EditionNotifier>(context, listen: false);
    _editable = editionProvider.editable;
    final basketProvider = Provider.of<BasketNotifier>(context, listen: false);
    _baskets = basketProvider.size;
    basketProvider.addListener(() {
      if (!mounted) return;
      setState(() {
        _baskets = basketProvider.size;
      });
    });
    _fetch();
  }

  _fetch() async {
    setState(() {
      _ratings = Database().getRatings(beer: widget.model.uuid);
    });
    _calculate();
  }

  _calculate() async {
    double rating = 0;
    List<RatingModel>? list = await _ratings;
    if (list != null && list.length > 0) {
      for(RatingModel model in list) {
        rating += model.rating!;
      }
      rating = rating / list.length;
    }
    setState(() {
      _notices = list != null ? list.length : 0;
      _rating = rating;
    });
  }

  _edit(ProductModel model) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return FormProductPage(model);
    }));
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