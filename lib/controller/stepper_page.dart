import 'dart:async';

import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Internal package
import 'package:bab/helpers/device_helper.dart';
import 'package:bab/models/brew_model.dart';
import 'package:bab/models/fermentable_model.dart';
import 'package:bab/models/hop_model.dart' as hm;
import 'package:bab/models/misc_model.dart' as mm;
import 'package:bab/models/recipe_model.dart';
import 'package:bab/models/yeast_model.dart' as ym;
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/utils/constants.dart' as constants;
import 'package:bab/utils/database.dart';
import 'package:bab/utils/mash.dart' as mash;
import 'package:bab/utils/notification_service.dart';
import 'package:bab/widgets/circular_timer.dart';
import 'package:bab/widgets/containers/ph_container.dart';
import 'package:bab/widgets/countdown_text.dart';
import 'package:bab/widgets/custom_stepper.dart';
import 'package:bab/widgets/dialogs/confirm_dialog.dart';
import 'package:bab/widgets/form_decoration.dart';

// External package
import 'package:another_flushbar/flushbar.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:sprintf/sprintf.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:uuid/uuid.dart';

class StepperPage extends StatefulWidget {
  final BrewModel model;
  StepperPage(this.model);

  @override
  _StepperPageState createState() => _StepperPageState();
}

class Ingredient {
  int minutes;
  Map<String, String>? map;
  Ingredient({
    required this.minutes,
    this.map
  }) {
    map ??= {};
  }
}

extension ListParsing on List {
  void set(Iterable<dynamic> iterable, BuildContext context) {
    for(dynamic item in iterable) {
      if (item.amount != null) {
        String? text = AppLocalizations.of(context)!.measurementFormat(item.amount, item.measurement);
        if (text != null) {
          Ingredient? boil = this.cast<Ingredient?>().firstWhere((e) => e!.minutes == item.duration, orElse: () => null);
          if (boil != null) {
            boil.map![AppLocalizations.of(context)!.localizedText(item.name)] = text;
          } else {
            add(Ingredient(
              minutes: item.duration!,
              map: { AppLocalizations.of(context)!.localizedText(item.name): text},
            ));
          }
        }
      }
    }
  }
}

