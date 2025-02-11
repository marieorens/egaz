import 'dart:convert'; 
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:egaz/pages_vendeur/profilempodificationpage.dart';
import 'package:egaz/pages_authentification/login_screen.dart';
import 'package:egaz/database/database_egaz.dart';
import 'package:egaz/pages_authentification/auth_service.dart';
import 'package:egaz/pages_vendeur/confirm_acc_deletion.dart'; 

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String shopName = "Johnny Shop";  
  String avatarUrl = "";  

  @override
  void initState() {
    super.initState();
    _loadShopProfile();
  }

 void _loadShopProfile() async {
  String? userId = await AuthService().getCurrentUserId();
  print("Tentative de récupération du profil pour l'ID : $userId");

  if (userId != null) {
    Map<String, dynamic>? vendeurProfile = await DatabaseHelper().getVendeurProfil(userId);
    if (vendeurProfile != null) {
      setState(() {
        shopName = vendeurProfile['nom_boutique'] ?? "Nom de la boutique non défini";
        avatarUrl = vendeurProfile['photo'] != null
            ? "data:image/png;base64,${base64Encode(vendeurProfile['photo'])}"
            : "";
      });
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[300],
              backgroundImage: avatarUrl.isNotEmpty
                  ? MemoryImage(base64Decode(avatarUrl.split(',').last)) 
                  : null,
              child: avatarUrl.isEmpty
                  ? const Icon(
                      Icons.shop,
                      size: 30,
                      color: Colors.grey,
                    )
                  : null,
            ),
            const SizedBox(height: 10),
            // Nom de la boutique
            Text(
              shopName,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 30),
            _buildButton(
              context: context,
              icon: Icons.edit,
              label: "Modifier mon profil",
              color: Colors.black,
              onTap: () async {
                
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileModificationPage(
                      onProfileUpdated: _loadShopProfile, 
                    ),
                  ),
                );

                
                if (result == true) {
                  _loadShopProfile();
                }
              },
            ),
            const SizedBox(height: 15),
            _buildButton(
              context: context,
              icon: Icons.logout,
              label: "Déconnexion",
              color: Colors.red,
              onTap: () async {
                   await AuthService().logoutUser();  
                   Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
            ),
            const SizedBox(height: 15),
            _buildButton(
              context: context,
              icon: Icons.delete,
              label: "Supprimer mon compte",
              color: Colors.red,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                   builder: (context) => const ConfirmDeleteAccountPage(),
               ),
              );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}