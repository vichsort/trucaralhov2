import 'package:flutter/material.dart';
import './logic/truco.dart';
import './components/cards.dart';
import './requests.dart';

void main() {
  runApp(MaterialApp(home: TrucoHomePage()));
}

late TrucoGame game;

class TrucoHomePage extends StatefulWidget {
  const TrucoHomePage({super.key});

  @override
  State<TrucoHomePage> createState() => _TrucoHomePageState();
}

class _TrucoHomePageState extends State<TrucoHomePage> {
  // Isso dá não inicializado toda hora, então inicializei aqui por que to nervoso
  TrucoGame game = TrucoGame();
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
      game = TrucoGame();
      // Aqui usamos o serviço para pegar as cartas
      List<String> validCards = await deckService.drawCards(
        15,
      ); // Pega 15 cartas

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
      game.iniciarRodada(
        validCards
            .map((url) => Carta(valor: 'A', naipe: Naipe.hearts, imageUrl: url))
            .toList(),
      );
    } catch (e) {
      // Tratamento de erro pra se der erro
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar cartas: $e'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        player1Cards = [];
        player2Cards = [];
        tableCard = [];
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void onCartaTapped(int index) {
    String cartaJogada = player1Cards[index];

    // Adiciona a carta à mesa
    setState(() {
      tableCard.add(cartaJogada);
      player1Cards.removeAt(index);
    });

    game.onCartaTapped(index);
    _opponentPlay();
  }

  Future<void> _opponentPlay() async {
    if (player2Cards.isEmpty) return;

    await Future.delayed(const Duration(seconds: 1)); // Simula tempo do bot

    setState(() {
      // Remove a primeira carta da mão do oponente
      String cartaJogada = player2Cards.removeAt(0);

      // Adiciona a carta jogada na mesa (onde mostramos a frente)
      tableCard.add(cartaJogada);
    });

    // Atualiza a lógica do jogo
    game.jogarCarta(0, false);
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
            'Cartas na MesaA',
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
              children: tableCard.map((imageUrl) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: buildTableCard(imageUrl),
                );
              }).toList(),
            ),
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
              children: player1Cards.asMap().entries.map((entry) {
                int index = entry.key;
                String imageUrl = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: buildCardFront(
                    imageUrl,
                    index,
                    onCartaTapped, // Passa a função de callback
                  ),
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
