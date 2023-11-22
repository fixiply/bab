import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Internal package
import 'package:bab/controller/home_page.dart';
import 'package:bab/firebase_options.dart';
import 'package:bab/helpers/device_helper.dart';
import 'package:bab/models/user_model.dart';
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/utils/basket_notifier.dart';
import 'package:bab/utils/changes_notifier.dart';
import 'package:bab/utils/constants.dart';
import 'package:bab/utils/database.dart';
import 'package:bab/utils/device.dart';
import 'package:bab/utils/edition_notifier.dart';
import 'package:bab/utils/locale_notifier.dart';
import 'package:bab/utils/notification_service.dart';
import 'package:bab/utils/user_notifier.dart';
import 'package:bab/widgets/builders/carousel_builder.dart';
import 'package:bab/widgets/builders/chatgpt_builder.dart';
import 'package:bab/widgets/builders/list_builder.dart';
import 'package:bab/widgets/builders/markdown_builder.dart';
import 'package:bab/widgets/builders/parallax_builder.dart';
import 'package:bab/widgets/builders/subscription_builder.dart';

// External package
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:json_dynamic_widget/json_dynamic_widget.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';

final StreamController<String?> selectNotificationStream = StreamController<String?>.broadcast();
String? selectedNotificationPayload;

final BasketNotifier basketNotifier = BasketNotifier();
final ChangesNotifier changesNotifier = ChangesNotifier();
final LocaleNotifier localeNotifier = LocaleNotifier();
final UserNotifier userNotifier = UserNotifier();
final ValuesNotifier editionNotifier = ValuesNotifier();

var logger = Logger();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Notifications().initialize();
  // showNotification(message);
  debugPrint('[$APP_NAME] Handling a background message ${message.messageId}');
}

Future<void> showNotification(RemoteMessage message) async {
  RemoteNotification? notification = message.notification;
  if (notification != null) {
    String? id = message.data['id'];
    NotificationService.instance.showNotification(
      id != null ? id.hashCode : 0,
      title: notification.title,
      body: notification.body,
      payload: id
    );
  }
}

@pragma('vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) {
    print("Native called background task: $task"); //simpleTask will be emitted here.
    return Future.value(true);
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  _configureFirebaseMessaging();
  if (!foundation.kIsWeb) {
    NotificationService.instance.initialize();
    Workmanager().initialize(
      callbackDispatcher, // The top level function, aka callbackDispatcher
    );
  }
  FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true, cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED);
  await dotenv.load(fileName: 'assets/.env');
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => basketNotifier),
        ChangeNotifierProvider(create: (_) => changesNotifier),
        ChangeNotifierProvider(create: (_) => editionNotifier),
        ChangeNotifierProvider(create: (_) => localeNotifier),
        ChangeNotifierProvider(create: (_) => userNotifier),
      ],
      child: MyApp()),
  );
}

void _configureFirebaseMessaging() async {
  // Set the background messaging handler early on, as a named top-level function
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
}

