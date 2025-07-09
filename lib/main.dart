import 'package:flutter/material.dart';
import './logic/truco.dart';
import './components/cards.dart';
import './requests.dart'; // Importando a camada de serviço

late TrucoGame game;

class TrucoHomePage extends StatefulWidget {
  const TrucoHomePage({super.key});

  @override
  State<TrucoHomePage> createState() => _TrucoHomePageState();
}

class _TrucoHomePageState extends State<TrucoHomePage> {
  // Carta da mesa (visível para ambos os jogadores)
  List<String> tableCard = [];
  // Cartas do Jogador 1 (você - visíveis)
  List<String> player1Cards = [];

  // Cartas do Jogador 2 (oponente - ocultas, só sabemos quantas são)
  List<String> player2Cards = [];
  int player2CardCount = 0;

  bool isLoading = false;

  // Instancia o serviço de cartas
  final DeckService deckService = DeckService();

  @override
  void initState() {
    super.initState();
    startGame();
  }

  Future<void> startGame() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Aqui usamos o serviço para pegar as cartas
      List<String> validCards = await deckService.drawCards(15); // Pega 15 cartas

      setState(() {
        if (validCards.length >= 6) {
          tableCard = validCards.take(1).toList();
          player1Cards = validCards.skip(1).take(3).toList();
          player2Cards = validCards.skip(4).take(3).toList();
        } else {
          player1Cards = validCards.take(3).toList();
          player2Cards = validCards.skip(3).toList();
        }
      });
    } catch (e) {
      debugPrint('Erro ao iniciar o jogo: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/fundo.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: ListView(
          children: [
            // Área do Jogador 2 (Oponente) - Cartas Ocultas
            buildPlayer2Area(),

            // Área da Mesa - Carta Visível
            buildTableCardArea(),

            // Área do Jogador 1 (Você) - Cartas Visíveis
            buildPlayer1Area(),
          ],
        ),
      ),
    );
  }

  Widget buildPlayer2Area() {
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
              children: player2Cards.map((imageUrl) {
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

  Widget buildTableCardArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Carta na Mesa',
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
            buildCardFront(tableCard.first)
        ],
      ),
    );
  }

  Widget buildPlayer1Area() {
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
              children: player1Cards.map((imageUrl) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: buildCardFront(imageUrl),
                );
              }).toList(),
            )
          else
            const Text('Nenhuma carta disponível'),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: isLoading ? null : () => startGame(),
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
}
