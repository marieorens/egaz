import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:egaz/autres_pages/splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:egaz/pages_authentification/firebase_options.dart';
import 'package:egaz/providers/cart_provider.dart';
import 'package:egaz/database/database_egaz.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

     DatabaseHelper dbHelper = DatabaseHelper();
     await dbHelper.getDatabase();
    

  runApp(
    MultiProvider(
      providers: [
       
        ChangeNotifierProvider(create: (ctx) => CartProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme:  ThemeData.light().copyWith(
                  appBarTheme: const AppBarTheme(
                    backgroundColor: Colors.white,
                    iconTheme: IconThemeData(color: Colors.black),
                    titleTextStyle: TextStyle(color: Colors.black, fontSize: 20),
                  ),
                ),
          home: const SplashScreen(),
        );
      },
    );
  }
}
