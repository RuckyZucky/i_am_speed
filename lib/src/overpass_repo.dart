import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

OverpassRepository? _instance;

class OverpassRepository {

  OverpassRepository._internal();

  factory OverpassRepository() {
    _instance ??= OverpassRepository._internal();
    return _instance!;
  }

  Future<int?> getRailSpeedAt(Position position) async {
    var body = """
[out:json][timeout:25];
(
  way["railway"="rail"](around:10,${position.latitude},${position.longitude});
);
out body;
>;
out skel qt;
    
    """;

    var result = await http.post(Uri.parse('https://overpass-api.de/api/interpreter'), body: body);
    if (result.statusCode == 200) {
      var data = jsonDecode(result.body);
      for(Map<String, dynamic> way in data['elements']) {
        if (way['tags']?['maxspeed'] != null) {
          return int.parse(way['tags']['maxspeed']);
        }
      }
    }

    return null;
  }

}
