import 'package:blood_bank/add_blood.dart';
import 'package:blood_bank/details_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp();
  runApp(const MyApp());
}
class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex= 1;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text(_selectedIndex == 1 ? 'Add New Data' : 'Details')),
        bottomNavigationBar: BottomNavigationBar(
          fixedColor: Colors.green,
          currentIndex: _selectedIndex,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.list_alt),label: 'Details'),
            BottomNavigationBarItem(icon: Icon(Icons.add_box_outlined),label: 'Add'),
          ],
          onTap: (index){
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
        body: _selectedIndex==0 ? const DetailsPage():const AddBlood(),
      ),
    );
  }
}
