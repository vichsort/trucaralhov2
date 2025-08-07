import 'package:flutter/material.dart';
import 'package:trucaralho/screens/counting games/counter_truco.dart';
import 'package:trucaralho/screens/counting games/blackjack.dart';
import 'package:trucaralho/screens/counting games/poker.dart';
import 'package:trucaralho/screens/counting games/fodinha.dart';

class CounterHomePage extends StatelessWidget {
  const CounterHomePage({super.key});

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
          child: Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: [
              GameCard(
                label: 'Jogos',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CounterTrucoPage()),
                ),
              ),
              GameCard(
                label: 'BlackJack',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BlackJackPage()),
                ),
              ),
              GameCard(
                label: 'Poker',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PokerPage()),
                ),
              ),
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
