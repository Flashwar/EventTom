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
      maxAmount: json['participant_id'],
      availAmount: json['username'],
      basePrice: json['participant_id'],
      extraPrice: json['participant_id'],
    );
  }
}

class Event {
  final String name;
  final List<TicketType> tickets;
  final DateTime time;

  Event({
    required this.name,
    required this.tickets,
    required this.time,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      name: json['username'],
      tickets: json['participant_id'],
      time: json['time'],
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
