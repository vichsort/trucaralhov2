import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const TrucoApp());
}

class TrucoApp extends StatelessWidget {
  const TrucoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Truco Demo',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const TrucoHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TrucoHomePage extends StatefulWidget {
  const TrucoHomePage({super.key});

  @override
  State<TrucoHomePage> createState() => _TrucoHomePageState();
}

class _TrucoHomePageState extends State<TrucoHomePage> {
  // Cartas do Jogador 1 (você - visíveis)
  List<String> player1Cards = [];

  // Cartas do Jogador 2 (oponente - ocultas, só sabemos quantas são)
  List<String> player2Cards = [];
  int player2CardCount = 0;

  String deckId = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    startGame();
  }

  Future<void> getNewDeck() async {
    debugPrint('Obtendo novo baralho...');
    final url = Uri.parse(
      'https://deckofcardsapi.com/api/deck/new/shuffle/?deck_count=1',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      deckId = data['deck_id'];
      debugPrint('Novo baralho obtido: $deckId');
    }
  }

  Future<void> drawCards(int count) async {
    debugPrint('chamado drawCards com count: $count');

    if (deckId.isEmpty) {
      await getNewDeck();
    }

    final url = Uri.parse(
      'https://deckofcardsapi.com/api/deck/$deckId/draw/?count=$count',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final cards = data['cards'];

      final trucoValid = [
        'ACE',
        '2',
        '3',
        '4',
        '5',
        '6',
        '7',
        'JACK',
        'QUEEN',
        'KING',
      ];

      final validCards = cards
          .where((card) => trucoValid.contains(card['value']))
          .map<String>((card) => card['image'] as String)
          .toList();

      setState(() {
        // Divide as cartas entre os dois jogadores
        if (validCards.length >= 6) {
          // Jogador 1 (você) recebe as 3 primeiras cartas (visíveis)
          player1Cards = validCards.take(3).toList();

          // Jogador 2 (oponente) recebe as próximas 3 cartas (ocultas)
          player2Cards = validCards.skip(3).take(3).toList();
          player2CardCount = player2Cards.length;
        } else {
          // Caso não tenha cartas suficientes, distribui o que tiver
          player1Cards = validCards.take(3).toList();
          player2Cards = validCards.skip(3).toList();
          player2CardCount = player2Cards.length;
        }
      });
    }

    debugPrint('Jogador 1 cartas: $player1Cards');
    debugPrint('Jogador 2 cartas: ${player2Cards}');
  }

  Future<void> startGame() async {
    debugPrint('Iniciando o jogo...');

    setState(() {
      isLoading = true;
    });

    try {
      await getNewDeck();
      await drawCards(
        12,
      ); // Pega mais cartas para ter certeza que terá 6 válidas
    } catch (e) {
      debugPrint('Erro ao iniciar jogo: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Widget para criar uma carta com verso (caixa preta)
  Widget buildCardBack() {
    return Container(
      width: 80,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.red[900],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.casino, color: Colors.white, size: 30),
            SizedBox(height: 4),
            Text(
              'TRUCO',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para criar uma carta com imagem
  Widget buildCardFront(String imageUrl) {
    return Container(
      width: 80,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
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
        child: Column(
            children: [
              // Área do Jogador 2 (Oponente) - Cartas Ocultas
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Jogador 2 (Oponente)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red[800],
                        ),
                      ),
                      const SizedBox(height: 20),

                      if (isLoading)
                        const CircularProgressIndicator()
                      else
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(player2CardCount, (index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: buildCardBack(),
                            );
                          }),
                        ),
                    ],
                  ),
                ),
              ),

              // Divisória visual
              Container(
                height: 4,
                color: Colors.green[800],
                margin: const EdgeInsets.symmetric(horizontal: 20),
              ),

              // Área do Jogador 1 (Você) - Cartas Visíveis
              Expanded(
                child: Container(
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: Text(
                          isLoading
                              ? 'Distribuindo...'
                              : 'Distribuir Novas Cartas',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
      ),
    );
  }
}
