import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:egaz/pages_client/customer_screen.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,  
          crossAxisAlignment: CrossAxisAlignment.center,
         
          children: [
            Lottie.asset('assets/images/success_payment.json'),
            const SizedBox(height: 24),
           const Text(
              'Paiement effectué!',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Vous serez livré dans quelques instants...',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                 context,
                   MaterialPageRoute(
                    builder: (context) => const CustomerScreen(), 
                   ),
                    );
              },
              style: ElevatedButton.styleFrom(
                 backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 16),
              ),
              child:const Text(
                'OK',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}