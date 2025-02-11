import 'package:flutter/material.dart'; 
import 'package:google_fonts/google_fonts.dart';
import 'package:egaz/pages_vendeur/add_delivery_person_page.dart';
import 'package:egaz/pages_authentification/auth_service.dart';
import 'package:egaz/database/database_egaz.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:egaz/database/database_egaz.dart';
import 'package:egaz/pages_authentification/auth_service.dart';


///////////////////////////////////////////////////////////////////////////
///                                                                       // 
///                                                                       //
///       PAGE GENERALE DE LA BOUTIQUE                                    //
///                                                                      //
///                                                                      //
///                                                                      //
///                                                                      //
/// ///////////////////////////////////////////////////////////////////////
class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Nombre de colonnes
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          children: [
            _buildOption(
              context,
              icon: Icons.storage,
              label: 'Mon stock',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const StockPage()),
                );
              },
            ),
            _buildOption(
              context,
              icon: Icons.star,
              label: 'Voir mes notes',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ReviewsPage()),
                );
              },
            ),
            _buildOption(
              context,
              icon: Icons.location_on,
              label: 'Changer mon emplacement',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LocationPage()),
                );
              },
            ),
            _buildOption(
              context,
              icon: Icons.local_shipping,
              label: 'Gérer les livreurs',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DeliveryPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFEAEAEA),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.black),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

///////////////////////////////////////////////////////////////////////////
///                                                                        
///                                                                       
///       DANS LE CODE SUIVANT LE VENDEUR POURRA VOIR     
///                  L'ETAT DE SON STOCK                                 
///                                                                      
///                                                                      
///                                                                      
///                                                                      
/// ///////////////////////////////////////////////////////////////////////

class StockPage extends StatelessWidget {
  const StockPage({super.key});

