import 'dart:convert';
import 'package:http/http.dart' as http;

class ExchangeService {
  static Future<Map<String, double>> convertSalary(double idr) async {
    const url = 'https://api.exchangerate-api.com/v4/latest/USD';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rates = data['rates'];
        return {
          'IDR': idr,
          'USD': idr / rates['IDR'], 
          'EUR': idr / rates['IDR'] * rates['EUR'], 
          'JPY': idr / rates['IDR'] * rates['JPY'], 
        };
      }
    } catch (e) {
      print('Gagal konversi mata uang: $e');
    }
    return {'IDR': idr, 'USD': 0, 'EUR': 0, 'JPY': 0};
  }
}
