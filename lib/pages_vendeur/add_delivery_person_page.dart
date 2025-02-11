import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'package:egaz/database/database_egaz.dart';
import 'package:egaz/pages_authentification/auth_service.dart';

class AddDeliveryPersonPage extends StatefulWidget {
  const AddDeliveryPersonPage({super.key});

  @override
  _AddDeliveryPersonPageState createState() => _AddDeliveryPersonPageState();
}

class _AddDeliveryPersonPageState extends State<AddDeliveryPersonPage> {
  final _formKey = GlobalKey<FormState>();
  final bool isDarkMode = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _engineController = TextEditingController();

  Future<void> _saveDeliveryPerson() async {
    if (_formKey.currentState?.validate() ?? false) {
      String? vendeurId = await AuthService().getCurrentUserId();
      if (vendeurId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Impossible de récupérer l'ID du vendeur")),
        );
        return;
      }

      String livreurId = const Uuid().v4();

      await DatabaseHelper().addLivreur(
          id: livreurId,
          nom: _nameController.text.trim(),
          prenom: _surnameController.text.trim(),
          telephone: _contactController.text.trim(),
          engin: _engineController.text.trim(),
          idVendeur: vendeurId,
          
);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Livreur ajouté avec succès !")),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ajouter un livreur',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        backgroundColor: isDarkMode ? Colors.black : const Color(0xFFEAEAEA),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.notifications,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTextField(label: 'Nom', controller: _nameController, isDarkMode: isDarkMode),
                  const SizedBox(height: 16),
                  _buildTextField(label: 'Prénom', controller: _surnameController, isDarkMode: isDarkMode),
                  const SizedBox(height: 16),
                  _buildTextField(label: 'Contact', controller: _contactController, isDarkMode: isDarkMode),
                  const SizedBox(height: 16),
                  _buildTextField(label: 'Engin', controller: _engineController, isDarkMode: isDarkMode),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _saveDeliveryPerson,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                    ),
                    child: Text(
                      'Enregistrer',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required String label, required TextEditingController controller, required bool isDarkMode}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(
          fontSize: 14,
          color: isDarkMode ? Colors.white : Colors.black,
        ),
        filled: true,
        fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
      style: GoogleFonts.poppins(
        fontSize: 14,
        color: isDarkMode ? Colors.white : Colors.black,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Ce champ ne peut pas être vide';
        }
        return null;
      },
    );
  }
}
