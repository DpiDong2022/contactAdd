import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ứng dụng Danh bạ',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Contact> contacts = [];

  @override
  void initState() {
    super.initState();
    loadContacts();
  }

  Future<File> get _localFile async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/contacts.json');
  }

  Future<void> loadContacts() async {
    try {
      final file = await _localFile;
      final contents = await file.readAsString();
      final List<dynamic> jsonData = json.decode(contents);
      setState(() {
        contacts = jsonData.map((data) => Contact.fromJson(data)).toList();
      });
    } catch (e) {
      // If encountering an error, return an empty list
      setState(() {
        contacts = [];
      });
    }
  }

  Future<void> saveContacts() async {
    final file = await _localFile;
    final String jsonContacts =
        json.encode(contacts.map((contact) => contact.toJson()).toList());
    await file.writeAsString(jsonContacts);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh sách Liên hệ'),
      ),
      body: ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(contacts[index].name),
            subtitle: Text(contacts[index].phone),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        DetailScreen(contact: contacts[index])),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    AddContactScreen(onAddContact: (newContact) {
                      setState(() {
                        contacts.add(newContact);
                        saveContacts();
                      });
                    })),
          );
        },
        child: Icon(Icons.add),
        tooltip: 'Thêm Liên hệ',
      ),
    );
  }
}

class Contact {
  String name;
  String phone;

  Contact({required this.name, required this.phone});

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      name: json['name'],
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
    };
  }
}

class DetailScreen extends StatelessWidget {
  final Contact contact;

  DetailScreen({required this.contact});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(contact.name),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Tên: ${contact.name}', style: TextStyle(fontSize: 22)),
            Text('Số điện thoại: ${contact.phone}',
                style: TextStyle(fontSize: 22)),
          ],
        ),
      ),
    );
  }
}

class AddContactScreen extends StatefulWidget {
  final Function(Contact) onAddContact;

  AddContactScreen({required this.onAddContact});

  @override
  _AddContactScreenState createState() => _AddContactScreenState();
}

class _AddContactScreenState extends State<AddContactScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thêm Liên hệ Mới'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Tên'),
            ),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Số điện thoại'),
              keyboardType: TextInputType.phone,
            ),
            ElevatedButton(
              child: Text('Lưu Liên hệ'),
              onPressed: () {
                final newContact = Contact(
                  name: _nameController.text,
                  phone: _phoneController.text,
                );
                widget.onAddContact(newContact);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
