import 'package:flutter/material.dart';
import './logic/truco.dart';        // Carta, TrucoGame, etc.
import './components/cards.dart';  // buildCardFront/back/tableCard widgets
import './requests.dart';          // DeckService

void main() {
  runApp(const MaterialApp(home: TrucoHomePage()));
}

class TrucoHomePage extends StatefulWidget {
  const TrucoHomePage({super.key});

  @override
  State<TrucoHomePage> createState() => _TrucoHomePageState();
}

class _TrucoHomePageState extends State<TrucoHomePage> {
  /// Estado do jogo lógico
  TrucoGame game = TrucoGame();

  /// Cartas visíveis na mesa (tanto vira quanto cartas jogadas)
  List<Carta> tableCards = [];

  /// Cartas do Jogador 1 (você)
  List<Carta> player1Cards = [];

  /// Cartas do Jogador 2 (oponente) - guardamos as cartas completas, mas exibimos viradas
  List<Carta> player2Cards = [];

  bool isLoading = false;

  /// Serviço remoto
  final DeckService deckService = DeckService();

  @override
  void initState() {
    super.initState();
    startGame();
  }

  Future<void> startGame() async {
    setState(() => isLoading = true);

    try {
      // Reinicia lógica
      game = TrucoGame();

      // Busca cartas da API (List<Map<String,dynamic>>)
      final apiCards = await deckService.drawCards(15);

      // Converte para modelo interno (List<Carta>)
      final cartas = apiCards.map((card) => Carta.fromApi(card)).toList();

      // Inicializa rodada na lógica
      game.iniciarRodada(cartas);

      // Sincroniza estado visual
      setState(() {
        if (cartas.length >= 7) {
          tableCards = [cartas[0]];             // vira
          player1Cards = cartas.sublist(1, 4);  // 3 cartas
          player2Cards = cartas.sublist(4, 7);  // 3 cartas
        } else {
          // fallback defensivo
          player1Cards = cartas.take(3).toList();
          player2Cards = cartas.skip(3).take(3).toList();
          tableCards = [];
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar cartas: $e')),
        );
      }
      setState(() {
        player1Cards = [];
        player2Cards = [];
        tableCards = [];
      });
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  /// Jogador 1 toca numa carta
  void onCartaTapped(int index) {
    if (index < 0 || index >= player1Cards.length) return;
    final cartaJogada = player1Cards[index];

    setState(() {
      tableCards.add(cartaJogada);
      player1Cards.removeAt(index);
    });

    // Atualiza lógica
    game.jogarCartaObjeto(cartaJogada, isJogador1: true);

    // Bot joga
    _opponentPlay();
  }

  /// Jogada automática do oponente
  Future<void> _opponentPlay() async {
    if (player2Cards.isEmpty) return;

    await Future.delayed(const Duration(seconds: 1)); // simula pensar

    final cartaJogada = player2Cards.removeAt(0);

    setState(() {
      tableCards.add(cartaJogada);
    });

    game.jogarCartaObjeto(cartaJogada, isJogador1: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/fundo.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: ListView(
          children: [
            buildPlayer2Area(),
            buildTableCardArea(),
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

  Widget buildTableCardArea() {
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
                final index = entry.key;
                final carta = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: buildCardFront(
                    carta.imageUrl,
                    index,
                    onCartaTapped,
                  ),
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
}