class MyApp extends StatefulWidget {
  MyApp({ Key? key }) : super(key: key);
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<MyApp> {
  TranslationsDelegate? _newLocaleDelegate;

  @override
  void initState() {
    super.initState();
    _newLocaleDelegate = const TranslationsDelegate(newLocale: null);
    _initialize();
    _authStateChanges();
    _subscribe();
    _initBuilders();
    final localeNotifier = Provider.of<LocaleNotifier>(context, listen: false);
    localeNotifier.addListener(() {
      if (!mounted) return;
      onLocaleChange(localeNotifier.locale!);
    });
  }

  void onLocaleChange(Locale locale) {
    setState(() {
      _newLocaleDelegate = TranslationsDelegate(newLocale: locale);
    });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ThemeData(
      fontFamily: 'Montserrat',
      brightness: Brightness.light,
      primaryColor: PrimaryColor,
      primaryColorLight: PrimaryColorLight,
      primaryColorDark: PrimaryColorDark,
      bottomAppBarTheme: const BottomAppBarTheme(color: PrimaryColor),
      // navigationBarTheme: const NavigationBarThemeData(backgroundColor: PrimaryColor),
    );
    return MaterialApp(
      onGenerateTitle: (BuildContext context) => AppLocalizations.of(context)!.text('app_title'),
      debugShowCheckedModeBanner: false,
      theme: theme.copyWith(
        colorScheme: theme.colorScheme.copyWith(
          primary: PrimaryColor,
          secondary: PrimaryColor,
          onPrimary: Colors.white,
          background: PrimaryColor
        ),
        appBarTheme: theme.appBarTheme.copyWith(
            backgroundColor: PrimaryColor,
        ),
        // inputDecorationTheme: theme.inputDecorationTheme.copyWith(focusColor: PrimaryColor),
      ),
      home: HomePage(),
      builder: EasyLoading.init(),
      localizationsDelegates: [
        _newLocaleDelegate!,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'), // English
        Locale('fr', 'FR') // French
      ]
    );
  }

  _initialize() async {
    if (!foundation.kIsWeb) {
      NotificationService.instance.isAndroidPermissionGranted();
      NotificationService.instance.requestPermissions();
    }
  }

  _authStateChanges() async {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      _loadUser(user);
    });
  }

  _loadUser(User? user) async {
    UserModel? model;
    if (user != null && user.emailVerified) {
      model = await Database().getUser(user.uid);
      if (model != null) {
        model.user = user;
        if (!foundation.kIsWeb) {
          Device? device = await _device();
          String? token = await _token();
          if (device != null && token != null) {
            device.token = token;
            if (!model.devices!.contains(device)) {
              model.devices!.add(device);
              Database().update(model);
            }
          }
        }
        logger.d('[$APP_NAME] User "${user.email}" is signed in with "${model.role}".');
      }
    }
    Provider.of<UserNotifier>(context, listen: false).set(model);
    setState(() {
      currentUser = model;
    });
  }

  Future<Device?> _device() async {
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    try {
      if (foundation.kIsWeb) {
        WebBrowserInfo info = await deviceInfoPlugin.webBrowserInfo;
        return Device(name: info.browserName.name, os: 'Web');
      } else {
        if (Platform.isAndroid) {
          AndroidDeviceInfo info = await deviceInfoPlugin.androidInfo;
          if (foundation.kDebugMode) {
            debugPrint(DeviceHelper.readAndroidBuildData(info).toString());
          }
          return Device(name: info.model, os: 'Android');
        } else if (Platform.isIOS) {
          IosDeviceInfo info = await deviceInfoPlugin.iosInfo;
          if (foundation.kDebugMode) {
            debugPrint(DeviceHelper.readIosDeviceInfo(info).toString());
          }
          return Device(name: info.utsname.nodename, os: 'iOS');
        } else if (Platform.isLinux) {
          LinuxDeviceInfo info = await deviceInfoPlugin.linuxInfo;
          if (foundation.kDebugMode) {
            debugPrint(DeviceHelper.readLinuxDeviceInfo(info).toString());
          }
          return Device(name: info.name, os: 'linux');
        } else if (Platform.isMacOS) {
          MacOsDeviceInfo info = await deviceInfoPlugin.macOsInfo;
          if (foundation.kDebugMode) {
            debugPrint(DeviceHelper.readMacOsDeviceInfo(info).toString());
          }
          return Device(name: info.computerName, os: 'macOS');
        } else if (Platform.isWindows) {
          WindowsDeviceInfo info = await deviceInfoPlugin.windowsInfo;
          if (foundation.kDebugMode) {
            debugPrint(DeviceHelper.readWindowsDeviceInfo(info).toString());
          }
          return Device(name: info.computerName, os: 'Windows');
        }
      }
    } on PlatformException {
    }
    return null;
  }

  Future<String?> _token() async {
    FirebaseApp app = Firebase.apps.first;
    return await FirebaseMessaging.instance.getToken(
        vapidKey: app.options.apiKey
    );
  }

  Future<void> _subscribe() async {
    if (!DeviceHelper.isDesktop) {
      await FirebaseMessaging.instance.subscribeToTopic(foundation.kDebugMode ? NOTIFICATION_TOPIC_DEBUG : NOTIFICATION_TOPIC);
      logger.d('[$APP_NAME] Firebase messaging subscribe from "${foundation.kDebugMode ? NOTIFICATION_TOPIC_DEBUG : NOTIFICATION_TOPIC}"');
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        showNotification(message);
      });
    }
  }

  _initBuilders() async {
    var registry = JsonWidgetRegistry.instance;
    registry.registerCustomBuilder(
      CarouselBuilder.type,
      const JsonWidgetBuilderContainer(
        builder: CarouselBuilder.fromDynamic
      ),
    );
    registry.registerCustomBuilder(
      ParallaxBuilder.type,
      const JsonWidgetBuilderContainer(
          builder: ParallaxBuilder.fromDynamic
      ),
    );
    registry.registerCustomBuilder(
      ListBuilder.type,
      const JsonWidgetBuilderContainer(
          builder: ListBuilder.fromDynamic
      ),
    );
    registry.registerCustomBuilder(
      MarkdownBuilder.type,
      const JsonWidgetBuilderContainer(
          builder: MarkdownBuilder.fromDynamic
      ),
    );
    registry.registerCustomBuilder(
      ChatGPTBuilder.type,
      const JsonWidgetBuilderContainer(
          builder: ChatGPTBuilder.fromDynamic
      ),
    );
    registry.registerCustomBuilder(
      SubscriptionBuilder.type,
      const JsonWidgetBuilderContainer(
          builder: SubscriptionBuilder.fromDynamic
      ),
    );
    // registry.registerCustomBuilder(
    //   ImageEditorBuilder.type,
    //   JsonWidgetBuilderContainer(
    //       builder: ImageEditorBuilder.fromDynamic
    //   ),
    // );
  }
}
