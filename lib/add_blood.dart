import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AddBlood extends StatefulWidget {
  const AddBlood({Key? key}) : super(key: key);

  @override
  State<AddBlood> createState() => _AddBloodState();
}

class _AddBloodState extends State<AddBlood> {
  String dropdownValue = 'A+';
  String statusMessage = '';
  bool dataAdding = false;
  bool isLoading = false;

  TextEditingController nameController = TextEditingController();
  TextEditingController placeController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    Text(
                      statusMessage,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 22),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          label: Text('Name'),
                          hintText: 'Enter Name'),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: placeController,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          label: Text('Place'),
                          hintText: 'Enter Place'),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextField(
                      maxLength: 10,
                      keyboardType: TextInputType.phone,
                      controller: phoneController,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          label: Text('Phone'),
                          hintText: 'Enter Phone Number'),
                    ),
                    Container(
                      alignment: Alignment.centerRight,
                      child: DropdownButton<String>(
                        value: dropdownValue,
                        icon: const Icon(Icons.arrow_drop_down),
                        elevation: 16,
                        style: const TextStyle(color: Colors.deepPurple),
                        underline: Container(
                          height: 2,
                          color: Colors.deepPurpleAccent,
                        ),
                        onChanged: (String? newValue) {
                          setState(() {
                            dropdownValue = newValue!;
                          });
                        },
                        items: <String>[
                          'A+',
                          'B+',
                          'O+',
                          'AB+',
                          'A-',
                          'B-',
                          'O-',
                          'AB-'
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isLoading = true;
                          });
                          if (!(nameController.text == '' ||
                              phoneController.text == '' ||
                              placeController.text == '')) {
                            if (phoneController.text.length == 10) {
                              FirebaseFirestore.instance
                                  .collection('data')
                                  .add({
                                'Name': nameController.text,
                                'Phone': phoneController.text,
                                'Blood': dropdownValue,
                                'Place': placeController.text
                              }).then((value) {
                                nameController.clear();
                                phoneController.clear();
                                placeController.clear();

                                FocusScope.of(context)
                                    .requestFocus(FocusNode());

                                setState(() {
                                  statusMessage = 'Success';
                                  dataAdding = true;
                                  isLoading = false;
                                });

                                Future.delayed(const Duration(seconds: 1), () {
                                  setState(() {
                                    statusMessage = '';
                                    dataAdding = false;
                                  });
                                });
                              });
                            } else {
                              setState(() {
                                isLoading = false;
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Phone number must be 10 digit')));
                              });
                            }
                          } else {
                            setState(() {
                              isLoading = false;
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('All Fields are required')));
                            });
                          }
                        },
                        child: const Text('Add'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : const SizedBox(),
          dataAdding
              ? Center(
                  child: Lottie.asset('assets/done.json'),
                )
              : const SizedBox(),
        ],
      ),
    );
  }
}
