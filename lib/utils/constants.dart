import 'package:flutter/material.dart';

// Internal package
import 'package:bab/models/user_model.dart';
import 'package:bab/utils/app_localizations.dart';

const String APP_NAME = 'BAB';
const String BUNDLE_IDENTIFIER = 'com.fixiply.bab';
const String RECIPIENT = 'contact@beandbrew.com';
const String GUEST = 'guest@beandbrew.com';
const String PROJECT_ID = 'beandbrew';
const String BUCKET = '$PROJECT_ID.appspot.com';
const NOTIFICATION_TOPIC = 'default';
const NOTIFICATION_TOPIC_DEBUG = 'debug';

const String EDITION_MODE_KEY = 'edition_mode';
const String EDIT_KEY = 'edit';
const String SIGN_IN_KEY = 'sign_in_email';
const String REMEMBER_ME = 'remember_me';

const String channelId = 'high_importance_channel';

const String TERMS_CONDITIONS = 'terms/terms_conditions.md';
const String PRIVACY_POLICY = 'terms/privacy_policy.md';

const double DEFAULT_YIELD = 75.0;
const double DEFAULT_BOIL_LOSS = 2.0;
const double DEFAULT_WORT_SHRINKAGE = 1.04;

//User Global
UserModel? currentUser;

mixin Enums<T extends Enum> on Enum implements Comparable<Enum>  {
  List<Enum> get enums;
  String getLabel(BuildContext context) {
    return AppLocalizations.of(context)!.text(toString().toLowerCase());
  }

  @override
  int compareTo(other) {
    return index.compareTo(other.index);
  }
}

enum Measurement with Enums {
  gram(symbol: 'g'),
  kilo(symbol: 'kg'),
  milliliter(symbol: 'ml'),
  liter(symbol: 'l'),
  packages(symbol: 'pkg'),
  units();

  const Measurement({
    this.symbol
  });
  final String? symbol;

  List<Enum> get enums => [ gram, kilo, milliliter, liter, packages, units];
}
enum Style with Enums { hight, low, spontaneous;
  List<Enum> get enums => [ hight, low, spontaneous ];
}
enum Ingredient with Enums { fermentable, hops, yeast, misc;
  List<Enum> get enums => [ fermentable, hops, yeast, misc ];
}
enum Payments with Enums { credit_card, paypal, apple_pay, google_pay;
  List<Enum> get enums => [ credit_card, paypal, apple_pay, google_pay ];
}
enum Period { day, week, month, year }
enum Time with Enums { minutes, hours, days, weeks, month;
  List<Enum> get enums => [ minutes, hours, days, weeks, month];
}
enum Role with Enums { admin, editor, customer;
  List<Enum> get enums => [ admin, editor, customer ];
}
enum Acid { hydrochloric, phosphoric, lactic, sulfuric }
enum Sort { asc_date, desc_date, asc_name, desc_name, asc_size, desc_size }
enum Status { pending, publied, archived }
enum Unit { metric, us }
enum Gravity { sg, plato, brix }
enum Pressure { psi, bar, pascal}

//Colors
const Color PrimaryColor = Color(0xFF008351);
const Color PrimaryColorLight = Color(0xff4ab47e);
const Color PrimaryColorDark = Color(0xff005528);
const Color SecondaryColor = Color(0xFF66bb6a);
const Color SecondaryColorLight = Color(0xFF98ee99);
const Color SecondaryColorDark = Color(0xFF66bb6a);
const Color FillColor = Color(0xFFf3f3f4);
const Color BlendColor = Color(0x12000000);
const Color TextGrey = Color(0xff94959b);
const Color TextWhiteGrey = Color(0xfff1f1f5);
const Color AccentColor = Colors.blue;
const Color PointerColor = Color(0xFFff5722);

const ShimmerGradient = LinearGradient(
  colors: [
    Color(0xFFEBEBF4),
    Color(0xCCF4F4F4),
    Color(0xFFEBEBF4),
  ],
  stops: [ 0.1, 0.3, 0.4 ],
  begin: Alignment(-1.0, -0.3),
  end: Alignment(1.0, 0.3),
  tileMode: TileMode.clamp,
);

TextStyle heading2 = const TextStyle(
  fontSize: 22,
  fontWeight: FontWeight.w700,
);

TextStyle heading5 = const TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w600,
);

TextStyle heading6 = const TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w600,
);

TextStyle regular14pt = const TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w400,
);

TextStyle regular16pt = const TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w400,
);