class Visitante {
  String? nome;
  String? email;
  String? telefone;
  String? cidade;
  String? estado;
  bool? primeiraVez;
  Visitante? pertenceIgreja;
  List<String>? acompanhantes;
  String? igreja;
  String? genero;

  DateTime? createdAt;

  Visitante({
    this.nome,
    this.email,
    this.telefone,
    this.cidade,
    this.primeiraVez,
    this.acompanhantes = const [],
    this.igreja = '',
    this.genero,
  });

  Visitante.fromJson(Map<String, dynamic> json) {
    nome = json['Nome'];
    email = json['Email'];
    telefone = json['Telefone'];
    cidade = json['Cidade'];
    estado = json['Estado'];
    primeiraVez = json['primeiraVez'];
    acompanhantes = (json['Acompanhantes'] as String?)?.split(';');
    igreja = json['Igreja'];
    genero = json['Genero'];

    createdAt = json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Nome'] = nome;
    data['Email'] = email;
    data['Telefone'] = telefone;
    data['Cidade'] = cidade;
    data['Estado'] = estado;
    data['primeiraVez'] = primeiraVez;
    data['Acompanhantes'] = acompanhantes?.join(';');
    data['Igreja'] = igreja;
    data['Genero'] = genero;

    return data;
  }
}
