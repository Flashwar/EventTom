import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart';
import 'controller.dart';
import 'model.dart';

const double textWidth = 300;
String user_id = '';
String current_username = '';
int isadmin = 2;
Color red_colour = Color.fromRGBO(77, 153, 143, 1);
Color blue_colour = Color.fromRGBO(50, 121, 194, 1.00);
Color black_colour = Color.fromRGBO(33, 37, 41, 1.00);

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
                try_login(_passwordController.text, _usernameController.text,
                    context);
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
                  pw_reset(_nameController.text);
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
