import 'dart:io';

import 'package:flutter/material.dart';

// Internal package
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/utils/constants.dart';

// External package
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothPage extends StatefulWidget {
  @override
  _BluetoothPageState createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> with AutomaticKeepAliveClientMixin<BluetoothPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: FillColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.text('bluetooth_connection')),
        elevation: 0,
        foregroundColor: Theme.of(context).primaryColor,
        backgroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: () => FlutterBluePlus.instance.startScan(timeout: const Duration(seconds: 4)),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              StreamBuilder<List<BluetoothDevice>>(
                stream: Stream.periodic(const Duration(seconds: 2)).asyncMap((_) => FlutterBluePlus.instance.connectedDevices),
                initialData: const [],
                builder: (c, snapshot) {
                  if (snapshot.data!.isEmpty) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height / 2,
                      child: Center(
                        child: StreamBuilder<BluetoothState>(
                          stream: FlutterBluePlus.instance.state,
                          initialData: BluetoothState.unknown,
                          builder: (c, snapshot) {
                            final state = snapshot.data;
                            if (state == BluetoothState.on) {
                              return CircleAvatar(
                                backgroundColor: Colors.white,
                                radius: 50,
                                child: Icon(Icons.bluetooth, color: Theme.of(context).primaryColor, size: 50),
                              );
                            }
                            return ElevatedButton(
                              child: Text(AppLocalizations.of(context)!.text('activate_bluetooth')),
                              onPressed: Platform.isAndroid ? () async {
                                if (!await Permission.bluetooth.isGranted) {
                                  await Permission.bluetoothConnect.request();
                                }
                                FlutterBluePlus.instance.turnOn();
                              } : null,
                            );
                          }
                        ),
                      )
                    );
                  }
                  return Column(
                    children: snapshot.data!.map((d) => ListTile(
                      title: Text(d.name),
                      subtitle: Text(d.id.toString()),
                      trailing: StreamBuilder<BluetoothDeviceState>(
                        stream: d.state,
                        initialData: BluetoothDeviceState.disconnected,
                        builder: (c, snapshot) {
                          if (snapshot.data ==
                              BluetoothDeviceState.connected) {
                            return ElevatedButton(
                              child: const Text('OPEN'),
                              onPressed: () {
                              },
                            );
                          }
                          return Text(snapshot.data.toString());
                        },
                      ),
                    )).toList(),
                  );
                },
              ),
              StreamBuilder<List<ScanResult>>(
                stream: FlutterBluePlus.instance.scanResults,
                initialData: const [],
                builder: (c, snapshot) => Column(
                  children: snapshot.data!.map((r) {
                    return ListTile(
                      title: Text(r.device.name),
                      onTap: () {},
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: ElevatedButton(
          child: Text(AppLocalizations.of(context)!.text('find_device')),
          style: ElevatedButton.styleFrom(padding: EdgeInsets.all(18)),
          onPressed: () async {
            FlutterBluePlus.instance.startScan(timeout: const Duration(seconds: 4));
          },
        )
      ),
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

