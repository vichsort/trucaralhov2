import 'package:flutter/material.dart';

List<Map<String, dynamic>> gameHistory = [];
int roundNumber = 1;

int pot = 0;
int leftValue = 0;
int rightValue = 0;

// Adicionar ação ao histórico
void addToHistory(
  String action,
  String game,
  String player, {
  int? amount,
  String? details,
}) {
  gameHistory.add({
    'round': roundNumber,
    'timestamp': DateTime.now(),
    'action': action,
    'player': player,
    'game': game,
    'amount': amount,
    'details': details,
    'potAfter': pot,
    'leftValueAfter': leftValue,
    'rightValueAfter': rightValue,
  });
}

void showGameHistory(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => StatefulBuilder(
      builder: (_, setState) => Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Icon(Icons.history, color: Colors.white, size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Histórico da Partida',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Stats resumo
            Container(
              padding: EdgeInsets.all(16),
              color: Colors.grey[850],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        'Rodada Atual',
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                      Text(
                        '$roundNumber',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        'Total de Ações',
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                      Text(
                        '${gameHistory.length}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        'Pot Atual',
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                      Text(
                        '\$${pot}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Lista do histórico
            Expanded(
              child: gameHistory.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history,
                            size: 64,
                            color: Colors.grey[600],
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Nenhuma ação ainda',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[400],
                            ),
                          ),
                          Text(
                            'Faça sua primeira jogada!',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: gameHistory.length,
                      reverse: true, // Mostrar mais recente primeiro
                      itemBuilder: (context, index) {
                        final historyIndex = gameHistory.length - 1 - index;
                        final entry = gameHistory[historyIndex];
                        return historyTile(entry, historyIndex);
                      },
                    ),
            ),

            // Footer com botões
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                border: Border(top: BorderSide(color: Colors.grey[700]!)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => clearHistory(context),
                      icon: Icon(Icons.delete_sweep),
                      label: Text('Limpar Histórico'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[700],
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.check),
                      label: Text('Fechar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void clearHistory(BuildContext context) {
  gameHistory.clear();
  Navigator.pop(context);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Histórico limpo com sucesso!'),
      backgroundColor: Colors.green,
    ),
  );
}

Widget historyTile(Map<String, dynamic> entry, int index) {
  String actionText = entry['action'];
  String playerName = entry['player'];
  String game = entry['game'];
  int? amount = entry['amount'];
  String? details = entry['details'];
  DateTime timestamp = entry['timestamp'];

  Color actionColor = Colors.white;
  IconData actionIcon = Icons.circle;

  switch (actionText.toUpperCase()) {
    case 'CALL':
      actionColor = Colors.green;
      actionIcon = Icons.add_circle;
      break;
    case 'CHECK':
      actionColor = Colors.blue;
      actionIcon = Icons.check_circle;
      break;
    case 'RAISE' || 'TRUCOU':
      actionColor = Colors.orange;
      actionIcon = Icons.trending_up;
      break;
    case 'FOLD' || 'CORREU' || 'PASSOU' || 'ESTOUROU':
      actionColor = Colors.red;
      actionIcon = Icons.cancel;
      break;
    case 'ALL IN':
      actionColor = Colors.purple;
      actionIcon = Icons.all_inclusive;
      break;
    case 'ACCEPT':
      actionColor = Colors.teal;
      actionIcon = Icons.thumb_up;
      break;
    case 'WIN':
      actionColor = Colors.amber;
      actionIcon = Icons.emoji_events;
      break;
  }

  Color gameColor = Colors.white;

  switch (game.toUpperCase()) {
    case 'TRUCO':
      gameColor = Colors.deepPurple;
      break;
    case 'BLACKJACK':
      gameColor = Colors.red;
      break;
    case 'FODINHA':
      gameColor = Colors.blue;
      break;
    case 'POKER':
      gameColor = Colors.orange;
      break;
  }

  return Container(
    margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.grey[800],
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey[700]!),
    ),
    child: ListTile(
      leading: CircleAvatar(
        backgroundColor: actionColor.withValues(alpha: 0.2),
        child: Icon(actionIcon, color: actionColor, size: 20),
      ),
      title: Row(
        children: [
          Text(
            playerName,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(width: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: actionColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              actionText,
              style: TextStyle(
                color: actionColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: gameColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              game,
              style: TextStyle(
                color: gameColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          if (amount != null) ...[
            SizedBox(width: 8),
            Text(
              '\$${amount}',
              style: TextStyle(
                color: Colors.green[300],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (details != null)
            Text(
              details,
              style: TextStyle(color: Colors.grey[400], fontSize: 13),
            ),
          SizedBox(height: 4),
          Row(
            children: [
              Text(
                'Rodada ${entry['round']}',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
              SizedBox(width: 12),
              Text(
                '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
              SizedBox(width: 12),
              Text(
                'Pot: \$${entry['potAfter']}',
                style: TextStyle(color: Colors.green[400], fontSize: 12),
              ),
            ],
          ),
        ],
      ),
      dense: true,
    ),
  );
}
