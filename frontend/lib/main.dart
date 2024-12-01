import 'dart:html';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:http/http.dart';
import 'package:url_launcher/url_launcher.dart';

const double textWidth = 300;
String user_id = '';
String current_username = '';
int isadmin = 2;
Color red_colour = Color.fromRGBO(202, 255, 248, 1);
Color blue_colour = Color.fromRGBO(50, 121, 194, 1.00);
Color black_colour = Color.fromRGBO(33, 37, 41, 1.00);

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EventTim',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: red_colour,
          title: const Text('EventTim',
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Arial', color: Colors.white)),
        ),
        body: LoginPage(title: 'Login Page'),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.title});

  final String title;

  @override
  State<LoginPage> createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  bool? LoggedIn = false;

  Future<Response> sendPOST(final body, String target) async {
    final response = await post(
      Uri.parse('https://mux-2024.azurewebsites.net/' + target),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token b3d9c5f7b5ea782a8b76bbdec59bb9b5aff5e554'
      },
      body: body,
    );

    return response;
  }

  Future<void> _pw_reset(String name) async {
    final body = jsonEncode({'username': name});
    sendPOST(body, 'api/password_reset/');
  }

  Future<void> _try_login(String pw, String id) async {
    final body = jsonEncode({'password': pw, 'username': id});
    /*final response = await sendPOST(body, '/api/login/');
    if (response.statusCode == 200) {
    
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.statusCode.toString())));
      final Map<String, dynamic> status = jsonDecode(response.body);
      user_id = status['user_id'];
      current_username = id;

      if (LoggedIn != true) {
        clearlog();
      }
      Navigator.push(context, MaterialPageRoute(builder: (_) => UserPage()));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logging in...')),
      );
      */ //reused when API added
    if (1 == 1) {
      if (LoggedIn != true) {
        clearlog();
      }
      if (isadmin == 0) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => UserPage()));
      }
      if (isadmin == 1) {
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => CreatorPage()));
      }
      if (isadmin == 2) {
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => ManagerPage()));
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logging in...')),
      );
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Loggin failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Center(
              child: Text('EventTim'),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text('Login'),
            ),
            Center(
              child: SizedBox(
                width: 400,
                child: TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'Benutzername'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Benutzername';
                    }
                    return null;
                  },
                ),
              ),
            ),
            Center(
              child: SizedBox(
                width: 400,
                child: TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Passwort'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Passwort';
                    }
                    return null;
                  },
                ),
              ),
            ),
            Center(
              child: Checkbox(
                value: LoggedIn,
                onChanged: (bool? value) {
                  setState(() {
                    LoggedIn = value;
                  });
                },
              ),
            ),
            const Text('Angemeldet Bleiben'),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: const BeveledRectangleBorder(),
              ),
              onPressed: () {
                _try_login(_passwordController.text, _usernameController.text);
              },
              child: const Text('Einloggen',
                  style: TextStyle(fontFamily: 'Arial', color: Colors.white)),
            ),
            const SizedBox(height: 100),
            Center(
              child: InkWell(
                child: const Text('Passwort vergessen'),
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return resetpw();
                      });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget resetpw() {
    return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
        elevation: 16,
        child: Column(children: <Widget>[
          const Text('Passwort Resetten', textAlign: TextAlign.left),
          const SizedBox(height: 10),
          Container(
              child: Column(children: <Widget>[
            const Text('Nutzername', textAlign: TextAlign.left),
            Center(
              child: SizedBox(
                width: textWidth,
                child: TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nutzername'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nutzername';
                    }
                    return null;
                  },
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: const BeveledRectangleBorder(),
                  alignment: Alignment.centerLeft,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Abbrechen',
                    style: TextStyle(fontFamily: 'Arial', color: blue_colour)),
              ),
              Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: blue_colour,
                  shape: const BeveledRectangleBorder(),
                  alignment: Alignment.centerRight,
                ),
                onPressed: () {
                  _pw_reset(_nameController.text);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Reset Message sent')),
                  );
                },
                child: const Text('Passwort zurücksetzen',
                    style: TextStyle(fontFamily: 'Arial', color: Colors.white)),
              ),
            ]),
          ])),
        ]));
  }

  void clearlog() {
    _usernameController.clear();
    _passwordController.clear();
  }
}

class UserPage extends StatelessWidget {
  final List<String> artifacts = [
    'Event1',
    'Event2',
    'Event3',
    'Event4',
    'Event5'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Artifacts')),
      body: ListView.builder(
        itemCount: artifacts.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(artifacts[index]),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${artifacts[index]} clicked!')),
              );
            },
          );
        },
      ),
    );
  }
}

class ManagerPage extends StatelessWidget {
  final List<String> artifacts = [
    'EventA',
    'Event2',
    'Event3',
    'Event4',
    'Event5'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Artifacts')),
      body: ListView.builder(
        itemCount: artifacts.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(artifacts[index]),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${artifacts[index]} clicked!')),
              );
            },
          );
        },
      ),
    );
  }
}

class CreatorPage extends StatelessWidget {
  final List<String> artifacts = [
    'EventB',
    'Event2',
    'Event3',
    'Event4',
    'Event5'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Artifacts')),
      body: ListView.builder(
        itemCount: artifacts.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(artifacts[index]),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${artifacts[index]} clicked!')),
              );
            },
          );
        },
      ),
    );
  }
}

class User {
  final String name;
  final String id;

  User({
    required this.id,
    required this.name,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['username'],
      id: json['participant_id'],
    );
  }
}
