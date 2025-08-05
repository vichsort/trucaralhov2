import 'package:flutter/material.dart';
import '../logic/bet.dart';
import '../logic/historico.dart';
import '../components/player_area.dart';
import '../logic/howTo.dart';

class BlackJackPage extends StatefulWidget {
  const BlackJackPage({Key? key}) : super(key: key);

  @override
  State<BlackJackPage> createState() => _BlackJackPageState();
}

class _BlackJackPageState extends State<BlackJackPage> {
  int _leftCount = 0;
  int _leftWins = 0;
  int _rightCount = 0;
  int _rightWins = 0;
  int up = 2;
  String carta = "2";
  bool aceDetect = false;

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
    );
  }

  _increment(String side) {
    setState(() {
      if (side == "left") {
        _leftCount += up;
        up = 2;
        carta = "2";
        if (_leftCount == 21) {
          _leftCount = 0;
          _rightCount = 0;
          _leftWins++;
          showMessage('O convidado ganhou!');
          addToHistory(
            'WIN',
            'BLACKJACK',
            'CONVIDADO',
            details: "O convidado levou a partida!",
          );
        } else if (_leftCount > 21) {
          _leftCount = 0;
          _rightCount = 0;
          _rightWins++;
          showMessage('O convidado passou de 21!');
          addToHistory(
            'PASSOU',
            'BLACKJACK',
            'CONVIDADO',
            details: "O convidado passou de 21, dando a partida para o dealer!",
          );
        }
      } else {
        _rightCount += up;
        up = 2;
        carta = "2";

        if (_rightCount == 21) {
          _leftCount = 0;
          _rightCount = 0;
          _rightWins++;
          showMessage('O dealer ganhou!');
          addToHistory(
            'WIN',
            'BLACKJACK',
            'DEALER',
            details: "O dealer levou a partida!",
          );
        } else if (_rightCount > 21) {
          _leftCount = 0;
          _rightCount = 0;
          _leftWins++;
          showMessage('O dealer passou de 21!');
          addToHistory(
            'PASSOU',
            'BLACKJACK',
            'DEALER',
            details: "O dealer passou de 21, dando a partida para o convidado!",
          );
        }
      }
    });
  }

  void _decrease(String side) {
    setState(() {
      if (side == "left") {
        _leftCount--;
        if (_leftCount <= 0) {
          _leftCount = 0;
          showMessage('Não pode diminuir mais!');
        }
      } else {
        _rightCount--;
        if (_rightCount <= 0) {
          _rightCount = 0;
          showMessage('Não pode diminuir mais!');
        }
      }
    });
  }

  void _changeUp() {
    setState(() {
      Map<String, int> cartado = {
        "2": 2,
        "3": 3,
        "4": 4,
        "5": 5,
        "6": 6,
        "7": 7,
        "8": 8,
        "9": 9,
        "10": 10,
        "Rainha": 10,
        "Valete": 10,
        "Rei": 10,
        "Ás": 11,
      };

      List<String> keys = cartado.keys.toList();
      int currentIndex = keys.indexOf(carta);
      currentIndex = (currentIndex + 1) % keys.length;
      carta = keys[currentIndex];
      up = cartado[carta]!;

      up == 11 ? aceDetect = true : aceDetect = false;
    });
  }

  void _reset() {
    setState(() {
      _leftCount = 0;
      _rightCount = 0;
      _leftWins = 0;
      _rightWins = 0;
      up = 2;
      carta = "2";
      addToHistory(
        'RESET',
        'BLACKJACK',
        'Jogo',
        details: 'Um novo jogo começou!',
      );
    });
  }

  void _aceVal(String side, bool total) {
    total ? up = 11 : up = 1;
    if (side == "left") {
      _increment("left");
    } else {
      _increment("right");
    }
  }

  void _openModal() {
    showModalBottomSheet(context: context, builder: (context) => BetPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trucaralho | BlackJack'),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () => showGameHistory(context),
            tooltip: 'Histórico',
          ),
          IconButton(
            onPressed: _openModal,
            icon: Icon(Icons.attach_money_sharp),
          ),
          IconButton(
            icon: const Icon(Icons.question_mark_outlined),
            onPressed: () => BlackJackDialog(),
            tooltip: "Como jogar",
          ),
        ],
      ),
      body: Stack(
        children: [
          Row(
            children: [
              blackJackPlayer(
                _increment,
                _decrease,
                "left",
                _leftCount,
                _leftWins,
                aceDetect,
                _aceVal,
              ),

              Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ValueListenableBuilder<int>(
                    valueListenable:
                        BetController.instance.selectedValuesNotifier,
                    builder: (context, value, child) {
                      return Text('Na mesa: ${value * 2}');
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(onPressed: _changeUp, child: Text('$carta')),
                  SizedBox(height: 20),
                  ElevatedButton(onPressed: _reset, child: Icon(Icons.refresh)),
                ],
              ),

              blackJackPlayer(
                _increment,
                _decrease,
                "right",
                _rightCount,
                _rightWins,
                aceDetect,
                _aceVal,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
