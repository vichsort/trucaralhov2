import 'package:http/http.dart' as http;
import 'dart:convert';

class DeckService {
  String deckId = '';

  Future<void> getNewDeck() async {
    final url = Uri.parse(
      'https://deckofcardsapi.com/api/deck/new/shuffle/?deck_count=1',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      deckId = data['deck_id'];
    } else {
      throw Exception('Falha ao carregar novo deck');
    }
  }

  Future<List<Map<String, dynamic>>> drawCards(int count) async {
  if (deckId.isEmpty) {
    await getNewDeck();
  }

  final url = Uri.parse(
    'https://deckofcardsapi.com/api/deck/$deckId/draw/?count=$count',
  );

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final cards = data['cards'];

    final trucoValid = [
      'ACE', '2', '3', '4', '5', '6', '7', 'JACK', 'QUEEN', 'KING'
    ];

    return cards
        .where((card) => trucoValid.contains(card['value']))
        .map<Map<String, dynamic>>((card) => {
              'value': card['value'],
              'suit': card['suit'],
              'image': card['image'],
            })
        .toList();
  } else {
    throw Exception('Falha ao carregar cartas');
  }
}

}
