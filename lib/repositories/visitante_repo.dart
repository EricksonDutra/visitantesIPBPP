import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:visitantes/models/visitante.dart';

class VisitanteRepo {
  static Future<void> addVisitante(Visitante visitante) async {
    Map<String, String> userHeader = {
      "X-Parse-Application-Id": dotenv.get("X-Parse-Application-Id"),
      "X-Parse-REST-API-Key": dotenv.get("X-Parse-REST-API-Key"),
      "Content-Type": "application/json",
    };
    final res = await http.post(Uri.parse('https://parseapi.back4app.com/functions/create-visitante'),
        headers: userHeader, body: json.encode(visitante.toJson()));

    if (res.statusCode == 200) {
      debugPrint("Visitante adicionado com sucesso!");
    } else {
      debugPrint("Erro ao adicionar o visitante");
    }
  }

  static Future<List<Visitante>> getVisitantes() async {
    Map<String, String> userHeader = {
      "X-Parse-Application-Id": dotenv.get("X-Parse-Application-Id"),
      "X-Parse-REST-API-Key": dotenv.get("X-Parse-REST-API-Key"),
    };

    final res =
        await http.post(Uri.parse('https://parseapi.back4app.com/functions/get-visitantes'), headers: userHeader);
    if (res.statusCode == 200) {
      List<Visitante> visitantes = [];
      for (var visitante in jsonDecode(res.body)['result']) {
        visitantes.add(Visitante.fromJson(visitante));
      }
      return visitantes;
    } else {
      return [];
    }
  }
}
