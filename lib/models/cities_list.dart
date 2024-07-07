import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:visitantes/models/cidades.dart';

class CitiesList with ChangeNotifier {
  List<Estados> _states = [];
  String? _selectedState;
  String? _selectedCity;

  List<Estados> get states => [..._states];
  String? get selectedState => _selectedState;
  String? get selectedCity => _selectedCity;

  CitiesList() {
    _loadCities();
  }

  Future<void> _loadCities() async {
    final String response = await rootBundle.loadString('assets/cidades.json');
    final Map<String, dynamic> data = json.decode(response);
    final Cidades cidades = Cidades.fromJson(data);
    _states = cidades.estados ?? [];
    notifyListeners();
  }

  void updateSelectedState(String? state) {
    _selectedState = state;
    _selectedCity = null; // Reset city when state changes
    notifyListeners();
  }

  void updateSelectedCity(String? city) {
    _selectedCity = city;
    notifyListeners();
  }
}
