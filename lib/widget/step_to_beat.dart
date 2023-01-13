import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:esense_flutter/esense.dart';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'package:runningmusic/models/tracks.dart';

class StepToBeat extends StatefulWidget {
  const StepToBeat({super.key});

  final String title = "StepToBeat";

  @override
  State<StepToBeat> createState() => _StepToBeatState();
}

class _StepToBeatState extends State<StepToBeat> {
  static const String _eSenseName = "eSense-0678";
  String _deviceStatus = '';
  bool _runningCount = false;
  int _counter = 0;
  int _bpm = 80;
  late StreamSubscription<FlSpot> _subscription;
  final List<FlSpot> _speed = [];

  ESenseManager eSenseManager = ESenseManager(_eSenseName);
  final audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _connectToESense();
    _speed.add(const FlSpot(0, 0));
    setAudio();

    audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
    });

    audioPlayer.onDurationChanged.listen((newDuration) {
      setState(() {
        duration = newDuration;
      });
    });

    audioPlayer.onPositionChanged.listen((newPosition) {
      setState(() {
        position = newPosition;
      });
    });
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

  Tracks tracks = Tracks();
  Future setAudio() async {
    audioPlayer.setReleaseMode(ReleaseMode.loop);
    audioPlayer.setSource(AssetSource(tracks.getTitleForBpm(_bpm).path));
  }

  void _startcounting() async {
    setState(() {
      _runningCount = true;
    });

    await Future.delayed(const Duration(seconds: 4), () {});
    _subscription = eSenseManager.sensorEvents
        .map((event) => FlSpot(DateTime.now().millisecondsSinceEpoch.toDouble(),
            event.accel!.first.toDouble()))
        .listen((event) {
      setState(() {
        _speed.add(event);

        if (_speed[_speed.length - 2].y < _speed[_speed.length - 1].y &&
            _speed[_speed.length - 1].y > -2500) {
          _counter++;
        }
      });
    });
    Timer(const Duration(seconds: 6), _stopcounting);
  }

  void _stopcounting() async {
    _subscription.cancel();
    if (_counter >= 8) {
      _bpm = _counter * 10;
    } else {
      _bpm = 80;
    }
    _counter = 0;
    setAudio();
    audioPlayer.resume();
    setState(() {
      _runningCount = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Align(
        alignment: Alignment.center,
        child: ListView(
          children: [
            const SizedBox(height: 100),
            Center(
                child: Text(
              'eSense Device Status: \t$_deviceStatus',
              textScaleFactor: 1.25,
            )),
            const SizedBox(height: 20),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Stack(
                  children: <Widget>[
                    Positioned.fill(
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: <Color>[
                              Color.fromARGB(255, 13, 90, 3),
                              Color.fromARGB(164, 25, 210, 87),
                              Color.fromARGB(255, 66, 245, 96),
                            ],
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16.0),
                        textStyle: const TextStyle(fontSize: 20),
                      ),
                      onPressed: _connectToESense,
                      child: const Text('Mit  eSense Verbinden'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Press the "start tracking" Button to track you current stepfrequency. After a 4 sec delay this app will track your stepfrequency for the next 6 seconds and will play a fitting song für your runningspeed',
                textScaleFactor: 1.25,
              ),
            ),
            const SizedBox(height: 50),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Stack(
                  children: <Widget>[
                    Positioned.fill(
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: <Color>[
                              Color.fromARGB(255, 13, 90, 3),
                              Color.fromARGB(164, 25, 210, 87),
                              Color.fromARGB(255, 66, 245, 96),
                            ],
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16.0),
                        textStyle: const TextStyle(fontSize: 20),
                      ),
                      onPressed: (!eSenseManager.connected)
                          ? null
                          : (!_runningCount)
                              ? _startcounting
                              : null,
                      child: const Text('start tracking'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
                child: Text(
              'Current BPM: $_bpm',
              textScaleFactor: 1.25,
            )),
            const SizedBox(height: 30),
            Center(
                child: Text(
              'playing: \n ${tracks.getTitleForBpm(_bpm).title}',
              textScaleFactor: 2,
              textAlign: TextAlign.center,
            )),
            Slider(
                min: 0,
                max: duration.inSeconds.toDouble(),
                value: position.inSeconds.toDouble(),
                onChanged: ((value) async {
                  final position = Duration(seconds: value.toInt());
                  await audioPlayer.seek(position);

                  await audioPlayer.resume();
                })),
            CircleAvatar(
              radius: 35,
              child: IconButton(
                icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                iconSize: 50,
                onPressed: () async {
                  if (isPlaying) {
                    await audioPlayer.pause();
                  } else {
                    await audioPlayer.resume();
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    eSenseManager.disconnect();
    if (_runningCount) {
      _subscription.cancel();
    }
    super.dispose();
  }
}
