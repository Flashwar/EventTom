import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:web_socket_channel/io.dart';
import 'controller.dart';
import 'model.dart';
import 'package:flutter/services.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

const double textWidth = 300;
int user_id = 0;
String current_username = '';
String webSocketAdress = getWebSocketAdress();
int isadmin = 2;
Color red_colour = Color.fromRGBO(77, 153, 143, 1);
Color blue_colour = Color.fromRGBO(50, 121, 194, 1.00);
Color black_colour = Color.fromRGBO(33, 37, 41, 1.00);
Color highlightColor = Color.fromRGBO(247, 192, 11, 1);
Color barColor = Color.fromRGBO(6, 86, 167, 1);

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
      title: 'EventTom',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: red_colour,
          title: const Text('EventTom',
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
    return Center(
        // Das Formular wird mittig zentriert
        child: Padding(
      padding: const EdgeInsets.all(16.0), // Abstand vom Rand
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Center(
              child: Text('EventTom'),
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
                try_login(_usernameController.text,
                    'BlackPearl24' /*_passwordController.text*/, context);
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
    ));
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
  final _channel = WebSocketChannel.connect(
    Uri.parse(webSocketAdress + 'event/update/'),
  );

  final List<String> imagePaths = [
    'assets/images/istockphoto-505963814-1024x1024.jpg',
    'assets/images/istockphoto-1128020862-1024x1024.jpg',
    'assets/images/istockphoto-1340877488-1024x1024.jpg',
    'assets/images/istockphoto-1440928369-1024x1024.jpg',
    'assets/images/istockphoto-1483833011-1024x1024.jpg',
    'assets/images/istockphoto-1783743772-1024x1024.jpg',
    'assets/images/istockphoto-2150389695-1024x1024.jpg',
    'assets/images/istockphoto-2150707819-1024x1024.jpg',
    'assets/images/istockphoto-2152071167-1024x1024.jpg',
    'assets/images/istockphoto-2155005515-1024x1024.jpg',
    'assets/images/istockphoto-2157031195-1024x1024.jpg'
    // Add more image paths as needed
  ];

  @override
  void dispose() {
    // Close the WebSocket connection when the widget is disposed
    _channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Events')),
      body: ListView(
        children: <Widget>[
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 100), // Limit the height
            child: StreamBuilder(
              stream: _channel.stream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}',
                      textAlign: TextAlign.right);
                } else if (snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.hasData) {
                    final Map<String, dynamic> pos = jsonDecode(snapshot.data);
                    if (pos['type'] == 'new_event') {
                      return Text(
                          'New Message: Ein neues Event findet statt, sei der Erste der bei ' +
                              pos['message']['title'] +
                              ' dabei ist^^',
                          textAlign: TextAlign.right);
                    } else {
                      return Text('', textAlign: TextAlign.right);
                    }
                  } else {
                    return Text('No messages yet.', textAlign: TextAlign.right);
                  }
                }
                return Text('', textAlign: TextAlign.right);
              },
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 900), // Limit the height
            child: FutureBuilder<List<Event>>(
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
                        leading: CircleAvatar(
                            child: Image.asset(
                                'assets/images/istockphoto-505963814-1024x1024.jpg') /*Text((index + 1).toString())*/),
                        title: Text(items[index].title),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EventView(evnt: items[index]),
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
          ),
        ],
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
  final _channel = WebSocketChannel.connect(
    Uri.parse(webSocketAdress + 'event/update/'),
  );
  int _currentamount = 0;
  final int _minVal = 0;
  int bought_tickets = 0;
  int _maxVal = 100;
  int couponId = 0;
  double gutscheinWert = 0.0;

  @override
  void dispose() {
    // Close the WebSocket connection when the widget is disposed
    _channel.sink.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    bought_tickets = widget.evnt.bought_tickets;
    _amountController.addListener(() {
      final text = _amountController.text;
      if (text.isNotEmpty) {
        final value = int.tryParse(text);
        if (value != null) {
          if (value < _minVal) {
            _amountController.text = _minVal.toString();
          } else if (value > _maxVal) {
            _amountController.text = _maxVal.toString();
          }
          _amountController.selection = TextSelection.fromPosition(
            TextPosition(offset: _amountController.text.length),
          );
        }
      } else {
        _amountController.text = _minVal.toString();
      }
    });
    _channel.stream.listen(
      (data) {
        final Map<String, dynamic> pos = jsonDecode(data);
        if (pos['message']['title'] == widget.evnt.title) {
          setState(() {
            bought_tickets = 7;
            //pos['message']['bought_tickets'];
          });

          //widget.evnt.max_tickets - int.parse(pos['bought_tickets']);
        }
      },
      onError: (error) {
        print('WebSocket Error: $error');
      },
      onDone: () {
        print('WebSocket Connection Closed');
      },
    );
  }

  void _decrement() {
    setState(() {
      if (_currentamount > _minVal) {
        _currentamount--;
        _amountController.text = _currentamount.toString();
      }
    });
  }

  void _increment() {
    setState(() {
      if (_currentamount < _maxVal) {
        _currentamount++;
        _amountController.text = _currentamount.toString();
      }
    });
  }

  void _onTextFieldChange(String value) {
    setState(() {
      _currentamount = int.tryParse(value) ?? 0;
    });
  }

  void _vbuyTickets(
      int id, String eName, int amount, int couponID, String tickType) {
    buyTicket(id, eName, amount, couponID, tickType);
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
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('Verfügbare Tickets', textAlign: TextAlign.center),
              Divider(
                height: 40,
                thickness: 2,
                indent: 20,
                endIndent: 0,
                color: red_colour,
              ),
              Text((widget.evnt.max_tickets - bought_tickets).toString(),
                  textAlign: TextAlign.center),
            ]),
            Divider(
              height: 40,
              thickness: 2,
              indent: 20,
              endIndent: 0,
              color: red_colour,
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('Ticket Preis', textAlign: TextAlign.center),
              Divider(
                height: 40,
                thickness: 2,
                indent: 20,
                endIndent: 0,
                color: red_colour,
              ),
              Text(
                  (widget.evnt.base_price + (widget.evnt.base_price * getFee()))
                      .toString(),
                  textAlign: TextAlign.center),
              //
            ]),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text('Gutschein hinzufügen', textAlign: TextAlign.center),
              IconButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return chooseGutschein();
                      });
                },
                icon: Icon(Icons.add),
              ),
            ]),
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
                  onPressed: () {
                    _increment();
                    _maxVal =
                        widget.evnt.max_tickets - widget.evnt.bought_tickets;
                  },
                  icon: Icon(Icons.add),
                ),
              ],
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(
                  (widget.evnt.base_price * _currentamount +
                          ((widget.evnt.base_price * _currentamount) *
                                      getFee() >
                                  gutscheinWert
                              ? (widget.evnt.base_price * _currentamount) *
                                      getFee() -
                                  gutscheinWert
                              : 0))
                      .toString(),
                  textAlign: TextAlign.center),
              TextButton(
                  onPressed: () {
                    _vbuyTickets(getUserID(), widget.evnt.title, _currentamount,
                        couponId, 'Standard');
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(_amountController.text +
                            ' Tickets wurden gekauft')));
                    setState(() {
                      _currentamount = 0;
                      _amountController.text = '0';
                    });
                  },
                  child: Text('kaufen'))
            ])
          ]),
    );
  }

  Widget chooseGutschein() {
    return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
        elevation: 16,
        child: Column(children: <Widget>[
          const Text('Gutschein wählen', textAlign: TextAlign.left),
          const SizedBox(height: 10),
          Container(
              width: 500,
              child: Column(children: <Widget>[
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
                        style:
                            TextStyle(fontFamily: 'Arial', color: blue_colour)),
                  ),
                  SizedBox(width: 40.0),
                  const Text('Gutscheine:', textAlign: TextAlign.left),
                ]),
                FutureBuilder<List<Gutschein>>(
                  future: getGutschein(getUserID()),
                  builder: (context, snapshot) {
                    // Handling different states
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (snapshot.hasData) {
                      final items = snapshot.data!;
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: CircleAvatar(
                                child: Text((index + 1).toString())),
                            title: Text(items[index].amount.toString()),
                            dense: true,
                            visualDensity: VisualDensity(vertical: -3),
                            onTap: () {
                              couponId = items[index].id;
                              gutscheinWert = items[index].amount;
                              Navigator.pop(context);
                            },
                          );
                        },
                      );
                    } else {
                      return const Center(child: Text('No data available.'));
                    }
                  },
                ),
              ])),
        ]));
  }
}

