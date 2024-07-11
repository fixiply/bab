import 'dart:async';

import 'package:bab/helpers/device_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';

// Internal package
import 'package:bab/models/equipment_model.dart';
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/utils/bluetooth.dart';
import 'package:bab/utils/constants.dart';
import 'package:bab/widgets/bluetooth/service_page.dart';
import 'package:bab/widgets/custom_dual_switch.dart';
import 'package:bab/widgets/custom_gauge.dart';
import 'package:bab/widgets/custom_state.dart';
import 'package:bab/widgets/bluetooth/extra.dart';

// External package
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class DevicePage extends StatefulWidget {
  final BluetoothDevice device;
  final EquipmentModel model;

  const DevicePage({Key? key, required this.device, required this.model}) : super(key: key);

  @override
  _DevicePageState createState() => _DevicePageState();
}

class _DevicePageState extends CustomState<DevicePage> with AutomaticKeepAliveClientMixin<DevicePage> {
  late StreamSubscription<BluetoothConnectionState> _connectionStateSubscription;
  late StreamSubscription<bool> _isConnectingSubscription;
  late StreamSubscription<bool> _isDisconnectingSubscription;

  BluetoothConnectionState _connectionState = BluetoothConnectionState.disconnected;
  BluetoothCharacteristic? _read_characteristic;
  StreamSubscription? _scanResultsSubscription;
  double _targetTemp = 0;
  double _currentTemp = 0;
  bool _heat = false;
  bool _pump = false;

  bool _isConnecting = false;
  bool _isDisconnecting = false;

  @override
  bool get wantKeepAlive => true;

  TabBar get _tabBar => TabBar(
    indicatorSize: TabBarIndicatorSize.tab,
    indicator: ShapeDecoration(
      color: Theme.of(context).primaryColor.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
    ),
    tabs: [
      Tab(icon: Icon(Icons.takeout_dining_outlined, color: Theme.of(context).primaryColor), iconMargin: EdgeInsets.zero, child: Text(AppLocalizations.of(context)!.text('tank'), overflow: TextOverflow.ellipsis, style: TextStyle(color: Theme.of(context).primaryColor))),
      Tab(icon: Icon(Icons.bluetooth, color: Theme.of(context).primaryColor), iconMargin: EdgeInsets.zero, child: Text(AppLocalizations.of(context)!.text('services'), overflow: TextOverflow.ellipsis, style: TextStyle(color: Theme.of(context).primaryColor))),
    ],
  );

