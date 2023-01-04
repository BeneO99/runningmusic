import 'package:flutter/material.dart';
import 'package:esense_flutter/esense.dart';
import 'dart:async';
import '../stream_chart/stream_chart.dart';
import '../stream_chart/chart_legend.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class musicplayer extends StatefulWidget {
  const musicplayer({super.key});

  final String title = "Test";

  @override
  State<musicplayer> createState() => _musicplayerState();
}

class _musicplayerState extends State<musicplayer> {
  static const String _eSenseName = "eSense-0678";
  ESenseManager eSenseManager = ESenseManager(_eSenseName);
  String _deviceStatus = '';

  @override
  void initState() {
    super.initState();
    _connectToESense();
  }

  Future<void> _askForPermissions() async {
    if (!(await Permission.bluetooth.request().isGranted)) {
      _deviceStatus =
          'WARNING - no permission to use Bluetooth granted. Cannot access eSense device.';
    }
    if (!(await Permission.bluetoothConnect.request().isGranted)) {
      _deviceStatus =
          'WARNING - no permission to use Bluetooth-Connect granted. Cannot access eSense device.';
    }
    if (!(await Permission.bluetoothScan.request().isGranted)) {
      _deviceStatus =
          'WARNING - no permission to use Bluetooth-Scan granted. Cannot access eSense device.';
    }
    if (!(await Permission.locationWhenInUse.request().isGranted)) {
      _deviceStatus =
          'WARNING - no permission to access location granted. Cannot access eSense device.';
    }
  }

  Future<void> _connectToESense() async {
    if (Platform.isAndroid) await _askForPermissions();

    await eSenseManager.disconnect();
    await eSenseManager.connect();

    eSenseManager.connectionEvents.listen((event) {
      setState(() {
        switch (event.type) {
          case ConnectionType.connected:
            _deviceStatus = 'connected';
            break;
          case ConnectionType.unknown:
            print("fuuuuuuuuuuck this shit");
            _deviceStatus = 'unknown';
            break;
          case ConnectionType.disconnected:
            _deviceStatus = 'disconnected';
            break;
          case ConnectionType.device_found:
            _deviceStatus = 'device_found';
            break;
          case ConnectionType.device_not_found:
            _deviceStatus = 'device_not_found';
            break;
        }
      });
    });
  }

  List<double> _handleAccel(SensorEvent event) {
    if (event.accel != null) {
      return [
        event.accel![0].toDouble(),
        event.accel![1].toDouble(),
        event.accel![2].toDouble(),
      ];
    } else {
      return [0.0, 0.0, 0.0];
    }
  }

  List<double> _handleGyro(SensorEvent event) {
    if (event.gyro != null) {
      return [
        event.gyro![0].toDouble(),
        event.gyro![1].toDouble(),
        event.gyro![2].toDouble(),
      ];
    } else {
      return [0.0, 0.0, 0.0];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          StreamBuilder<ConnectionEvent>(
            stream: ESenseManager(_eSenseName).connectionEvents,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                switch (_deviceStatus) {
                  case 'connected':
                    return Column(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: StreamChart<SensorEvent>(
                              stream: ESenseManager(_eSenseName).sensorEvents,
                              handler: _handleAccel,
                              timeRange: const Duration(seconds: 10),
                              minValue: -20000.0,
                              maxValue: 20000.0,
                            ),
                          ),
                        ),
                        const ChartLegend(label: "Accel"),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: StreamChart<SensorEvent>(
                              stream: ESenseManager(_eSenseName).sensorEvents,
                              handler: _handleGyro,
                              timeRange: const Duration(seconds: 10),
                              minValue: -20000.0,
                              maxValue: 20000.0,
                            ),
                          ),
                        ),
                        const ChartLegend(label: "Gyro"),
                      ],
                    );
                  case 'unknown':
                    return ReconnectButton(
                      child: const Text("Connection: Unknown"),
                      onPressed: _connectToESense,
                    );
                  case 'disconnected':
                    return ReconnectButton(
                      child: const Text("Connection: Disconnected"),
                      onPressed: _connectToESense,
                    );
                  case 'device_found':
                    return const Center(
                        child: Text("Connection: Device found"));
                  case '':
                    return ReconnectButton(
                      child:
                          Text("Connection: Device not found - $_eSenseName"),
                      onPressed: _connectToESense,
                    );
                  default:
                    return ReconnectButton(
                      child:
                          Text("Connection: Device not found - $_eSenseName"),
                      onPressed: _connectToESense,
                    );
                }
              } else {
                return const Center(
                    child: Text("Waiting for Connection Data..."));
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    ESenseManager(_eSenseName).disconnect();
    super.dispose();
  }
}

class ReconnectButton extends StatelessWidget {
  const ReconnectButton(
      {Key? key, required this.child, required this.onPressed})
      : super(key: key);

  final Widget child;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        child,
        ElevatedButton(
          onPressed: onPressed,
          child: const Text("Connect To eSense"),
        )
      ]),
    );
  }
}
