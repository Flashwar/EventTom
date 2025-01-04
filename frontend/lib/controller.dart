import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart';
import 'main.dart';
import 'view.dart';
import 'model.dart';

String apiadress =
    'https://saqs-b5h9dwfnfuewamam.francecentral-01.azurewebsites.net/api/';
String webSocketAdress = apiadress;
String authorisation = '';
String username = '';
String token = '';
int user_id = 0;
String isadmin = '';

int getUserID() {
  return user_id;
}

String getWebSocketAdress() {
  return webSocketAdress;
}

Future<Response> sendGET(String target) async {
  final response = await get(
    Uri.parse(apiadress + target),
    headers: {'Content-Type': 'application/json', 'Bearer': token},
  );
  return response;
}

Future<Response> sendPOST(final body, String target) async {
  final response = await post(
    Uri.parse(apiadress + target),
    headers: <String, String>{
      'Access-Control-Allow-Origin': '*',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ' + token
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
  final response = await sendPOST(body, 'token/');
  if (response.statusCode == 200) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(response.statusCode.toString())));
    final Map<String, dynamic> status = jsonDecode(response.body);
    username = uname;
    token = status['access'];
    await setUserID(uname); //status['position']
    await setUserPos(user_id);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logging in...')),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logging in...')),
    );
    if (isadmin == 'NO') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => UserPage()));
    } else if (isadmin == 'EC') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => CreatorPage()));
    } else if (isadmin == 'EM') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => ManagerPage()));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Loggin failed')));
    }
  } else {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Loggin failed')));
  }
}

Future<void> setUserID(String name) async {
  final body = jsonEncode({'username': name});
  final response = await sendPOST(body, 'user/getUserId/');
  final Map<String, dynamic> ID = jsonDecode(response.body);
  user_id = ID['user_id'];
}

Future<void> setUserPos(int id) async {
  final body = jsonEncode({'userid': id});
  final response = await sendPOST(body, 'user/getEmployeePosition/');
  final Map<String, dynamic> pos = jsonDecode(response.body);
  isadmin = pos['jobPosition'];
}

void deleteGutschein(int id) {}

void buyTicket(
    int cID, String eName, int tamount, int couponID, String ticketType) async {
  final body = jsonEncode({
    'customerID': cID,
    'eventName': eName,
    'numberTickets': tamount,
    'couponID': couponID,
    'ticketTyp': ticketType
  });
  final response = await sendPOST(body, 'user/buyTicket/');
  print(1);
}

Future<void> createEvent(String title, int max_tickets, int bought_tickets,
    int threshold, double base_price, DateTime date, context) async {
  final body = jsonEncode({
    'title': title,
    'max_tickets': max_tickets,
    'bought_tickets': bought_tickets,
    'threshold_tickets': threshold,
    'base_price': base_price
  });
  final response = await sendPOST(body, 'manage/createEvent/');
  if (response.statusCode == 201) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(response.statusCode.toString())));
  }
}

double getFee() {
  return 0.12;
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
  final response = await sendPOST(body, 'user/getEmployeePosition/');
  final Map<String, dynamic> choosen = jsonDecode(response.body);
  return choosen['position'];
}

Future<List<Gutschein>> getGutschein(int uID) async {
  final body = jsonEncode({'ownerID': uID});
  final response = await sendPOST(body, 'user/listCoupons/');
  final List<dynamic> jsonResponse = jsonDecode(response.body);
  final List<Gutschein> gutscheinList =
      jsonResponse.map((gutschein) => Gutschein.fromJson(gutschein)).toList();
  return gutscheinList;
}