  @override
  void initState() {
    super.initState();
    _connectionStateSubscription = widget.device.connectionState.listen((state) async {
      _connectionState = state;

      if (state == BluetoothConnectionState.connected) {
        Bluetooth? controller = widget.model.controller;
        if (controller != null) {
          _read_characteristic =
          await controller.getReadCharateristic(widget.device);
          if (_read_characteristic != null) {
            _scanResultsSubscription =
                _read_characteristic!.onValueReceived.listen((value) {
                  double? target = controller.getTargetTemperature(
                      String.fromCharCodes(value));
                  if (target != null) {
                    setState(() {
                      _targetTemp = target;
                    });
                  }
                  double? current = controller.getCurrentTemperature(
                      String.fromCharCodes(value));
                  if (current != null) {
                    setState(() {
                      _currentTemp = current;
                    });
                  }
                });
            widget.device.cancelWhenDisconnected(_scanResultsSubscription!);
            await _read_characteristic!.setNotifyValue(true);
          }
        }
      }
    });

    _isConnectingSubscription = widget.device.isConnecting.listen((value) {
      _isConnecting = value;
      if (mounted) {
        setState(() {});
      }
    });

    _isDisconnectingSubscription = widget.device.isDisconnecting.listen((value) {
      _isDisconnecting = value;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _connectionStateSubscription.cancel();
    _isConnectingSubscription.cancel();
    _isDisconnectingSubscription.cancel();
    _scanResultsSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (foundation.kDebugMode || currentUser != null && currentUser!.isAdmin()) {
      return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.device.platformName),
            elevation: 0,
            foregroundColor: Theme.of(context).primaryColor,
            backgroundColor: Colors.white,
            actions: [buildConnectButton(context)],
            bottom: PreferredSize(
              preferredSize: _tabBar.preferredSize,
              child: ColoredBox(
                color: FillColor,
                child: _tabBar,
              ),
            ),
          ),
          body: TabBarView(
            children: [
              _body(),
              ServicePage(device: widget.device)
            ]
          )
        )
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device.platformName),
        elevation: 0,
        foregroundColor: Theme.of(context).primaryColor,
        backgroundColor: Colors.white,
        actions: [buildConnectButton(context)],
      ),
      body: _body()
    );
    return _body();
  }

  Widget _body() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CustomGauge(
              context,
              annotations: <GaugeAnnotation>[
                GaugeAnnotation(
                  angle: 90,
                  positionFactor: 0.35,
                  widget: Text(
                      AppLocalizations.of(context)!.tempFormat(_targetTemp)!,
                      style: const TextStyle(fontSize: 22)
                  )
                ),
                GaugeAnnotation(
                  angle: 90,
                  positionFactor: 0.8,
                  widget: Text(AppLocalizations.of(context)!.tempFormat(_currentTemp)!,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                  ),
                )
              ],
              pointers: <GaugePointer>[
                NeedlePointer(
                  value: _currentTemp,
                  enableAnimation: true,
                  needleStartWidth: 0,
                  needleEndWidth: 3,
                  knobStyle: KnobStyle(knobRadius: 0.05),
                ),
                RangePointer(
                  value: _targetTemp,
                  onValueChanged: (value) => setState(() {
                    _targetTemp = value.roundToDouble();
                  }),
                  onValueChangeEnd: tempValueChanged,
                  enableDragging: true,
                  width: 0.26,
                  sizeUnit: GaugeSizeUnit.factor,
                ),
                MarkerPointer(
                  value: _targetTemp,
                  color: Colors.white,
                  borderColor: Theme.of(context).primaryColor,
                  borderWidth: 3,
                  markerHeight: 35,
                  markerWidth: 35,
                  markerOffset: DeviceHelper.isMobile ? 15 : 15,
                  markerType: MarkerType.circle,
                  overlayColor: Theme.of(context).primaryColor.withOpacity(.2),
                  overlayRadius: 30
                ),
              ]
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                alignment: Alignment.centerRight,
                child: Text('Chaleur', style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 10),
              CustomDualSwitch<bool>.dual(
                current: _heat,
                onChanged: (b) async {
                  setState(() => _heat = b);
                  Bluetooth? controller = widget.model.controller;
                  if (controller != null) {
                    try {
                      await controller.setHeat(widget.device, _heat);
                      showSnackbar("Descriptor Write : Success");
                    } catch (e) {
                      debugPrint(e.toString());
                      showSnackbar(prettyException("Descriptor Write Error:", e), success: false);
                    }
                  }
                },
              ),
            ]
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                alignment: Alignment.centerRight,
                child: Text('Pompe', style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 10),
              CustomDualSwitch<bool>.dual(
                current: _pump,
                onChanged: (b) async {
                  setState(() => _pump = b);
                  Bluetooth? controller = widget.model.controller;
                  if (controller != null) {
                    try {
                      await controller.setHeat(widget.device, _pump);
                      showSnackbar("Descriptor Write : Success");
                    } catch (e) {
                      debugPrint(e.toString());
                      showSnackbar(prettyException("Descriptor Write Error:", e), success: false);
                    }
                  }
                },
              ),
            ]
          )
        ],
      ),
    );
  }

  /// Dragged pointer new value is updated to pointer and
  /// annotation current value.
  void tempValueChanged(dynamic value) async {
    setState(() {
      _targetTemp = value.roundToDouble();
    });
    Bluetooth? controller = widget.model.controller;
    if (controller != null) {
      try {
        await controller.setTargetTemperature(widget.device, _targetTemp);
        showSnackbar("Descriptor Write : Success");
      } catch (e) {
        debugPrint(e.toString());
        showSnackbar(prettyException("Descriptor Write Error:", e), success: false);
      }
    }
  }

  bool get isConnected {
    return _connectionState == BluetoothConnectionState.connected;
  }

  Future onConnectPressed() async {
    try {
      await widget.device.connectAndUpdateStream();
      showSnackbar("Connect: Success");
    } catch (e) {
      if (e is FlutterBluePlusException && e.code == FbpErrorCode.connectionCanceled.index) {
        // ignore connections canceled by the user
      } else {
        debugPrint(e.toString());
        showSnackbar(prettyException("Connect Error:", e), success: false);
      }
    }
  }

  Future onDisconnectPressed() async {
    try {
      await widget.device.disconnectAndUpdateStream();
      setState(() {
        _currentTemp = 0;
        _targetTemp = 0;
        _heat = false;
        _pump = false;
      });
      showSnackbar("Disconnect: Success");
    } catch (e) {
      debugPrint(e.toString());
      showSnackbar(prettyException("Disconnect Error:", e), success: false);
    }
  }

  Future onCancelPressed() async {
    try {
      await widget.device.disconnectAndUpdateStream(queue: false);
      showSnackbar("Cancel: Success");
    } catch (e) {
      debugPrint(e.toString());
      showSnackbar(prettyException("Cancel Error:", e), success: false);
    }
  }

  Widget buildSpinner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: AspectRatio(
        aspectRatio: 1.0,
        child: CircularProgressIndicator(
          backgroundColor: Colors.black12,
          color: Colors.black26,
        ),
      ),
    );
  }

  Widget buildConnectButton(BuildContext context) {
    return Row(children: [
      if (_isConnecting || _isDisconnecting) buildSpinner(context),
      TextButton(
          onPressed: _isConnecting ? onCancelPressed : (isConnected ? onDisconnectPressed : onConnectPressed),
          child: Text( _isConnecting ? "CANCEL" : (isConnected ? "DISCONNECT" : "CONNECT")
          ))
    ]);
  }
}