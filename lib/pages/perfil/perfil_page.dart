// perfil_usuario_page.dart
import 'package:coffee_shop/components/navbar/custom_navbar.dart';
import 'package:coffee_shop/firestorelogic/perfil/profile_logic.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  final User? user;
  const ProfilePage({super.key, this.user});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Página de Perfil'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cerrar Sesión', style: TextStyle(color: Colors.white)),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
      ),
      // ...
      body: Column(
        children: [
          SizedBox(
            height: 230, // Ajusta esta altura para cambiar el tamaño de ProfileLogic
            child: ProfileLogic(user: FirebaseAuth.instance.currentUser!),
          ),
          const SizedBox(height: 10),
          const Text('Tus acciones', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Expanded(
            child: ListView(
              children: [
                _buildCardItem(context, 'Recargar Saldo', Icons.attach_money, '/recargarSaldo'),
                _buildCardItem(context, 'Historial de Pedidos', Icons.history, '/historialPedidos'),
                _buildCardItem(context, 'Historial de Recargas', Icons.receipt, '/historialRecargas'),
                _buildCardItem(context, 'Modificar Perfil', Icons.edit, '/modificarPerfil'),
              ],
            ),
          )
        ],
      ),
      //navbar
      bottomNavigationBar: const CustomNavBar(currentIndex: 2),
    );
  }

  Widget _buildCardItem(BuildContext context, String title, IconData icon, String routeName) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        leading: Icon(icon, size: 40.0),
        title: Text(title, style: const TextStyle(fontSize: 20)),
        onTap: () {
          Navigator.pushNamed(context, routeName);
        },
      ),
    );
  }
}
