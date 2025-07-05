enum Naipe { hearts, spades, clubs, diamonds }

class Carta {
  final String valor;
  final Naipe naipe;
  final String imageUrl;

  Carta({required this.valor, required this.naipe, required this.imageUrl});

  int get forca {
    const ordem = ["4", "5", "6", "7", "Q", "J", "K", "A", "2", "3"];
    return ordem.indexOf(valor.toUpperCase());
  }

  @override
  String toString() => '$valor de $naipe';
}

class TrucoGame {
  List<Carta> maoJogador1 = [];
  List<Carta> maoJogador2 = [];
  Carta? vira;
  List<String> manilhas = [];
  int pontosTime1 = 0;
  int pontosTime2 = 0;
  int valorRodada = 1;

  void iniciarRodada(List<Carta> cartasDistribuidas) {
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
    int idx = ordem.indexOf(valorVira.toUpperCase());
    manilhas = [ordem[(idx + 1) % ordem.length]];
  }

  bool isManilha(Carta carta) {
    return manilhas.contains(carta.valor.toUpperCase());
  }

  int compararCartas(Carta c1, Carta c2) {
    bool manilha1 = isManilha(c1);
    bool manilha2 = isManilha(c2);

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

  void pedirTruco() {
    if (valorRodada == 1) valorRodada = 3;
    else if (valorRodada == 3) valorRodada = 6;
    else if (valorRodada == 6) valorRodada = 9;
  }

  void aceitarTruco() {
    // manter valorRodada como está
  }

  void correr(bool jogador1Correu) {
    if (jogador1Correu) {
      pontosTime2 += valorRodada;
    } else {
      pontosTime1 += valorRodada;
    }
  }

  bool fimDeJogo() {
    return pontosTime1 >= 12 || pontosTime2 >= 12;
  }
}
