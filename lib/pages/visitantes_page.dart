import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:visitantes/models/visitante.dart';
import 'package:visitantes/repositories/visitante_repo.dart';

class VisitantesPage extends StatefulWidget {
  const VisitantesPage({super.key});

  @override
  State<VisitantesPage> createState() => _VisitantesPageState();
}

class _VisitantesPageState extends State<VisitantesPage> {
  List<Visitante> visitantes = [];
  bool loading = false;
  DateTimeRange? selectedDateRange;

  @override
  void initState() {
    super.initState();
    carregaVisitantes();
  }

  void carregaVisitantes() async {
    setState(() {
      loading = true;
    });

    List<Visitante> allVisitantes = await VisitanteRepo.getVisitantes();
    DateTime now = DateTime.now();
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    DateTime endOfWeek = now.add(Duration(days: DateTime.daysPerWeek - now.weekday));

    // Filter visitors based on the selected date range or the current week
    if (selectedDateRange != null) {
      visitantes = allVisitantes.where((visitante) {
        return visitante.createdAt!.isAfter(selectedDateRange!.start.subtract(const Duration(days: 1))) &&
            visitante.createdAt!.isBefore(selectedDateRange!.end.add(const Duration(days: 1)));
      }).toList();
    } else {
      visitantes = allVisitantes.where((visitante) {
        return visitante.createdAt!.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
            visitante.createdAt!.isBefore(endOfWeek.add(const Duration(days: 1)));
      }).toList();
    }

    setState(() {
      loading = false;
    });
  }

  Future<void> selectDateRange() async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      initialDateRange: selectedDateRange ??
          DateTimeRange(
            start: DateTime.now().subtract(const Duration(days: 6)),
            end: DateTime.now(),
          ),
    );
    if (picked != null && picked != selectedDateRange) {
      setState(() {
        selectedDateRange = picked;
      });
      carregaVisitantes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visitantes Cadastrados'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: selectDateRange,
          ),
        ],
      ),
      body: Center(
        child: loading
            ? const CircularProgressIndicator()
            : ListView.builder(
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${visitantes[index].nome}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.email, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                visitantes[index].email.toString(),
                                style: const TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.phone, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                visitantes[index].telefone.toString(),
                                style: const TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                '${visitantes[index].cidade} - ${visitantes[index].estado}',
                                style: const TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.church, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                visitantes[index].igreja ?? '-',
                                style: const TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.person_pin_outlined, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Gênero: ${visitantes[index].genero ?? 'gênero'}',
                                style: const TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (visitantes[index].acompanhantes != null && visitantes[index].acompanhantes!.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.only(left: 8),
                              margin: const EdgeInsets.only(left: 16),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Acompanhantes:'),
                                  ...visitantes[index].acompanhantes!.map((acompanhante) => Text(
                                        '- $acompanhante',
                                        style: const TextStyle(fontSize: 18),
                                      )),
                                ],
                              ),
                            ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                '${DateFormat('dd/MM/yyyy - HH:mm').format(visitantes[index].createdAt!)}h',
                                style: const TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
                itemCount: visitantes.length,
              ),
      ),
    );
  }
}
