import 'package:flutter/material.dart';

class TrucoDialog {
  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Como jogar Truco?'),
          content: const Text(
            'Truco é um jogo de cartas jogado com um baralho espanhol. '
            'Os jogadores podem pedir "truco" para aumentar a aposta. '
            'O jogo envolve blefes e estratégias para enganar o adversário. '
            'Um "Truco" faz com que a rodada passe a valer 3 pontos, o adversário pode'
            'aceitar ou correr, se correr o adversário ganha 1 ponto, se aceitar o truco a aposta aumenta para 6 pontos. '
            'O mesmo se aplica para 9 e 12 pontos. '
            'O jogo termina quando um jogador/dupla atinge 12 pontos.',
          ),
          actions: [
            TextButton(
              child: const Text('Fechar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class BlackJackDialog {
  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Como jogar Blackjack?'),
          content: const Text(
            'Blackjack é um jogo de cartas jogado com um baralho comum. '
            'O objetivo do jogo é chegar o mais próximo possível de 21 pontos, '
            'sem ultrapassar esse valor, se ultrapassado, o convidado perde.'
            'Na mesa, o jogador da casa irá distrubuir as cartas que serão reveladas ao longo do jogo.',
          ),
          actions: [
            TextButton(
              child: const Text('Fechar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class FodinhaDialog {
  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Como jogar Fodinha?'),
          content: const Text(
            'Fodinha é um jogo similar ao Truco Paulista, a diferença é que '
            'não existe a possibilidade de pedir truco, e o jogo pode ser jogado com até 6 jogadores. '
            'O objetivo é adivinhar quantas rodadas cada jogador irá ganhar, '
            'se um jogador errar o número de rodadas em que ele iria ganhar, ele perde 1 de suas 5 vidas. '
            'Na primeira rodada, com 1 carta, os jogadores não poderão ver sua carta, e terão que adivinhar '
            'se ganham ou não a partir das cartas dos adversários. '
            'A partir da segunda rodada, cada jogador poderá ver suas cartas e determinar seu '
            'Número de rodadas em que acha que irá ganhar.',
          ),
          actions: [
            TextButton(
              child: const Text('Fechar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class PokerDialog {
  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Como jogar Poker?'),
          content: const Text(
            'Poker é um jogo de cartas onde o objetivo é ganhar fichas apostadas pelos jogadores. '
            'Os jogadores fazem apostas (BET), aumentar a aposta (RAISE), igualar a aposta (CALL/CHECK) ou desistir (FOLD). '
            'O jogo é jogado em rodadas, e o jogador que ganhar a rodada leva o pot. '
            'Os jogadores podem fazer apostas em fichas de diferentes valores, e o valor total da aposta é chamado de pot. '
            'Além disso, os jogadores podem fazer apostas adicionais (ALL IN) colocando todas as suas fichas na mesa. '
            'O jogo continua até que um jogador ganhe todas as fichas ou até que os jogadores decidam parar. ',
          ),
          actions: [
            TextButton(
              child: const Text('Fechar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
