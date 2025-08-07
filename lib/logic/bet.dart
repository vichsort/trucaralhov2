import 'package:flutter/material.dart';
import 'package:trucaralho/logic/chip.dart';

class BetPage extends StatefulWidget {
  const BetPage({super.key});

  @override
  _BetPageState createState() => _BetPageState();
}

class BetController {
  BetController._privateConstructor();

  static final BetController instance = BetController._privateConstructor();

  Map<int, int> selectedIndices = {};
  int selectedValues = 0;

  final ValueNotifier<int> selectedValuesNotifier = ValueNotifier<int>(0);

  void save(Map<int, int> indices, int values) {
    selectedIndices = Map<int, int>.from(indices);
    selectedValues = values;
    selectedValuesNotifier.value = values;
  }

  void clear() {
    selectedIndices.clear();
    selectedValues = 0;
  }
}

class BetControllerManager {
  BetControllerManager._privateConstructor();

  static final BetControllerManager instance =
      BetControllerManager._privateConstructor();

  final Map<String, BetController> _controllers = {};

  BetController getController(String id) {
    return _controllers.putIfAbsent(
      id,
      () => BetController._privateConstructor(),
    );
  }

  void clearAll() {
    _controllers.clear();
  }
}

class _BetPageState extends State<BetPage> {
  final Map<int, int> selectedIndices = {};
  int selectedValues = 0;

  @override
  void initState() {
    super.initState();
    // salvos do controller (quando inicia)
    selectedIndices.addAll(BetController.instance.selectedIndices);
    selectedValues = BetController.instance.selectedValues;
  }

  @override
  void dispose() {
    // salva no controller (quando fecha)
    BetController.instance.save(selectedIndices, selectedValues);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Apostas')),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3 / 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: chips.length,
                itemBuilder: (context, index) {
                  final ficha = chips[index];
                  int count = selectedIndices[index] ?? 0;

                  return Card(
                    color: count > 0 ? Colors.blue[900] : Colors.grey[700],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (ficha.caminhoImagem.isNotEmpty)
                          Image.asset(
                            ficha.caminhoImagem,
                            height: 20,
                            fit: BoxFit.contain,
                          ),
                        const SizedBox(height: 4),
                        Text(
                          ficha.nome,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('Valor: \$: ${ficha.valor}'),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              color: Colors.white,
                              onPressed: count > 0
                                  ? () {
                                      setState(() {
                                        if (selectedIndices[index] != null &&
                                            selectedIndices[index]! > 1) {
                                          selectedIndices[index] =
                                              selectedIndices[index]! - 1;
                                        } else {
                                          selectedIndices.remove(index);
                                        }
                                        selectedValues -= chips[index].valor;
                                        BetController.instance.save(
                                          selectedIndices,
                                          selectedValues,
                                        );
                                      });
                                    }
                                  : null,
                            ),
                            Text(
                              '$count',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              color: Colors.white,
                              onPressed: () {
                                setState(() {
                                  selectedIndices[index] =
                                      (selectedIndices[index] ?? 0) + 1;
                                  selectedValues += chips[index].valor;
                                  BetController.instance.save(
                                    selectedIndices,
                                    selectedValues,
                                  );
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            Text('Total adicionado: $selectedValues'),
          ],
        ),
      ),
    );
  }
}

Widget pokerCall(
  void Function(int) handleCall,
  String side,
  int leftValue,
  int rightValue,
) {
  final controller = BetControllerManager.instance.getController(side);
  final indices = Map<int, int>.from(controller.selectedIndices);
  int betAmount = controller.selectedValues;

  return StatefulBuilder(
    builder: (_, setState) => Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'CALL - Fazer Aposta',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        Text(
          'Seu saldo: \$${side == 'left' ? leftValue : rightValue}',
          style: TextStyle(fontSize: 18),
        ),
        Text(
          'Valor da aposta: \$${betAmount}',
          style: TextStyle(fontSize: 20, color: Colors.blue),
        ),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3 / 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: chips.length,
            itemBuilder: (_, index) {
              final ficha = chips[index];
              int count = indices[index] ?? 0;
              return Card(
                color: count > 0 ? Colors.blue[900] : Colors.grey[700],
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      ficha.caminhoImagem,
                      height: 26,
                      fit: BoxFit.contain,
                    ),
                    Text(
                      ficha.nome,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('Valor: \$${ficha.valor}'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          color: Colors.white,
                          onPressed: count > 0
                              ? () {
                                  setState(() {
                                    indices[index] = (indices[index]! > 1)
                                        ? indices[index]! - 1
                                        : 0;
                                    betAmount -= ficha.valor;
                                    controller.save(indices, betAmount);
                                  });
                                }
                              : null,
                        ),
                        Text(
                          '$count',
                          style: const TextStyle(color: Colors.white),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          color: Colors.white,
                          onPressed: () {
                            int playerValue = side == 'left'
                                ? leftValue
                                : rightValue;
                            if (betAmount + ficha.valor <= playerValue) {
                              setState(() {
                                indices[index] = (indices[index] ?? 0) + 1;
                                betAmount += ficha.valor;
                                controller.save(indices, betAmount);
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: betAmount > 0 ? () => handleCall(betAmount) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: Text(
                    'CALL - Apostar \$${betAmount}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget PokerRaise(
  void Function(int) raise,
  int currentBet,
  String side,
  int leftValue,
  int rightValue,
) {
  final controller = BetControllerManager.instance.getController(
    '${side}raise',
  );
  final indices = Map<int, int>.from(controller.selectedIndices);
  int raiseAmount = controller.selectedValues;

  return StatefulBuilder(
    builder: (_, setState) => Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'RAISE - Aumentar Aposta',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                'Aposta atual: ${currentBet}',
                style: TextStyle(fontSize: 18, color: Colors.yellow),
              ),
              Text(
                'Seu saldo: \$${side == 'left' ? leftValue : rightValue}',
                style: TextStyle(fontSize: 18),
              ),
              Text(
                'Valor do raise: \$${raiseAmount}',
                style: TextStyle(fontSize: 20, color: Colors.orange),
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3 / 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: chips.length,
            itemBuilder: (_, index) {
              final ficha = chips[index];
              int count = indices[index] ?? 0;
              return Card(
                color: count > 0 ? Colors.orange[900] : Colors.grey[700],
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      ficha.caminhoImagem,
                      height: 26,
                      fit: BoxFit.contain,
                    ),
                    Text(
                      ficha.nome,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('Valor: \$${ficha.valor}'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          color: Colors.white,
                          onPressed: count > 0
                              ? () {
                                  setState(() {
                                    indices[index] = (indices[index]! > 1)
                                        ? indices[index]! - 1
                                        : 0;
                                    raiseAmount -= ficha.valor;
                                    controller.save(indices, raiseAmount);
                                  });
                                }
                              : null,
                        ),
                        Text(
                          '$count',
                          style: const TextStyle(color: Colors.white),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          color: Colors.white,
                          onPressed: () {
                            int playerValue = side == 'left'
                                ? leftValue
                                : rightValue;
                            int totalCost =
                                currentBet + raiseAmount + ficha.valor;
                            if (totalCost <= playerValue) {
                              setState(() {
                                indices[index] = (indices[index] ?? 0) + 1;
                                raiseAmount += ficha.valor;
                                controller.save(indices, raiseAmount);
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: raiseAmount > 0 ? () => raise(raiseAmount) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: Text(
                    'RAISE +${raiseAmount} (Total: ${currentBet + raiseAmount})',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
