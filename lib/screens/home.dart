import 'package:flutter/material.dart';
import './truco.dart';
import './counter_truco.dart';
import './blackjack.dart';
import './poker.dart';
import './fodinha.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/fundo.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GameCard(
                label: 'Jogos',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TrucoPage()),
                ),
              ),
              const SizedBox(width: 20),
              GameCard(
                label: 'Contador de truco',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CounterTrucoPage()),
                ),
              ),
              const SizedBox(width: 20),
              GameCard(
                label: 'BlackJack',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BlackJackPage()),
                ),
              ),
              const SizedBox(width: 20),
              GameCard(
                label: 'Poker',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PokerPage()),
                ),
              ),
              const SizedBox(width: 20),
              GameCard(
                label: 'Fodinha',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FodinhaPage()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GameCard extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const GameCard({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('images/carta-avesso.png', width: 100, height: 150),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(color: Colors.black, blurRadius: 4)],
            ),
          ),
        ],
      ),
    );
  }
}