class _StepperPageState extends State<StepperPage> with AutomaticKeepAliveClientMixin<StepperPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _index = 0;
  double _grainTemp = 20;
  Future<double>? _initialBrewTemp;

  List<MyStep> _steps = [];
  late SfRadialGauge _temp;

  CountDownController _boilController = CountDownController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _initialize();
    });
  }

  @override
  void dispose() {
    // WidgetsBinding.instance.removeObserver(this);
    if (!foundation.kIsWeb) {
      NotificationService.instance.cancelAll();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool? exitResult = await showDialog(
          context: context,
          builder: (context) => ConfirmDialog(content: Text(AppLocalizations.of(context)!.text('stop_brewing'))),
        );
        return exitResult ?? false;
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: constants.FillColor,
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.text('brewing_steps')),
          centerTitle: false,
          elevation: 0,
          foregroundColor: Theme.of(context).primaryColor,
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: DeviceHelper.isLargeScreen(context) ? const Icon(Icons.close) : const BackButtonIcon(),
            onPressed:() async {
              bool? exitResult = await showDialog(
                context: context,
                builder: (context) => ConfirmDialog(content: Text(AppLocalizations.of(context)!.text('stop_brewing'))),
              );
              if (exitResult == true) {
                Navigator.pop(context);
              }
            }
          ),
        ),
        body: CustomStepper(
          steps: _steps,
          currentStep: widget.model.last_step ?? 0,
          onLastStep: (index) {
            widget.model.last_step = index;
            Database().update(widget.model, updateLogs: false);
          }
        )
      )
    );
  }

  _initialize() async {
    _temp = SfRadialGauge(
        animationDuration: 3500,
        enableLoadingAnimation: true,
        axes: <RadialAxis>[
          RadialAxis(
              ranges: <GaugeRange>[
                GaugeRange(
                    startValue: 0,
                    endValue: 10,
                    startWidth: 0.265,
                    sizeUnit: GaugeSizeUnit.factor,
                    endWidth: 0.265,
                    color: const Color.fromRGBO(34, 195, 199, 0.75)),
                GaugeRange(
                    startValue: 10,
                    endValue: 30,
                    startWidth: 0.265,
                    sizeUnit: GaugeSizeUnit.factor,
                    endWidth: 0.265,
                    color: const Color.fromRGBO(123, 199, 34, 0.75)),
                GaugeRange(
                    startValue: 30,
                    endValue: 40,
                    startWidth: 0.265,
                    sizeUnit: GaugeSizeUnit.factor,
                    endWidth: 0.265,
                    color: const Color.fromRGBO(238, 193, 34, 0.75)),
                GaugeRange(
                    startValue: 40,
                    endValue: 70,
                    startWidth: 0.265,
                    sizeUnit: GaugeSizeUnit.factor,
                    endWidth: 0.265,
                    color: const Color.fromRGBO(238, 79, 34, 0.65)),
                GaugeRange(
                    startValue: 70,
                    endValue: 100,
                    startWidth: 0.265,
                    sizeUnit: GaugeSizeUnit.factor,
                    endWidth: 0.265,
                    color: const Color.fromRGBO(255, 0, 0, 0.65)),
              ],
              annotations: <GaugeAnnotation>[
                GaugeAnnotation(
                    angle: 90,
                    positionFactor: 0.35,
                    widget: Text(
                        'Temp.${AppLocalizations.of(context)!.tempMeasure}',
                        style: const TextStyle(
                            color: Color(0xFFF8B195), fontSize: 9))),
                const GaugeAnnotation(
                  angle: 90,
                  positionFactor: 0.8,
                  widget: Text('  0  ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                )
              ],
              pointers: const <GaugePointer>[
                NeedlePointer(
                  value: 0,
                  needleStartWidth: 0,
                  needleEndWidth: 3,
                  knobStyle: KnobStyle(knobRadius: 0.05),
                )
              ]
          )
        ]
    );
    _initialBrewTemp = widget.model.initialBrewTemp(_grainTemp);
    _generate();
  }

  _generate() async {
    RecipeModel recipe = widget.model.recipe!.copy();
    Map<CountDownTextController, Ingredient> ingredients = await _ingredients(recipe);
    List<ym.YeastModel> yeasts = await recipe.getYeasts(volume: widget.model.volume);
    setState(() {
      _steps = [
        MyStep(
          index: ++_index,
          title: Text(AppLocalizations.of(context)!.text('beginning')),
          content: Container(
            alignment: Alignment.centerLeft,
            child: Text(AppLocalizations.of(context)!.text('starting_brew'))
          ),
          onStepContinue: (int index) {
            if (widget.model.started_at == null) {
              widget.model.started_at = DateTime.now();
              Database().update(widget.model, updateLogs: false);
            }
          },
        ),
        MyStep(
          index: ++_index,
          title: Text(AppLocalizations.of(context)!.text('crushing')),
          content: Container(
            alignment: Alignment.centerLeft,
            child: FutureBuilder<List<FermentableModel>>(
              future: recipe.getFermentables(volume: widget.model.volume, forceResizing: true),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: snapshot.data!.map((e) {
                      return Flexible(child: Text(sprintf(AppLocalizations.of(context)!.text('crush_grain'),
                        [
                          AppLocalizations.of(context)!.weightFormat(e.amount),
                          AppLocalizations.of(context)!.localizedText(e.name)
                        ]
                      )));
                    }).toList()
                  );
                }
                return Container();
              }
            )
          ),
        ),
        MyStep(
          index: ++_index,
          title: Text(sprintf(AppLocalizations.of(context)!.text('add_water'),
            [
              AppLocalizations.of(context)!.litterVolumeFormat(widget.model.mash_water),
            ]
          )),
          content: Container(
            alignment: Alignment.centerLeft,
            child: PHContainer(
              target: widget.model.mash_ph,
              volume: widget.model.volume,
            )
          ),
        ),
        MyStep(
          index: ++_index,
          title: FutureBuilder<double?>(
            future: _initialBrewTemp,
            builder: (context, snapshot) {
              double initialTemp = 50;
              if (snapshot.hasData) {
                initialTemp = snapshot.data!;
              }
              return Text(sprintf(AppLocalizations.of(context)!.text('heat_tank'),
                [
                  AppLocalizations.of(context)!.tempFormat(initialTemp)
                ]
              ));
            }
          ),
          content: Container(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(AppLocalizations.of(context)!.text('grain_temperature')),
                SizedBox(
                  width: DeviceHelper.isLargeScreen(context) ? 320: null,
                  child: TextFormField(
                    initialValue: _grainTemp.toString(),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
                    ],
                    onChanged: (String? value) {
                      if (value != null) {
                        _grainTemp = AppLocalizations.of(context)!.decimal(value) ?? 20;
                        _initialBrewTemp = widget.model.initialBrewTemp(_grainTemp);
                        _generate();
                      }
                    },
                    decoration: FormDecoration(
                      labelText: AppLocalizations.of(context)!.text('temperature'),
                      suffixText: AppLocalizations.of(context)!.tempMeasure,
                      border: InputBorder.none,
                      fillColor: constants.FillColor, filled: true
                    )
                  ),
                ),
                if (widget.model.tank!.hasBluetooth()) const SizedBox(height: 6),
                if (widget.model.tank!.hasBluetooth()) SizedBox(
                  width: 140,
                  height: 140,
                  child: _temp,
                )
              ],
            )
          ),
        ),
        MyStep(
          index: ++_index,
          title: Text(AppLocalizations.of(context)!.text('add_grain')),
          content: Container(),
        ),
        ..._mash(recipe),
        MyStep(
          index: ++_index,
          title: Text(sprintf(AppLocalizations.of(context)!.text('rinsing_spent_grains'),
            [
              AppLocalizations.of(context)!.litterVolumeFormat(widget.model.sparge_water),
              AppLocalizations.of(context)!.tempFormat(78)
            ]
          )),
          content: Container(
            alignment: Alignment.centerLeft,
            child: PHContainer(
              target: widget.model.sparge_ph,
              volume: widget.model.volume,
            )
          ),
        ),
        ..._boil(recipe, ingredients),
        MyStep(
          index: ++_index,
          title: Text(AppLocalizations.of(context)!.text('make_whirlpool')),
          content: Container(),
        ),
        MyStep(
          index: ++_index,
          title: Text(AppLocalizations.of(context)!.text('transfer_fermenter')),
          content: Container(),
        ),
        MyStep(
          index: ++_index,
          title: Text(AppLocalizations.of(context)!.text('take_original_gravity')),
          content: TextField(
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
            ],
            onSubmitted: (value) {
              widget.model.og = AppLocalizations.of(context)!.decimal(value);
              widget.model.calculate();
              Database().update(widget.model, updateLogs: false);
            },
            decoration: FormDecoration(
                icon: const Icon(Icons.colorize_outlined),
                hintText: constants.Gravity.sg == AppLocalizations.of(context)!.gravity ? '1.xxx' : null,
                labelText: AppLocalizations.of(context)!.text('oiginal_gravity'),
                border: InputBorder.none,
                fillColor: constants.FillColor, filled: true
            ),
          ),
        ),
        ..._yeast(recipe, yeasts),
        MyStep(
          index: ++_index,
          title: Text(AppLocalizations.of(context)!.text('end')),
          content: Container(
              alignment: Alignment.centerLeft,
              child: Text(AppLocalizations.of(context)!.text('brew_ready'))
          ),
        )
      ];
    });
  }

  List<MyStep> _mash(RecipeModel recipe) {
    List<MyStep> values = [];
    for(mash.Mash item in recipe.mash!) {
      if (item.type == mash.Type.infusion) {
        var index = ++_index;
        CountDownController controller = CountDownController();
        values.add(MyStep(
          index: index,
          title: Text(sprintf(AppLocalizations.of(context)!.text('level_minutes'),
            [
              item.name,
              AppLocalizations.of(context)!.tempFormat(item.temperature),
              item.duration
            ]
          )),
          content: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              hoverColor: Colors.transparent,
              focusColor: Colors.transparent,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: CircularTimer(
                controller,
                duration: 0,
                index: index,
                onComplete: (int index) {
                  _notification(sprintf(AppLocalizations.of(context)!.text('level_over'),
                    [
                      item.name,
                      AppLocalizations.of(context)!.tempFormat(item.temperature)
                    ]
                  ));
                  _steps[index].completed = true;
                }
              ),
              onTap: () {
                if (!controller.isStarted) {
                  controller.restart(duration: item.duration! * 60);
                }
              },
            )
          ),
          onStepContinue: (int index) {
            if (!_steps[index].completed) {
              throw AppLocalizations.of(context)!.text('step_not_finished');
            }
          },
        ));
      }
    }
    return values;
  }

  List<MyStep> _boil(RecipeModel recipe, Map<CountDownTextController, Ingredient> ingredients)  {
    List<MyStep> values = [];
    values.add(MyStep(
      index: ++_index,
      title: Text(AppLocalizations.of(context)!.text('boil_tank')),
      content: widget.model.tank?.bluetooth == true ? Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: 140,
          height: 140,
          child: _temp,
        )
      ) : Container(),
      onStepContinue: (int index) {
      },
    ));
    var index = ++_index;
    values.add(MyStep(
      index: index,
      title: Text(sprintf(AppLocalizations.of(context)!.text('start_hopping'),
        [
          AppLocalizations.of(context)!.durationFormat(recipe.boil)
        ]
      )),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              hoverColor: Colors.transparent,
              focusColor: Colors.transparent,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: CircularTimer(
                _boilController,
                duration: 0,
                index: index,
                onComplete: (int index) {
                  _notification(AppLocalizations.of(context)!.text('hopping_finished'));
                  _steps[index].completed = true;
                }
              ),
              onTap: () {
                if (!_boilController.isStarted) {
                  var secondes = recipe.boil! * 60;
                  _boilController.restart(duration: secondes);
                  ingredients.forEach((key, value) {
                    Duration duration = Duration(seconds: secondes - (value.minutes * 60));
                    key.start(duration);
                    String text = '';
                    value.map!.forEach((k, v) {
                      text += '${text.isNotEmpty ? '\n' : ''}${AppLocalizations.of(context)!.text('add')} $v «$k»';
                    });
                    _notification(text, duration: duration);
                  });
                }
              }
            )
          ),
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: ingredients.entries.map((e) {
                return CountDownText(
                  duration: Duration(minutes: recipe.boil! - e.value.minutes),
                  map: e.value.map!,
                  controller: e.key,
                );
              }).toList()
            )
          )
        ]
      ),
      onStepTapped: (int index) {
      },
      onStepContinue: (int index) {
        if (!_steps[index].completed) {
          throw AppLocalizations.of(context)!.text('step_not_finished');
        }
      },
    ));
    return values;
  }

  List<MyStep> _yeast(RecipeModel recipe, List<ym.YeastModel> yeasts) {
    List<MyStep> values = [];
    for(ym.YeastModel item in yeasts) {
      values.add(MyStep(
        index: ++_index,
        title: Text(sprintf(AppLocalizations.of(context)!.text('add_yeast'),
          [
            AppLocalizations.of(context)!.weightFormat(item.amount),
            AppLocalizations.of(context)!.localizedText(item.name)
          ]
        )),
        content: Container(),
        onStepContinue: (int index) {
          if (widget.model.fermented_at == null) {
            widget.model.fermented_at = DateTime.now();
            Database().update(widget.model, updateLogs: false);
          }
        },
      ));
    }
    return values;
  }

  Future<Map<CountDownTextController, Ingredient>> _ingredients(RecipeModel recipe) async {
    List<Ingredient> list = [];
    Map<CountDownTextController, Ingredient> map = {};
    list.set(await recipe.gethops(volume: widget.model.volume, use: hm.Use.boil, forceResizing: true), context);
    list.set(await recipe.getMisc(volume: widget.model.volume, use: mm.Use.boil, forceResizing: true), context);
    list.sort((a, b) => b.minutes.compareTo(a.minutes));
    for(Ingredient e in list) {
      CountDownTextController controller = CountDownTextController(); 
      map[controller] = e;
    }
    return map;
  }

  _notification(String message, {Duration? duration}) async {
    if (foundation.kIsWeb) {
      if (duration != null && duration.inSeconds > 0) {
        Future.delayed(duration, () {
          _flushbar(message);// Prints after 1 second.
        });
        return;
      }
      _flushbar(message);
      return;
    }
    NotificationService.instance.showNotification(
      Uuid().v4().hashCode,
      body: message,
      duration: duration
    );
  }

  _flushbar(String message) {
    AudioPlayer().play(AssetSource('/sounds/notification.mp3'));
    Flushbar(
      // icon: Icon(Icons.check, color: Theme.of(context).primaryColor),
      messageText: Text(message, style: const TextStyle(fontSize: 18.0)),
      mainButton: TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Text(
          MaterialLocalizations.of(context).closeButtonLabel,
          style: TextStyle(color: Theme.of(context).primaryColor),
        ),
      ),
      duration: const Duration(seconds: 25),
      backgroundColor: Colors.white,
      flushbarPosition: FlushbarPosition.TOP,
      flushbarStyle: FlushbarStyle.FLOATING,
      reverseAnimationCurve: Curves.decelerate,
      forwardAnimationCurve: Curves.elasticOut,
      showProgressIndicator: true,
    ).show(context);
  }
}

