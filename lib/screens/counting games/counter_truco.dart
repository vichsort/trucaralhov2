import 'package:flutter/material.dart';
import 'package:trucaralho/logic/historico.dart';
import 'package:trucaralho/components/player_area.dart';
import 'package:trucaralho/logic/howTo.dart';

class CounterTrucoPage extends StatefulWidget {
  const CounterTrucoPage({super.key});

  @override
  State<CounterTrucoPage> createState() => _CounterTrucoPageState();
}

class _CounterTrucoPageState extends State<CounterTrucoPage> {
  int _leftCount = 0;
  int _leftWins = 0;
  int _rightCount = 0;
  int _rightWins = 0;
  int up = 1;
  bool rightDetect = false;
  bool hideRight = false;
  bool leftDetect = false;
  bool hideLeft = false;
  String words = "TRUCO!";
  ValueNotifier<bool> isDialOpen = ValueNotifier(false);
  bool customeDialRoot = false;
  bool extend = false;

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
    );
  }

  void _increment(String side) {
    setState(() {
      if (side == "left") {
        _leftCount += up;
        _microReset();
        if (_leftCount >= 12) {
          _leftCount = 0;
          _rightCount = 0;
          _leftWins++;
          showMessage('Nós ganhamos!');
          addToHistory('WIN', 'TRUCO', 'NÓS', details: 'Nós levamos a rodada!');
        }
      } else {
        _rightCount += up;
        _microReset();
        if (_rightCount >= 12) {
          _leftCount = 0;
          _rightCount = 0;
          _rightWins++;
          showMessage('Eles ganharam!');
          addToHistory(
            'WIN',
            'TRUCO',
            'ELES',
            details: 'Eles levaram a rodada!',
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

  void _resetSide(String side) {
    setState(() {
      if (side == "left") {
        _leftCount = 0;
      } else {
        _rightCount = 0;
      }
    });
  }

  void _changeUp(String side, bool trucado) {
    setState(() {
      final wordss = ["TRUCO!", "SEIS!", "NOVE!", "DOZE!"];
      final ups = [1, 3, 6, 9, 12];

      int currentIndex = wordss.indexOf(words);

      // Se for trucado aumenta a aposta
      if (trucado) {
        if (currentIndex < wordss.length - 1) {
          // mostra aceitar/correr no outro side
          if (side == "left") {
            rightDetect = true;
            leftDetect = false;
            hideLeft = true;
            hideRight = false;
          } else {
            leftDetect = true;
            rightDetect = false;
            hideRight = true;
            hideLeft = false;
          }
          up = ups[currentIndex + 1];
          words = wordss[currentIndex + 1];
        } else {
          // não sobe depois de doze
          up = 12;
          words = wordss.last;
          rightDetect = false;
          leftDetect = false;
          hideRight = true;
          hideLeft = true;
        }
        addToHistory(
          'TRUCOU',
          'TRUCO',
          side == "left" ? "NÓS" : "ELES",
          details: '${side == "left" ? "Nós pedimos" : "Eles pediram"} $words',
        );
        return;
      }

      // este loop refere quando se aceita o trucado
      // dai escondemos os aceitar/correr para pode aumentar a aposta
      if (side == "left") {
        rightDetect = false;
        leftDetect = false;
        hideRight = true;
        hideLeft = false;
      } else {
        leftDetect = false;
        rightDetect = false;
        hideLeft = true;
        hideRight = false;
      }
    });
  }

  void _reset() {
    setState(() {
      _leftCount = 0;
      _rightCount = 0;
      _leftWins = 0;
      _rightWins = 0;
      _microReset();
      addToHistory('RESET', 'TRUCO', 'Jogo', details: 'Um novo jogo começou!');
    });
  }

  void _correr(side) {
    setState(() {
      if (side == "left") {
        _rightCount += up;
        leftDetect = false;
      } else {
        _leftCount += up;
        rightDetect = false;
      }

      if (_leftCount >= 12) {
        _increment("left");
      } else if (_rightCount >= 12) {
        _increment("right");
      }
      addToHistory(
        'CORREU',
        'TRUCO',
        side == "left" ? "NÓS" : "ELES",
        details:
            '${side == "left" ? "Nós corremos" : "Eles correram"} do trucado, dando $up pontos para ${side != "left" ? "nós" : "eles"}',
      );
      _microReset();
    });
  }

  void _microReset() {
    setState(() {
      up = 1;
      words = "TRUCO!";
      hideRight = false;
      hideLeft = false;
      rightDetect = false;
      leftDetect = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trucaralho | Truco'),

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
            icon: const Icon(Icons.question_mark_outlined),
            onPressed: () => TrucoDialog(),
            tooltip: 'Como jogar',
          ),
        ],
      ),
      body: Stack(
        children: [
          // nos
          Row(
            children: [
              trucoPlayer(
                _increment,
                _decrease,
                _resetSide,
                "left",
                _leftCount,
                _leftWins,
                leftDetect,
                hideLeft,
                _changeUp,
                words,
                _correr,
              ),

              // Meio
              Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Valendo: $up"),
                  SizedBox(height: 60),
                  ElevatedButton(onPressed: _reset, child: Icon(Icons.refresh)),
                ],
              ),

              trucoPlayer(
                _increment,
                _decrease,
                _resetSide,
                "right",
                _rightCount,
                _rightWins,
                rightDetect,
                hideRight,
                _changeUp,
                words,
                _correr,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
