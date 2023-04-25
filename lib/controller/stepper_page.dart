import 'package:flutter/material.dart';

// Internal package
import 'package:bb/models/brew_model.dart';
import 'package:bb/models/hop_model.dart';
import 'package:bb/models/receipt_model.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/utils/mash.dart';
import 'package:bb/widgets/circular_timer.dart';

// External package
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class StepperPage extends StatefulWidget {
  final BrewModel model;
  StepperPage(this.model);
  _StepperPageState createState() => new _StepperPageState();
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

  List<MyStep> _steps = [];
  late SfRadialGauge _temp;

  CountDownController _mashController = CountDownController();
  CountDownController _hopController = CountDownController();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: FillColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.text('stages')),
        elevation: 0,
        foregroundColor: Theme.of(context).primaryColor,
        backgroundColor: Colors.white
      ),
      body: FutureBuilder<List<Step>>(
        future: _generate(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Stepper(
                currentStep: _index,
                onStepCancel: () {
                  if (_index > 0) {
                    try {
                      _steps[_index].onStepCancel?.call(_index);
                      setState(() {
                        _index -= 1;
                      });
                    } catch (e) {
                      _showSnackbar(e.toString());
                    }
                  }
                },
                onStepContinue: () {
                  if (_index < _steps.length - 1) {
                    try {
                      _steps[_index].onStepContinue?.call(_index);
                      setState(() {
                        _index += 1;
                        if (_index > _lastIndex) _lastIndex = _index;
                      });
                    } catch (e) {
                      _showSnackbar(e.toString());
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
                steps: snapshot.data!
            );
          }
          return Container();
        }
      )
    );
  }

  Future<List<Step>> _generate() async {
    _initialize();
    ReceiptModel receipt = widget.model.receipt!;
    _steps = [
      MyStep(
        index: 0,
        title: const Text('Début'),
        content: Container(
          alignment: Alignment.centerLeft,
          child: const Text('Démarrage du brassin')
        ),
      ),
      MyStep(
        index: 1,
        title: Text('Concasser le grain'),
        content:  Container(
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: receipt.fermentables!.map((e) {
              return Flexible(child: Text('Concassez ${AppLocalizations.of(context)!.weightFormat(e.amount! * 1000)} de ${AppLocalizations.of(context)!.localizedText(e.name)}.'));
            }).toList()
          )
        ),
      ),
      MyStep(
        index: 2,
        title: Text('Ajouter l\'eau'),
        content: Container(
          alignment: Alignment.centerLeft,
          child: Text('Ajoutez ${AppLocalizations.of(context)!.volumeFormat(widget.model.volume)} d\'eau dans votre cuve')
        ),
      ),
    ];
    _mashs(receipt);
    _steps.add(MyStep(
      index: _steps.length,
      title: Text('Rinçage des drêches'),
      content: Container(),
    ));
    _steps.add(MyStep(
      index: _steps.length,
      title: Text('Mettre en ébullition votre cuve.'),
      content: Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.all(8.0),
        child: SizedBox(
          width: 140,
          height: 140,
          child: _temp,
        )
      ),
    ));
    await _hops(receipt);
    _steps.add(MyStep(
      index: _steps.length,
      title: Text('Faire un whirlpool'),
      content: Container(),
    ));
    _steps.add(MyStep(
      index: _steps.length,
      title: Text('Transfert dans le fermenteur'),
      content: Container(),
    ));
    await _yeasts(receipt);
    _steps.add(MyStep(
      index: _steps.length,
      title: Text('Fin'),
      content: Container(
        alignment: Alignment.centerLeft,
        child: const Text('Votre brassin est prêt.')
      ),
    ));
    return _steps;
  }

  _mashs(ReceiptModel receipt) {
    for(int i = 0 ; i < receipt.mash!.length ; i++) {
      Mash mash = receipt.mash![i];
      _steps.add(MyStep(
        index: _steps.length,
        title: Text('Mettre en chauffe votre cuve à ${AppLocalizations.of(context)!.tempFormat(mash.temperature)}'),
        content: Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.all(8.0),
            child: SizedBox(
              width: 140,
              height: 140,
              child: _temp,
            )
        ),
      ));
      if (i == 0) {
        _steps.add(MyStep(
            index: _steps.length,
            title: Text('Ajouter le grain'),
            content: Container(),
            onStepContinue: (int index) {
              if (!_mashController.isStarted) {
                _mashController.restart(duration: 60 * 60);
              }
            }
        ));
      }
      _steps.add(MyStep(
          index: _steps.length,
          title: Text('Empâtage pendant 60 minutes'),
          content: Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.all(8.0),
              child: CircularTimer(_mashController,
                  duration: 60 * 60,
                  index: _steps.length,
                  onComplete: (int index) {
                    _steps[index].completed = true;
                  }
              )
          ),
          onStepContinue: (int index) {
            if (!_steps[index].completed) {
              throw Exception('Le processus n\'est pas terminé.');
            }
          }
      ));
    };
  }

  _hops(ReceiptModel receipt) async {
    List<Widget> children = [];
    await receipt.hopsAsync.then((values) {
      List<HopModel> hops = values.where((element) => element.use == Use.boil).toList() ?? [];
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
          children.add(SizedBox(height: 12));
          children.add(CircularTimer(_hopController,
            duration: hops[i].duration! * 60,
            index: _steps.length,
          ));
        }
        _steps.add(MyStep(
            index: _steps.length,
            title: Text(children.isNotEmpty ? 'Ajouter les houblons' : 'Ajouter $text'),
            content: Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.all(8.0),
                child: children.isNotEmpty ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: children,
                ) : CircularTimer(_hopController,
                  duration: hops[i].duration! * 60,
                  index: _steps.length,
                )
              // child: timer
            ),
            onStepContinue: (int index) {
              _hopController.restart(duration: hops[i].duration! * 60);
            }
        ));
        children = [];
      }
    });
  }

  _yeasts(ReceiptModel receipt) async {
    await receipt.yeastsAsync.then((values) {
      _steps.add(MyStep(
        index: _steps.length,
        title: Text('Ajouter ${AppLocalizations.of(context)!.weightFormat(receipt.yeasts.first.amount)} de levure ${AppLocalizations.of(context)!.localizedText(receipt.yeasts!.first.name)}'),
        content: Container(),
      ));
    });
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
              widget: Text('Temp.${AppLocalizations.of(context)!.tempUnit}', style: TextStyle(color: Color(0xFFF8B195), fontSize: 9))),
            GaugeAnnotation(
              angle: 90,
              positionFactor: 0.8,
              widget: Text('  0  ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            )
          ],
          pointers: <GaugePointer>[
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