class ManagerPage extends StatefulWidget {
  const ManagerPage({super.key});

  @override
  State<ManagerPage> createState() => _ManagerPage();
}

class _ManagerPage extends State<ManagerPage> {
  final _channel = WebSocketChannel.connect(
    Uri.parse(webSocketAdress + 'admin/notifications/'),
  );
  String _receivedMessage = '';

  @override
  void dispose() {
    // Close the WebSocket connection when the widget is disposed
    _channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Events')),
      body: ListView(children: <Widget>[
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 100), // Limit the height
          child: StreamBuilder(
            stream: _channel.stream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}',
                    textAlign: TextAlign.right);
              } else if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.hasData) {
                  final Map<String, dynamic> pos = jsonDecode(snapshot.data);
                  return Text('Neue Nachricht: ' + pos['message'],
                      textAlign: TextAlign.right);
                } else {
                  return Text('No messages yet.', textAlign: TextAlign.right);
                }
              }
              return Text('', textAlign: TextAlign.right);
            },
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 900), // Limit the height
          child: FutureBuilder<List<Event>>(
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
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ManagerEventView(evnt: items[index]),
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
        ),
      ]),
    );
  }
}

class ManagerEventView extends StatefulWidget {
  const ManagerEventView({super.key, required this.evnt});

  final Event evnt;

