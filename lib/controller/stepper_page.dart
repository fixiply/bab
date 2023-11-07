import 'dart:async';

import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Internal package
import 'package:bab/helpers/device_helper.dart';
import 'package:bab/models/brew_model.dart';
import 'package:bab/models/fermentable_model.dart';
import 'package:bab/models/hop_model.dart' as hp;
import 'package:bab/models/misc_model.dart' as mm;
import 'package:bab/models/receipt_model.dart';
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/utils/constants.dart' as constants;
import 'package:bab/utils/database.dart';
import 'package:bab/utils/mash.dart' as mash;
import 'package:bab/utils/notification_service.dart';
import 'package:bab/widgets/circular_timer.dart';
import 'package:bab/widgets/containers/error_container.dart';
import 'package:bab/widgets/containers/ph_container.dart';
import 'package:bab/widgets/countdown_text.dart';
import 'package:bab/widgets/custom_stepper.dart';
import 'package:bab/widgets/dialogs/confirm_dialog.dart';
import 'package:bab/widgets/form_decoration.dart';

// External package
import 'package:another_flushbar/flushbar.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
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
      Ingredient? boil = this.cast<Ingredient?>().firstWhere((e) => e!.minutes == item.duration, orElse: () => null);
      if (boil != null) {
        boil.map![AppLocalizations.of(context)!.localizedText(item.name)] = AppLocalizations.of(context)!.weightFormat(item.amount)!;
      } else {
        add(Ingredient(
          minutes: item.duration!,
          map: { AppLocalizations.of(context)!.localizedText(item.name): AppLocalizations.of(context)!.weightFormat(item.amount)! },
        ));
      }
    }
  }
}

