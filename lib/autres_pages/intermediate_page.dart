import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:egaz/pages_authentification/login_screen.dart';
import 'package:google_fonts/google_fonts.dart';


class IntermediatePage extends StatefulWidget {
  const IntermediatePage({super.key});

  @override
  State<IntermediatePage> createState() => _IntermediatePageState();
}

class _IntermediatePageState extends State<IntermediatePage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _slides = [
    {
      "title": "Oups, il vous manque du gaz mais vous ne voulez pas vous déplacer pour recharger? 😭",
      "description": "Commandez juste votre gaz et on vous livre.\n Chill, n'est-ce pas? 😎",
      "animation": "assets/images/gas.json",
    },
    {
      "title": "Vous disposez d'un stock de gaz?",
      "description": "No problemo, inscrivez-vous juste et faites de bonnes affaires!.",
      "animation": "assets/images/business.json",
    },
  ];

  void _goToNextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOut,  
      );
    } else {
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) =>const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 210, 159, 93),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _slides.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                final slide = _slides[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        slide["title"],
                        style: GoogleFonts.poppins(  
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 24),
                      Lottie.asset(
                        slide["animation"],
                        width: 500,
                        height: 500,
                        repeat: true,  
                        reverse: true,  
                      ),
                      const SizedBox(height: 16),
                      Text(
                        slide["description"],
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Skip Button
                TextButton(
                  onPressed: _navigateToLogin,
                  child: Text(
                    "Passer",
                    style: GoogleFonts.poppins(  
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              
                ElevatedButton(
                  onPressed: _goToNextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _currentPage == _slides.length - 1 ? "Commencer" : "Suivant",
                        style: GoogleFonts.poppins(  
                          fontSize: 16, 
                          color: Colors.black,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, color: Colors.black),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
