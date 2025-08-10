import 'package:flutter/material.dart';
import 'package:trucaralho/logic/truco.dart';
import 'package:trucaralho/components/player_area.dart';
import 'package:trucaralho/components/animated_card.dart';
import 'package:trucaralho/requests.dart';

class TrucoPage extends StatefulWidget {
  const TrucoPage({super.key});

  @override
  State<TrucoPage> createState() => _TrucoPageState();
}

class _TrucoPageState extends State<TrucoPage> {
  late TrucoGame game;

  List<Carta> tableCards = [];
  List<Carta> p1Cards = [];
  List<Carta> p2Cards = [];

  bool isLoading = false;
  bool isLocked = false;

  Carta? animatingCard;
  Offset cardStart = Offset.zero;
  Offset cardEnd = Offset.zero;
  List<GlobalKey> p1CardKeys = [];
  List<GlobalKey> p2CardKeys = [];
  bool get isMyTurn => game.vez == Player.p1 && !isLocked;

  final DeckService deckService = DeckService();

  @override
  void initState() {
    super.initState();
    game = TrucoGame();
    startGame(novaPartida: true);
  }

  void onCardTapped(int index) async {
    if (!isMyTurn || isLocked) return;
    if (index < 0 || index >= p1Cards.length) return;

    final playedCard = p1Cards[index];
    final key = p1CardKeys[index];

    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final startOffset = renderBox.localToGlobal(Offset.zero);
    final screenSize = MediaQuery.of(context).size;
    final endOffset = Offset(
      screenSize.width / 2 - 30,
      screenSize.height / 2 - 50,
    );

    setState(() {
      animatingCard = playedCard;
      cardStart = startOffset;
      cardEnd = endOffset;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      p1Cards.removeAt(index);
      p1CardKeys.removeAt(index);
      tableCards.add(playedCard);
      animatingCard = null;
    });

    game.throwCard(playedCard, isJogador1: true);
    await _checkEndOfTrick();
    verifyEmpty();
    nextTurn();
  }

  Future<void> _checkEndOfTrick() async {
    if (game.mesa[0] != null && game.mesa[1] != null) {
      setState(() => isLocked = true);
      // Espera 5 segundos para avaliar as cartas antes de limpar
      await Future.delayed(const Duration(seconds: 5));
      setState(() {
        tableCards.clear();
        game.mesa = [null, null];
        isLocked = false;
      });
    }
  }

  void nextTurn() async {
    while (!isMyTurn) {
      await Future.delayed(const Duration(seconds: 1)); // "pensa" antes de agir

      // Oponente decide pedir truco aleatoriamente e progressivamente
      if (game.decidirPedirTruco()) {
        bool aceitou = await _mostrarDialogoTruco();
        if (!aceitou) {
          int gainedPoints = game.roundValue;
          game.pontosTime2 += gainedPoints;
          setState(() {
            game.lastResult =
                "Você correu! Oponente ganhou +$gainedPoints ponto(s)!";
          });
          await Future.delayed(const Duration(seconds: 1));
          startGame();
          return;
        } else {
          game.acceptTruco();
          setState(() {});
        }
      }

      await _opponentPlay();
      await Future.delayed(const Duration(milliseconds: 300));
    }
  }

  Future<bool> _mostrarDialogoTruco() async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(
              "Oponente pediu ${_textoBotaoTruco()}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            content: const Text("Você aceita?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Correr"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Aceitar"),
              ),
            ],
          ),
        ) ??
        false;
  }

  void verifyEmpty() {
    if (p1Cards.isEmpty && p2Cards.isEmpty) {
      startGame();
    }
  }

  Future<List<Carta>> callCards() async {
    final apiCards = await deckService.drawCards(15);
    return apiCards.map<Carta>((card) => Carta.fromApi(card)).toList();
  }

  Future<void> _opponentPlay() async {
    if (p2Cards.isEmpty || game.vez != Player.p2 || isLocked) return;
    await Future.delayed(const Duration(seconds: 1)); // pensa 1 segundo
    final playedCard = p2Cards.removeAt(0);
    setState(() => tableCards.add(playedCard));
    game.throwCard(playedCard, isJogador1: false);
    await _checkEndOfTrick();
    verifyEmpty();
  }

  Future<void> startGame({bool novaPartida = false}) async {
    setState(() => isLoading = true);
    try {
      final cards = await callCards();
      game.startRound(cards, novaPartida: novaPartida);
      setState(() {
        tableCards = [cards[0]];
        p1Cards = cards.sublist(1, 4);
        p2Cards = cards.sublist(4, 7);
        p1CardKeys = List.generate(p1Cards.length, (_) => GlobalKey());
        p2CardKeys = List.generate(p2Cards.length, (_) => GlobalKey());
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
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _pedirTruco() async {
    game.pedirTruco(true);

    await Future.delayed(const Duration(seconds: 1));

    bool aceitou = game.avaliaracceptTruco();

    if (!aceitou) {
      game.pontosTime1 += game.roundValue;
      setState(() {
        game.lastResult =
            "Oponente correu! Você ganhou +${game.roundValue} ponto(s)!";
      });
      await Future.delayed(const Duration(seconds: 1));
      startGame();
    } else {
      setState(() {
        game.lastResult = "Oponente aceitou!";
      });
      await Future.delayed(const Duration(milliseconds: 500));
      nextTurn();
    }
  }

  String _textoBotaoTruco() {
    switch (game.roundValue) {
      case 1:
        return "TRUCO!";
      case 3:
        return "SEIS!";
      case 6:
        return "NOVE!";
      case 9:
        return "DOZE!";
      default:
        return "TRUCO!";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Truco'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => startGame(novaPartida: true),
          ),
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
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Nós: ${game.pontosTime1}",
                      style: const TextStyle(fontSize: 20, color: Colors.white),
                    ),
                    const SizedBox(width: 20),
                    Text(
                      "Eles: ${game.pontosTime2}",
                      style: const TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  "Rodada ${game.rodadaAtual} - Valor: ${game.roundValue}",
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
                const SizedBox(height: 5),
                if (game.lastResult.isNotEmpty)
                  Text(
                    game.lastResult,
                    style: const TextStyle(fontSize: 16, color: Colors.yellow),
                  ),
                buildPlayer2Area(p2Cards, isLoading, p2CardKeys),
                const Spacer(),
                buildTableCardArea(tableCards, isLoading),
                const Spacer(),
                buildPlayer1Area(
                  p1Cards,
                  isLoading,
                  onCardTapped,
                  startGame,
                  p1CardKeys,
                  isMyTurn,
                ),
                ElevatedButton(
                  onPressed: isMyTurn ? _pedirTruco : null,
                  child: Text(_textoBotaoTruco()),
                ),
              ],
            ),
          ),
          if (animatingCard != null)
            AnimatedCard(card: animatingCard!, start: cardStart, end: cardEnd),
        ],
      ),
    );
  }
}
