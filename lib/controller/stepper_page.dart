import 'package:flutter/material.dart';

// Internal package
import 'package:bb/helpers/device_helper.dart';
import 'package:bb/models/brew_model.dart';
import 'package:bb/models/fermentable_model.dart';
import 'package:bb/models/hop_model.dart';
import 'package:bb/models/receipt_model.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/constants.dart' as CS;
import 'package:bb/utils/database.dart';
import 'package:bb/utils/mash.dart' as Mash;
import 'package:bb/utils/notifications.dart';
import 'package:bb/widgets/circular_timer.dart';
import 'package:bb/widgets/containers/error_container.dart';
import 'package:bb/widgets/containers/ph_container.dart';
import 'package:bb/widgets/dialogs/confirm_dialog.dart';
import 'package:bb/widgets/form_decoration.dart';

// External package
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:uuid/uuid.dart';

class StepperPage extends StatefulWidget {
  final BrewModel model;
  StepperPage(this.model);

  @override
  _StepperPageState createState() => _StepperPageState();
}

class MyStep extends Step {
  int index;
  bool completed = false;
  final void Function(int index)? onStepCancel;
  final void Function(int index)? onStepContinue;
  MyStep({
    required this.index,
    required Widget title,
    Widget? subtitle,
    required Widget content,
    Widget? label,
    this.onStepCancel,
    this.onStepContinue
  }) : super(
    title: title,
    subtitle: subtitle,
    content: content,
    state: StepState.indexed,
    isActive: false,
  );
}

