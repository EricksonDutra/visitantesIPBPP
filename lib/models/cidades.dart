class Cidades {
  List<Estados>? estados;

  Cidades({this.estados});

  Cidades.fromJson(Map<String, dynamic> json) {
    if (json['estados'] != null) {
      estados = <Estados>[];
      json['estados'].forEach((v) {
        estados!.add(Estados.fromJson(v));
      });
    }
  }
}

class Estados {
  String? sigla;
  String? nome;
  List<String>? cidades;

  Estados({this.sigla, this.nome, this.cidades});

  Estados.fromJson(Map<String, dynamic> json) {
    sigla = json['sigla'];
    nome = json['nome'];
    cidades = json['cidades'].cast<String>();
  }
}
