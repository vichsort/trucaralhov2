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
      return value; // 2..7
  }
}

class Carta {
  final String valor; // "4","5","6","7","Q","J","K","A","2","3"
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

  // Aqui ocorre o armazenamento por matriz: [Jogador 1, Jogado 2]
  List<Carta?> mesa = [null, null];

  void startRound(List<Carta> cartasDistribuidas) {
    if (cartasDistribuidas.length < 7) {
      throw Exception("Cartas insuficientes");
    }

    vira = cartasDistribuidas[0];
    definirManilhas(vira!.valor);

    maoJogador1 = cartasDistribuidas.sublist(1, 4);
    maoJogador2 = cartasDistribuidas.sublist(4, 7);
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
      return c1.naipe.index.compareTo(c2.naipe.index); // naipe desempata
    } else if (manilha1) {
      return 1;
    } else if (manilha2) {
      return -1;
    } else {
      return c1.forca.compareTo(c2.forca);
    }
  }

  // void pedirTruco() {
  //   if (valorRodada == 1) {
  //     valorRodada = 3;
  //   } else if (valorRodada == 3) {
  //     valorRodada = 6;
  //   } else if (valorRodada == 6) {
  //     valorRodada = 9;
  //   }
  // }

  // void aceitarTruco() {
  //   /* mantém valor */
  // }

  // void correr(bool jogador1Correu) {
  //   if (jogador1Correu) {
  //     pontosTime2 += valorRodada;
  //   } else {
  //     pontosTime1 += valorRodada;
  //   }
  // }

  bool gameOver() => pontosTime1 >= 12 || pontosTime2 >= 12;

  void throwCard(Carta carta, {required bool isJogador1}) {
    final mao = isJogador1 ? maoJogador1 : maoJogador2;
    final i = mao.indexOf(carta);
    final playedCard = mao.removeAt(i);
    registerInTable(playedCard, isJogador1);
  }

  void registerInTable(Carta carta, bool isJogador1) {
    mesa[isJogador1 ? 0 : 1] = carta;

    final jogadaCompleta = mesa[0] != null && mesa[1] != null;

    if (jogadaCompleta) {
      final resultado = compareCards(mesa[0]!, mesa[1]!);

      if (resultado > 0) {
        pontosTime1 += valorRodada;
        vez = Player.p1;
        print('J1 Ganhou (+$valorRodada).');
      } else if (resultado < 0) {
        pontosTime2 += valorRodada;
        print('J2 Ganhou (+$valorRodada).');
        vez = Player.p2;
      } else {
        // se empatar é o cara de antes..
        vez = vaza;
        print('Empate na vaza.');
      }

      vaza = vez;
      print(vez);
      mesa = [null, null];
    } else {
      // Depois do primeiro jogar, é a vez do outro
      vez = isJogador1 ? Player.p2 : Player.p1;
    }
  }

  void resolveWin() {
    final c1 = mesa[0]!;
    final c2 = mesa[1]!;
    final resultado = compareCards(c1, c2);
    if (resultado > 0) {
      pontosTime1 += valorRodada;
      print('J1 Ganhou (+$valorRodada).');
    } else if (resultado < 0) {
      pontosTime2 += valorRodada;
      print('j2 Ganhou (+$valorRodada).');
    } else {
      print('Empate na vaza.');
    }
    mesa = [null, null];
  }
}
