import 'dart:convert';
import 'package:http/http.dart' as http;

class TimeService {
  static Future<String> getConvertedTime(String baseTime, String zone) async {
    final offsets = {'WIB': 7, 'WITA': 8, 'WIT': 9, 'London': 1};
    try {
      final base = DateTime.parse(baseTime);
      final offset = offsets[zone] ?? 7;
      final converted = base.add(Duration(hours: offset - 7));
      return converted.toString().substring(0, 16);
    } catch (e) {
      return 'Waktu tidak valid';
    }
  }

  static Future<String> getCurrentTime(String zone) async {
    try {
      final response = await http.get(Uri.parse('https://worldtimeapi.org/api/timezone/Asia/Jakarta'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final utc = DateTime.parse(data['utc_datetime']);
        final offsets = {'WIB': 7, 'WITA': 8, 'WIT': 9, 'London': 1};
        final local = utc.add(Duration(hours: offsets[zone] ?? 7));
        return local.toString().substring(0, 16);
      }
    } catch (e) {
      print('Gagal konversi waktu: $e');
    }
    return DateTime.now().toString().substring(0, 16);
  }
}