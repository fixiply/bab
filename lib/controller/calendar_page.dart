import 'package:bb/models/product_model.dart';
import 'package:bb/utils/database.dart';
import 'package:flutter/material.dart';

// Internal package
import 'package:bb/widgets/days.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/constants.dart';

// External package
import 'package:table_calendar/table_calendar.dart';

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
        backgroundColor: Colors.white
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
              defaultBuilder: (context, day, _) {
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

