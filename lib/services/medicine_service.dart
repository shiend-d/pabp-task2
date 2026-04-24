import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';
import '../models/medicine_model.dart';

class MedicineService {
  /// GET all medicines from Supabase REST API
  static Future<List<Medicine>> getMedicines(String token) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.medicinesUrl}?order=name.asc'),
      headers: ApiConstants.authHeaders(token),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
      return data
          .map((json) => Medicine.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Gagal memuat data obat (${response.statusCode})');
    }
  }

  /// POST create a new medicine
  static Future<Medicine> createMedicine(
      String token, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse(ApiConstants.medicinesUrl),
      headers: ApiConstants.authHeadersWithPrefer(token),
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      final List<dynamic> result = jsonDecode(response.body) as List<dynamic>;
      return Medicine.fromJson(result.first as Map<String, dynamic>);
    } else {
      throw Exception('Gagal menambahkan obat (${response.statusCode})');
    }
  }

  /// PATCH update an existing medicine
  static Future<Medicine> updateMedicine(
      String token, int id, Map<String, dynamic> data) async {
    final response = await http.patch(
      Uri.parse('${ApiConstants.medicinesUrl}?id=eq.$id'),
      headers: ApiConstants.authHeadersWithPrefer(token),
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      final List<dynamic> result = jsonDecode(response.body) as List<dynamic>;
      return Medicine.fromJson(result.first as Map<String, dynamic>);
    } else {
      throw Exception('Gagal memperbarui obat (${response.statusCode})');
    }
  }

  /// DELETE a medicine
  static Future<void> deleteMedicine(String token, int id) async {
    final response = await http.delete(
      Uri.parse('${ApiConstants.medicinesUrl}?id=eq.$id'),
      headers: ApiConstants.authHeaders(token),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Gagal menghapus obat (${response.statusCode})');
    }
  }
}
