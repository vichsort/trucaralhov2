import 'dart:math';

/// Enumeração dos naipes disponíveis no baralho.
enum Naipe { hearts, spades, clubs, diamonds }

/// Identificação dos jogadores.
enum Player { p1, p2 }

/// Converte string do naipe vindo da API para [Naipe].
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

/// Normaliza os valores recebidos da API para representação do truco.
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

/// Representa uma carta no truco.
class Carta {
  final String valor;
  final Naipe naipe;
  final String imageUrl;

  Carta({
    required this.valor,
    required this.naipe,
    required this.imageUrl,
  });

  /// Cria carta a partir do retorno da API.
  factory Carta.fromApi(Map<String, dynamic> data) {
    return Carta(
      valor: normalizeValor(data['value'] as String),
      naipe: parseSuit(data['suit'] as String),
      imageUrl: data['image'] as String,
    );
  }

  /// Força da carta no truco (sem manilha).
  int get strength {
    const ordem = ["4", "5", "6", "7", "Q", "J", "K", "A", "2", "3"];
    return ordem.indexOf(valor.toUpperCase());
  }

  @override
  String toString() => '$valor de ${naipe.name}';
}

/// Classe principal com as regras e estado do jogo.
///
/// [opponentIsAI] define se o jogador 2 é um robô. Quando true,
/// pedidos de truco feitos por Player.p1 são resolvidos automaticamente.
class TrucoGame {
  // Config
  final bool opponentIsAI;

  // Cartas na mão de cada jogador
  List<Carta> handP1 = [];
  List<Carta> handP2 = [];

  // Carta "vira" e lista de manilhas
  Carta? vira;
  List<String> manilhas = [];

  // Pontuação geral
  int pointsP1 = 0;
  int pointsP2 = 0;

  // Valor atual da rodada
  int roundValue = 1;

  // Controle de turnos e vazas
  Player vez = Player.p1;
  Player vaza = Player.p1;
  List<Carta?> mesa = [null, null];

  // Placar da mão (melhor de 3 vazas)
  int winsP1 = 0;
  int winsP2 = 0;
  int round = 1;

  // Último resultado exibido na tela
  String lastResult = "";

  // Controle do pedido de truco (impede pedir duas vezes ilegalmente)
  bool usedTruco = false;

  // Random para decisões da IA
  final Random _rnd = Random();

  TrucoGame({this.opponentIsAI = true});

  /// Inicia uma nova rodada, distribuindo cartas.
  /// Espera pelo menos 7 cartas no array (1 vira + 3 para p1 + 3 para p2).
  void startRound(List<Carta> cartasDistribuidas, {bool novaPartida = false}) {
    if (cartasDistribuidas.length < 7) {
      throw Exception("Cartas insuficientes");
    }

    if (novaPartida) {
      pointsP1 = 0;
      pointsP2 = 0;
    }

    usedTruco = false;
    vira = cartasDistribuidas[0];
    definirManilhas(vira!.valor);

    handP1 = cartasDistribuidas.sublist(1, 4).toList();
    handP2 = cartasDistribuidas.sublist(4, 7).toList();

    winsP1 = 0;
    winsP2 = 0;
    round = 1;
    vez = Player.p1;
    vaza = Player.p1;
    roundValue = 1;
    mesa = [null, null];
    lastResult = "";
  }

  /// Define as manilhas a partir da carta "vira".
  void definirManilhas(String valorVira) {
    const ordem = ["4", "5", "6", "7", "Q", "J", "K", "A", "2", "3"];
    final idx = ordem.indexOf(valorVira.toUpperCase());
    manilhas = [ordem[(idx + 1) % ordem.length]];
  }

  /// Verifica se a carta é manilha.
  bool isManilha(Carta carta) => manilhas.contains(carta.valor.toUpperCase());

  /// Compara duas cartas e retorna:
  /// > 0 se [c1] vence, < 0 se [c2] vence, 0 se empate.
  int compareCards(Carta c1, Carta c2) {
    final manilha1 = isManilha(c1);
    final manilha2 = isManilha(c2);

    if (manilha1 && manilha2) {
      // Desempate por naipe (ordem do enum)
      return c1.naipe.index - c2.naipe.index;
    }
    if (manilha1) return 1;
    if (manilha2) return -1;

    return c1.strength - c2.strength;
  }

  /// Verifica se alguém atingiu 12 pontos.
  bool gameOver() => pointsP1 >= 12 || pointsP2 >= 12;

