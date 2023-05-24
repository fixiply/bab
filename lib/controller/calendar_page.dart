import 'package:flutter/material.dart';

// Internal package
import 'package:bb/controller/basket_page.dart';
import 'package:bb/controller/brew_page.dart';
import 'package:bb/helpers/color_helper.dart';
import 'package:bb/helpers/date_helper.dart';
import 'package:bb/models/brew_model.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/basket_notifier.dart';
import 'package:bb/utils/constants.dart' as CS;
import 'package:bb/utils/database.dart';
import 'package:bb/widgets/containers/empty_container.dart';
import 'package:bb/widgets/containers/error_container.dart';
import 'package:bb/widgets/custom_menu_button.dart';
import 'package:bb/widgets/days.dart';

// External package
import 'package:table_calendar/table_calendar.dart';
import 'package:badges/badges.dart' as badge;
import 'package:provider/provider.dart';

import '../models/model.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> with AutomaticKeepAliveClientMixin<CalendarPage> {
  int _baskets = 0;
  Future<List<Model>>? _data;
  final ValueNotifier<List<ListTile>> _selectedEvents = ValueNotifier([]);
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  DateTime? _rangeStart;
  DateTime? _rangeEnd;
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
      backgroundColor: CS.FillColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.text('calendar')),
        elevation: 0,
        foregroundColor: Theme.of(context).primaryColor,
        backgroundColor: Colors.white,
        actions: [
          badge.Badge(
            position: badge.BadgePosition.topEnd(top: 0, end: 3),
            animationDuration: const Duration(milliseconds: 300),
            animationType: badge.BadgeAnimationType.slide,
            showBadge: _baskets > 0,
            badgeContent: _baskets > 0 ? Text(
              _baskets.toString(),
              style: const TextStyle(color: Colors.white),
            ) : null,
            child: IconButton(
              icon: const Icon(Icons.shopping_cart_outlined),
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
      body: RefreshIndicator(
        onRefresh: () => _fetch(),
        child: FutureBuilder<List<Model>>(
          future: _data,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!.isEmpty) {
                return EmptyContainer(message: AppLocalizations.of(context)!.text('no_result'));
              }
              return Column(
                children: [
                  TableCalendar(
                    focusedDay: _focusedDay,
                    firstDay: DateTime.utc(2010, 10, 16),
                    lastDay: DateTime.utc(2030, 3, 14),
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    locale: AppLocalizations.of(context)!.text('locale'),
                    selectedDayPredicate: (day) {
                      return isSameDay(_selectedDay, day);
                    },
                    rangeStartDay: _rangeStart,
                    rangeEndDay: _rangeEnd,
                    onDaySelected: (selected, focused) {
                      if (!isSameDay(_selectedDay, selected)) {
                        setState(() {
                          _selectedDay = selected;
                          _focusedDay = focused;
                        });
                      }
                      _selectedEvents.value = _getEventsForDay(snapshot.data!, selected);
                    },
                    onRangeSelected: (DateTime? start, DateTime? end, DateTime focusedDay) {
                      setState(() {
                        _selectedDay = null;
                        _focusedDay = focusedDay;
                        _rangeStart = start;
                        _rangeEnd = end;
                      });

                      // `start` or `end` could be null
                      if (start != null && end != null) {
                        _selectedEvents.value = _getEventsForRange(snapshot.data!, start, end);
                      } else if (start != null) {
                        _selectedEvents.value = _getEventsForDay(snapshot.data!, start);
                      } else if (end != null) {
                        _selectedEvents.value = _getEventsForDay(snapshot.data!, end);
                      }
                    },
                    eventLoader: (DateTime day) {
                      return _getEventsForDay(snapshot.data!, day);
                    },
                    calendarBuilders: CalendarBuilders(
                      markerBuilder: (BuildContext context, date, events) {
                        if (events.isNotEmpty) {
                          return Align(
                              alignment: Alignment.bottomRight,
                              child: Container(
                                width: 20,
                                padding: const EdgeInsets.all(4.0),
                                decoration: const BoxDecoration(
                                    color: Colors.redAccent,
                                    shape: BoxShape.rectangle
                                ),
                                child: Text(events.length.toString(),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                              )
                          );
                        }
                        return null;
                      },
                      selectedBuilder: (context, day, focusedDay) {
                        return Days.buildCalendarDayMarker(text: day.day.toString(), backColor: CS.PrimaryColor);
                      },
                      todayBuilder: (context, day, focusedDay) {
                        return Days.buildCalendarDayMarker(text: day.day.toString(), backColor: CS.TextGrey);
                      }
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Expanded(
                    child: ValueListenableBuilder<List<ListTile>>(
                      valueListenable: _selectedEvents,
                      builder: (context, value, _) {
                        return ListView.builder(
                          itemCount: value.length,
                          itemBuilder: (context, index) {
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                              child: value[index],
                            );
                          },
                        );
                      }
                    )
                  )
                ]
              );
            }
            if (snapshot.hasError) {
              return ErrorContainer(snapshot.error.toString());
            }
            return const Center(child: CircularProgressIndicator(strokeWidth: 2.0, valueColor:AlwaysStoppedAnimation<Color>(Colors.black38)));
          }
        )
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
  }

  _fetch() async {
    _data = Database().getBrews(user: CS.currentUser!.uuid, ordered: true);
  }

  List<ListTile> _getEventsForDay(List<Model> data, DateTime day) {
    List<Model> brews = data.where((element) {
      if (element is BrewModel) {
        if (DateHelper.toDate(element.started()) == DateHelper.toDate(day)) {
          return true;
        }
        if (element.status != Status.pending &&
            ((element.finish() == DateHelper.toDate(day)) ||
            (element.secondaryDate() == DateHelper.toDate(day)) ||
            (element.secondaryDate() == DateHelper.toDate(day)))) {
          return true;
        }
      }
      return false;
    }).toList();
    return brews.map((e) {
      Color color = CS.SecondaryColor;
      String title = '';
      String? subtitle;
      Widget? leading;
      Widget? trailing;
      GestureTapCallback? onTap;
      if (e is BrewModel) {
        color = ColorHelper.fromHex(e.color!) ?? color;
        title = '#${e.reference!} - ${AppLocalizations.of(context)!.localizedText(e.receipt!.title)}';
        if (DateHelper.toDate(e.started()) == DateHelper.toDate(day)) {
          subtitle = 'Démarrage du brassin.';
        }  else if (e.finish() == DateHelper.toDate(day)) {
          subtitle = 'Fin de la fermentation.';
        } else if (e.secondaryDate() == DateHelper.toDate(day)) {
          subtitle = 'Début de la fermentation à ${AppLocalizations.of(context)!.tempFormat(e.receipt!.secondarytemp)}.';
        } else if (e.tertiaryDate() == DateHelper.toDate(day)) {
          subtitle = 'Début de la fermentation à ${AppLocalizations.of(context)!.tempFormat(e.receipt!.tertiaryday)}.';
        }
        trailing = Text(AppLocalizations.of(context)!.text(e.status.toString().toLowerCase()), style: const TextStyle(color: Colors.white));
        onTap = () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return BrewPage(e);
          }));
        };
      }
      return ListTile(
        tileColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(color: Colors.white)) : null,
        leading: leading,
        trailing: trailing,
        onTap: onTap
    );
    }).toList();
  }

  List<ListTile> _getEventsForRange(List<Model> data, DateTime start, DateTime end) {
    final days = daysInRange(start, end);
    return [ for (final d in days) ..._getEventsForDay(data, d) ];
  }

  List<DateTime> daysInRange(DateTime first, DateTime last) {
    final dayCount = last.difference(first).inDays + 1;
    return List.generate(
      dayCount, (index) => DateTime.utc(first.year, first.month, first.day + index),
    );
  }

  _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 10)
        )
    );
  }
}

