import 'package:flutter/material.dart';
import '../logic/truco.dart';
import '../components/player_area.dart';
import '../components/animated_card.dart';
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
  List<Carta> p1Cards = [];

  /// Cartas do Jogador 2 (oponente) - guardamos as cartas completas, mas exibimos viradas
  List<Carta> p2Cards = [];

  bool isLoading = false;

  Carta? animatingCard;
  Offset cardStart = Offset.zero;
  Offset cardEnd = Offset.zero;
  List<GlobalKey> cardKeys = [];

  /// Serviço remoto
  final DeckService deckService = DeckService();

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void onCardTapped(int index) async {
    if (index < 0 || index >= p1Cards.length) return;

    final playedCard = p1Cards[index];
    final key = cardKeys[index];

    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final startOffset = renderBox.localToGlobal(Offset.zero);

    final screenSize = MediaQuery.of(context).size;
    final endOffset = Offset(
      screenSize.width / 2 - 30,
      screenSize.height / 2 - 50,
    ); // centralize

    setState(() {
      animatingCard = playedCard;
      cardStart = startOffset;
      cardEnd = endOffset;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      p1Cards.removeAt(index);
      cardKeys.removeAt(index);
      tableCards.add(playedCard);
      animatingCard = null;
    });

    game.throwCard(playedCard, isJogador1: true);

    await _opponentPlay();
  }

  void verifyEmpty() {
    if (p1Cards.isEmpty && p2Cards.isEmpty) {
      // Reinicia o jogo
      callCards();
      startGame();
    }
  }

  Future<List<Carta>> callCards() async {
    // Busca cartas da API (List<Map<String,dynamic>>)
    final apiCards = await deckService.drawCards(15);

    // Converte para modelo interno (List<Carta>)
    final cards = apiCards.map<Carta>((card) => Carta.fromApi(card)).toList();
    return cards;
  }

  Future<void> _opponentPlay() async {
    if (p2Cards.isEmpty) return;

    await Future.delayed(const Duration(seconds: 1)); // simula pensar

    final playedCard = p2Cards.removeAt(0);

    setState(() {
      tableCards.add(playedCard);
    });

    game.throwCard(playedCard, isJogador1: false);
    verifyEmpty();
  }

  Future<void> startGame() async {
    setState(() => isLoading = true);

    try {
      // Reinicia lógica
      game = TrucoGame();

      final cards = await callCards();

      // Inicializa rodada na lógica
      game.startRound(cards);

      // Sincroniza estado visual
      setState(() {
        if (cards.length >= 7) {
          tableCards = [cards[0]];
          p1Cards = cards.sublist(1, 4);
          p2Cards = cards.sublist(4, 7);
        } else {
          p1Cards = cards.take(3).toList();
          p2Cards = cards.skip(3).take(3).toList();
          tableCards = [];
        }
        cardKeys = List.generate(p1Cards.length, (_) => GlobalKey());
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao carregar cartas: $e')));
      }
      setState(() {
        p1Cards = [];
        p2Cards = [];
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
      appBar: AppBar(
        title: const Text('Truco'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: startGame),
        ],
      ),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/fundo.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              children: [
                buildPlayer2Area(p2Cards, isLoading),
                const Spacer(),
                buildTableCardArea(tableCards, isLoading),
                const Spacer(),
                buildPlayer1Area(
                  p1Cards,
                  isLoading,
                  onCardTapped,
                  startGame,
                  cardKeys,
                ),
              ],
            ),
          ),

          // Carta sendo animada
          if (animatingCard != null)
            AnimatedCard(card: animatingCard!, start: cardStart, end: cardEnd),
        ],
      ),
    );
  }
}
