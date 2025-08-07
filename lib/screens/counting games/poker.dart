import 'package:flutter/material.dart';
import 'package:trucaralho/components/player_area.dart';
import 'package:trucaralho/logic/bet.dart';
import 'package:trucaralho/logic/chip.dart';
import 'package:trucaralho/logic/historico.dart';
import 'package:trucaralho/logic/how_to.dart';

class PokerPage extends StatefulWidget {
  const PokerPage({super.key});

  @override
  State<PokerPage> createState() => _PokerPageState();
}

class _PokerPageState extends State<PokerPage> {
  int leftInTable = 0;
  int rightInTable = 0;
  int leftWins = 0;
  int rightWins = 0;
  int leftValue = 1000;
  int rightValue = 1000;
  bool actionDetect = false;
  bool showWinAnimation = false;
  int pot = 0;
  int currentBet = 0;
  String gamePhase = 'betting';
  String lastAction = '';

  void showAnimation() {
    setState(() => showWinAnimation = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => showWinAnimation = false);
    });
  }

  Future<void> _modalCall(BuildContext context, String side) async {
    await showModalBottomSheet(
      context: context,
      builder: (_) {
        return pokerCall(
          (int betAmount) => handleCall(side, betAmount),
          side,
          leftValue,
          rightValue,
        );
      },
    );
  }

  void handleCall(String side, int amount) {
    setState(() {
      if (side == 'left') {
        leftValue -= amount;
        leftInTable = amount;
      } else {
        rightValue -= amount;
        rightInTable = amount;
      }
      pot += amount;
      currentBet = amount;
      gamePhase = 'called';
      lastAction =
          '${side == 'left' ? 'Convidado' : 'Casa'} fez CALL de \$$amount';
      actionDetect = true;
    });

    // Adicionar ao histórico
    addToHistory(
      'CALL',
      'Poker',
      side == 'left' ? 'Convidado' : 'Casa',
      amount: amount,
      details: 'Aposta inicial de \$$amount',
    );

    Navigator.pop(context);
  }

  // CHECK - Seguir a aposta
  void _check(String side) {
    if (currentBet == 0) {
      // Se não há aposta na mesa, CHECK é gratuito
      setState(() {
        lastAction = '${side == 'left' ? 'Convidado' : 'Casa'} fez CHECK';
        gamePhase = 'checked';
      });
    } else {
      // Se há aposta na mesa, CHECK significa igualar a aposta
      int playerValue = side == 'left' ? leftValue : rightValue;
      if (playerValue >= currentBet) {
        setState(() {
          if (side == 'left') {
            leftValue -= currentBet;
            leftInTable = currentBet;
          } else {
            rightValue -= currentBet;
            rightInTable = currentBet;
          }
          pot += currentBet;
          lastAction =
              '${side == 'left' ? 'Convidado' : 'Casa'} fez CHECK ($currentBet)';
          gamePhase = 'showdown';
          actionDetect = true;
        });
      }
    }
  }

  Future<void> _confirmFold(String side) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar FOLD'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Você tem certeza que quer dar FOLD?'),
                SizedBox(height: 10),
                Text(
                  'Isso significa que você vai desistir e o oponente ganhará o pot de \${pot}.',
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Confirmar FOLD',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _fold(side);
              },
            ),
          ],
        );
      },
    );
  }

  void _fold(String side) {
    String winner = side == 'left' ? 'right' : 'left';
    setState(() {
      lastAction = '${side == 'left' ? 'Convidado' : 'Casa'} deu FOLD';
    });

    // Adicionar ao histórico
    addToHistory(
      'FOLD',
      'Poker',
      side == 'left' ? 'Convidado' : 'Casa',
      details: 'Desistiu da rodada, perdendo \$$pot',
    );

    _win(winner);
  }

  // RAISE - Aumentar aposta
  Future<void> _modalRaise(BuildContext context, String side) async {
    await showModalBottomSheet(
      context: context,
      builder: (_) {
        return PokerRaise(
          (int raiseAmount) => handleRaise(side, raiseAmount),
          currentBet,
          side,
          leftValue,
          rightValue,
        );
      },
    );
  }

  void handleRaise(String side, int raiseAmount) {
    int totalBet = currentBet + raiseAmount;
    setState(() {
      if (side == 'left') {
        leftValue -= totalBet;
        leftInTable = totalBet;
      } else {
        rightValue -= totalBet;
        rightInTable = totalBet;
      }
      pot += totalBet;
      currentBet = totalBet;
      gamePhase = 'raised';
      lastAction =
          '${side == 'left' ? 'Convidado' : 'Casa'} fez RAISE para \$$totalBet';
      actionDetect = false;
    });
    Navigator.pop(context);

    addToHistory(
      'RAISE',
      'Poker',
      side == 'left' ? 'Convidado' : 'Casa',
      details:
          'Aumentou a aposta em \$${side == 'left' ? leftValue : rightValue}',
    );
  }

  Future<void> allInConfirm(String side) async {
    int playerValue = side == 'left' ? leftValue : rightValue;

    var chipsDisponiveis = chips
        .where((f) => f.valor * 10 <= playerValue)
        .toList();
    if (chipsDisponiveis.isEmpty) {
      return showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Saldo Insuficiente'),
          content: Text(
            'Você não tem saldo suficiente para fazer ALL IN com 10 chips.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }

    var fichaMaior = chipsDisponiveis.reduce(
      (a, b) => a.valor > b.valor ? a : b,
    );
    int allInAmount = fichaMaior.valor * 10;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar ALL IN'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Você tem certeza que quer dar ALL IN?'),
                SizedBox(height: 10),
                Text('Isso colocará 10 chips ${fichaMaior.nome}.'),
                Text('Equivalente a \$$allInAmount'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Confirmar ALL IN',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _allIn(side, allInAmount, fichaMaior.nome);
              },
            ),
          ],
        );
      },
    );
  }

  void _allIn(String side, int amount, String fichaName) {
    setState(() {
      if (side == 'left') {
        leftValue -= amount;
        leftInTable = amount;
      } else {
        rightValue -= amount;
        rightInTable = amount;
      }
      pot += amount;
      currentBet = amount;
      gamePhase = 'all_in';
      lastAction =
          '${side == 'left' ? 'Convidado' : 'Casa'} fez ALL IN: \$$amount (10x $fichaName)';

      addToHistory(
        'ALL IN',
        'Poker',
        side == 'left' ? 'Convidado' : 'Casa',
        details: 'Aumentou o valor em \$$amount',
      );
    });
  }

  void _accept(String side) {
    int opponentBet = side == 'left' ? rightInTable : leftInTable;
    int playerValue = side == 'left' ? leftValue : rightValue;

    if (playerValue >= opponentBet) {
      setState(() {
        if (side == 'left') {
          leftValue -= opponentBet;
          leftInTable = opponentBet;
        } else {
          rightValue -= opponentBet;
          rightInTable = opponentBet;
        }
        pot += opponentBet;
        lastAction =
            '${side == 'left' ? 'Convidado' : 'Casa'} aceitou a aposta';
        gamePhase = 'showdown';
        actionDetect = true;
      });

      addToHistory(
        'ACCEPT',
        'Poker',
        side == 'left' ? 'Convidado' : 'Casa',
        amount: opponentBet,
        details: 'Aceitou a aposta de \$$opponentBet',
      );
    }
  }

  void _win(String winner) {
    setState(() {
      if (winner == 'left') {
        leftValue += pot;
        leftWins++;
      } else {
        rightValue += pot;
        rightWins++;
      }
      addToHistory(
        'WIN',
        'Poker',
        winner == 'left' ? 'Convidado' : 'Casa',
        details:
            '${winner == 'left' ? ' O Convidado' : ' A Casa'} levou a rodada valendo \$$pot',
      );

      pot = 0;
      currentBet = 0;
      leftInTable = 0;
      rightInTable = 0;
      actionDetect = false;
      gamePhase = 'betting';
      lastAction =
          '${winner == 'left' ? 'Convidado' : 'Casa'} ganhou a rodada!';

      BetControllerManager.instance.getController('left').clear();
      BetControllerManager.instance.getController('right').clear();
      BetControllerManager.instance.getController('leftraise').clear();
      BetControllerManager.instance.getController('rightraise').clear();
      BetControllerManager.instance.getController('leftraise').clear();
      BetControllerManager.instance.getController('rightraise').clear();

      showAnimation();
    });
  }

  void resetGame() {
    setState(() {
      pot = 0;
      currentBet = 0;
      leftInTable = 0;
      rightInTable = 0;
      actionDetect = false;
      gamePhase = 'betting';
      lastAction = 'Novo jogo iniciado';

      BetControllerManager.instance.getController('left').clear();
      BetControllerManager.instance.getController('right').clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trucaralho | Poker'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () => showGameHistory(context),
            tooltip: 'Histórico',
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: resetGame,
            tooltip: 'Novo Jogo',
          ),
          IconButton(
            icon: const Icon(Icons.question_mark_outlined),
            onPressed: () => PokerDialog(),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                color: Colors.grey[800],
                child: Column(
                  children: [
                    Text(
                      'Pot: \$$pot',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    if (currentBet > 0)
                      Text(
                        'Aposta atual: \$$currentBet',
                        style: TextStyle(fontSize: 18, color: Colors.yellow),
                      ),
                    if (lastAction.isNotEmpty)
                      Text(
                        lastAction,
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: pokerPlayer(
                        context,
                        _modalCall,
                        _check,
                        _modalRaise,
                        _confirmFold,
                        allInConfirm,
                        _accept,
                        _win,
                        "left",
                        leftInTable,
                        leftValue,
                        leftWins,
                        gamePhase,
                        currentBet,
                        rightInTable,
                        leftInTable,
                        actionDetect,
                      ),
                    ),
                    Container(width: 2, color: Colors.white24),
                    Expanded(
                      child: pokerPlayer(
                        context,
                        _modalCall,
                        _check,
                        _modalRaise,
                        _confirmFold,
                        allInConfirm,
                        _accept,
                        _win,
                        "right",
                        rightInTable,
                        rightValue,
                        rightWins,
                        gamePhase,
                        currentBet,
                        rightInTable,
                        leftInTable,
                        actionDetect,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
