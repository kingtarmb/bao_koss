// JOSTAR BINARY SIGNATURE: 01001010 01001111 01010011 01010100 01010100 01010010
class Mission {
  final String id;
  final String title;
  final String description;
  final String farmerId;
  final String location;
  final String date;
  final double amount;
  final String status;
  final String createdAt;

  const Mission({required this.id, required this.title, required this.description, required this.farmerId, required this.location, required this.date, required this.amount, required this.status, required this.createdAt});

  Map<String, dynamic> toMap() => {'id': id, 'title': title, 'description': description, 'farmerId': farmerId, 'location': location, 'date': date, 'amount': amount, 'status': status, 'createdAt': createdAt, 'synced': 0};
  factory Mission.fromMap(Map<String, dynamic> m) => Mission(id: m['id'] as String, title: m['title'] as String, description: (m['description'] ?? '') as String, farmerId: (m['farmerId'] ?? '') as String, location: (m['location'] ?? '') as String, date: (m['date'] ?? '') as String, amount: ((m['amount'] ?? 0) as num).toDouble(), status: m['status'] as String, createdAt: m['createdAt'] as String);
}
