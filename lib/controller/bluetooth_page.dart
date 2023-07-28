import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';

// Internal package
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/utils/constants.dart';

// External package
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

final snackBarKeyA = GlobalKey<ScaffoldMessengerState>();
final snackBarKeyB = GlobalKey<ScaffoldMessengerState>();
final snackBarKeyC = GlobalKey<ScaffoldMessengerState>();

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
    return ScaffoldMessenger(
      key: snackBarKeyA,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: FillColor,
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.text('bluetooth_connection')),
          elevation: 0,
          foregroundColor: Theme.of(context).primaryColor,
          backgroundColor: Colors.white,
        ),
        body: RefreshIndicator(
          onRefresh: () {
            if (FlutterBluePlus.isScanningNow == false) {
              return FlutterBluePlus.startScan(timeout: const Duration(seconds: 15), androidUsesFineLocation: false);
            }
            return Future.value();
          },
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                StreamBuilder<List<BluetoothDevice>>(
                  stream: Stream.periodic(const Duration(seconds: 5)).asyncMap((_) => FlutterBluePlus.connectedSystemDevices),
                  initialData: const [],
                  builder: (c, snapshot) {
                    if (snapshot.data!.isEmpty) {
                      return SizedBox(
                        height: MediaQuery.of(context).size.height / 2,
                        child: Center(
                          child: StreamBuilder<BluetoothAdapterState>(
                            stream: FlutterBluePlus.adapterState,
                            initialData: BluetoothAdapterState.unknown,
                            builder: (c, snapshot) {
                              final state = snapshot.data;
                              if (state == BluetoothAdapterState.on) {
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
                                  FlutterBluePlus.turnOn();
                                } : null,
                              );
                            }
                          ),
                        )
                      );
                    }
                    return Column(
                      children: snapshot.data!.map((d) => ListTile(
                        title: Text(d.localName),
                        subtitle: Text(d.remoteId.toString()),
                        trailing: StreamBuilder<BluetoothConnectionState>(
                          stream: d.connectionState,
                          initialData: BluetoothConnectionState.disconnected,
                          builder: (c, snapshot) {
                            if (snapshot.data == BluetoothConnectionState.connected) {
                              return ElevatedButton(
                                child: const Text('OPEN'),
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => DeviceScreen(device: d),
                                      settings: RouteSettings(name: '/deviceScreen')));
                                },
                              );
                            }
                            if (snapshot.data == BluetoothConnectionState.disconnected) {
                              return ElevatedButton(
                                child: const Text('CONNECT'),
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) {
                                        d.connect(timeout: Duration(seconds: 4)).catchError((e) {
                                          final snackBar =
                                          SnackBar(content: Text('Connect Error: $e'));
                                          snackBarKeyB.currentState?.showSnackBar(snackBar);
                                        });
                                        return DeviceScreen(device: d);
                                      },
                                      settings: RouteSettings(name: '/deviceScreen')));
                                }
                              );
                            }
                            return Text(snapshot.data.toString().toUpperCase().split('.')[1]);
                          },
                        ),
                      )).toList(),
                    );
                  },
                ),
                StreamBuilder<List<ScanResult>>(
                  stream: FlutterBluePlus.scanResults,
                  initialData: const [],
                  builder: (c, snapshot) => Column(
                    children: snapshot.data!.map((r) {
                      return ListTile(
                        title: Text(r.device.localName),
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
              try {
                if (FlutterBluePlus.isScanningNow == false) {
                  FlutterBluePlus.startScan(timeout: const Duration(seconds: 15), androidUsesFineLocation: false);
                }
              } catch (e) {
                _showSnackbar('Start Scan Error:, ${e}');
              }
            },
          )
        ),
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

class DeviceScreen extends StatelessWidget {
  const DeviceScreen({Key? key, required this.device}) : super(key: key);

  final BluetoothDevice device;

  List<int> _getRandomBytes() {
    final math = Random();
    return [math.nextInt(255), math.nextInt(255), math.nextInt(255), math.nextInt(255)];
  }

  List<Widget> _buildServiceTiles(BuildContext context, List<BluetoothService> services) {
    return services.map((s) => ServiceTile(
        service: s,
        characteristicTiles: s.characteristics.map((c) => CharacteristicTile(
            characteristic: c,
            onReadPressed: () async {
              try {
                await c.read();
              } catch (e) {
                final snackBar = SnackBar(content: Text('Read Error: $e'));
                snackBarKeyC.currentState?.showSnackBar(snackBar);
              }
            },
            onWritePressed: () async {
              try {
                await c.write(_getRandomBytes(), withoutResponse: c.properties.writeWithoutResponse);
                if (c.properties.read) {
                  await c.read();
                }
              } catch (e) {
                final snackBar = SnackBar(content: Text('Write Error: $e'));
                snackBarKeyC.currentState?.showSnackBar(snackBar);
              }
            },
            onNotificationPressed: () async {
              try {
                await c.setNotifyValue(c.isNotifying == false);
                if (c.properties.read) {
                  await c.read();
                }
              } catch (e) {
                final snackBar = SnackBar(content: Text('Subscribe Error: $e'));
                snackBarKeyC.currentState?.showSnackBar(snackBar);
              }
            },
            descriptorTiles: c.descriptors
                .map(
                  (d) => DescriptorTile(
                descriptor: d,
                onReadPressed: () async {
                  try {
                    await d.read();
                  } catch (e) {
                    final snackBar = SnackBar(content: Text('Read Error: $e'));
                    snackBarKeyC.currentState?.showSnackBar(snackBar);
                  }
                },
                onWritePressed: () async {
                  try {
                    await d.write(_getRandomBytes());
                  } catch (e) {
                    final snackBar = SnackBar(content: Text('Write Error: $e'));
                    snackBarKeyC.currentState?.showSnackBar(snackBar);
                  }
                },
              ),
            ).toList(),
          ),
        ).toList(),
      ),
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: snackBarKeyC,
      child: Scaffold(
        appBar: AppBar(
          title: Text(device.localName),
          actions: <Widget>[
            StreamBuilder<BluetoothConnectionState>(
              stream: device.connectionState,
              initialData: BluetoothConnectionState.connecting,
              builder: (c, snapshot) {
                VoidCallback? onPressed;
                String text;
                switch (snapshot.data) {
                  case BluetoothConnectionState.connected:
                    onPressed = () async {
                      try {
                        await device.disconnect();
                      } catch (e) {
                        final snackBar = SnackBar(content: Text('Disconnect Error: $e'));
                        snackBarKeyC.currentState?.showSnackBar(snackBar);
                      }
                    };
                    text = 'DISCONNECT';
                    break;
                  case BluetoothConnectionState.disconnected:
                    onPressed = () async {
                      try {
                        await device.connect(timeout: Duration(seconds: 4));
                      } catch (e) {
                        final snackBar = SnackBar(content: Text('Connect Error: $e'));
                        snackBarKeyC.currentState?.showSnackBar(snackBar);
                      }
                    };
                    text = 'CONNECT';
                    break;
                  default:
                    onPressed = null;
                    text = snapshot.data.toString().split(".").last.toUpperCase();
                    break;
                }
                return TextButton(
                    onPressed: onPressed,
                    child: Text(
                      text,
                      style: Theme.of(context).primaryTextTheme.labelLarge?.copyWith(color: Colors.white),
                    ));
              },
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              StreamBuilder<BluetoothConnectionState>(
                stream: device.connectionState,
                initialData: BluetoothConnectionState.connecting,
                builder: (c, snapshot) => Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('${device.remoteId}'),
                    ),
                    ListTile(
                      leading: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          snapshot.data == BluetoothConnectionState.connected
                              ? const Icon(Icons.bluetooth_connected)
                              : const Icon(Icons.bluetooth_disabled),
                          snapshot.data == BluetoothConnectionState.connected
                              ? StreamBuilder<int>(
                              stream: rssiStream(),
                              builder: (context, snapshot) {
                                return Text(snapshot.hasData ? '${snapshot.data}dBm' : '',
                                    style: Theme.of(context).textTheme.bodySmall);
                              })
                              : Text('', style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                      title: Text('Device is ${snapshot.data.toString().split('.')[1]}.'),
                      trailing: StreamBuilder<bool>(
                        stream: device.isDiscoveringServices,
                        initialData: false,
                        builder: (c, snapshot) => IndexedStack(
                          index: (snapshot.data ?? false) ? 1 : 0,
                          children: <Widget>[
                            TextButton(
                              child: const Text("Get Services"),
                              onPressed: () async {
                                try {
                                  await device.discoverServices();
                                } catch (e) {
                                  final snackBar = SnackBar(content: Text('Discover Services Error: $e'));
                                  snackBarKeyC.currentState?.showSnackBar(snackBar);
                                }
                              },
                            ),
                            const IconButton(
                              icon: SizedBox(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation(Colors.grey),
                                ),
                                width: 18.0,
                                height: 18.0,
                              ),
                              onPressed: null,
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              StreamBuilder<int>(
                stream: device.mtu,
                initialData: 0,
                builder: (c, snapshot) => ListTile(
                  title: const Text('MTU Size'),
                  subtitle: Text('${snapshot.data} bytes'),
                  trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        try {
                          await device.requestMtu(223);
                        } catch (e) {
                          final snackBar = SnackBar(content: Text('Change Mtu Error: $e'));
                          snackBarKeyC.currentState?.showSnackBar(snackBar);
                        }
                      }),
                ),
              ),
              StreamBuilder<List<BluetoothService>>(
                stream: device.servicesStream,
                initialData: const [],
                builder: (c, snapshot) {
                  return Column(
                    children: _buildServiceTiles(context, snapshot.data ?? []),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Stream<int> rssiStream({Duration frequency = const Duration(seconds: 5)}) async* {
    var isConnected = true;
    final subscription = device.connectionState.listen((v) {
      isConnected = v == BluetoothConnectionState.connected;
    });
    while (isConnected) {
      try {
        yield await device.readRssi();
      } catch (e) {
        print("Error reading RSSI: $e");
        break;
      }
      await Future.delayed(frequency);
    }
    // Device disconnected, stopping RSSI stream
    subscription.cancel();
  }
}

class ServiceTile extends StatelessWidget {
  final BluetoothService service;
  final List<CharacteristicTile> characteristicTiles;

  const ServiceTile({Key? key, required this.service, required this.characteristicTiles}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (characteristicTiles.isNotEmpty) {
      return ExpansionTile(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('Service'),
            Text('0x${service.serviceUuid.toString().toUpperCase()}',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: Theme.of(context).textTheme.bodySmall?.color))
          ],
        ),
        children: characteristicTiles,
      );
    } else {
      return ListTile(
        title: const Text('Service'),
        subtitle: Text('0x${service.serviceUuid.toString().toUpperCase()}'),
      );
    }
  }
}

class CharacteristicTile extends StatefulWidget {
  final BluetoothCharacteristic characteristic;
  final List<DescriptorTile> descriptorTiles;
  final VoidCallback? onReadPressed;
  final VoidCallback? onWritePressed;
  final VoidCallback? onNotificationPressed;

  const CharacteristicTile(
      {Key? key,
        required this.characteristic,
        required this.descriptorTiles,
        this.onReadPressed,
        this.onWritePressed,
        this.onNotificationPressed})
      : super(key: key);

  @override
  State<CharacteristicTile> createState() => _CharacteristicTileState();
}

class _CharacteristicTileState extends State<CharacteristicTile> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<int>>(
      stream: widget.characteristic.onValueReceived,
      initialData: widget.characteristic.lastValue,
      builder: (context, snapshot) {
        final List<int>? value = snapshot.data;
        return ExpansionTile(
          title: ListTile(
            title: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('Characteristic'),
                Text('0x${widget.characteristic.characteristicUuid.toString().toUpperCase()}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).textTheme.bodySmall?.color),
                ),
                Row(
                  children: [
                    if (widget.characteristic.properties.read)
                      TextButton(
                          child: Text("Read"),
                          onPressed: () {
                            widget.onReadPressed!();
                            setState(() {});
                          }),
                    if (widget.characteristic.properties.write)
                      TextButton(
                          child: Text(widget.characteristic.properties.writeWithoutResponse ? "WriteNoResp" : "Write"),
                          onPressed: () {
                            widget.onWritePressed!();
                            setState(() {});
                          }),
                    if (widget.characteristic.properties.notify || widget.characteristic.properties.indicate)
                      TextButton(
                          child: Text(widget.characteristic.isNotifying ? "Unsubscribe" : "Subscribe"),
                          onPressed: () {
                            widget.onNotificationPressed!();
                            setState(() {});
                          })
                  ],
                )
              ],
            ),
            subtitle: Text(value.toString()),
            contentPadding: const EdgeInsets.all(0.0),
          ),
          children: widget.descriptorTiles,
        );
      },
    );
  }
}

class DescriptorTile extends StatelessWidget {
  final BluetoothDescriptor descriptor;
  final VoidCallback? onReadPressed;
  final VoidCallback? onWritePressed;

  const DescriptorTile({Key? key, required this.descriptor, this.onReadPressed, this.onWritePressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('Descriptor'),
          Text('0x${descriptor.descriptorUuid.toString().toUpperCase()}',
              style:
              Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).textTheme.bodySmall?.color))
        ],
      ),
      subtitle: StreamBuilder<List<int>>(
        stream: descriptor.onValueReceived,
        initialData: descriptor.lastValue,
        builder: (c, snapshot) => Text(snapshot.data.toString()),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
            icon: Icon(
              Icons.file_download,
              color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
            ),
            onPressed: onReadPressed,
          ),
          IconButton(
            icon: Icon(
              Icons.file_upload,
              color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
            ),
            onPressed: onWritePressed,
          )
        ],
      ),
    );
  }
}

