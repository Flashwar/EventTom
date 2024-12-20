import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart';
import 'controller.dart';
import 'model.dart';
import 'package:flutter/services.dart';

const double textWidth = 300;
String user_id = '';
String current_username = '';
int isadmin = 2;
Color red_colour = Color.fromRGBO(77, 153, 143, 1);
Color blue_colour = Color.fromRGBO(50, 121, 194, 1.00);
Color black_colour = Color.fromRGBO(33, 37, 41, 1.00);
Event curEvent = new Event(
    base_price: 1.0,
    threshold_tickets: 1,
    max_tickets: 1,
    title: '',
    bought_tickets: 1,
    date: DateTime.now());

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
                try_login('BeatBuddha', 'BlackPearl24', context);
                /*try_login(_usernameController.text, _passwordController.text,
                    context);*/
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
                  getAllEvents();
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

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPage();
}

class _UserPage extends State<UserPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Artifacts')),
      body: FutureBuilder<List<Event>>(
        future: getAllEvents(),
        builder: (context, snapshot) {
          // Handling different states
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final items = snapshot.data!;
            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(child: Text((index + 1).toString())),
                  title: Text(items[index].title),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventView(evnt: items[index]),
                      ),
                    );
                  },
                );
              },
            );
          } else {
            return const Center(child: Text('No data available.'));
          }
        },
      ),
    );
  }
}

class EventView extends StatefulWidget {
  const EventView({super.key, required this.evnt});

  final Event evnt;

  @override
  State<EventView> createState() => _EventView();
}

class _EventView extends State<EventView> {
  final TextEditingController _amountController = TextEditingController();
  int _currentamount = 0;

  void _decrement() {
    setState(() {
      _currentamount--;
      _amountController.text = _currentamount.toString();
    });
  }

  void _increment() {
    setState(() {
      _currentamount++;
      _amountController.text = _currentamount.toString();
    });
  }

  void _onTextFieldChange(String value) {
    setState(() {
      _currentamount = int.tryParse(value) ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.evnt.title)),
      body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(widget.evnt.title, textAlign: TextAlign.center),
            SizedBox(height: 10),
            Divider(
              height: 40,
              thickness: 2,
              indent: 20,
              endIndent: 0,
              color: red_colour,
            ),
            const Text('Verfügbare Tickets', textAlign: TextAlign.center),
            Text(
                (widget.evnt.max_tickets - widget.evnt.bought_tickets)
                    .toString(),
                textAlign: TextAlign.center),
            Divider(
              height: 40,
              thickness: 2,
              indent: 20,
              endIndent: 0,
              color: red_colour,
            ),
            const Text('Ticket Preis', textAlign: TextAlign.center),
            Text((widget.evnt.base_price).toString(),
                textAlign: TextAlign.center),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(onPressed: _decrement, icon: Icon(Icons.remove)),
                Container(
                  width: 100,
                  child: TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textAlign: TextAlign.center,
                    onChanged: _onTextFieldChange,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _increment,
                  icon: Icon(Icons.add),
                ),
              ],
            ),
          ]),
    );
  }
}

class ManagerPage extends StatefulWidget {
  const ManagerPage({super.key});

  @override
  State<ManagerPage> createState() => _ManagerPage();
}

class _ManagerPage extends State<ManagerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Artifacts')),
      body: FutureBuilder<List<Event>>(
        future: getAllEvents(),
        builder: (context, snapshot) {
          // Handling different states
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final items = snapshot.data!;
            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(child: Text((index + 1).toString())),
                  title: Text(items[index].title),
                );
              },
            );
          } else {
            return const Center(child: Text('No data available.'));
          }
        },
      ),
    );
  }
}

class CreatorPage extends StatefulWidget {
  const CreatorPage({super.key});

  @override
  State<CreatorPage> createState() => _CreatorPage();
}

class _CreatorPage extends State<CreatorPage> {
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Artifacts')),
      body: Stack(
        children: [
          FutureBuilder<List<Event>>(
            future: getAllEvents(),
            builder: (context, snapshot) {
              // Handling different states
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData) {
                final items = snapshot.data!;
                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading:
                          CircleAvatar(child: Text((index + 1).toString())),
                      title: Text(items[index].title),
                    );
                  },
                );
              } else {
                return const Center(child: Text('No data available.'));
              }
            },
          ),
          Positioned(
            bottom: 10,
            right: 200,
            child: InkWell(
              child: const Text('Event hinzufügen'),
              onTap: (() {
                showDialog(
                    context: context,
                    builder: (context) {
                      return addEvent();
                    });
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget addEvent() {
    final TextEditingController _EventTitleController = TextEditingController();
    final TextEditingController _EventPriceController = TextEditingController();
    final TextEditingController _EventMaxTicketsController =
        TextEditingController();
    final TextEditingController _EventDateController = TextEditingController();

    return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
        elevation: 16,
        child: Column(children: <Widget>[
          const Text('Event Erzeugen', textAlign: TextAlign.left),
          const SizedBox(height: 10),
          Container(
              child: Column(children: <Widget>[
            const Text('Eventtitel', textAlign: TextAlign.left),
            Center(
              child: SizedBox(
                width: textWidth,
                child: TextFormField(
                  controller: _EventTitleController,
                  decoration: const InputDecoration(labelText: 'Eventtitel'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Eventtitel';
                    }
                    return null;
                  },
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
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
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: blue_colour,
                  shape: const BeveledRectangleBorder(),
                ),
                onPressed: () => _selectDate(context),
                child: const Text('Datum auswählen',
                    style: TextStyle(fontFamily: 'Arial', color: Colors.white)),
              ),
              Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: blue_colour,
                  shape: const BeveledRectangleBorder(),
                  alignment: Alignment.centerRight,
                ),
                onPressed: () {
                  createEvent(
                      _EventTitleController.text,
                      _EventMaxTicketsController.text as int,
                      0,
                      ((_EventMaxTicketsController.text as num) / 2).toInt(),
                      (_EventPriceController.text as num) * 1.0,
                      DateTime.now(),
                      context);
                  Navigator.pop(context);
                },
                child: const Text('Ändern',
                    style: TextStyle(fontFamily: 'Arial', color: Colors.white)),
              ),
            ]),
          ])),
        ]));
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2024, 7, 1),
        lastDate: DateTime(2024, 7, 31));
    if (picked != null && picked != selectedDate) {
      selectedDate = picked;
    }
  }
}
