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

  int get forca {
    const ordem = ["4", "5", "6", "7", "Q", "J", "K", "A", "2", "3"];
    return ordem.indexOf(valor.toUpperCase());
  }

  @override
  String toString() => '$valor de ${naipe.name}';
}

class TrucoGame {
  List<Carta> maoJogador1 = [];
  List<Carta> maoJogador2 = [];
  Carta? vira;
  List<String> manilhas = [];

  int pontosTime1 = 0;
  int pontosTime2 = 0;
  int valorRodada = 1;

  Player vez = Player.p1;
  Player vaza = Player.p1;

  List<Carta?> mesa = [null, null];

  int vitoriasRodadaP1 = 0;
  int vitoriasRodadaP2 = 0;
  int rodadaAtual = 1;
  String ultimoResultado = "";

  bool trucoUsado = false;

  final Random _rnd = Random();

  void startRound(List<Carta> cartasDistribuidas, {bool novaPartida = false}) {
    trucoUsado = false;
    if (cartasDistribuidas.length < 7) throw Exception("Cartas insuficientes");

    if (novaPartida) {
      pontosTime1 = 0;
      pontosTime2 = 0;
    }

    vira = cartasDistribuidas[0];
    definirManilhas(vira!.valor);

    maoJogador1 = cartasDistribuidas.sublist(1, 4);
    maoJogador2 = cartasDistribuidas.sublist(4, 7);

    vitoriasRodadaP1 = 0;
    vitoriasRodadaP2 = 0;
    rodadaAtual = 1;
    vez = Player.p1;
    vaza = Player.p1;
    valorRodada = 1;
    mesa = [null, null];
    ultimoResultado = "";
    trucoUsado = false;
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
      return c1.forca - c2.forca;
    }
  }

  bool gameOver() => pontosTime1 >= 12 || pontosTime2 >= 12;

  void throwCard(Carta carta, {required bool isJogador1}) {
    final mao = isJogador1 ? maoJogador1 : maoJogador2;
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
        vitoriasRodadaP1++;
        vez = Player.p1;
        ultimoResultado = "Você ganhou a vaza $rodadaAtual!";
      } else if (resultado < 0) {
        vitoriasRodadaP2++;
        vez = Player.p2;
        ultimoResultado = "Oponente ganhou a vaza $rodadaAtual!";
      } else {
        vez = vaza;
        ultimoResultado = "Empate na vaza $rodadaAtual!";
      }

      vaza = vez;
      rodadaAtual++;
      verificarFimRodada();
    } else {
      vez = isJogador1 ? Player.p2 : Player.p1;
    }
  }

  void verificarFimRodada() {
    if (vitoriasRodadaP1 == 2 || vitoriasRodadaP2 == 2 || rodadaAtual > 3) {
      if (vitoriasRodadaP1 > vitoriasRodadaP2) {
        pontosTime1 += valorRodada;
        ultimoResultado = "Você ganhou a mão e fez +$valorRodada ponto(s)!";
      } else if (vitoriasRodadaP2 > vitoriasRodadaP1) {
        pontosTime2 += valorRodada;
        ultimoResultado = "Oponente ganhou a mão e fez +$valorRodada ponto(s)!";
      }
    }
  }

  void pedirTruco(bool isJogador1) {
    if (trucoUsado) return;

    if (valorRodada == 1) {
      valorRodada = 3;
    } else if (valorRodada == 3) {
      valorRodada = 6;
    } else if (valorRodada == 6) {
      valorRodada = 9;
    } else if (valorRodada == 9) {
      valorRodada = 12;
    }

    trucoUsado = true;
  }

  void aceitarTruco() {
    if (valorRodada == 1) {
      valorRodada = 3;
    } else if (valorRodada == 3) {
      valorRodada = 6;
    } else if (valorRodada == 6) {
      valorRodada = 9;
    } else if (valorRodada == 9) {
      valorRodada = 12;
    }
    trucoUsado = false; // permite pedir de novo depois
  }

  bool avaliarAceitarTruco() {
    int boas = maoJogador2.where((c) => isManilha(c) || c.forca >= 7).length;
    if (boas >= 2) return true;
    if (boas == 1 && valorRodada < 6) return true;
    return _rnd.nextInt(100) < 45;
  }

  bool decidirPedirTruco() {
    if (trucoUsado || valorRodada >= 12) return false;
    int boas = maoJogador2.where((c) => isManilha(c) || c.forca >= 8).length;
    int baseChance = 6;
    if (boas == 1) baseChance += 20;
    if (boas >= 2) baseChance += 40;
    int chance = baseChance.clamp(0, 70);
    return _rnd.nextInt(100) < chance;
  }
}
