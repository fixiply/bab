import 'package:flutter/material.dart';

// Internal package
import 'package:bb/controller/forms/form_receipt_page.dart';
import 'package:bb/models/receipt_model.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/utils/edition_notifier.dart';

// External package
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';

class ReceiptPage extends StatefulWidget {
  final ReceiptModel model;
  ReceiptPage(this.model);
  _ReceiptPageState createState() => new _ReceiptPageState();
}

class _ReceiptPageState extends State<ReceiptPage> {
  // Edition mode
  bool _editable = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            expandedHeight: 250.0,
            foregroundColor: Theme.of(context).primaryColor,
            backgroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: EdgeInsets.only(left: 160),
              title: Text(widget.model.title!, style: TextStyle(color: Theme.of(context).primaryColor)),
              background: Stack(
                children: [
                  Container(
                    padding: EdgeInsets.only(left:20),
                    child: Image.asset('assets/images/beer3.png',
                      color: SRM[widget.model.getSRM()]
                      // fit: BoxFit.fill,
                      // colorBlendMode: BlendMode.modulate
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left:20),
                    child: Image.asset('assets/images/beer2.png'),
                  ),
                ]
              ),
            ),
            actions: <Widget> [
              if (_editable && currentUser != null && currentUser!.isEditor()) IconButton(
                icon: Icon(Icons.edit_note),
                onPressed: () {
                  _edit(widget.model);
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.all(8),
              child: MarkdownBody(data: widget.model.text!, softLineBreak: true)
            )
          )
        ]
      )
    );
  }

  _initialize() async {
    final provider = Provider.of<EditionNotifier>(context, listen: false);
    _editable = provider.editable;
  }

  _edit(ReceiptModel model) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return FormReceiptPage(model);
    }));
  }
}