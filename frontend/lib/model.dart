class User {
  final String name;
  final String id;
  final int position;

  User({
    required this.id,
    required this.name,
    required this.position,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['uname'],
      id: json['uid'],
      position: json['pos'],
    );
  }
}

class TicketType {
  final String name;
  final int maxAmount;
  final int availAmount;
  final double basePrice;
  final double extraPrice;

  TicketType({
    required this.name,
    required this.maxAmount,
    required this.availAmount,
    required this.basePrice,
    required this.extraPrice,
  });

  factory TicketType.fromJson(Map<String, dynamic> json) {
    return TicketType(
      name: json['username'],
      maxAmount: json['maxAmount'],
      availAmount: json['availAmount'],
      basePrice: json['basePrice'],
      extraPrice: json['extraPrice'],
    );
  }
}

class Event {
  final String title;
  final int max_tickets;
  final int bought_tickets;
  final int threshold_tickets;
  final double base_price;
  final DateTime date;

  Event({
    required this.title,
    required this.max_tickets,
    required this.bought_tickets,
    required this.threshold_tickets,
    required this.base_price,
    required this.date,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      title: json['title'],
      max_tickets: json['max_tickets'],
      bought_tickets: json['bought_tickets'],
      date: DateTime.parse(json['date']),
      threshold_tickets: json['threshold_tickets'],
      base_price: double.parse(json['base_price'].toString()),
    );
  }
}

class Gutschein {
  final int id;
  final double amount;

  Gutschein({
    required this.id,
    required this.amount,
  });

  factory Gutschein.fromJson(Map<String, dynamic> json) {
    return Gutschein(
      id: json['username'],
      amount: json['participant_id'],
    );
  }
}
