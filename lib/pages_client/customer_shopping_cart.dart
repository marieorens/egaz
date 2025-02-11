import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:kkiapay_flutter_sdk/kkiapay_flutter_sdk.dart';
import 'package:egaz/pages_client/success_pay.dart';
import 'package:egaz/pages_client/failed_pay.dart';
import 'package:egaz/providers/cart_provider.dart';
import 'package:egaz/database/database_egaz.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final _addressController = TextEditingController();
  bool _isAddressValid = false;

  @override
  void initState() {
    super.initState();
    _addressController.addListener(_validateAddress);
  }

  void _validateAddress() {
    setState(() {
      _isAddressValid = _addressController.text.trim().isNotEmpty;
    });
  }

  
  void startPayment(BuildContext context, int amount) {
    if (!_isAddressValid) {
      Fluttertoast.showToast(
        msg: "Vous devez renseigner votre adresse de livraison avant de passer au paiement!",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

     final kkiapay = KKiaPay(
    amount: amount,
    countries: const ["BJ", "CI", "SN", "TG"],
    phone: "",
    name: "",
    email: "",
    reason: 'Paiement de commande',
    sandbox: true,
    apikey: "0a9be610652111efbf02478c5adba4b8",
    callback: (response, _) => paymentCallback(response, context),
    theme: "#222F5A",
    paymentMethods: const ["momo", "card"],
  );

  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => kkiapay),
  );

    
  }

  void paymentCallback(Map<String, dynamic> response, BuildContext context) async {
    if (response['status'] == PAYMENT_SUCCESS) {
      final cart = Provider.of<CartProvider>(context, listen: false);
      final dbHelper = DatabaseHelper();

      try {
        await dbHelper.enregistrerCommande(
          produits: cart.items.values.toList(),
          total: cart.totalAmount.toDouble(),
          adresseLivraison: _addressController.text,
        );

        cart.clear();

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SuccessScreen()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Erreur : Impossible d\'enregistrer la commande.')),
        );
      }
    } else {
     
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, child) {
        if (cart.items.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                'Mon Panier',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 25),
              ),
              centerTitle: true,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_cart_outlined, size: 100, color: Colors.black),
                  const SizedBox(height: 20),
                  Text(
                    'Votre panier est vide',
                    style: GoogleFonts.poppins(fontSize: 20, color: Colors.black),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(
              'Mon Panier',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 25),
            ),
            centerTitle: true,
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final item = cart.items.values.toList()[index];
                    return ListTile(
                      leading: Image.memory(item.imageUrl, width: 50, height: 50, fit: BoxFit.cover),
                      title: Text(item.name, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${item.price} FCFA',
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w400)),
                          Row(
                            children: [
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () => cart.updateQuantity(item.id, false),
                              ),
                              Text(
                                item.quantity.toString(),
                                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () => cart.updateQuantity(item.id, true),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    hintText: "Adresse de livraison ...",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on),
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18)),
                        Text('${cart.totalAmount} FCFA',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () => startPayment(context, cart.totalAmount),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: _isAddressValid ? Colors.green : Colors.grey,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        'Payer',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 20, color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
