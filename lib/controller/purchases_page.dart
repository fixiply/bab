import 'package:bab/utils/database.dart';
import 'package:bab/widgets/containers/empty_container.dart';
import 'package:bab/widgets/containers/error_container.dart';
import 'package:bab/widgets/image_animate_rotate.dart';
import 'package:flutter/material.dart';

// Internal package
import 'package:bab/models/purchase_model.dart';
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/utils/constants.dart';

class PurchasesPage extends StatefulWidget {
  @override
  _PurchasesPageState createState() => _PurchasesPageState();
}

class _PurchasesPageState extends State<PurchasesPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController? _controller;
  Future<List<PurchaseModel>>? _purchases;

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
        title: Text(AppLocalizations.of(context)!.text('my_purchases')),
        elevation: 0,
        foregroundColor: Theme.of(context).primaryColor,
        backgroundColor: Colors.white
      ),
      body: FutureBuilder<List<PurchaseModel>>(
        future: _purchases,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.isEmpty) {
              return EmptyContainer(
                image: Icon(Icons.local_offer_outlined, size: 80, color: Theme.of(context).primaryColor),
                message: AppLocalizations.of(context)!.text('no_purchase')
              );
            }
            return ListView.builder(
              controller: _controller,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: snapshot.hasData ? snapshot.data!.length : 0,
              itemBuilder: (context, index) {
                PurchaseModel model = snapshot.data![index];
                return const ListTile(
                );
              }
            );
          }
          if (snapshot.hasError) {
            return ErrorContainer(snapshot.error.toString());
          }
          return Center(
            child: ImageAnimateRotate(
              child: Image.asset('assets/images/logo.png', width: 60, height: 60, color: Theme.of(context).primaryColor),
            )
          );
        }
      ),
    );
  }

  _fetch() async {
    setState(() {
      _purchases = Database().getPurchases(user: currentUser!.uuid);
    });
  }
}

