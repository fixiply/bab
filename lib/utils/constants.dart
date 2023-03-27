import 'package:bb/utils/app_localizations.dart';
import 'package:flutter/material.dart';

// Internal package
import 'package:bb/models/user_model.dart';

const String APP_NAME = 'BB';
const String BUNDLE_IDENTIFIER = 'com.fixiply.bb';
const String RECIPIENT = 'contact@fixiply.com';
const String PROJECT_ID = 'brasseur-bordelais';
const String BUCKET = '$PROJECT_ID.appspot.com';
const NOTIFICATION_TOPIC = 'default';
const NOTIFICATION_TOPIC_DEBUG = 'debug';

const String EDITION_MODE_KEY = 'edition_mode';
const String EDIT_KEY = 'edit';
const String SIGN_IN_KEY = 'sign_in_email';

const String channelId = 'high_importance_channel';

const String TERMS_CONDITIONS = 'terms/terms_conditions.md';
const String PRIVACY_POLICY = 'terms/privacy_policy.md';

const double DEFAULT_YIELD = 72.0;
const double DEFAULT_LOSS_BOIL = 2.0;
const double DEFAULT_HEAD_LOSS = 2.0;

//User Global
UserModel? currentUser;

mixin Enums<T extends Enum> on Enum {
  List<Enum> get enums;
  String getLabel(BuildContext context) {
    return AppLocalizations.of(context)!.text(this.toString().toLowerCase());
  }
}

//Enums
// enum Fermentable with Enums { grain, sugar, extract,  dry_extract, adjunct, fruit, juice, honey;
//   List<Enum> get enums => [ grain, sugar, extract,  dry_extract, adjunct, fruit, juice, honey ];
// }
enum Fermentation with Enums { hight, low, spontaneous;
  List<Enum> get enums => [ hight, low, spontaneous ];
}
// enum HopType with Enums { aroma, bittering, both;
//   List<Enum> get enums => [ aroma, bittering, both ];
// }
// enum HopUse with Enums { mash, first_wort, boil, aroma, dry_hop;
//   List<Enum> get enums => [ mash, first_wort, boil, aroma, dry_hop ];
// }
// enum Hops with Enums { leaf, pellet, plug, other;
//   List<Enum> get enums => [ leaf, pellet, plug, other ];
// }
enum Ingredient with Enums { fermentable, hops, yeast, misc;
  List<Enum> get enums => [ fermentable, hops, yeast, misc ];
}
// enum Method with Enums { mashed,  steeped;
//   List<Enum> get enums => [ mashed,  steeped ];
// }
// enum Mash with Enums { infusion, temperature, decoction;
//   List<Enum> get enums => [ infusion, temperature, decoction ];
// }
// enum Misc with Enums { spice, fining, water_agent, herb, flavor, other;
//   List<Enum> get enums => [ spice, fining, water_agent, herb, flavor, other ];
// }
// enum MiscUse with Enums { boil, mash, primary, secondary, bottling, sparge;
//   List<Enum> get enums => [ boil, mash, primary, secondary, bottling, sparge ];
// }
enum Payments with Enums { credit_card, paypal, apple_pay, google_pay;
  List<Enum> get enums => [ credit_card, paypal, apple_pay, google_pay ];
}
enum Period { day, week, month, year }
enum Product with Enums { article, booking, other;
  List<Enum> get enums => [ article, booking, other ];
}
enum Role with Enums { admin, editor, customer;
  List<Enum> get enums => [ admin, editor, customer ];
}
enum Sort { asc_date, desc_date, asc_name, desc_name, asc_size, desc_size }
enum Status { pending, publied, disabled }
enum Unit with Enums { weight, volume, pressure, time, temperature;
  List<Enum> get enums => [ weight, volume, pressure, time, temperature ];
}
// enum Yeast with Enums { liquid, dry, slant, culture;
//   List<Enum> get enums => [ liquid, dry, slant, culture ];
// }

//Colors
const Color PrimaryColor = const Color(0xFF008351);
const Color PrimaryColorLight = const Color(0xff4ab47e);
const Color PrimaryColorDark = const Color(0xff005528);
const Color SecondaryColor = const Color(0xFF66bb6a);
const Color SecondaryColorLight = const Color(0xFF98ee99);
const Color SecondaryColorDark = const Color(0xFF66bb6a);
const Color FillColor = const Color(0xFFf3f3f4);
const Color BlendColor = const Color(0x12000000);
const Color TextGrey = Color(0xff94959b);
const Color TextWhiteGrey = Color(0xfff1f1f5);
const Color AccentColor = Colors.blue;
const Color PointerColor = const Color(0xFFff5722);

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

TextStyle heading2 = TextStyle(
  fontSize: 22,
  fontWeight: FontWeight.w700,
);

TextStyle heading5 = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w600,
);

TextStyle heading6 = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w600,
);

TextStyle regular14pt = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w400,
);

TextStyle regular16pt = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w400,
);