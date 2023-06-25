import 'package:flutter/material.dart';

// Internal package
import 'package:bab/utils/app_localizations.dart';

class EmptyContainer extends StatelessWidget {
  final Widget? image;
  final String? message;
  final double? size;
  final double? fontSize;
  final double initHeight;

  EmptyContainer({
    this.image,
    this.message,
    this.size = 80,
    this.fontSize = 18,
    this.initHeight = 0,
  });

  @override
  Widget build(BuildContext context) {
    EdgeInsets padding = MediaQuery.of(context).padding; // Height (without SafeArea)
    double appbar = Scaffold.of(context).appBarMaxHeight ?? kToolbarHeight; // Height (without SafeArea)
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double netHeight = constraints.maxHeight - padding.top - kBottomNavigationBarHeight - appbar - initHeight;
        return SizedBox(
          height: netHeight,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(child: image ?? Image.asset('assets/images/logo.png', width: size, height: size, color: Theme.of(context).primaryColor)),
                Text(message != null ? message! : AppLocalizations.of(context)!.text('empty_list'),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.clip,
                  style: TextStyle(fontSize: fontSize, color: Theme.of(context).primaryColor)
                )
              ],
            )
          )
        );
      }
    );
  }
}
