import 'package:flutter/material.dart';

// Internal package
import 'package:bab/main.dart';
import 'package:bab/controller/basket_page.dart';
import 'package:bab/utils/app_localizations.dart';

// External package
import 'package:badges/badges.dart' as badge;

class BasketButton extends StatefulWidget {
  const BasketButton({Key? key}) : super(key: key);

  @override
  _BasketButtonState createState() => _BasketButtonState();
}

class _BasketButtonState extends State<BasketButton> with SingleTickerProviderStateMixin {
  int _baskets = 0;

  @override
  void initState() {
    super.initState();
    _baskets = basketNotifier.size;
    basketNotifier.addListener(() {
      if (!mounted) return;
      setState(() {
        _baskets = basketNotifier.size;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return badge.Badge(
      position: badge.BadgePosition.topEnd(top: 0, end: 3),
      badgeAnimation: const badge.BadgeAnimation.slide(
        // animationDuration: const Duration(milliseconds: 300),
      ),
      showBadge: _baskets > 0,
      badgeContent: _baskets > 0 ? Text(
        _baskets.toString(),
        style: const TextStyle(color: Colors.white),
      ) : null,
      child: Center(
        child: IconButton(
          icon: const Icon(Icons.shopping_cart_outlined),
          tooltip: AppLocalizations.of(context)!.text('basket'),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return BasketPage();
            }));
          },
        ),
      ),
    );
  }
}