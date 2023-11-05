import 'package:flutter/material.dart';

// Internal package
import 'package:bab/controller/brew_page.dart';
import 'package:bab/helpers/color_helper.dart';
import 'package:bab/helpers/date_helper.dart';
import 'package:bab/models/brew_model.dart';
import 'package:bab/models/model.dart';
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/utils/constants.dart' as constants;
import 'package:bab/utils/database.dart';
import 'package:bab/widgets/basket_button.dart';
import 'package:bab/widgets/containers/empty_container.dart';
import 'package:bab/widgets/containers/error_container.dart';
import 'package:bab/widgets/custom_menu_button.dart';
import 'package:bab/widgets/days.dart';

// External package
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> with AutomaticKeepAliveClientMixin<CalendarPage> {
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
      backgroundColor: constants.FillColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.text('calendar')),
        elevation: 0,
        foregroundColor: Theme.of(context).primaryColor,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.refresh),
            tooltip: AppLocalizations.of(context)!.text('refresh'),
            onPressed: () {
              _fetch();
            },
          ),
          BasketButton(),
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
                                  color: constants.TextGrey,
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
                        return Days.buildCalendarDayMarker(text: day.day.toString(), backColor: Theme.of(context).primaryColor);
                      },
                      todayBuilder: (context, day, focusedDay) {
                        return Days.buildCalendarDayMarker(text: day.day.toString(), backColor: Theme.of(context).primaryColor.withOpacity(0.3));
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

  _fetch() async {
    setState(() {
      _data = Database().getBrews(user: constants.currentUser!.uuid, ordered: true);
    });
  }

  List<ListTile> _getEventsForDay(List<Model> data, DateTime day) {
    List<Model> elements
    = data.where((element) {
      if (element is BrewModel) {
        if (element.started_at == null || element.started_at == false) {
          return false;
        }
        if (DateHelper.toDate(element.started_at!) == DateHelper.toDate(day) ||
            (element.fermented_at != null && DateHelper.toDate(element.fermented_at!) == DateHelper.toDate(day))) {
          return true;
        }
        if ((element.finish() == DateHelper.toDate(day)) ||
            (element.endDatePrimary() == DateHelper.toDate(day)) ||
            (element.endDateSecondary() == DateHelper.toDate(day))) {
          return true;
        }
      }
      return false;
    }).toList();
    return elements.map((e) {
      Color color = constants.SecondaryColor;
      String title = '';
      String? subtitle;
      Widget? leading;
      Widget? trailing;
      GestureTapCallback? onTap;
      if (e is BrewModel) {
        color = ColorHelper.fromHex(e.color!) ?? color;
        title = '#${e.reference!} - ${AppLocalizations.of(context)!.localizedText(e.receipt!.title)}';
        if (e.started_at != null && DateHelper.toDate(e.started_at!) == DateHelper.toDate(day)) {
          subtitle = 'Début du brassin.';
        }  else if (e.finish() == DateHelper.toDate(day)) {
          subtitle = 'Fin du brassin.';
        } else if (e.fermented_at != null && DateHelper.toDate(e.fermented_at!) == DateHelper.toDate(day)) {
          subtitle = 'Début de la fermentation primaire.';
        } else if (e.endDatePrimary() == DateHelper.toDate(day)) {
          subtitle = 'Début de la fermentation secondaire.';
        } else if (e.endDateSecondary() == DateHelper.toDate(day)) {
          subtitle = 'Début de la fermentation tertiaire.';
        }
        trailing = TextButton(
          child: Text(AppLocalizations.of(context)!.text('move'), style: TextStyle(color: Colors.white)),
          onPressed: () async {
            DateTime? date = await showDatePicker(
              context: context,
              initialDate: DateHelper.toDate(day), //get today's date
              firstDate:DateTime(2000), //DateTime.now() - not to allow to choose before today.
              lastDate: DateTime(2101)
            );
            if (date != null && DateHelper.toDate(day) != DateHelper.toDate(date)) {
              int days = DateHelper.toDate(date).difference(DateHelper.toDate(day)).inDays;
              if (days != 0) {
                if (e.started_at != null && DateHelper.toDate(e.started_at!) == DateHelper.toDate(day)) {
                  e.started_at = date;
                } else if (e.fermented_at != null && DateHelper.toDate(e.fermented_at!) == DateHelper.toDate(day)) {
                  e.fermented_at = date;
                } else if (e.endDatePrimary() == DateHelper.toDate(day)) {
                  e.primaryday = e.primaryDay()! + days;
                } else if (e.endDateSecondary() == DateHelper.toDate(day)) {
                  e.secondaryday = e.secondaryDay()! + days;
                } else if (e.endDateTertiary() == DateHelper.toDate(day)) {
                  e.tertiaryday = e.tertiaryDay()! + days;
                }
                Database().update(e).then((value) async {
                  _showSnackbar(AppLocalizations.of(context)!.text('saved_item'));
                  _fetch();
                }).onError((e, s) {
                  _showSnackbar(e.toString());
                });
              }
              debugPrint('old ${day.toUtc()} new ${date.toUtc()} difference ${DateHelper.toDate(date).difference(DateHelper.toDate(day)).inDays}');
            }
          },
          style: TextButton.styleFrom(shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
            side: BorderSide(color: Colors.white),
          )),
        );
        // trailing = Text(AppLocalizations.of(context)!.text(e.status.toString().toLowerCase()), style: const TextStyle(color: Colors.white));
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

