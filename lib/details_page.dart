import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailsPage extends StatefulWidget {
  const DetailsPage({Key? key}) : super(key: key);

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  String dropdownValue = 'A+';
  String bloodGroup = '';
  bool filterButtonPressed=false;
  String searchData='';
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                hintText: 'Search Name',
                icon: Icon(Icons.search),
              ),
              onChanged: (value){
                setState(() {
                  searchData = value;
                  filterButtonPressed=false;
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                DropdownButton<String>(
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
                const SizedBox(width: 10,),
                ElevatedButton(onPressed: (){
                  setState(() {
                    bloodGroup = dropdownValue;
                    filterButtonPressed = true;
                  });
                }, child: const Text('Filter'),),
              ],
            ),
            Expanded(
              child: StreamBuilder(
                stream: filterButtonPressed? FirebaseFirestore.instance
                    .collection('data')
                    .where('Blood',isEqualTo:bloodGroup)
                    .snapshots():
                FirebaseFirestore.instance
                    .collection('data')
                .orderBy('Name').startAt([searchData]).endAt([searchData+'\uf8ff'])
                    .snapshots(),
                builder:
                    (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if(snapshot.data!.docs.isEmpty){
                    return Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('images/empty.png'),
                            Text('No $bloodGroup Data'),
                          ],
                        ),
                      ),
                    );
                  }
                  return ListView(
                    children: snapshot.data!.docs.map((document) {
                      return GestureDetector(
                        onLongPress: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text("Are You Sure"),
                              content: Text("Do You want To Delete ${document['Name']}"),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () async {

                                    try {
                                      final result = await InternetAddress.lookup('example.com');
                                      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
                                        FirebaseFirestore.instance.collection('data').doc(document.id).delete();
                                        Navigator.of(ctx).pop();
                                      }
                                    } on SocketException catch (_) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Check Internet Connection')));
                                    }

                                  },
                                  child: const Text("Yes"),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Card(
                          elevation: 5,
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.red,
                              child: Center(
                                  child: Text(
                                document['Blood'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, color: Colors.white),
                              )),
                            ),
                            subtitle: Column(
                              children: [
                                Text(document['Name']),
                                Text(document['Place']),
                                Text(document['Phone']),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.call,
                                color: Colors.green,
                              ),
                              onPressed: () {
                                launch("tel://${document['Phone']}");
                              },
                            ),
                          ),
                        ),
                      );
                    }).toList(),
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
