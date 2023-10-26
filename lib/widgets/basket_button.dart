import 'package:flutter/material.dart';

// Internal package
import 'package:bab/controller/basket_page.dart';
import 'package:bab/utils/basket_notifier.dart';

// External package
import 'package:badges/badges.dart' as badge;
import 'package:provider/provider.dart';

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
    final basketProvider = Provider.of<BasketNotifier>(context, listen: false);
    _baskets = basketProvider.size;
    basketProvider.addListener(() {
      if (!mounted) return;
      setState(() {
        _baskets = basketProvider.size;
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
      child: IconButton(
        padding: EdgeInsets.only(top: 8),
        icon: const Icon(Icons.shopping_cart_outlined),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return BasketPage();
          }));
        },
      ),
    );
  }
}