class _StepperPageState extends State<StepperPage> with AutomaticKeepAliveClientMixin<StepperPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _index = 0;
  double _grainTemp = 20;
  Future<double>? _initialBrewTemp;

  Future<List<MyStep>>? _steps;
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
        body: FutureBuilder<List<MyStep>>(
          future: _steps,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return CustomStepper(
                steps: snapshot.data!,
                currentStep: widget.model.last_step ?? 0,
                onLastStep: (index) {
                  widget.model.last_step = index;
                  Database().update(widget.model, updateLogs: false);
                }
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
    _fetch();
  }

  _fetch() async {
    setState(() {
      _steps = _generate();
    });
  }

  Future<List<MyStep>> _generate() async {
    ReceiptModel receipt = widget.model.receipt!.copy();
    List<MyStep> steps = [
      MyStep(
        index: ++_index,
        title: const Text('Début'),
        content: Container(
          alignment: Alignment.centerLeft,
          child: const Text('Démarrage du brassin')
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
        title: const Text('Concasser le grain'),
        content: Container(
          alignment: Alignment.centerLeft,
          child: FutureBuilder<List<FermentableModel>>(
            future: receipt.getFermentables(volume: widget.model.volume, forceResizing: true),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: snapshot.data!.map((e) {
                    return Flexible(child: Text('Concassez ${AppLocalizations.of(context)!.kiloWeightFormat(e.amount)} de «${AppLocalizations.of(context)!.localizedText(e.name)}».'));
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
        title: Text('Ajoutez ${AppLocalizations.of(context)!.litterVolumeFormat(widget.model.mash_water)} d\'eau dans votre cuve'),
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
        title: RichText(
          text: TextSpan(
            text: 'Mettre en chauffe votre cuve',
            style: DefaultTextStyle.of(context).style,
            children: [
              // TextSpan(text:  ' à ${AppLocalizations.of(context)!.tempFormat(_initialBrewTemp)}'),
              WidgetSpan(
                child: FutureBuilder<double?>(
                  future: _initialBrewTemp,
                  builder: (context, snapshot) {
                    double initialTemp = 50;
                    if (snapshot.hasData) {
                      initialTemp = snapshot.data!;
                    }
                    return Text(' à ${AppLocalizations.of(context)!.tempFormat(initialTemp)}');
                  }
                )
              )
            ],
          ),
        ),
        content: Container(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Température du grain'),
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
                      _fetch();
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
              const SizedBox(height: 6),
              SizedBox(
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
        title: const Text('Ajouter le grain'),
        content: Container(),
      )
    ];
    _mash(receipt, steps);
    steps.add(MyStep(
      index: ++_index,
      title: Text('Rinçage des drêches avec ${AppLocalizations.of(context)!.litterVolumeFormat(widget.model.sparge_water)} d\'eau à ${AppLocalizations.of(context)!.tempFormat(78)}'),
      content: Container(
        alignment: Alignment.centerLeft,
        child: PHContainer(
          target: widget.model.sparge_ph,
          volume: widget.model.volume,
        )
      ),
    ));
    await _boil(receipt, steps);
    steps.add(MyStep(
      index: ++_index,
      title: const Text('Faire un whirlpool'),
      content: Container(),
    ));
    steps.add(MyStep(
      index: ++_index,
      title: const Text('Transférer le moût dans le fermenteur'),
      content: Container(),
    ));
    steps.add(MyStep(
      index: ++_index,
      title: const Text('Prendre la densité initiale'),
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
    ));
    await receipt.getYeasts(volume: widget.model.volume).then((values) {
      steps.add(MyStep(
        index: ++_index,
        title: Text('Ajouter ${AppLocalizations.of(context)!.weightFormat(receipt.yeasts.first.amount)} de levure «${AppLocalizations.of(context)!.localizedText(receipt.yeasts.first.name)}»'),
        content: Container(),
        onStepContinue: (int index) {
          if (widget.model.fermented_at == null) {
            widget.model.fermented_at = DateTime.now();
            Database().update(widget.model, updateLogs: false);
          }
        },
      ));
    });
    steps.add(MyStep(
      index: ++_index,
      title: Text('Fin'),
      content: Container(
        alignment: Alignment.centerLeft,
        child: const Text('Votre brassin est prêt.')
      ),
    ));
    return steps;
  }

  _mash(ReceiptModel receipt, List<MyStep> steps) {
    for(int i = 0 ; i < receipt.mash!.length ; i++) {
      if (receipt.mash![i].type == mash.Type.infusion) {
        CountDownController controller = CountDownController();
        steps.add(MyStep(
          index: ++_index,
          title: Text('Palier «${receipt.mash![i].name}» à ${AppLocalizations.of(context)!.tempFormat(receipt.mash![i].temperature)} pendant ${receipt.mash![i].duration} minutes'),
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
                index: steps.length,
                onComplete: (int index) {
                  _notification('Le Palier «${receipt.mash![i].name}» à ${AppLocalizations.of(context)!.tempFormat(receipt.mash![i].temperature)} est terminé.');
                  steps[index].completed = true;
                }
              ),
              onTap: () {
                if (!controller.isStarted) {
                  controller.restart(duration: receipt.mash![i].duration! * 60);
                }
              },
            )
          ),
          onStepContinue: (int index) {
            if (!steps[index].completed) {
              throw 'Cette étape n\'est pas terminée.';
            }
          },
        ));
      }
    }
  }

  _boil(ReceiptModel receipt, List<MyStep> steps) async {
    Map<CountDownTextController, Ingredient> ingredients = await _ingredients(receipt);
    steps.add(MyStep(
      index: ++_index,
      title: Text('Mettre en ébullition votre cuve'),
      content: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: 140,
          height: 140,
          child: _temp,
        )
      ),
      onStepContinue: (int index) {
      },
    ));
    steps.add(MyStep(
      index: ++_index,
      title: Text('Commencer le houblonnage pendant ${AppLocalizations.of(context)!.durationFormat(receipt.boil)}'),
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
                index: steps.length,
                onComplete: (int index) {
                  _notification('Houblonnage terminé.');
                  steps[index].completed = true;
                }
              ),
              onTap: () {
                if (!_boilController.isStarted) {
                  var secondes = receipt.boil! * 60;
                  _boilController.restart(duration: secondes);
                  ingredients.forEach((key, value) {
                    Duration duration = Duration(seconds: secondes - (value.minutes * 60));
                    key.start(duration);
                    String text = '';
                    value.map!.forEach((k, v) {
                      text += '${text.isNotEmpty ? '\n' : ''}Ajoutez $v de «$k»';
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
                  duration: Duration(minutes: receipt.boil! - e.value.minutes),
                  map: e.value.map!,
                  controller: e.key,
                );
              }).toList()
            )
          )
        ]
      ),
      onStepTapped: (int index) {
        debugPrint('onStepTapped');
      },
      onStepContinue: (int index) {
        if (!steps[index].completed) {
          throw 'Cette étape n\'est pas terminée.';
        }
      },
    ));
  }

  Future<Map<CountDownTextController, Ingredient>> _ingredients(ReceiptModel receipt) async {
    List<Ingredient> list = [];
    Map<CountDownTextController, Ingredient> map = {};
    list.set(await receipt.gethops(volume: widget.model.volume, use: hp.Use.boil, forceResizing: true), context);
    list.set(await receipt.getMisc(volume: widget.model.volume, use: mm.Use.boil, forceResizing: true), context);
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

