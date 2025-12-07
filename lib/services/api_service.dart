import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/job.dart';

class ApiLayanan {
  static const String _url = 'https://apilokerin.vercel.app/jobs.json';

  static Future<List<Job>> ambilSemua() async {
    try {
      final response = await http.get(Uri.parse(_url));
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body)['jobs'];
        return data.map((e) => Job.fromJson(e)).toList();
      }
    } catch (e) {
      print('Gagal ambil data API: $e');
    }
    return [];
  }
}