  @override
  Widget build(BuildContext context) {
    const bool isDarkMode =
        false; 

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mon Stock',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        backgroundColor: isDarkMode ? Colors.black : const Color(0xFFEAEAEA),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Affichage des types de gaz
            Text(
              'Types de Gaz',
              style: GoogleFonts.poppins(
                  fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _GasCard(gasName: 'Oryx'),
                _GasCard(gasName: 'Bénin Petro'),
                _GasCard(gasName: 'ProGaz'),
              ],
            ),
            const SizedBox(height: 32),

            // Affichage des quantités de bouteilles

            const SizedBox(height: 16),
            const Column(
              children: [
               
                Padding(
                  padding:
                      EdgeInsets.only(bottom: 16), 
                  child: Expanded(
                    child: _QuantityCard(
                        label: 'Petites Bouteilles', quantity: 426),
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsets.only(bottom: 16), 
                  child: Expanded(
                    child: _QuantityCard(
                        label: 'Grandes Bouteilles', quantity: 332),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
     
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddGasFormPage()),
          );
        },
        backgroundColor: isDarkMode ? Colors.yellow : Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _GasCard extends StatelessWidget {
  final String gasName;

  const _GasCard({required this.gasName});

  @override
  Widget build(BuildContext context) {
    const bool isDarkMode =
        false; 

    return Card(
      color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          gasName,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}

class _QuantityCard extends StatelessWidget {
  final String label;
  final int quantity;

  const _QuantityCard({required this.label, required this.quantity});

  @override
  Widget build(BuildContext context) {
    const bool isDarkMode =
        false; 
    const Color textColor = isDarkMode ? Colors.white : Colors.black;
    final Color quantityColor = quantity < 100 ? Colors.red : Colors.green;

    
    final IconData icon = quantity < 100
        ? Icons.inventory_2_rounded 
        : Icons.inventory_2_rounded; 

    // Dimensions adaptatives
    final double screenWidth = MediaQuery.of(context).size.width;
    final double cardWidth = screenWidth * 0.85; 

    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: 10.0, horizontal: 16.0), 
      child: Card(
        color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: cardWidth,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icône en haut
              Icon(
                icon,
                size: 50,
                color: isDarkMode ? Colors.amber : Colors.blue,
              ),
              const SizedBox(height: 8),

              // Étiquette
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),

              // Quantité
              AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(milliseconds: 500),
                child: Text(
                  '$quantity',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: quantityColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

///////////////////////////////////////////////////////////////////////////
///                                                                       // 
///                                                                       //
///       DANS LE CODE SUIVANT LE VENDEUR POURRA GERER SON STOCK         //
///                                                                      //
///                                  ajouter un produit                  //
//                                                                       //
///                                                                      //
///                                                                      //
/// /////////////////////////////////////////////////////////////////////// 

class AddGasFormPage extends StatefulWidget {
  const AddGasFormPage({super.key});

  @override
  _AddGasFormPageState createState() => _AddGasFormPageState();
}

class _AddGasFormPageState extends State<AddGasFormPage> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;

  final TextEditingController _designationController = TextEditingController();
  final TextEditingController _prixController = TextEditingController();
  final TextEditingController _marqueController = TextEditingController();
  final TextEditingController _photoController = TextEditingController();

  String? idVendeur;
  XFile? _imageFile;
  String? _categorie;

  @override
  void initState() {
    super.initState();
    _getCurrentUserId();
  }

  _getCurrentUserId() async {
    idVendeur = await AuthService().getCurrentUserId();
    setState(() {});
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
        _photoController.text = _imageFile!.path;
      });
    }
  }

  List<Step> _buildSteps() {
    return [
      Step(
        title: const Text("Informations Générales",
         style: TextStyle(
           fontSize: 25, 
           fontWeight: FontWeight.bold, 
           color: Colors.black, 
           letterSpacing: 1.5, 
           fontFamily: "Poppins",
  ),
         ),
        content: Column(
          children: [
            _buildTextField(_designationController, 'Désignation', 'Veuillez entrer une désignation',),
            _buildTextField(_prixController, 'Prix', 'Veuillez entrer un prix', isNumber: true),
          ],
        ),
        isActive: _currentStep >= 0,
      ),
      Step(
        title: const Text("Détails du Produit",style: TextStyle(
           fontSize: 25,
           fontWeight: FontWeight.bold, 
           color: Colors.black, 
           letterSpacing: 1.5,
           fontFamily: "Poppins", 
          ),
           ),
        content: Column(
          children: [
            _buildTextField(_marqueController, 'Marque', 'Veuillez entrer une marque'),
            DropdownButtonFormField<String>(
              value: _categorie,
              onChanged: (newValue) => setState(() => _categorie = newValue),
              items: const [
                DropdownMenuItem(value: 'Petites Bouteilles', child: Text('Petites Bouteilles')),
                DropdownMenuItem(value: 'Grandes Bouteilles', child: Text('Grandes Bouteilles')),
              ],
              decoration: const InputDecoration(labelText: 'Catégorie', border: OutlineInputBorder()),
              validator: (value) => value == null ? 'Veuillez sélectionner une catégorie' : null,
            ),
          ],
        ),
        isActive: _currentStep >= 1,
      ),
      Step(
  title: const Text(
    "Ajout de l'Image",
    style: TextStyle(
      fontSize: 25,
      fontWeight: FontWeight.bold,
      color: Colors.black,
      letterSpacing: 1.5,
      fontFamily: "Poppins",
    ),
  ),
  content: Column(
    children: [
      ElevatedButton(
        onPressed: () async {
          final ImagePicker picker = ImagePicker();
          final XFile? image = await picker.pickImage(source: ImageSource.gallery);
          if (image != null) {
            setState(() {
              _imageFile = image;
            });
          }
        },
        child: const Text('Choisir une Image'),
      ),
      const SizedBox(height: 10),
      _imageFile == null
          ? const Text('Aucune image sélectionnée')
          : Column(
              children: [
                ClipOval(
                  child: Image.file(
                    File(_imageFile!.path),
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 10),
                Text('Image sélectionnée : ${_imageFile!.name}'),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _imageFile = null; 
                    });
                  },
                  child: const Text('Supprimer l\'image'),
                ),
              ],
            ),
    ],
  ),
  isActive: _currentStep >= 2,
),

      Step(
        title: const Text("Confirmation",
        style: TextStyle(
           fontSize: 25, 
           fontWeight: FontWeight.bold, 
           color: Colors.black, 
           letterSpacing: 1.5,
           fontFamily: "Poppins", 
          ),
          ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Désignation : ${_designationController.text}"),
            Text("Prix : ${_prixController.text}"),
            Text("Marque : ${_marqueController.text}"),
            Text("Catégorie : $_categorie"),
            _imageFile != null ? Text("Image : ${_imageFile!.path}") : const Text("Image : Aucune"),
          ],
        ),
        isActive: _currentStep >= 3,
      ),
    ];
  }

