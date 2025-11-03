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
  final _formkey = GlobalKey<FormState>();
  final _namecontroller = TextEditingController();
  final _quantitycontroller = TextEditingController();
  final _pricecontroller = TextEditingController();
  String _status = "";

  final CollectionReference products =
      FirebaseFirestore.instance.collection("products_details");

  Future<void> _addproduct() async {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Products Info"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Form(
              key: _formkey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _namecontroller,
                    decoration: const InputDecoration(
                      labelText: "Enter Product name",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Enter Product name";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _quantitycontroller,
                    decoration: const InputDecoration(
                      labelText: "Enter Quantity",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Enter Quantity";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _pricecontroller,
                    decoration: const InputDecoration(
                      labelText: "Enter Price",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Enter Price";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey,
                        foregroundColor: Colors.white),
                    onPressed: _addproduct,
                    child: const Text("Save Details"),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _status,
                    style: const TextStyle(color: Colors.cyanAccent),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: products.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text("Error loading data"));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator());
                  }

                  final records = snapshot.data?.docs ?? [];

                  if (records.isEmpty) {
                    return const Center(child: Text("No products found"));
                  }

                  return ListView.builder(
                    itemCount: records.length,
                    itemBuilder: (context, index) {
                      final product =
                          records[index].data() as Map<String, dynamic>;
                      return Card(
                        elevation: 3,
                        child: ListTile(
                          title: Text(product["name"]),
                          subtitle: Text(
                              "Quantity: ${product["quantity"]}, Price: ₹${product["price"]}"),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
