import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:i_am_speed/src/background_painter.dart';
import 'package:i_am_speed/src/overpass_repo.dart';
import 'package:i_am_speed/src/settings_page.dart';
import 'package:i_am_speed/src/sign_painter.dart';
import 'package:i_am_speed/src/speed_unit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {

  late final AnimationController _animationController;
  late final AnimationController _signAnimationController;
  final Random rnd = Random();

  bool locationDisabled = false;
  double currentSpeed = 0.0;
  SpeedUnit speedUnit = SpeedUnit.KPH;
  int? speedLimit;

  Map<SpeedUnit, bool> activated = {
    SpeedUnit.KPH: true,
    SpeedUnit.MPS: true,
    SpeedUnit.MPH: false,
    SpeedUnit.KN: true,
    SpeedUnit.MACH: true,
    SpeedUnit.LIGHTSPEED: true,
  };

  late final SharedPreferences preferences;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(seconds: 500));
    _signAnimationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    startMeasurement();
    _animationController.repeat();
    SharedPreferences.getInstance().then((value) {
      preferences = value;
      setState(() {
        for (var value in SpeedUnit.values) {
          activated[value] = preferences.getBool(value.displayName) ?? activated[value]!;
        }
      });
    });
  }

  void startMeasurement() {
    // if (Platform.isAndroid || Platform.isIOS) {
      checkPermission();
    // }

    var options = const LocationSettings(accuracy: LocationAccuracy.best, distanceFilter: 0);
    Geolocator.getPositionStream(locationSettings: options).listen((position) {
      setPosition(position);
    });

    Timer.periodic(const Duration(seconds: 30), (timer) async {
      var position = await Geolocator.getCurrentPosition();
      setPosition(position);
      speedLimit = await OverpassRepository().getRailSpeedAt(position);
      if (speedLimit == null) {
        _signAnimationController.reverse();
      } else {
        _signAnimationController.forward();
      }
    });
  }

  void setPosition(Position position) {
    setState(() {
      currentSpeed = position.speed;
      _animationController.duration = Duration(milliseconds: 150000 ~/ max(0.001, currentSpeed));
      _animationController.repeat();
    });
  }

  void checkPermission() async {
    bool serviceEnabled;
    LocationPermission permission;


    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('location disabled');
      setState(() {
        locationDisabled = true;
      });
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      print('location denied');
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('location denied');
        setState(() {
          locationDisabled = true;
        });
      }
    }

    if (permission == LocationPermission.deniedForever) {
      SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    }

    setState(() {
      locationDisabled = false;
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return CustomPaint(
                  foregroundPainter: CloudBackgroundPainter(
                    animation: _animationController.value,
                  ),
                  painter: ColorBackgroundPainter(),
                );
              }
            ),
          ),
          Positioned(
            bottom: 12.0,
            right: 12.0,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  var unitValues = SpeedUnit.values;
                  do {
                    speedUnit = unitValues[(unitValues.indexOf(speedUnit) + 1) %
                        unitValues.length];
                  } while(activated[speedUnit] != true);
                });
              },
              child: Text(speedUnit.displayName),
            ),
          ),
          Positioned(
            bottom: 0.0,
            left: 24.0,
            height: 200,
            width: 100,
            child: AnimatedBuilder(
              animation: _signAnimationController,
              builder: (context, child) {
                return Transform(
                  alignment: Alignment.bottomCenter,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.003)
                    ..rotateX(pi / 2 * Curves.elasticIn.transform(1 - _signAnimationController.value)),
                  child: child,
                );
              },
              child: CustomPaint(
                foregroundPainter: TrainSignPainter(speedLimit?.toString().substring(0, speedLimit.toString().length - 1) ?? '6'),
              ),
            ),
          ),
          Positioned(
            top: 12.0,
            right: 12.0,
            child: SafeArea(
              child: IconButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => SettingsPage(
                    activated: activated,
                    onChanged: (unit, value) {
                      setState(() {
                        activated[unit] = value;
                      });
                      preferences.setBool(unit.displayName, value);
                    },
                  )));
                },
                icon: const Icon(Icons.settings),
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            child: Center(
              child: locationDisabled
                  ? ElevatedButton(
                      onPressed: startMeasurement,
                      child: const Text('Neuer Versuch'))
                  : Text(
                      speedUnit.format(currentSpeed),
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(fontFamily: GoogleFonts.acme().fontFamily, fontSize: 72),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
