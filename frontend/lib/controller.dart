import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart';
import 'main.dart';
import 'view.dart';
import 'model.dart';

String apiadress =
    'https://saqs-b5h9dwfnfuewamam.francecentral-01.azurewebsites.net/api/';
String authorisation = '';
String username = '';
String staffnumber = '';
int id = 1;

Future<Response> sendGET(String target) async {
  final response = await get(
    Uri.parse(apiadress + target),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': authorisation,
    },
  );
  return response;
}

Future<Response> sendPOST(final body, String target) async {
  final response = await post(
    Uri.parse(apiadress + target),
    headers: <String, String>{
      'Access-Control-Allow-Origin': '*',
      'Content-Type': 'application/json',
      'Accept': '*/*'
    },
    body: body,
  );
  return response;
}

//###############################################################################
Future<void> logout(String name) async {
  final response = await sendGET('logout/');
  final Map<String, dynamic> status = jsonDecode(response.body);
  print(status);
}

Future<void> try_login(String uname, String pw, context) async {
  final body = jsonEncode({'password': pw, 'username': uname});
  int isadmin = 1;
  final response = await sendPOST(body, 'token/');
  if (response.statusCode == 200) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(response.statusCode.toString())));
    final Map<String, dynamic> status = jsonDecode(response.body);
    username = uname;
    staffnumber = status['access'];
    isadmin = 0; //status['position']
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logging in...')),
    );
  }
  //reused when API added
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

void buyTicket(
    int cID, String eName, int tNumber, int couponID, String ticketType) {
  final body = jsonEncode({
    'customerID': cID,
    'eventName': eName,
    'numberTickets': tNumber,
    'couponID': couponID,
    'ticketType': ticketType
  });
  final response = sendPOST(body, 'user/buyTicket');
}

Future<void> createEvent(String title, int max_tickets, int bought_tickets,
    int threshold, double base_price, DateTime date, context) async {
  final body = jsonEncode({
    'title': title,
    'max_tickets': max_tickets,
    'bought_tickets': bought_tickets,
    'threshold_tickets': threshold,
    'base_price': base_price,
    'date': date
  });
  final response = await sendPOST(body, 'manage/createEvent/');
  if (response.statusCode == 200) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(response.statusCode.toString())));
  }
}

double getPrice() {
  return 5.0;
}

Future<Event> getEvent(String title) async {
  final body = jsonEncode({'title': title});
  final response = await sendPOST(body, 'event/getEvent');
  Event choosen = Event.fromJson(jsonDecode(response.body));
  return choosen;
}

Future<List<Event>> getAllEvents() async {
  final response = await sendGET('event/listAll/');
  final List<dynamic> jsonResponse = jsonDecode(response.body);
  final List<Event> eventList =
      jsonResponse.map((events) => Event.fromJson(events)).toList();
  return eventList;
}

Future<String> getPosition(int uID) async {
  final body = jsonEncode({'userid': uID});
  final response = await sendPOST(body, 'user/getEmployeePosition');
  final Map<String, dynamic> choosen = jsonDecode(response.body);
  return choosen['position'];
}

/*
TicketType getTicket() {}

Gutschein getGutschein() {}

List<Event> getAllEvents() {}
*/
