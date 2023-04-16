import 'package:flutter/material.dart';

// Internal package
import 'package:bb/controller/basket_page.dart';
import 'package:bb/models/product_model.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/basket_notifier.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/utils/database.dart';
import 'package:bb/widgets/custom_menu_button.dart';
import 'package:bb/widgets/days.dart';

// External package
import 'package:table_calendar/table_calendar.dart';
import 'package:badges/badges.dart' as badge;
import 'package:provider/provider.dart';

class CalendarPage extends StatefulWidget {
  _CalendarPageState createState() => new _CalendarPageState();
}

class Event {
  final String title;
  const Event(this.title);
  @override
  String toString() => title;
}


class _CalendarPageState extends State<CalendarPage> with AutomaticKeepAliveClientMixin<CalendarPage> {
  int _baskets = 0;
  Future<List<ProductModel>>? _products;
  late final ValueNotifier<List<Event>> _selectedEvents;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  DateTime? _selectedDay;
  DateTime _focusedDay = DateTime.now();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _initialize();
    _fetch();
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: FillColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.text('calendar')),
        elevation: 0,
        foregroundColor: Theme.of(context).primaryColor,
        backgroundColor: Colors.white,
        actions: [
          badge.Badge(
            position: badge.BadgePosition.topEnd(top: 0, end: 3),
            animationDuration: Duration(milliseconds: 300),
            animationType: badge.BadgeAnimationType.slide,
            showBadge: _baskets > 0,
            badgeContent: _baskets > 0 ? Text(
              _baskets.toString(),
              style: TextStyle(color: Colors.white),
            ) : null,
            child: IconButton(
              icon: Icon(Icons.shopping_cart_outlined),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return BasketPage();
                }));
              },
            ),
          ),
          CustomMenuButton(
            context: context,
            publish: false,
            filtered: false,
            archived: false,
          )
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime.now(),
            lastDay: DateTime.now().add(Duration(days: 90)),
            startingDayOfWeek: StartingDayOfWeek.monday,
            locale: AppLocalizations.of(context)!.text('locale'),
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selected, focused) {
              if (!isSameDay(_selectedDay, selected)) {
                setState(() {
                  _selectedDay = selected;
                  _focusedDay = focused;
                });
              }
            },
            eventLoader: (day) {
              return [ Event('Hello')];
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (BuildContext context, date, events) {
                return Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    width: 20,
                    padding: EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle
                    ),
                    child: Text(events.length.toString(), textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                  )
                );
              },
              selectedBuilder: (context, day, focusedDay) {
                return Days.buildCalendarDayMarker(text: day.day.toString(), backColor: PrimaryColor);
              },
              todayBuilder: (context, day, focusedDay) {
                return Days.buildCalendarDayMarker(text: day.day.toString(), backColor: TextGrey);
              }
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: ValueListenableBuilder<List<Event>>(
              valueListenable: _selectedEvents,
              builder: (context, value, _) {
                return ListView.builder(
                  itemCount: value.length,
                  itemBuilder: (context, index) {
                    return Container();
                  }
                );
              }
            )
          )
        ]
      )
    );
  }

  _initialize() async {
    final basketProvider = Provider.of<BasketNotifier>(context, listen: false);
    _baskets = basketProvider.size;
    basketProvider.addListener(() {
      if (!mounted) return;
      setState(() {
        _baskets = basketProvider.size;
      });
    });
    // _fetch();
  }

  _fetch() async {
    _products = Database().getProducts(product: Product.booking);
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  List<Event> _getEventsForDay(DateTime day) {
    // Implementation example
    return [];
  }

  _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(message),
            duration: Duration(seconds: 10)
        )
    );
  }
}

