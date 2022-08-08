import 'package:flutter/material.dart';

// Internal package
import 'package:bb/utils/app_localizations.dart';

class EmptyContainer extends StatelessWidget {
  final String? message;

  EmptyContainer({
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height; // Full screen width and height
    EdgeInsets padding = MediaQuery.of(context).padding; // Height (without SafeArea)
    double appbar = Scaffold.of(context).appBarMaxHeight ?? kToolbarHeight; // Height (without SafeArea)
    double netHeight = height - padding.top - kBottomNavigationBarHeight - appbar;
    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      child: Container(
        height: netHeight,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if ((100 + 40) < netHeight) Image.asset('assets/images/logo.png', width: 100, height: 100, color: Theme.of(context).primaryColor),
              Text(message != null ? message! : AppLocalizations.of(context)!.text('empty_list'),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.clip,
                  style: TextStyle(fontSize: 25, color: Theme.of(context).primaryColor)
              )
            ],
          )
        )
      ),
    );
  }

  @override
  Widget old(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/logo.png', width: 100, height: 100, color: Colors.black38),
                Text(message != null ? message! : AppLocalizations.of(context)!.text('empty_list'),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 25, color: Colors.black38)
                )
              ],
            ),
          )
        )
      ]
    );
  }
}
