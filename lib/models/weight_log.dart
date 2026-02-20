/// A single weight log entry for tracking progress over time.
class WeightLog {
  final String id;
  final String userId;
  final double weight;
  final DateTime loggedAt;
  final String? note;

  WeightLog({
    required this.id,
    required this.userId,
    required this.weight,
    required this.loggedAt,
    this.note,
  });

  factory WeightLog.fromMap(Map<String, dynamic> map) {
    return WeightLog(
      id: map['id'],
      userId: map['user_id'],
      weight: (map['weight'] as num).toDouble(),
      loggedAt: DateTime.parse(map['logged_at']),
      note: map['note'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'weight': weight,
      'note': note,
    };
  }
}
