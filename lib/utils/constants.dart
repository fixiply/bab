import 'package:flutter/material.dart';

// Internal package
import 'package:bb/models/user_model.dart';

const String APP_NAME = 'BB';
const String BUNDLE_IDENTIFIER = 'com.fixiply.ucb';
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

//User Global
UserModel? currentUser;

//Enums
enum Status { pending, publied, disabled}
enum Roles { admin, editor, customer}
enum Fermentation { hight, low, spontaneous}
enum Sort { asc_date, desc_date, asc_name, desc_name, asc_size, desc_size}

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

final List<Color> EBC = [
  Color.fromARGB(255, 250, 250, 210),
  Color.fromARGB(255, 250, 250, 160),
  Color.fromARGB(255, 250, 250, 133),
  Color.fromARGB(255, 250, 250, 105),
  Color.fromARGB(255, 250, 250, 78),
  Color.fromARGB(255, 245, 246, 50),
  Color.fromARGB(255, 240, 238, 46),
  Color.fromARGB(255, 235, 228, 47),
  Color.fromARGB(255, 230, 218, 48),
  Color.fromARGB(255, 224, 206, 50),
  Color.fromARGB(255, 219, 196, 51),
  Color.fromARGB(255, 214, 186, 52),
  Color.fromARGB(255, 209, 176, 54),
  Color.fromARGB(255, 204, 166, 55),
  Color.fromARGB(255, 200, 156, 56),
  Color.fromARGB(255, 197, 146, 56),
  Color.fromARGB(255, 195, 139, 56),
  Color.fromARGB(255, 192, 136, 56),
  Color.fromARGB(255, 192, 132, 56),
  Color.fromARGB(255, 192, 128, 56),
  Color.fromARGB(255, 192, 124, 56),
  Color.fromARGB(255, 192, 120, 56),
  Color.fromARGB(255, 192, 116, 56),
  Color.fromARGB(255, 192, 112, 56),
  Color.fromARGB(255, 192, 109, 56),
  Color.fromARGB(255, 188, 105, 56),
  Color.fromARGB(255, 183, 101, 56),
  Color.fromARGB(255, 178, 97, 56),
  Color.fromARGB(255, 171, 94, 55),
  Color.fromARGB(255, 164, 90, 53),
  Color.fromARGB(255, 157, 86, 52),
  Color.fromARGB(255, 149, 82, 51),
  Color.fromARGB(255, 141, 77, 49),
  Color.fromARGB(255, 134, 73, 46),
  Color.fromARGB(255, 127, 69, 43),
  Color.fromARGB(255, 119, 66, 39),
  Color.fromARGB(255, 112, 62, 36),
  Color.fromARGB(255, 105, 58, 31),
  Color.fromARGB(255, 98, 54, 25),
  Color.fromARGB(255, 91, 51, 19),
  Color.fromARGB(255, 84, 47, 13),
  Color.fromARGB(255, 77, 43, 8),
  Color.fromARGB(255, 69, 39, 11),
  Color.fromARGB(255, 62, 36, 13),
  Color.fromARGB(255, 54, 31, 16),
  Color.fromARGB(255, 47, 27, 19),
  Color.fromARGB(255, 39, 24, 21),
  Color.fromARGB(255, 36, 21, 20),
  Color.fromARGB(255, 33, 20, 19),
  Color.fromARGB(255, 31, 18, 17),
  Color.fromARGB(255, 28, 16, 15),
  Color.fromARGB(255, 28, 15, 14),
  Color.fromARGB(255, 23, 13, 12),
  Color.fromARGB(255, 21, 11, 10),
  Color.fromARGB(255, 18, 10, 9),
  Color.fromARGB(255, 16, 8, 7),
  Color.fromARGB(255, 13, 6, 5),
  Color.fromARGB(255, 11, 5, 4),
  Color.fromARGB(255, 9, 3, 2),
  Color.fromARGB(255, 6, 2, 1),
];

final List<Color> SRM = [
  const Color(0xFFFFE699),
  const Color(0xFFFFD878),
  const Color(0xFFFFCA5A),
  const Color(0xFFFFBF42),
  const Color(0xFFFBB123),
  const Color(0xFFF8A600),
  const Color(0xFFF39C00),
  const Color(0xFFEA8F00),
  const Color(0xFFE58500),
  const Color(0xFFDE7C00),
  const Color(0xFFD77200),
  const Color(0xFFCF6900),
  const Color(0xFFCB6200),
  const Color(0xFFC35900),
  const Color(0xFFBB5100),
  const Color(0xFFB54C00),
  const Color(0xFFB04500),
  const Color(0xFFA63E00),
  const Color(0xFFA13700),
  const Color(0xFF9B3200),
  const Color(0xFF952D00),
  const Color(0xFF8E2900),
  const Color(0xFF882300),
  const Color(0xFF821E00),
  const Color(0xFF7B1A00),
  const Color(0xFF771900),
  const Color(0xFF701400),
  const Color(0xFF6A0E00),
  const Color(0xFF660D00),
  const Color(0xFF5E0B00),
  const Color(0xFF5A0A02),
  const Color(0xFF600903),
  const Color(0xFF520907),
  const Color(0xFF4C0505),
  const Color(0xFF470606),
  const Color(0xFF440607),
  const Color(0xFF3F0708),
  const Color(0xFF3B0607),
  const Color(0xFF3A070B),
  const Color(0xFF36080A),
];