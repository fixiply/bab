import 'package:flutter/material.dart';

// Internal package
import 'package:bb/helpers/date_helper.dart';
import 'package:bb/models/basket_model.dart';
import 'package:bb/models/model.dart';
import 'package:bb/models/product_model.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/basket_notifier.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/widgets/days.dart';
import 'package:bb/widgets/form_decoration.dart';

// External package
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class ModalBottomSheet {
  static Future showInformation(BuildContext context, Model model) async {
    return showModalBottomSheet(
      context: context,
      // isScrollControlled: true,
      builder: (BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            titleSpacing: 15,
            centerTitle: true,
            iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
            backgroundColor: Colors.transparent,
            bottomOpacity: 0.0,
            elevation: 0.0,
            leading: IconButton(
              icon:const Icon(Icons.clear),
              onPressed:() async {
                Navigator.pop(context);
              }
            ),
            title: Text(AppLocalizations.of(context)!.text('information'),
                style: TextStyle(color: Theme.of(context).primaryColor)
            ),
          ),
          body: SizedBox(
            height: 200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  initialValue: model.uuid,
                  readOnly: true,
                  decoration: FormDecoration(
                    prefixIcon: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: const Text('ID :', style: TextStyle(fontSize: 16.0)),
                    ),
                    prefixIconConstraints: const BoxConstraints(
                        minWidth: 0, minHeight:0
                    ),
                  ),
                ),
                TextFormField(
                  initialValue: DateHelper.formatDateTime(context, model.inserted_at),
                  readOnly: true,
                  decoration: FormDecoration(
                    prefixIcon: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text('${AppLocalizations.of(context)!.text('create')} :', style: const TextStyle(fontSize: 16.0)),
                    ),
                    prefixIconConstraints: const BoxConstraints(
                        minWidth: 0, minHeight:0
                    ),
                  ),
                ),
                TextFormField(
                  initialValue: DateHelper.formatDateTime(context, model.updated_at),
                  readOnly: true,
                  decoration: FormDecoration(
                    prefixIcon: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text('${AppLocalizations.of(context)!.text('updated')} :', style: const TextStyle(fontSize: 16.0)),
                    ),
                    prefixIconConstraints: const BoxConstraints(
                        minWidth: 0, minHeight:0
                    ),
                  ),
                ),
                TextFormField(
                  initialValue: model.creator,
                  readOnly: true,
                  decoration: FormDecoration(
                    prefixIcon: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text('${AppLocalizations.of(context)!.text('creator')} :', style: const TextStyle(fontSize: 16.0)),
                    ),
                    prefixIconConstraints: const BoxConstraints(
                        minWidth: 0, minHeight:0
                    ),
                  ),
                ),
              ]
            )
          ),
        );
      }
    );
  }

  static Future showAddToCart(BuildContext context, ProductModel product, {BasketModel? basket}) async {
    bool update = basket != null;
    int quantity = basket != null ? basket.quantity! : product.pack ?? 1;
    BasketModel newBasket = basket ??  BasketModel(
      product: product.uuid,
      price: product.price
    );
    return showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
          return Container(
              height: 200,
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: quantity > (product.pack ?? 1) ? () {
                            setState(() {
                              quantity -= product.pack ?? 1;
                            });
                          } : null,
                          child: const Icon(Icons.remove, color: Colors.black),
                          style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(12),
                            backgroundColor: Colors.white, // <-- Button color
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text('$quantity ${AppLocalizations.of(context)!.text('bottle(s)')}',
                            style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: quantity < (product.max ?? 1) ? () {
                            setState(() {
                              quantity += product.pack ?? 1;
                            });
                          } : null,
                          child: const Icon(Icons.add, color: Colors.black),
                          style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(12),
                            backgroundColor: Colors.white, // <-- Button color
                          ),
                        )
                      ]
                    )
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        child: Text(AppLocalizations.of(context)!.text('cancel'),
                            style: const TextStyle(color: Colors.red)),
                        style: TextButton.styleFrom(backgroundColor: Colors.transparent),
                        onPressed: () async {
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(width: 30),
                      ElevatedButton(
                        child: Text(update ? AppLocalizations.of(context)!.text('edit_cart') : AppLocalizations.of(context)!.text('add_to_cart')),
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: BorderSide(color: Theme.of(context).primaryColor),
                        )),
                        onPressed: () async {
                          newBasket.quantity = quantity;
                          if (update) Provider.of<BasketNotifier>(context, listen: false).set(newBasket);
                          else Provider.of<BasketNotifier>(context, listen: false).add(newBasket);
                          Navigator.pop(context);
                        },
                      )
                    ]
                  )
                ]
              ),
            );
          }
        );
      }
    );
  }

  static Future showCalendar(BuildContext context, ProductModel product, {BasketModel? basket}) async {
    DateTime? selectedDay;
    DateTime focusedDay = DateTime.now();
    bool update = basket != null;
    int quantity = basket != null ? basket.quantity! : product.pack ?? 1;
    BasketModel newBasket = basket ??  BasketModel(
        product: product.uuid,
        price: product.price
    );
    return showModalBottomSheet(
        context: context,
        isScrollControlled:true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return Container(
                height: MediaQuery.of(context).size.height * 0.8,
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: TableCalendar(
                        focusedDay: focusedDay,
                        firstDay: DateTime.now(),
                        lastDay: DateTime.now().add(const Duration(days: 90)),
                        startingDayOfWeek: StartingDayOfWeek.monday,
                        locale: AppLocalizations.of(context)!.text('locale'),
                        selectedDayPredicate: (day) {
                          return isSameDay(selectedDay, day);
                        },
                        onDaySelected: (selected, focused) {
                          if (!isSameDay(selectedDay, selected)) {
                            setState(() {
                              selectedDay = selected;
                              focusedDay = focused;
                            });
                          }
                        },
                        calendarBuilders: CalendarBuilders(
                          defaultBuilder: (context, day, _) {
                            if (product.weekdays != null) {
                              DateTime? last = product.term != null ?  product.term!.getLast() : null;
                              for(dynamic weekday in product.weekdays!) {
                                if (day.weekday == weekday && (last == null || day.isBefore(last))) {

                                  return Days.buildCalendarDayMarker(text: day.day.toString(), backColor: Colors.green);
                                }
                              }
                            }
                            return null;
                          },
                          selectedBuilder: (context, day, focusedDay) {
                            return Days.buildCalendarDayMarker(text: day.day.toString(), backColor: PrimaryColor);
                          },
                          todayBuilder: (context, day, focusedDay) {
                            return Days.buildCalendarDayMarker(text: day.day.toString(), backColor: TextGrey);
                          }
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          child: Text(AppLocalizations.of(context)!.text('cancel'),
                          style: const TextStyle(color: Colors.red)),
                          style: TextButton.styleFrom(backgroundColor: Colors.transparent),
                          onPressed: () async {
                            Navigator.pop(context);
                          },
                        ),
                        const SizedBox(width: 30),
                        ElevatedButton(
                          child: Text(update ? AppLocalizations.of(context)!.text('edit_cart') : AppLocalizations.of(context)!.text('add_to_cart')),
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: BorderSide(color: Theme.of(context).primaryColor),
                            )
                          ),
                          onPressed: () async {
                            newBasket.quantity = quantity;
                            if (update) Provider.of<BasketNotifier>(context, listen: false).set(newBasket);
                            else Provider.of<BasketNotifier>(context, listen: false).add(newBasket);
                            Navigator.pop(context);
                          },
                        )
                      ]
                    )
                  ]
                ),
              );
            }
          );
        }
    );
  }
}
