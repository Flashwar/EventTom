import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart';
import 'main.dart';
import 'view.dart';
import 'model.dart';

String apiadress = 'api';

Future<Response> sendPOST(final body, String target) async {
  final response = await post(
    Uri.parse(apiadress + target),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Token b3d9c5f7b5ea782a8b76bbdec59bb9b5aff5e554'
    },
    body: body,
  );

  return response;
}

Future<void> pw_reset(String name) async {
  final body = jsonEncode({'username': name});
  sendPOST(body, 'api/password_reset/');
}

Future<void> try_login(String pw, String id, context) async {
  final body = jsonEncode({'password': pw, 'username': id});
  int isadmin = 1;
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
    if (isadmin == 0) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => UserPage()));
    }
    if (isadmin == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => CreatorPage()));
    }
    if (isadmin == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => ManagerPage()));
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logging in...')),
    );
  } else {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Loggin failed')));
  }
}

void deleteGutschein(int id) {}

void buyTicket() {}

void createEvent() {}

void login() {}

double getPrice() {
  return 5.0;
}
/*
Event getEvent() {}

TicketType getTicket() {}

Gutschein getGutschein() {}

List<Event> getAllEvents() {}
*/
