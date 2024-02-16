import 'dart:async';
import 'dart:io';

import 'package:bab/models/equipment_model.dart';
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/widgets/animated_action_button.dart';
import 'package:flutter/material.dart';

import 'package:bab/controller/device_page.dart';
import 'package:bab/widgets/bluetooth/extra.dart';
import 'package:bab/widgets/bluetooth/scan_result_tile.dart';
import 'package:bab/widgets/bluetooth/system_device_tile.dart';
import 'package:bab/widgets/custom_state.dart';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothPage extends StatefulWidget {
  EquipmentModel model;
  BluetoothPage(this.model, {Key? key}) : super(key: key);

  @override
  _BluetoothPageState createState() => _BluetoothPageState();
}

class _BluetoothPageState extends CustomState<BluetoothPage> {
  List<BluetoothDevice> _systemDevices = [];
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;
  late StreamSubscription<bool> _isScanningSubscription;

  @override
  void initState() {
    super.initState();

    _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
      _scanResults = results;
      if (mounted) {
        setState(() {});
      }
    }, onError: (e) {
      showSnackbar(prettyException("Scan Error:", e), success: false);
    });

    _isScanningSubscription = FlutterBluePlus.isScanning.listen((state) {
      _isScanning = state;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _scanResultsSubscription.cancel();
    _isScanningSubscription.cancel();
    super.dispose();
  }

  Future onScanPressed() async {
    try {
      _systemDevices = await FlutterBluePlus.systemDevices;
    } catch (e) {
      showSnackbar(prettyException("System Devices Error:", e), success: false);
    }
    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
    } catch (e) {
      showSnackbar(prettyException("Start Scan Error:", e), success: false);
    }
    if (mounted) {
      setState(() {});
    }
  }

  Future onStopPressed() async {
    try {
      FlutterBluePlus.stopScan();
    } catch (e) {
      showSnackbar(prettyException("Stop Scan Error:", e), success: false);
    }
  }

  void onConnectPressed(BluetoothDevice device) {
    device.connectAndUpdateStream().catchError((e) {
      showSnackbar(prettyException("Connect Error:", e), success: false);
    });
    MaterialPageRoute route = MaterialPageRoute(
        builder: (context) => DevicePage(device: device), settings: RouteSettings(name: '/DeviceScreen'));
    Navigator.of(context).push(route);
  }

  Future onRefresh() {
    if (_isScanning == false) {
      FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
    }
    if (mounted) {
      setState(() {});
    }
    return Future.delayed(Duration(milliseconds: 500));
  }

  Widget buildScanButton(BuildContext context) {
    if (FlutterBluePlus.isScanningNow) {
      return FloatingActionButton(
        child: const Icon(Icons.stop),
        onPressed: onStopPressed,
        backgroundColor: Colors.red,
      );
    } else {
      return AnimatedActionButton(
        title: AppLocalizations.of(context)!.text('search'),
        icon: const Icon(Icons.bluetooth_searching),
        onPressed: onScanPressed,
      );
    }
  }

  List<Widget> _buildSystemDeviceTiles(BuildContext context) {
    return _systemDevices.map((d) => SystemDeviceTile(
        device: d,
        onOpen: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => DevicePage(device: d),
            settings: RouteSettings(name: '/DeviceScreen'),
          ),
        ),
        onConnect: () => onConnectPressed(d),
      ),
    ).toList();
  }

  List<Widget> _buildScanResultTiles(BuildContext context) {
    return _scanResults.map((r) => ScanResultTile(
        result: r,
        onTap: () => onConnectPressed(r.device),
      ),
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.text('available_devices')),
      ),
      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          children: <Widget>[
            ..._buildSystemDeviceTiles(context),
            ..._buildScanResultTiles(context),
          ],
        ),
      ),
      floatingActionButton: buildScanButton(context),
    );
  }
}
