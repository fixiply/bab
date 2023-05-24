import 'package:flutter/material.dart';

// Internal package
import 'package:bb/utils/app_localizations.dart';

class EmptyContainer extends StatelessWidget {
  final Widget? image;
  final String? message;

  EmptyContainer({
    this.image,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height; // Full screen width and height
    EdgeInsets padding = MediaQuery.of(context).padding; // Height (without SafeArea)
    double appbar = Scaffold.of(context).appBarMaxHeight ?? kToolbarHeight; // Height (without SafeArea)
    double netHeight = height - padding.top - kBottomNavigationBarHeight - appbar;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: netHeight,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              image ?? Image.asset('assets/images/logo.png', width: 100, height: 100, color: Theme.of(context).primaryColor),
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

  // @override
  // Widget old(BuildContext context) {
  //   return CustomScrollView(
  //     slivers: <Widget>[
  //       SliverFillRemaining(
  //         child: Center(
  //           child: Column(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               Image.asset('assets/images/logo.png', width: 100, height: 100, color: Colors.black38),
  //               Text(message != null ? message! : AppLocalizations.of(context)!.text('empty_list'),
  //                   textAlign: TextAlign.center,
  //                   style: const TextStyle(fontSize: 25, color: Colors.black38)
  //               )
  //             ],
  //           ),
  //         )
  //       )
  //     ]
  //   );
  // }
}