  @override
 Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text(
        'Ajouter un Produit',
        style: TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          letterSpacing: 1.5,
          fontFamily: "Poppins",
        ),
      ),
      centerTitle: true,
    ),
    body: Form(
      key: _formKey, 
      child: Stepper(
        type: StepperType.vertical,
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep == _buildSteps().length - 1) {
            if (_formKey.currentState?.validate() ?? false) {
              print("Formulaire valide, envoi des données...");
              _submitForm();
            } else {
              print("Formulaire invalide");
            }
          } else {
            setState(() => _currentStep++);
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep--);
          }
        },
        steps: _buildSteps(),
        
        controlsBuilder: (BuildContext context, ControlsDetails details) {
          return Row(
            children: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: details.onStepContinue,
                child: Text(
                  "Continuer",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: details.onStepCancel,
                child: const Text("Annuler"),
              ),
            ],
          );
        },
      ),
    ),
  );
}

 void _submitForm() async {
  String designation = _designationController.text;
  int prix = int.parse(_prixController.text);
  String marque = _marqueController.text;
  String categorie = _categorie ?? 'Non spécifié';

  
  if (_imageFile != null) {
   
    File imageFile = File(_imageFile!.path);
    Uint8List imageBytes = await imageFile.readAsBytes();

    
    if (idVendeur != null) {
      await DatabaseHelper().insererProduit(
        designation: designation,
        prix: prix,
        photo: imageBytes,  
        marque: marque,
        categorie: categorie,
        idVendeur: idVendeur!,
      );

     Fluttertoast.showToast(
        msg: "Produit ajouté avec succès",
        toastLength: Toast.LENGTH_SHORT,  
        gravity: ToastGravity.TOP,  
        timeInSecForIosWeb: 4,  
        backgroundColor: Colors.green,  
        textColor: Colors.black,  
      );
      
      _formKey.currentState?.reset();
      _clearTextControllers();

     
      setState(() {
        _currentStep = 0;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur de récupération de l\'ID vendeur')),
      );
    }
  } else {
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Veuillez sélectionner une image')),
    );
  }
}

void _clearTextControllers() {
  _designationController.clear();
  _prixController.clear();
  _marqueController.clear();
  _photoController.clear();
  setState(() {
    _categorie = null; 
    _imageFile = null; 
  });
}

  Widget _buildTextField(TextEditingController controller, String label, String validationMessage, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        validator: (value) => value == null || value.isEmpty ? validationMessage : null,
      ),
    );
  }
}





///////////////////////////////////////////////////////////////////////////
///                                                                       // 
///                                                                       //
///       DANS LE CODE SUIVANT LE VENDEUR POURRA VOIR SES NOTES                                                                 //
///                                                                      //
///                                                                      //
///                                                                      //
///                                                                      //
/// ///////////////////////////////////////////////////////////////////////



class ReviewsPage extends StatelessWidget {
  ReviewsPage({super.key});

  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<List<Map<String, dynamic>>> _getAllReviews() async {
    final db = await _databaseHelper.getDatabase();
    return await db.query(
      'AVIS',
      orderBy: 'id DESC',
    );
  }

  String _formatRating(double rating) {
    return '${rating.toStringAsFixed(1)} étoiles';
  }

