import 'package:bab/widgets/image_animate_rotate.dart';
import 'package:flutter/material.dart';

// Internal package
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/widgets/custom_state.dart';

class MyStep extends Step {
  int index;
  bool completed = false;
  final void Function(int index)? onStepTapped;
  final void Function(int index)? onStepCancel;
  final void Function(int index)? onStepContinue;
  MyStep({
    required this.index,
    required Widget title,
    Widget? subtitle,
    required Widget content,
    Widget? label,
    StepState state = StepState.indexed,
    bool isActive = false,
    this.onStepTapped,
    this.onStepCancel,
    this.onStepContinue
  }) : super(
      title: title,
      subtitle: subtitle,
      content: content,
      state: state,
      isActive: isActive
  );
}

class CustomStepper extends StatefulWidget {
  List<MyStep> steps = [];
  int currentStep;
  final void Function(int index)? onLastStep;

  CustomStepper({Key? key, required this.steps, this.currentStep = 0, this.onLastStep}): super(key: key);
  @override
  CustomStepperState createState() => CustomStepperState();
}

class CustomStepperState extends CustomState<CustomStepper> with WidgetsBindingObserver  {
  int _lastStep = 0;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _lastStep = widget.currentStep ?? 0;
    _currentStep = widget.currentStep ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final MaterialLocalizations localizations = MaterialLocalizations.of(context);
    if (widget.steps.isEmpty) {
      return Center(
        child: ImageAnimateRotate(
          child: Image.asset('assets/images/logo.png', width: 60, height: 60, color: Theme.of(context).primaryColor),
        )
      );
    }
    return Stepper(
      currentStep: _currentStep,
      onStepCancel: () {
        if (_currentStep > 0) {
          try {
            widget.steps[_currentStep].onStepCancel?.call(_currentStep);
            setState(() {
              _currentStep -= 1;
            });
          } catch (e) {
            showSnackbar(e.toString(), success: false);
          }
        }
      },
      onStepContinue: () {
        if (_currentStep < widget.steps.length - 1) {
          try {
            widget.steps[_currentStep].onStepContinue?.call(_currentStep);
            setState(() {
              _currentStep += 1;
              if (_currentStep > _lastStep) {
                _lastStep = _currentStep;
                widget.onLastStep?.call(_lastStep);
              }
            });
          } catch (e) {
            showSnackbar(e.toString(), action: SnackBarAction(
              label: localizations.continueButtonLabel.toUpperCase(),
              textColor: Colors.white,
              onPressed: () {
                setState(() {
                  _currentStep += 1;
                  if (_currentStep > _lastStep) _lastStep = _currentStep;
                });
              },
            ));
          }
        }
      },
      onStepTapped: (int index) {
        if (index <= _lastStep) {
          widget.steps[_currentStep].onStepTapped?.call(index);
          setState(() {
            _currentStep = index;
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
                if (_currentStep == widget.steps.length - 1) ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(localizations.closeButtonLabel.toUpperCase()),
                ),
                if (_currentStep < widget.steps.length - 1) ElevatedButton(
                  onPressed: controls.onStepContinue,
                  child: Text(_currentStep == 0 ? AppLocalizations.of(context)!.text('start').toUpperCase() : localizations.continueButtonLabel.toUpperCase()),
                ),
                if (_currentStep != 0) TextButton(
                  onPressed: controls.onStepCancel,
                  child: Text(
                    localizations.backButtonTooltip.toUpperCase(),
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            )
          )
        );
      },
      steps: widget.steps
    );
  }
}