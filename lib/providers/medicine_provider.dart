import 'package:flutter/material.dart';
import '../models/medicine_model.dart';
import '../services/medicine_service.dart';

enum ViewState { idle, loading, error, loaded }

class MedicineProvider extends ChangeNotifier {
  ViewState _state = ViewState.idle;
  List<Medicine> _medicines = [];
  List<Medicine> _filteredMedicines = [];
  String _errorMessage = '';
  String _searchQuery = '';

  ViewState get state => _state;
  List<Medicine> get medicines => _filteredMedicines;
  String get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  /// Fetch all medicines from REST API
  Future<void> fetchMedicines(String token) async {
    _state = ViewState.loading;
    notifyListeners();

    try {
      _medicines = await MedicineService.getMedicines(token);
      _applyFilter();
      _state = ViewState.loaded;
    } catch (e) {
      final err = e.toString();
      if (err.contains('SocketException') || err.contains('host lookup')) {
        _errorMessage = 'Tidak ada koneksi internet. Periksa Wi-Fi atau data seluler Anda.';
      } else {
        _errorMessage = err.replaceAll('Exception: ', '');
      }
      _state = ViewState.error;
    }
    notifyListeners();
  }

  /// Search/filter medicines locally
  void search(String query) {
    _searchQuery = query;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _filteredMedicines = List.from(_medicines);
    } else {
      _filteredMedicines = _medicines
          .where((m) =>
              m.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              m.category.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
  }

  /// Create a new medicine
  Future<bool> createMedicine(
      String token, Map<String, dynamic> data) async {
    try {
      await MedicineService.createMedicine(token, data);
      await fetchMedicines(token);
      return true;
    } catch (e) {
      final err = e.toString();
      _errorMessage = (err.contains('SocketException') || err.contains('host lookup')) 
          ? 'Tidak ada koneksi internet.' 
          : err.replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Update an existing medicine
  Future<bool> updateMedicine(
      String token, int id, Map<String, dynamic> data) async {
    try {
      await MedicineService.updateMedicine(token, id, data);
      await fetchMedicines(token);
      return true;
    } catch (e) {
      final err = e.toString();
      _errorMessage = (err.contains('SocketException') || err.contains('host lookup')) 
          ? 'Tidak ada koneksi internet.' 
          : err.replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Delete a medicine
  Future<bool> deleteMedicine(String token, int id) async {
    try {
      await MedicineService.deleteMedicine(token, id);
      await fetchMedicines(token);
      return true;
    } catch (e) {
      final err = e.toString();
      _errorMessage = (err.contains('SocketException') || err.contains('host lookup')) 
          ? 'Tidak ada koneksi internet.' 
          : err.replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
