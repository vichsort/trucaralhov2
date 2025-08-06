import 'package:flutter/material.dart';
import './cards.dart';

Widget buildPlayer1Area(
  List player1Cards,
  bool isLoading,
  void Function(int) onCardTapped,
  VoidCallback startGame,
  List<GlobalKey> keys,
) {
  return Container(
    padding: const EdgeInsets.all(16),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          const CircularProgressIndicator()
        else if (player1Cards.isNotEmpty)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: player1Cards.asMap().entries.map((entry) {
              final index = entry.key;
              final carta = entry.value;
              final key = keys[index];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () => onCardTapped(index),
                  child: Container(
                    key: key,
                    child: buildCardFront(carta.imageUrl, index, onCardTapped),
                  ),
                ),
              );
            }).toList(),
          )
        else
          const Text('Nenhuma carta disponível'),
      ],
    ),
  );
}

Widget buildPlayer2Area(
  List player2Cards,
  bool isLoading,
  List<GlobalKey> keys,
) {
  return Container(
    padding: const EdgeInsets.all(16),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          const CircularProgressIndicator()
        else if (player2Cards.isNotEmpty)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(player2Cards.length, (index) {
              final key = keys[index];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Container(key: key, child: buildCardBack()),
              );
            }),
          )
        else
          const Text('Nenhuma carta disponível'),
      ],
    ),
  );
}

Widget buildTableCardArea(List tableCards, bool isLoading) {
  return Container(
    padding: const EdgeInsets.all(16),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
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

Widget trucoPlayer(
  void Function(String) increment,
  void Function(String) decrease,
  void Function(String) resetSide,
  String side,
  int count,
  int wins,
  bool detect,
  bool hide,
  void Function(String, bool) changeUp,
  String words,
  void Function(String) correr,
) {
  return Expanded(
    child: GestureDetector(
      onTap: () => increment(side),
      onDoubleTap: () => decrease(side),
      onLongPress: () => resetSide(side),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[Color(0xFF1f1d1e), Color(0xFF383838)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: side == "left" ? Colors.blue : Colors.red,
                ),
              ),
              Text(
                side == "left" ? "Nós" : "Eles",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF534d36),
                ),
              ),
              const SizedBox(height: 8),
              Image(
                image: AssetImage(
                  side == "left" ? "images/paus.png" : "images/copas.png",
                ),
                height: 150,
                width: 150,
              ),
              const SizedBox(height: 8),
              Text(
                '$wins',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),

              SizedBox(height: 100),

              if (detect == false && hide == false)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Color(0xFF1f1d1e),
                    minimumSize: Size(120, 66),
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                  onPressed: () {
                    changeUp(side, true);
                  },
                  child: Text(words),
                ),

              if (detect)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        correr(side);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: Text('CORRER'),
                    ),
                    SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () {
                        changeUp(side, false);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: Text('ACEITAR'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget blackJackPlayer(
  void Function(String) increment,
  void Function(String) decrease,
  String side,
  int count,
  int wins,
  bool aceDetect,
  void Function(String, bool) aceVal,
) {
  return Expanded(
    child: GestureDetector(
      onTap: () => increment(side),
      onLongPress: () => decrease(side),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[Color(0xFF1f1d1e), Color(0xFF383838)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: side == "left" ? Colors.blue : Colors.red,
                ),
              ),
              Text(
                side == "left" ? "Convidado" : "Dealer",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF534d36),
                ),
              ),
              const SizedBox(height: 8),
              Image(
                image: AssetImage(
                  side == "left" ? "images/paus.png" : "images/copas.png",
                ),
                height: 150,
                width: 150,
              ),
              const SizedBox(height: 8),
              Text(
                '$wins',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
              if (aceDetect)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        aceVal(side, false);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: Text('ACEITAR 1'),
                    ),
                    SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () {
                        aceVal(side, true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: Text('ACEITAR 11'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget pokerPlayer(
  BuildContext context,
  void Function(BuildContext, String) modalCall,
  void Function(String) check,
  void Function(BuildContext, String) modalRaise,
  void Function(String) confirmFold,
  void Function(String) allInConfirm,
  void Function(String) accept,
  void Function(String) win,
  String id,
  int inTable,
  int value,
  int wins,
  String gamePhase,
  int currentBet,
  int rightInTable,
  int leftInTable,
  bool actionDetect,
) {
  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[Color(0xFF1f1d1e), Color(0xFF383838)],
      ),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '\$$value',
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Color(0xFF534d36),
          ),
        ),
        const SizedBox(height: 8),

        Text(
          id == "left" ? "Convidado" : "Casa",
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF534d36),
          ),
        ),
        const SizedBox(height: 3),
        Image(
          image: AssetImage(
            id == "left" ? "images/paus.png" : "images/copas.png",
          ),
          height: 150,
          width: 150,
        ),
        Text(
          '$wins',
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.amber,
          ),
        ),
        if (inTable > 0)
          Container(
            margin: EdgeInsets.symmetric(vertical: 8),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue[700],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              'Na mesa: \$$inTable',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),

        // Botões de ação
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Linha 1: CALL e CHECK
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: gamePhase == 'betting'
                          ? () => modalCall(context, id)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'CALL',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          gamePhase != 'showdown' &&
                              gamePhase != 'all_in' &&
                              gamePhase != 'betting'
                          ? () => check(id)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        currentBet == 0 ? 'CHECK' : 'CHECK',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          (gamePhase == 'betting' || gamePhase == 'called')
                          ? () => modalRaise(context, id)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'RAISE',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          gamePhase != 'betting' && gamePhase != 'showdown'
                          ? () => confirmFold(id)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'FOLD',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (gamePhase == 'betting' || gamePhase == 'called')
                      ? () => allInConfirm(id)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'ALL IN',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              if (gamePhase == 'raised' || gamePhase == 'all_in')
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => accept(id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        "ACCEPT (\$$inTable})",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Botões de resultado (quando actionDetect é true)
        if (actionDetect)
          Padding(
            padding: const EdgeInsets.all(5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => win(id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                  ),
                  child: Text(
                    'Ganhou',
                    style: TextStyle(fontSize: 20, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
      ],
    ),
  );
}
