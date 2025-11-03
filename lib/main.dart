import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    title: "Product Inventory",
    home: ProductsApp(),
    debugShowCheckedModeBanner: false,
  ));
}

class ProductsApp extends StatefulWidget {
  const ProductsApp({super.key});

  @override
  State<ProductsApp> createState() => _ProductsAppState();
}

class _ProductsAppState extends State<ProductsApp> {
  //final _formkey = GlobalKey<FormState>();
  //final _namecontroller = TextEditingController();
  //final _quantitycontroller = TextEditingController();
  //final _pricecontroller = TextEditingController();
  //String _status = "";

  final TextEditingController _searchController = TextEditingController();

  String _productName = "";
  double? _quantity;
  double? _price;
  String _message = "";

  final CollectionReference products =
      FirebaseFirestore.instance.collection("products_details");

  /*Future<void> _addproduct() async {
    if (_formkey.currentState!.validate()) {
      await products.add({
        "name": _namecontroller.text,
        "quantity": double.parse(_quantitycontroller.text),
        "price": double.parse(_pricecontroller.text)
      });
      _namecontroller.clear();
      _quantitycontroller.clear();
      _pricecontroller.clear();

      setState(() {
        _status = "Data Saved Successfully";
      });
    }
  }*/

  Future<void> _searchProduct() async {
  String name = _searchController.text.trim();
  if (name.isNotEmpty) {
    final query = await FirebaseFirestore.instance
        .collection("products_details")
        .where("name", isEqualTo: name)
        .get();

    if (query.docs.isNotEmpty) {
      final product = query.docs.first.data();
      setState(() {
        _productName = product["name"];
        _quantity = product["quantity"];
        _price = product["price"];
        _message = "";
      });
    } else {
      setState(() {
        _productName = "";
        _quantity = null;
        _price = null;
        _message = "Product not found";
      });
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Products Info"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
  padding: const EdgeInsets.all(16.0),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TextField(
        controller: _searchController,
        decoration: InputDecoration(
          labelText: "Enter Product Name",
          border: OutlineInputBorder(),
        ),
      ),
      SizedBox(height: 10),
      ElevatedButton(
        onPressed: _searchProduct,
        child: Text("Search"),
      ),
      SizedBox(height: 20),
      if (_productName.isNotEmpty)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Name: $_productName", style: TextStyle(fontSize: 18)),
            Text("Quantity: $_quantity", style: TextStyle(fontSize: 18)),
            Text("Price: $_price", style: TextStyle(fontSize: 18)),
            if (_quantity != null && _quantity! < 5)
              Text("Low Stock!", style: TextStyle(color: Colors.red, fontSize: 16)),
          ],
        ),
      if (_message.isNotEmpty)
        Text(_message, style: TextStyle(color: Colors.red, fontSize: 16)),
    ],
  ),
),

    );
  }
}