  @override
  State<ManagerEventView> createState() => _ManagerEventView();
}

class _ManagerEventView extends State<ManagerEventView> {
  final _channel = WebSocketChannel.connect(
    Uri.parse(webSocketAdress + 'event/update/'),
  ); // Initial value
  int _maxValue = 55; // Maximum value
  int _thresholdLow = 20;
  int _thresholdHigh = 30;
  int bought_tickets = 0;
  String eventname = '';

  Color _getBarColor(int value) {
    if (value > _thresholdLow && value < _thresholdHigh) {
      return highlightColor; // Highlight color
    }
    print(_thresholdLow);
    print(_thresholdHigh);
    print(value);
    return barColor;
    // Default color
  }

  @override
  void initState() {
    super.initState();
    bought_tickets = widget.evnt.bought_tickets;
    _maxValue = widget.evnt.max_tickets;
    print(widget.evnt.threshold_tickets);

    print(widget.evnt.max_tickets * 0.1);
    _thresholdLow =
        widget.evnt.threshold_tickets - (widget.evnt.max_tickets * 0.1).toInt();
    _thresholdHigh =
        widget.evnt.threshold_tickets + (widget.evnt.max_tickets * 0.1).toInt();

    // Listen for WebSocket messages
    _channel.stream.listen(
      (data) {
        // Perform an action when data is received
        final Map<String, dynamic> pos = jsonDecode(data);
        if (pos['type'] == 'update_ticket_count' &&
            pos['message']['title'] == widget.evnt.title) {
          setState(() {
            bought_tickets = pos['message']['bought_tickets'];
            //
          });
        }
      },
      onError: (error) {
        print('WebSocket Error: $error');
      },
      onDone: () {
        print('WebSocket Connection Closed');
      },
    );
  }

  @override
  void dispose() {
    // Close the WebSocket connection when the widget is disposed
    _channel.sink.close();
    super.dispose();
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
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('Verfügbare Tickets', textAlign: TextAlign.center),
              Divider(
                height: 40,
                thickness: 2,
                indent: 20,
                endIndent: 0,
                color: red_colour,
              ),
              Text((widget.evnt.max_tickets - bought_tickets).toString(),
                  textAlign: TextAlign.center),
            ]),
            Divider(
              height: 40,
              thickness: 2,
              indent: 20,
              endIndent: 0,
              color: red_colour,
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('Gekaufte Tickets', textAlign: TextAlign.center),
              Divider(
                height: 40,
                thickness: 2,
                indent: 20,
                endIndent: 0,
                color: red_colour,
              ),
              Text((bought_tickets).toString(), textAlign: TextAlign.center),
            ]),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Stack(
                children: [
                  Container(
                    height: 20,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey[300],
                    ),
                  ),
                  Positioned(
                    left: 0,
                    child: Container(
                      height: 20,
                      width: (bought_tickets / _maxValue) *
                          MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: _getBarColor(
                            widget.evnt.max_tickets - bought_tickets),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Slider to adjust the value

            Text(
              "Value: ${bought_tickets.toStringAsFixed(1)}",
              style: const TextStyle(fontSize: 18),
            ),
          ]),
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
  String _receivedMessage = 'tt';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Events')),
      body: ListView(
        children: <Widget>[
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
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 900), // Limit the height
            child: FutureBuilder<List<Event>>(
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
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
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
                      decoration:
                          const InputDecoration(labelText: 'Eventtitel'),
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
                const Text('Maximale Tickets', textAlign: TextAlign.left),
                Center(
                  child: SizedBox(
                    width: textWidth,
                    child: TextFormField(
                      controller: _EventMaxTicketsController,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration:
                          const InputDecoration(labelText: 'Maximale Tickets'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Maximale Tickets';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text('Ticket Preis', textAlign: TextAlign.left),
                Center(
                  child: SizedBox(
                    width: textWidth,
                    child: TextFormField(
                      controller: _EventPriceController,
                      decoration:
                          const InputDecoration(labelText: 'Ticket Preis'),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ticket Preis';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: blue_colour,
                    shape: const BeveledRectangleBorder(),
                  ),
                  onPressed: () => _selectDate(context),
                  child: const Text('Datum auswählen',
                      style:
                          TextStyle(fontFamily: 'Arial', color: Colors.white)),
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
                        style:
                            TextStyle(fontFamily: 'Arial', color: blue_colour)),
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
                          int.parse(_EventMaxTicketsController.text),
                          0,
                          (int.parse(_EventMaxTicketsController.text) / 2)
                              .toInt(),
                          double.parse(_EventPriceController.text),
                          DateTime.now(),
                          context);
                      Navigator.pop(context);
                    },
                    child: const Text('Event erstellen',
                        style: TextStyle(
                            fontFamily: 'Arial', color: Colors.white)),
                  ),
                ]),
              ])),
            ]));
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2025, 1, 1),
        lastDate: DateTime(2025, 7, 31));
    if (picked != null && picked != selectedDate) {
      selectedDate = picked;
    }
  }
}
