import 'package:flutter/material.dart';

import '../crud.dart';
import '../linkapi.dart';
import 'home_owner.dart';

class PropertyOffers extends StatefulWidget {
  const PropertyOffers({super.key});

  @override
  State<PropertyOffers> createState() => _PropertyOffersState();
}

class _PropertyOffersState extends State<PropertyOffers> {
  final Crud _crud = Crud();

   bool isLoading = false;
   String selectedOffer ="";
  final TextEditingController _priceController = TextEditingController();

    addOffer() async {
    isLoading = true;
    setState(() {});

    try {
      var response = await _crud.postRequest(
        linkAddOffer,
        {
          "property_id": "1",
          "offer_type": selectedOffer,
          "price": _priceController.text,
         
        },
       
      );

      isLoading = false;
      setState(() {});

      if (response != null && response['status'] == "success") {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomeOwner()));
      } else {
        print("Adding real estate failed");
      }
    } catch (e) {
      isLoading = false;
      setState(() {});
      print("Exception occurred: $e");
    }
  }

 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Real Estate"),
        backgroundColor: Color.fromARGB(157, 42, 202, 181),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
                 child: Column(
                  children: [
                     DropdownButtonFormField<String>(
                      value: selectedOffer,
                      decoration: InputDecoration(
                        labelText: 'offer type',
                        labelStyle: TextStyle(
                          color: Colors.blue, // Label color
                          fontWeight: FontWeight.bold,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16), // Padding inside the dropdown
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(12), // Rounded corners
                          borderSide: BorderSide(
                            color: Colors.blue, // Border color
                            width: 2, // Border width
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.green, // Border color when focused
                            width: 2,
                          ),
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 16, // Text size in the dropdown
                        color: Colors.black, // Text color
                      ),
                      dropdownColor:
                          Colors.white, // Background color of dropdown options
                      items: [
                        DropdownMenuItem(
                          value: 'daily',
                          child: Text(
                            'daily',
                            style: TextStyle(
                              color: Colors.black, // Text color of the option
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'weekly',
                          child: Text(
                            'weekly',
                            style: TextStyle(
                              color: Colors.black, // Text color of the option
                            ),
                          ),
                        ),
                         DropdownMenuItem(
                          value: 'monthly',
                          child: Text(
                            'monthly',
                            style: TextStyle(
                              color: Colors.black, // Text color of the option
                            ),
                          ),
                        ),
                         DropdownMenuItem(
                          value: 'yearly',
                          child: Text(
                            'yearly',
                            style: TextStyle(
                              color: Colors.black, // Text color of the option
                            ),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedOffer = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 30),

                         TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Rent Amount",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter the Rent Amount.";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                     Center(
                      child: ElevatedButton(
                        onPressed:addOffer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(157, 42, 202, 181),
                          padding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 50),
                        ),
                        child: const Text(
                          "Submit",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ), 
                  ],

                 )
                ),
    );
  }
}