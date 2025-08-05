import 'package:flutter/material.dart';
import '../logic/truco.dart';
import '../components/player_area.dart';
import '../requests.dart';

class TrucoPage extends StatefulWidget {
  const TrucoPage({super.key});

  @override
  State<TrucoPage> createState() => _TrucoPageState();
}

class _TrucoPageState extends State<TrucoPage> {
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

  void onCartaTapped(int index) {
    if (index < 0 || index >= player1Cards.length) return;
    final cartaJogada = player1Cards[index];

    setState(() {
      tableCards.add(cartaJogada);
      player1Cards.removeAt(index);
    });

    // Atualiza lógica
    game.throwCard(cartaJogada, isJogador1: true);

    // Bot joga
    _opponentPlay();
  }

  void verifyEmpty() {
    if (player1Cards.isEmpty && player2Cards.isEmpty) {
      // Reinicia o jogo
      startGame();
    }
  }

  Future<void> _opponentPlay() async {
    if (player2Cards.isEmpty) return;

    await Future.delayed(const Duration(seconds: 1)); // simula pensar

    final cartaJogada = player2Cards.removeAt(0);

    setState(() {
      tableCards.add(cartaJogada);
    });

    game.throwCard(cartaJogada, isJogador1: false);
    verifyEmpty();
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
          tableCards = [cartas[0]]; // vira
          player1Cards = cartas.sublist(1, 4); // 3 cartas
          player2Cards = cartas.sublist(4, 7); // 3 cartas
        } else {
          // fallback defensivo
          player1Cards = cartas.take(3).toList();
          player2Cards = cartas.skip(3).take(3).toList();
          tableCards = [];
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao carregar cartas: $e')));
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
            buildPlayer2Area(player2Cards, isLoading),
            buildTableCardArea(tableCards, isLoading),
            buildPlayer1Area(player1Cards, isLoading, onCartaTapped, startGame),
          ],
        ),
      ),
    );
  }
}