  @override
  Widget build(BuildContext context) {
    const bool isDarkMode = false;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notes des Clients',
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
            icon: const Icon(
              Icons.notifications,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getAllReviews(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          final reviews = snapshot.data ?? [];
          
          if (reviews.isEmpty) {
            return Center(
              child: Text(
                'Aucune note disponible',
                style: GoogleFonts.poppins(fontSize: 16),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.separated(
              itemCount: reviews.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final review = reviews[index];
                return Container(
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            review['nom_client'],
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: isDarkMode ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Note donnée par le client',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.yellow : Colors.blue,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                        child: Text(
                          _formatRating(review['note_client']),
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

///////////////////////////////////////////////////////////////////////////
///                                                                       // 
///                                                                       //
///          DANS LE CODE SUIVANT LE VENDEUR PEUT CHANGER LA POSITION    //
///                           DE SA BOUTIQUE                              //
///                                                                      //
///                                                                      //
///                                                                      //
///                                                                      //
/// ///////////////////////////////////////////////////////////////////////


class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  _LocationPageState createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  bool _showBlurScreen = true; 
  LatLng? _selectedLocation; 
  String _locationInfo = ""; 
  bool _showNotification = false;

  
  Future<void> _getLocationInfo(LatLng position) async {
    final url = Uri.parse(
        "https://nominatim.openstreetmap.org/reverse?lat=${position.latitude}&lon=${position.longitude}&format=json");

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _locationInfo = data['display_name'] ?? "Lieu inconnu";
        _selectedLocation = position;
      });
    }
  }

 
  void _showLocationNotification() {
    setState(() {
      _showNotification = true;
    });

    // Cacher la notification après 3 secondes
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _showNotification = false;
      });
    });
  }

  
  Future<void> _updateLocationInDatabase() async {
   
    String? userId = await AuthService().getCurrentUserId();
    
    if (userId != null) {
    
      await DatabaseHelper().updateVendeurLocation(userId, _locationInfo);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
         
          fm.FlutterMap(
            options: fm.MapOptions(
              center: const LatLng(6.5244, 2.3470), 
              zoom: 10.0,
              onTap: (tapPosition, latLng) {
                _getLocationInfo(latLng); 
              },
            ),
            children: [
              fm.TileLayer(
                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: const ['a', 'b', 'c'],
              ),
              if (_selectedLocation != null)
                fm.MarkerLayer(
                  markers: [
                    fm.Marker(
                      width: 40.0,
                      height: 40.0,
                      point: _selectedLocation!,
                      child: const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ],
                ),
            ],
          ),

          
          if (_showBlurScreen)
            Positioned.fill(
              child: Container(
                color: Colors.grey.withOpacity(0.3), 
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Veuillez zoomer la carte pour choisir votre localisation.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 70),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _showBlurScreen = false; 
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text(
                        "J'ai compris",
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),

         
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
                    'Localisation mise à jour !',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

          
          if (_selectedLocation != null)
            Positioned(
              bottom: 30,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      "Lieu sélectionné :",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      _locationInfo,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                         _showLocationNotification();
                         await Future.delayed(const Duration(seconds: 2));
                         
                         
                         await _updateLocationInDatabase();
                         
                         
                         Navigator.pop(context, _selectedLocation); 
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text("Définir comme position actuelle"),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}



///////////////////////////////////////////////////////////////////////////
///                                                                       // 
///                                                                       //
///       DANS LE CODE SUIVANT LE VENDEUR POURRA VOIR SES LIVREURS ET     //
///                                LES GERER                              //
///                                                                      //
///                                                                      //
///                                                                      //
///                                                                      //
/// ///////////////////////////////////////////////////////////////////////


class DeliveryPage extends StatefulWidget {
  const DeliveryPage({super.key});

  @override
  _DeliveryPageState createState() => _DeliveryPageState();
}

class _DeliveryPageState extends State<DeliveryPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final AuthService _authService = AuthService();
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  List<Map<String, dynamic>> _livreurs = [];
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    String? userId = await _authService.getCurrentUserId();
    if (userId != null) {
      List<Map<String, dynamic>> livreurs = await _dbHelper.getLivreursByVendeur(userId);
      setState(() {
        _currentUserId = userId;
        _livreurs = livreurs;
      });
    }
  }

  void _onRefresh() async {
    await _fetchData();
    _refreshController.refreshCompleted();
  }

  void _showLivreurDetails(Map<String, dynamic> livreur) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '${livreur['nom']} ${livreur['prenom']}',
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Téléphone: ${livreur['telephone']}", style: GoogleFonts.poppins(fontSize: 16)),
              Text("Engin: ${livreur['engin']}", style: GoogleFonts.poppins(fontSize: 16)),
            ],
          ),
          actions: [
            TextButton(
              child: Text("Fermer", style: GoogleFonts.poppins()),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteLivreur(Map<String, dynamic> livreur) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Confirmer la suppression',
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Êtes-vous sûr de vouloir supprimer ${livreur['nom']} ${livreur['prenom']} ?',
            style: GoogleFonts.poppins(fontSize: 16),
          ),
          actions: [
            TextButton(
              child: Text("Annuler", style: GoogleFonts.poppins()),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(
                "Supprimer",
                style: GoogleFonts.poppins(
                  color: Colors.red,
                ),
              ),
              onPressed: () async {
                await _dbHelper.deleteLivreur(livreur['id']);
                _fetchData();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Gestion des livreurs',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: const Color(0xFFEAEAEA),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications, color: Colors.black),
          ),
        ],
      ),
      body: SmartRefresher(
        controller: _refreshController,
        onRefresh: _onRefresh,
        enablePullDown: true,
       header: CustomHeader(
            builder: (context, mode) {
             return Center(
             child: Lottie.asset(
                'assets/images/refresh.json',
                width: 80,
                height: 80,
               ),
                );
                  },
                      ),
        child: _livreurs.isEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(
                    'assets/images/nobody.json',  
                    width: 200,
                    height: 200,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Aucun livreur disponible",
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ],
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _livreurs.length,
                itemBuilder: (context, index) {
                  var livreur = _livreurs[index];
                  return GestureDetector(
                    onTap: () => _showLivreurDetails(livreur),
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${livreur['nom']} ${livreur['prenom']}',
                            style: GoogleFonts.poppins(fontSize: 16, color: Colors.black),
                          ),
                          ElevatedButton(
                            onPressed: () => _confirmDeleteLivreur(livreur),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: Text(
                              'Supprimer',
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: SizedBox(
        width: 200,
        height: 56,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddDeliveryPersonPage(),
              ),
            );
          },
          backgroundColor: Colors.green,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, color: Colors.white),
              SizedBox(width: 5),
              Text(
                'Ajouter un livreur',
                style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  
}