  /// Joga uma carta na mesa.
  void throwCard(Carta carta, {required bool isJogador1}) {
    final mao = isJogador1 ? handP1 : handP2;
    final i = mao.indexOf(carta);

    if (i >= 0) {
      final playedCard = mao.removeAt(i);
      registerInTable(playedCard, isJogador1);
    }
  }

  /// Registra a carta na mesa e, se necessário, avalia a vaza.
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
        // empate: mantém a vaza (quem estava com a vez de vazar)
        vez = vaza;
        lastResult = "Empate na vaza $round!";
      }

      // próximo jogador a vazar é quem venceu (ou quem tinha a vaza em empate)
      vaza = vez;
      round++;
      verifyEndOfRound();

      // NOTA: limpeza da mesa e distribuição da próxima rodada / reset de mãos
      // são controladas pela UI/startRound para manter responsabilidade separada.
    } else {
      // troca a vez para o outro jogador
      vez = isJogador1 ? Player.p2 : Player.p1;
    }
  }

  /// Verifica se a mão terminou (melhor de 3 vazas) e aplica pontos.
  void verifyEndOfRound() {
    if (winsP1 == 2 || winsP2 == 2 || round > 3) {
      if (winsP1 > winsP2) {
        pointsP1 += roundValue;
        lastResult = "Você ganhou a mão e fez +$roundValue ponto(s)!";
      } else if (winsP2 > winsP1) {
        pointsP2 += roundValue;
        lastResult = "Oponente ganhou a mão e fez +$roundValue ponto(s)!";
      } else {
        // empate técnico ao final: aplicar regra local (aqui não altera pontos)
        lastResult = "Mão terminou em empate.";
      }
    }
  }

  /// Se o adversário for IA e o pedido vier do humano (p1),
  /// a IA irá decidir automaticamente (avaliarAcceptTruco).
  ///
  /// Retorna true se o truco foi aceito, false se o adversário correu.
  ///
  /// Observação: a UI pode usar essa resposta para exibir animações/mensagens.
  bool requestTruco(Player requester) {
    if (usedTruco) return false; // já foi pedido nesta mão/estado

    // marca que houve pedido (evita spam)
    usedTruco = true;

    // Se o oponente for IA e o pedido vier do humano (p1), resolvemos aqui.
    final opponent = requester == Player.p1 ? Player.p2 : Player.p1;

    if (opponentIsAI) {
      final aceitou = avaliarAcceptTruco();
      if (aceitou) {
        // aplicamos o truco (aumenta valor)
        acceptTruco();
        lastResult = "${_playerName(requester)} pediu truco — oponente aceitou!";
        return true;
      } else {
        // oponente correu: requester ganha os pontos atuais da rodada
        if (requester == Player.p1) {
          pointsP1 += roundValue;
        } else {
          pointsP2 += roundValue;
        }
        lastResult =
            "${_playerName(opponent)} correu! ${_playerName(requester)} ganhou +$roundValue ponto(s)!";
        return false;
      }
    }

    // Se o oponente não é IA, a UI deve exibir diálogo e chamar acceptTruco() ou tratar recusa.
    // Aqui retornamos true para indicar que o pedido foi registrado; a decisão ficará para a UI.
    return true;
  }

  /// Aceita o truco e aumenta o valor da rodada.
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
    // libera novo pedido se houver (comportamento opcional)
    usedTruco = false;
  }

  /// Adversário decide aceitar truco com base nas cartas (IA).
  /// Retorna true = aceita, false = recusa.
  bool avaliarAcceptTruco() {
    int boasCartas =
        handP2.where((c) => isManilha(c) || c.strength >= 7).length;
    if (boasCartas >= 2) return true;
    if (boasCartas == 1 && roundValue < 6) return true;
    return _rnd.nextInt(100) < 45;
  }

  /// Adversário decide pedir truco com base nas cartas (IA).
  /// Retorna true se AI decide pedir.
  bool decidirPedirTruco() {
    if (usedTruco || roundValue >= 12) return false;

    int boasCartas =
        handP2.where((c) => isManilha(c) || c.strength >= 8).length;
    int chanceBase = 6;
    if (boasCartas == 1) chanceBase += 20;
    if (boasCartas >= 2) chanceBase += 40;

    int chance = chanceBase.clamp(0, 70);
    return _rnd.nextInt(100) < chance;
  }

  String _playerName(Player p) => p == Player.p1 ? "Você" : "Oponente";
}
