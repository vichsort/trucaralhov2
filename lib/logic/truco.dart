import 'dart:math';

enum Naipe { hearts, spades, clubs, diamonds }

enum Player { p1, p2 }

Naipe parseSuit(String suit) {
  switch (suit.toUpperCase()) {
    case 'HEARTS':
      return Naipe.hearts;
    case 'SPADES':
      return Naipe.spades;
    case 'CLUBS':
      return Naipe.clubs;
    case 'DIAMONDS':
      return Naipe.diamonds;
    default:
      throw ArgumentError('Naipe inválido: $suit');
  }
}

String normalizeValor(String value) {
  switch (value.toUpperCase()) {
    case 'ACE':
      return 'A';
    case 'JACK':
      return 'J';
    case 'QUEEN':
      return 'Q';
    case 'KING':
      return 'K';
    default:
      return value;
  }
}

class Carta {
  final String valor;
  final Naipe naipe;
  final String imageUrl;

  Carta({required this.valor, required this.naipe, required this.imageUrl});

  factory Carta.fromApi(Map<String, dynamic> data) {
    return Carta(
      valor: normalizeValor(data['value'] as String),
      naipe: parseSuit(data['suit'] as String),
      imageUrl: data['image'] as String,
    );
  }

  int get strenght {
    const ordem = ["4", "5", "6", "7", "Q", "J", "K", "A", "2", "3"];
    return ordem.indexOf(valor.toUpperCase());
  }

  @override
  String toString() => '$valor de ${naipe.name}';
}

class TrucoGame {
  List<Carta> handP1 = [];
  List<Carta> handP2 = [];
  Carta? vira;
  List<String> manilhas = [];

  int pointsP1 = 0;
  int pointsP2 = 0;
  int roundValue = 1;

  Player vez = Player.p1;
  Player vaza = Player.p1;

  List<Carta?> mesa = [null, null];

  int winsP1 = 0;
  int winsP2 = 0;
  int round = 1;
  String lastResult = "";

  bool usedTruco = false;

  final Random _rnd = Random();

  void startRound(List<Carta> cartasDistribuidas, {bool novaPartida = false}) {
    usedTruco = false;
    if (cartasDistribuidas.length < 7) throw Exception("Cartas insuficientes");

    if (novaPartida) {
      pointsP1 = 0;
      pointsP2 = 0;
    }

    vira = cartasDistribuidas[0];
    definirManilhas(vira!.valor);

    handP1 = cartasDistribuidas.sublist(1, 4);
    handP2 = cartasDistribuidas.sublist(4, 7);

    winsP1 = 0;
    winsP2 = 0;
    round = 1;
    vez = Player.p1;
    vaza = Player.p1;
    roundValue = 1;
    mesa = [null, null];
    lastResult = "";
    usedTruco = false;
  }

  void definirManilhas(String valorVira) {
    const ordem = ["4", "5", "6", "7", "Q", "J", "K", "A", "2", "3"];
    final idx = ordem.indexOf(valorVira.toUpperCase());
    manilhas = [ordem[(idx + 1) % ordem.length]];
  }

  bool isManilha(Carta carta) => manilhas.contains(carta.valor.toUpperCase());

  int compareCards(Carta c1, Carta c2) {
    final manilha1 = isManilha(c1);
    final manilha2 = isManilha(c2);

    if (manilha1 && manilha2) {
      return c1.naipe.index - c2.naipe.index;
    } else if (manilha1) {
      return 1;
    } else if (manilha2) {
      return -1;
    } else {
      return c1.strenght - c2.strenght;
    }
  }

  bool gameOver() => pointsP1 >= 12 || pointsP2 >= 12;

  void throwCard(Carta carta, {required bool isJogador1}) {
    final mao = isJogador1 ? handP1 : handP2;
    final i = mao.indexOf(carta);
    if (i >= 0) {
      final playedCard = mao.removeAt(i);
      registerInTable(playedCard, isJogador1);
    }
  }

  void registerInTable(Carta carta, bool isJogador1) {
    mesa[isJogador1 ? 0 : 1] = carta;

    final jogadaCompleta = mesa[0] != null && mesa[1] != null;

    if (jogadaCompleta) {
      final resultado = compareCards(mesa[0]!, mesa[1]!);

      if (resultado > 0) {
        winsP1++;
        vez = Player.p1;
        lastResult = "Você ganhou a vaza $round!";
      } else if (resultado < 0) {
        winsP2++;
        vez = Player.p2;
        lastResult = "Oponente ganhou a vaza $round!";
      } else {
        vez = vaza;
        lastResult = "Empate na vaza $round!";
      }

      vaza = vez;
      round++;
      verifyEndofRound();
    } else {
      vez = isJogador1 ? Player.p2 : Player.p1;
    }
  }

  void verifyEndofRound() {
    if (winsP1 == 2 || winsP2 == 2 || round > 3) {
      if (winsP1 > winsP2) {
        pointsP1 += roundValue;
        lastResult = "Você ganhou a mão e fez +$roundValue ponto(s)!";
      } else if (winsP2 > winsP1) {
        pointsP2 += roundValue;
        lastResult = "Oponente ganhou a mão e fez +$roundValue ponto(s)!";
      }
    }
  }

  void pedirTruco(bool isJogador1) {
    if (usedTruco) return;

    if (roundValue == 1) {
      roundValue = 1;
    } else if (roundValue == 3) {
      roundValue = 3;
    } else if (roundValue == 6) {
      roundValue = 6;
    } else if (roundValue == 9) {
      roundValue = 9;
    }

    usedTruco = true;
  }

  void acceptTruco() {
    if (roundValue == 1) {
      roundValue = 3;
    } else if (roundValue == 3) {
      roundValue = 6;
    } else if (roundValue == 6) {
      roundValue = 9;
    } else if (roundValue == 9) {
      roundValue = 12;
    }
    usedTruco = false; // permite pedir de novo depois
  }

  bool avaliaracceptTruco() {
    int goodCards = handP2
        .where((c) => isManilha(c) || c.strenght >= 7)
        .length;
    if (goodCards >= 2) return true;
    if (goodCards == 1 && roundValue < 6) return true;
    return _rnd.nextInt(100) < 45;
  }

  bool decidirPedirTruco() {
    if (usedTruco || roundValue >= 12) return false;
    int goodCards = handP2
        .where((c) => isManilha(c) || c.strenght >= 8)
        .length;
    int baseChance = 6;
    if (goodCards == 1) baseChance += 20;
    if (goodCards >= 2) baseChance += 40;
    int chance = baseChance.clamp(0, 70);
    return _rnd.nextInt(100) < chance;
  }
}
