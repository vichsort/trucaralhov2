class HistoryModel {
  final int round;
  final String action;
  final String player;
  final String game;
  final int potAfter;
  final int leftValueAfter;
  final int rightValueAfter;
  final int? amount;
  final String? details;
  final DateTime timestamp;

  HistoryModel({
    required this.round,
    required this.action,
    required this.player,
    required this.game,
    required this.potAfter,
    required this.leftValueAfter,
    required this.rightValueAfter,
    this.amount,
    this.details,
    required this.timestamp,
  });

  // Método para converter para Map
  Map<String, dynamic> toMap() {
    return {
      'round': round,
      'timestamp': timestamp.toIso8601String(),
      'action': action,
      'player': player,
      'game': game,
      'amount': amount,
      'details': details,
      'potAfter': potAfter,
      'leftValueAfter': leftValueAfter,
      'rightValueAfter': rightValueAfter,
    };
  }

  // Método para converter de Map para Objeto
  factory HistoryModel.fromMap(Map<String, dynamic> map) {
    return HistoryModel(
      round: map['round'],
      action: map['action'],
      player: map['player'],
      game: map['game'],
      potAfter: map['potAfter'],
      leftValueAfter: map['leftValueAfter'],
      rightValueAfter: map['rightValueAfter'],
      amount: map['amount'],
      details: map['details'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
