import 'package:flutter/material.dart';
import './cards.dart';

Widget buildPlayer1Area(
  List player1Cards,
  bool isLoading,
  void Function(int) onCartaTapped,
  VoidCallback startGame,
) {
  return Container(
    padding: const EdgeInsets.all(16),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Suas Cartas (Jogador 1)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue[800],
          ),
        ),
        const SizedBox(height: 20),
        if (isLoading)
          const CircularProgressIndicator()
        else if (player1Cards.isNotEmpty)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: player1Cards.asMap().entries.map((entry) {
              final index = entry.key;
              final carta = entry.value;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: buildCardFront(carta.imageUrl, index, onCartaTapped),
              );
            }).toList(),
          )
        else
          const Text('Nenhuma carta disponível'),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: isLoading ? null : startGame,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[700],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Text(
            isLoading ? 'Distribuindo...' : 'Distribuir Novas Cartas',
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    ),
  );
}

Widget buildPlayer2Area(List player2Cards, bool isLoading) {
  return Container(
    padding: const EdgeInsets.all(16),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Cartas do Oponente (Jogador 2)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue[800],
          ),
        ),
        const SizedBox(height: 20),
        if (isLoading)
          const CircularProgressIndicator()
        else if (player2Cards.isNotEmpty)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: player2Cards.map((_) {
              // carta virada
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: buildCardBack(),
              );
            }).toList(),
          )
        else
          const Text('Nenhuma carta disponível'),
      ],
    ),
  );
}

Widget buildTableCardArea(List tableCards, bool isLoading) {
  return Container(
    padding: const EdgeInsets.all(16),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Cartas na Mesa',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.orange[800],
          ),
        ),
        const SizedBox(height: 20),
        if (isLoading)
          const CircularProgressIndicator()
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: tableCards.map((carta) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: buildTableCard(carta.imageUrl),
              );
            }).toList(),
          ),
      ],
    ),
  );
}
