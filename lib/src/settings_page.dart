import 'package:flutter/material.dart';
import 'package:i_am_speed/src/speed_unit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key, required this.activated, required this.onChanged}) : super(key: key);

  final Map<SpeedUnit, bool> activated;
  final Function(SpeedUnit, bool) onChanged;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  late final Map<SpeedUnit, bool> activated;

  @override
  void initState() {
    super.initState();
    activated = widget.activated;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: Colors.lightBlueAccent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: SpeedUnit.values.map((e) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Transform.scale(
                    scale: 2.5,
                    child: Checkbox(
                      value: widget.activated[e],
                      onChanged: (value) {
                        if (value == false && activated.values.where((element) => element == true).length <= 1) {
                          return;
                        }
                        widget.onChanged(e, value ?? false);
                        setState(() {
                          activated[e] = value ?? false;
                        });
                      },
                      activeColor: Colors.white24,
                      checkColor: Colors.white,
                      side: const BorderSide(color: Colors.white54, width: 2.0),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Text(e.displayName, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 28),),
                  )
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