class _StepperPageState extends State<StepperPage> with AutomaticKeepAliveClientMixin<StepperPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _lastIndex = 0;
  int _index = 0;

  Future<List<MyStep>>? _steps;
  late SfRadialGauge _temp;
  int _mash = 60;

  CountDownController _mashController = CountDownController();
  CountDownController _hopController = CountDownController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final MaterialLocalizations localizations = MaterialLocalizations.of(context);
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
        backgroundColor: CS.FillColor,
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.text('stages')),
          elevation: 0,
          foregroundColor: Theme.of(context).primaryColor,
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: DeviceHelper.isLargeScreen(context) ? const Icon(Icons.close) : const BackButtonIcon(),
            onPressed:() async {
              Navigator.pop(context);
            }
          ),
        ),
        body: FutureBuilder<List<MyStep>>(
          future: _steps,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Stepper(
                currentStep: _index,
                onStepCancel: () {
                  if (_index > 0) {
                    try {
                      snapshot.data![_index].onStepCancel?.call(_index);
                      setState(() {
                        _index -= 1;
                      });
                    } catch (e) {
                      _showSnackbar(e.toString());
                    }
                  }
                },
                onStepContinue: () {
                  if (_index < snapshot.data!.length - 1) {
                    try {
                      snapshot.data![_index].onStepContinue?.call(_index);
                      setState(() {
                        _index += 1;
                        if (_index > _lastIndex) _lastIndex = _index;
                      });
                    } catch (e) {
                      _showSnackbar(e.toString(), action: SnackBarAction(
                        label: 'Continue',
                        onPressed: () {
                          setState(() {
                            _index += 1;
                            if (_index > _lastIndex) _lastIndex = _index;
                          });
                        },
                      ));
                    }
                  }
                },
                onStepTapped: (int index) {
                  if (index <= _lastIndex) {
                    setState(() {
                      _index = index;
                    });
                  }
                },
                controlsBuilder: (BuildContext context, ControlsDetails controls) {
                  return Container(
                    margin: const EdgeInsets.only(top: 16.0),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints.tightFor(height: 48.0),
                      child: Row(
                        children: <Widget>[
                          ElevatedButton(
                            onPressed: controls.onStepContinue,
                            child: Text(_index ==  0 ? AppLocalizations.of(context)!.text('start').toUpperCase() : localizations.continueButtonLabel),
                          ),
                          if (_index != 0) TextButton(
                            onPressed: controls.onStepCancel,
                            child: Text(
                              AppLocalizations.of(context)!.text('return').toUpperCase(),
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        ],
                      )
                    )
                  );
                },
                steps: snapshot.data!
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
                  widget: Text('Temp.${AppLocalizations.of(context)!.tempMeasure}', style: const TextStyle(color: Color(0xFFF8B195), fontSize: 9))),
              const GaugeAnnotation(
                angle: 90,
                positionFactor: 0.8,
                widget: Text('  0  ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
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
    setState(() {
      _steps = _generate();
    });
  }

  Future<List<MyStep>> _generate() async {
    ReceiptModel receipt = widget.model.receipt!.copy();
    List<MyStep> steps = [
      MyStep(
        index: 0,
        title: const Text('Début'),
        content: Container(
          alignment: Alignment.centerLeft,
          child: const Text('Démarrage du brassin')
        ),
        onStepContinue: (int index) {
          if (widget.model.status == Status.pending) {
            widget.model.status == Status.started;
            Database().update(widget.model);
          }
        }
      ),
      MyStep(
        index: 1,
        title: const Text('Concasser le grain'),
        content: Container(
          alignment: Alignment.centerLeft,
          child: FutureBuilder<List<FermentableModel>>(
            future: receipt.getFermentables(volume: widget.model.volume),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: snapshot.data!.map((e) {
                    return Flexible(child: Text('Concassez ${AppLocalizations.of(context)!.kiloWeightFormat(e.amount)} de ${AppLocalizations.of(context)!.localizedText(e.name)}.'));
                  }).toList()
                );
              }
              return Container();
            }
          )
        ),
      ),
      MyStep(
        index: 2,
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
        index: 3,
        title: Text('Mettre en chauffe votre cuve à ${AppLocalizations.of(context)!.tempFormat(50)}'),
        content: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: 140,
            height: 140,
            child: _temp,
          )
        ),
      ),
      MyStep(
        index: 4,
        title: const Text('Ajouter le grain'),
        content: Container()
      )
    ];
    await _mashs(receipt, steps);
    steps.add(MyStep(
      index: steps.length,
      title: Text('Rinçage des drêches avec ${AppLocalizations.of(context)!.litterVolumeFormat(widget.model.sparge_water)} d\'eau'),
      content: Container(),
    ));
    steps.add(MyStep(
      index: steps.length,
      title: const Text('Mettre en ébullition votre cuve'),
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
        if (!_mashController.isStarted) {
          _mashController.restart(duration: _mash * 60);
        }
      }
    ));
    await _hops(receipt, steps);
    steps.add(MyStep(
      index: steps.length,
      title: const Text('Faire un whirlpool'),
      content: Container(),
    ));
    steps.add(MyStep(
      index: steps.length,
      title: const Text('Transférer le moût dans le fermenteur'),
      content: Container(),
    ));
    steps.add(MyStep(
      index: steps.length,
      title: const Text('Prendre la densité initiale'),
      content: TextField(
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: (value) {
          widget.model.og = AppLocalizations.of(context)!.decimal(value);
        },
        decoration: FormDecoration(
          icon: const Icon(Icons.first_page_outlined),
            hintText: CS.Gravity.sg == AppLocalizations.of(context)!.gravity ? '1.xxx' : null,
          labelText: AppLocalizations.of(context)!.text('oiginal_gravity'),
          border: InputBorder.none,
          fillColor: CS.FillColor, filled: true
        ),
      ),
    ));
    await receipt.getYeasts(volume: widget.model.volume).then((values) {
      steps.add(MyStep(
        index: steps.length,
        title: Text('Ajouter ${AppLocalizations.of(context)!.weightFormat(receipt.yeasts.first.amount)} de levure ${AppLocalizations.of(context)!.localizedText(receipt.yeasts.first.name)}'),
        content: Container(),
      ));
    });
    steps.add(MyStep(
      index: steps.length,
      title: const Text('Fin'),
      content: Container(
        alignment: Alignment.centerLeft,
        child: const Text('Votre brassin est prêt.')
      ),
    ));
    return steps;
  }

  _mashs(ReceiptModel receipt, List<MyStep> steps) {
    for(int i = 0 ; i < receipt.mash!.length ; i++) {
      if (receipt.mash![i].type == Mash.Type.infusion) {
        steps.add(MyStep(
          index: steps.length,
          title: Text('Mettre en chauffe votre cuve à ${AppLocalizations.of(context)!.tempFormat(receipt.mash![i].temperature)}'),
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
            if (!_mashController.isStarted) {
              _mashController.restart(duration: _mash * 60);
            }
          }
        ));
        steps.add(MyStep(
          index: steps.length,
          title: Text('Palier ${receipt.mash![i].name} à ${AppLocalizations.of(context)!.tempFormat(receipt.mash![i].temperature)} pendant $_mash minutes'),
          content: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(8.0),
            child: CircularTimer(_mashController,
                duration: _mash * 60,
                index: steps.length,
                onChange: (String timeStamp) {
                  debugPrint('Countdown Changed $timeStamp');
                },
                onComplete: (int index) {
                  Notifications().showNotification(
                    const Uuid().hashCode,
                    'BeAndBrew',
                    body: 'Le Palier ${receipt.mash![i].name} à ${AppLocalizations.of(context)!.tempFormat(receipt.mash![i].temperature)} est terminé.'
                  );
                  steps[index].completed = true;
                }
            )
          ),
          onStepContinue: (int index) {
            if (!steps[index].completed) {
              throw 'Le processus n\'est pas terminé.';
            }
          }
        ));
      }
    }
  }

  _hops(ReceiptModel receipt, List<MyStep> steps) async {
    List<Widget> children = [];
    await receipt.gethops(volume: widget.model.volume).then((values) {
      List<HopModel> hops = values.where((element) => element.use == Use.boil).toList();
      hops.sort((a, b) => a.duration!.compareTo(b.duration!));
      for(int i = 0 ; i < hops.length; i++) {
        String text = '${AppLocalizations.of(context)!.weightFormat(hops[i].amount)} de ${AppLocalizations.of(context)!.localizedText(hops[i].name)}';
        if ((i+1) < hops.length) {
          if (hops[i].duration == hops[i+1].duration) {
            children.add(Text('Ajouter $text'));
            continue;
          }
        }
        if (children.isNotEmpty) {
          children.add(Text('Ajouter $text'));
          children.add(const SizedBox(height: 12));
          children.add(CircularTimer(_hopController,
            duration: hops[i].duration! * 60,
            index: steps.length,
          ));
        }
        steps.add(MyStep(
          index: steps.length,
          title: Text(children.isNotEmpty ? 'Ajouter les houblons suivants...' : 'Ajouter $text'),
          content: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(8.0),
            child: children.isNotEmpty ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ) : CircularTimer(_hopController,
              duration: hops[i].duration! * 60,
              index: steps.length,
              onComplete: (int index) {
                // Notifications().showNotification(
                //     Uuid().hashCode,
                //     'BeAndBrew',
                //     body: 'Le Palier ${receipt.mash![i].name} à ${AppLocalizations.of(context)!.tempFormat(receipt.mash![i].temperature)} est terminé.'
                // );
                steps[index].completed = true;
              }
            )
            // child: timer
          ),
          onStepContinue: (int index) {
            _hopController.restart(duration: hops[i].duration! * 60);
          },
        ));
        children = [];
      }
    });
  }

  _showSnackbar(String message, {SnackBarAction? action}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 10),
        action: action,
      )
    );
  }
}

