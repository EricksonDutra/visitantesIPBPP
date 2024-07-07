import 'package:flutter/material.dart';
import 'package:visitantes/pages/visitantes_page.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: const Text('Home'),
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            title: const Text('Visitantes'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const VisitantesPage()));
            },
          ),
        ],
      ),
    );
  }
}
