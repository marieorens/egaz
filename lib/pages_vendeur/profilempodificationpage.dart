import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; 
import 'package:egaz/database/database_egaz.dart';
import 'package:egaz/pages_authentification/auth_service.dart'; 


class ProfileModificationPage extends StatefulWidget {
  final VoidCallback onProfileUpdated; 

  const ProfileModificationPage({super.key, required this.onProfileUpdated});

  @override
  _ProfileModificationPageState createState() => _ProfileModificationPageState();
}

class _ProfileModificationPageState extends State<ProfileModificationPage> {
  File? _image; 
  final TextEditingController _nomBoutiqueController = TextEditingController();
  final TextEditingController _heureOuvertureController = TextEditingController(); 
  final TextEditingController _heureFermetureController = TextEditingController(); 

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path); 
      });
    }
  }

  void _saveProfile() async {
  String nomBoutique = _nomBoutiqueController.text;
  String heureOuverture = _heureOuvertureController.text; 
  String heureFermeture = _heureFermetureController.text; 

  String? userId = await AuthService().getCurrentUserId();

  if (userId != null) {
    await DatabaseHelper().updateVendeurProfile(
      userId,
      nomBoutique,
      _image,
      heureOuverture, 
      heureFermeture, 
    );

    _nomBoutiqueController.clear();
    _heureOuvertureController.clear(); 
    _heureFermetureController.clear(); 

    setState(() {
      _image = null;
    });

    _showLocationNotification();

    
    widget.onProfileUpdated();

    
    Navigator.pop(context, true);
  } else {
    print("Erreur: L'ID de l'utilisateur n'a pas pu être récupéré.");
  }
}

  bool _showNotification = false;
  void _showLocationNotification() {
    setState(() {
      _showNotification = true;
    });

    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _showNotification = false;
      });
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: const BackButton(color: Colors.black),
        title: Text(
          'Modification du profil',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Changer la photo',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    GestureDetector(
                      onTap: _pickImage, 
                      child: const Icon(Icons.upload_outlined, color: Colors.green),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                if (_image != null)
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: FileImage(_image!),
                  )
                else
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, color: Colors.white),
                  ),

                const SizedBox(height: 24),

                Text(
                  'Nom de la boutique:',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),

                TextFormField(
                  
                  controller: _nomBoutiqueController, 
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.green),
                    ),
                    hintText: 'Entrez le nom de votre boutique',
                    hintStyle: GoogleFonts.poppins(
                      fontWeight: FontWeight.normal,
                      color: Colors.grey[600],
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 18),
                  ),
                ),
                const SizedBox(height: 24),

                 Text(
                  'Ma boutique est ouverte de:',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  
                ),
                const SizedBox(height: 8),
                TextFormField(
                        controller: _heureOuvertureController,
                        style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                           color: Colors.black,
                            ),
                        decoration: InputDecoration(
                         filled: true,
                               fillColor: Colors.grey[200],
                               border: OutlineInputBorder(
                               borderRadius: BorderRadius.circular(12),
                                  ),
                                   focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(color: Colors.green),
                                            ),
    hintText: 'Heure d\'ouverture (ex: 08:00)',
    hintStyle: GoogleFonts.poppins(
      fontWeight: FontWeight.normal,
      color: Colors.grey[600],
    ),
    contentPadding: const EdgeInsets.symmetric(
        horizontal: 16, vertical: 18),
  ),
),
const SizedBox(height: 16),
Text(
                  'Et ferme à:',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  
                ),
                const SizedBox(height: 8),
TextFormField(
  controller: _heureFermetureController,
  style: GoogleFonts.poppins(
    fontWeight: FontWeight.bold,
    color: Colors.black,
  ),
  decoration: InputDecoration(
    filled: true,
    fillColor: Colors.grey[200],
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.green),
    ),
    hintText: 'Heure de fermeture (ex: 18:00)',
    hintStyle: GoogleFonts.poppins(
      fontWeight: FontWeight.normal,
      color: Colors.grey[600],
    ),
    contentPadding: const EdgeInsets.symmetric(
        horizontal: 16, vertical: 18),
  ),
),
const SizedBox(height: 24),
                const SizedBox(height: 24),

                if (_showNotification)
                  AnimatedContainer(
                    duration: const Duration(seconds: 2),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    color: Colors.yellow,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:  [
                        Icon(Icons.check_circle, color: Colors.black),
                        SizedBox(width: 10),
                        Text(
                          'Profil modifié avec succès !',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                Center(
                  child: SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      onPressed: _saveProfile, 
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Valider',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                const Divider(color: Colors.grey),
                const SizedBox(height: 10),
                Text(
                  'Assurez-vous que toutes les informations sont correctes avant de valider.',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: Colors.black.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}