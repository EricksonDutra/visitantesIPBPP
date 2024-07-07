import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';
import 'package:visitantes/models/cities_list.dart';
import 'package:visitantes/models/visitante.dart';
import 'package:visitantes/repositories/visitante_repo.dart';
import 'package:visitantes/widgets/custom_drawer.dart';
import 'package:visitantes/widgets/input_field.dart';

enum SingingCharacter { primeiraVez, segundaVez }

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();
  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final telefoneController = TextEditingController();
  final maskPhoneFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  SingingCharacter? _character;
  bool isLoading = false;
  bool _acompanhante = false;
  List<TextEditingController> _acompanhantesControllers = [TextEditingController()];
  String? selectedSex;
  String? _pertenceIgreja;
  TextEditingController igrejaController = TextEditingController();

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _enviaDados(String nome, String email, String telefone, String cidade, String estado,
      SingingCharacter? primeiraVez, List<String> acompanhantes, String? igreja, String? selectedSex) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    var visitante = Visitante()
      ..nome = nome
      ..email = email
      ..telefone = telefone
      ..cidade = cidade
      ..estado = estado
      ..primeiraVez = primeiraVez == SingingCharacter.primeiraVez
      ..acompanhantes = _acompanhantesControllers.map((controller) => controller.text).toList()
      ..igreja = igreja
      ..genero = selectedSex;

    try {
      await VisitanteRepo.addVisitante(visitante);
      if (mounted) {
        _showDialog('Sucesso', 'Visitante adicionado com sucesso!');
        _clearFields(estado);
      }
    } catch (e) {
      if (mounted) {
        _showDialog('Erro', 'Erro ao adicionar o visitante');
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _clearFields(estado) {
    nomeController.clear();
    emailController.clear();
    telefoneController.clear();
    for (var controller in _acompanhantesControllers) {
      controller.clear();
    }
    igrejaController.clear();

    setState(() {
      _character = null;
      _acompanhante = false;
      _acompanhantesControllers = [TextEditingController()];
      selectedSex = null;
      _pertenceIgreja = null;
      estado.clear();
    });
  }

  void _addAcompanhanteField() {
    setState(() {
      _acompanhantesControllers.add(TextEditingController());
    });
  }

  void _removeAcompanhanteField(int index) {
    if (_acompanhantesControllers.length > 1) {
      setState(() {
        _acompanhantesControllers.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final citiesList = Provider.of<CitiesList>(context);
    List<String> allCities = citiesList.states.expand<String>((state) => state.cidades ?? []).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Visitante'),
      ),
      drawer: const SafeArea(
        child: CustomDrawer(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildHeader(),
              const Text('Primeira vez?'),
              _buildRadioButtons(),
              _buildInputFields(),
              _buildGenderDropdown(),
              const SizedBox(height: 16),
              const Text('Está acompanhado(a)?'),
              _buildAcompanhanteRadioButtons(),
              if (_acompanhante) _buildAcompanhanteFields(),
              const SizedBox(height: 8),
              _buildLocationDropdowns(citiesList, allCities),
              const SizedBox(height: 16),
              _buildIgrejaField(),
              const SizedBox(height: 16),
              _buildSubmitButton(citiesList),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset('assets/img/logo-ipb.png'),
          const Text(
            'Seja Bem Vindo à IPB Ponta Porã!',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildRadioButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: RadioListTile<SingingCharacter>(
            title: const Text('Sim'),
            value: SingingCharacter.primeiraVez,
            groupValue: _character,
            onChanged: (value) => setState(() => _character = value),
          ),
        ),
        Expanded(
          child: RadioListTile<SingingCharacter>(
            title: const Text('Não'),
            value: SingingCharacter.segundaVez,
            groupValue: _character,
            onChanged: (value) => setState(() => _character = value),
          ),
        ),
      ],
    );
  }

  Widget _buildInputFields() {
    return Column(
      children: [
        InputField(
          controller: nomeController,
          labelText: "Nome",
          hintText: "Nome Completo",
          icon: const Icon(Icons.person),
          keyboardType: TextInputType.name,
          validator: (value) {
            if (value == null || value.length < 5) {
              return 'Por favor, insira seu nome';
            }
            return null;
          },
        ),
        InputField(
          controller: emailController,
          labelText: "E-mail",
          hintText: "email@email.com",
          icon: const Icon(Icons.email),
          keyboardType: TextInputType.emailAddress,
        ),
        InputField(
          controller: telefoneController,
          labelText: "Telefone",
          hintText: "(67) 99999-9999",
          icon: const Icon(Icons.phone),
          keyboardType: TextInputType.phone,
          inputFormatter: [maskPhoneFormatter],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor, insira seu telefone';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Sexo',
        border: OutlineInputBorder(),
      ),
      value: selectedSex,
      onChanged: (String? newValue) => setState(() => selectedSex = newValue),
      items: const [
        DropdownMenuItem(
          value: 'Masculino',
          child: Text('🧔🏻 - Masculino'),
        ),
        DropdownMenuItem(
          value: 'Feminino',
          child: Text('👱🏻‍♀️ - Feminino'),
        ),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, selecione o sexo';
        }
        return null;
      },
    );
  }

  Widget _buildAcompanhanteRadioButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: RadioListTile<bool>(
            title: const Text('Sim'),
            value: true,
            groupValue: _acompanhante,
            onChanged: (value) => setState(() => _acompanhante = value ?? false),
          ),
        ),
        Expanded(
          child: RadioListTile<bool>(
            title: const Text('Não'),
            value: false,
            groupValue: _acompanhante,
            onChanged: (value) => setState(() => _acompanhante = value ?? false),
          ),
        ),
      ],
    );
  }

  Widget _buildAcompanhanteFields() {
    return Column(
      children: [
        ..._acompanhantesControllers.asMap().entries.map((entry) {
          int index = entry.key;
          TextEditingController controller = entry.value;
          return Row(
            children: [
              Expanded(
                child: InputField(
                  controller: controller,
                  labelText: "Nome do Acompanhante",
                  hintText: "Nome Completo do Acompanhante",
                  icon: const Icon(Icons.person),
                  keyboardType: TextInputType.name,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o nome do acompanhante';
                    }
                    return null;
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.remove_circle),
                onPressed: () => _removeAcompanhanteField(index),
              ),
            ],
          );
        }),
        ElevatedButton(
          onPressed: _addAcompanhanteField,
          child: const Text('Adicionar Acompanhante'),
        ),
      ],
    );
  }

  Widget _buildLocationDropdowns(CitiesList citiesList, List<String> allCities) {
    return citiesList.states.isEmpty
        ? const CircularProgressIndicator()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Selecione o estado:'),
              DropdownButtonFormField<String>(
                value: citiesList.selectedState,
                hint: const Text('Selecione o estado'),
                onChanged: (newValue) => citiesList.updateSelectedState(newValue),
                items: citiesList.states
                    .map((state) => DropdownMenuItem<String>(
                          value: state.nome,
                          child: Text(state.nome ?? ''),
                        ))
                    .toList(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, selecione um estado';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text('Selecione a cidade:'),
              DropdownButtonFormField<String>(
                value: citiesList.selectedCity,
                hint: const Text('Selecione a cidade'),
                onChanged: (newValue) => citiesList.updateSelectedCity(newValue),
                items: allCities
                    .map((city) => DropdownMenuItem<String>(
                          value: city,
                          child: Text(city),
                        ))
                    .toList(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, selecione uma cidade';
                  }
                  return null;
                },
              ),
            ],
          );
  }

  Widget _buildSubmitButton(CitiesList citiesList) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading
            ? null
            : () => _enviaDados(
                  nomeController.text,
                  emailController.text,
                  telefoneController.text,
                  citiesList.selectedCity!,
                  citiesList.selectedState!,
                  _character,
                  _acompanhantesControllers.map((controller) => controller.text).toList(),
                  igrejaController.text,
                  selectedSex,
                ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                "Enviar",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
      ),
    );
  }

  Widget _buildIgrejaField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Pertence a alguma igreja?'),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: RadioListTile<String>(
                title: const Text('Sim'),
                value: 'Sim',
                groupValue: _pertenceIgreja,
                onChanged: (value) => setState(() {
                  _pertenceIgreja = value;
                  igrejaController.clear();
                }),
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                title: const Text('Não'),
                value: 'Não',
                groupValue: _pertenceIgreja,
                onChanged: (value) => setState(() {
                  _pertenceIgreja = value;
                  igrejaController.clear(); // Limpa o campo de igreja se não pertencer a nenhuma
                }),
              ),
            ),
          ],
        ),
        if (_pertenceIgreja == 'Sim')
          InputField(
            controller: igrejaController,
            labelText: "Nome da Igreja",
            hintText: "Nome da sua igreja",
            icon: const Icon(Icons.church),
            keyboardType: TextInputType.text,
            validator: (value) {
              if (_pertenceIgreja == 'Sim' && (value == null || value.isEmpty)) {
                return 'Por favor, insira o nome da sua igreja';
              }
              return null;
            },
          ),
      ],
    );
  }
}
