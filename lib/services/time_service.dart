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
}
