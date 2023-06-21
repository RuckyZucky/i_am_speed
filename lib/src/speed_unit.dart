import 'dart:math' as math;

typedef Formatter = String Function(double, String);

String _defaultFormatter(double value, String displayName) => '${value.toStringAsFixed(2)} $displayName';

String _lightSpeedFormatter(double value, String displayName) => '${value.toStringAsExponential(2)} $displayName';

String _machFormatter(double value, String displayName) => '$displayName ${value.toStringAsFixed(2)}';

enum SpeedUnit {
  KPH('km/h', 3.6, _defaultFormatter),
  MPS('m/s', 1.0, _defaultFormatter),
  MPH('mph', 2.237, _defaultFormatter),
  KN('kn', 1.944, _defaultFormatter),
  MACH('Mach', 1 / 343, _machFormatter),
  LIGHTSPEED('c', 3.336e-09, _lightSpeedFormatter);

  const SpeedUnit(this.displayName, this._factor, this.formatter);

  final String displayName;
  final double _factor;
  final Formatter formatter;

  /**
   * Converts value in m/s to specified unit and adds the unit string
   */
  String format(double value) {
    return formatter(value * _factor, displayName);
  }
}
