// como instalar o widget no android vitão games
// pasta android/app/main/src/res aí tu cria
// past layout e cria widget_layout.xml

// dentro do res cria uma pasta chamada xml e nela o truco_score_widget_info.xml

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Histórico de Truco',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.grey[900],
      ),
      home: GameHistoryPage(),
    );
  }
}

class GameHistoryPage extends StatefulWidget {
  const GameHistoryPage({super.key});

  @override
  _GameHistoryPageState createState() => _GameHistoryPageState();
}

class _GameHistoryPageState extends State<GameHistoryPage> {
  List<Map<String, dynamic>> gameHistory = [];
  int roundNumber = 1;

  // Pontuação para o widget
  int nosPoints = 0;
  int elesPoints = 0;

  Database? _database;

  final _playerController = TextEditingController();
  final _detailsController = TextEditingController();
  String _selectedAction = 'TRUCAR';

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  @override
  void dispose() {
    _playerController.dispose();
    _detailsController.dispose();
    _database?.close();
    super.dispose();
  }

  // Inicializar Home Widget



  // Inicializar banco de dados
  Future<void> _initDatabase() async {
    try {
      final databasePath = await getDatabasesPath();
      final path = join(databasePath, 'truco_history.db');

      _database = await openDatabase(
        path,
        version: 2, // Incrementar versão para adicionar tabela de pontuação
        onCreate: (db, version) async {
          await db.execute('''CREATE TABLE game_history(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              round INTEGER,
              timestamp TEXT,
              action TEXT,
              player TEXT,
              details TEXT
            )''');

          await db.execute('''CREATE TABLE score(
              id INTEGER PRIMARY KEY,
              nos_points INTEGER DEFAULT 0,
              eles_points INTEGER DEFAULT 0,
              updated_at TEXT
            )''');

          // Inserir registro inicial de pontuação
          await db.insert('score', {
            'id': 1,
            'nos_points': 0,
            'eles_points': 0,
            'updated_at': DateTime.now().toIso8601String(),
          });
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) {
            await db.execute('''CREATE TABLE score(
                id INTEGER PRIMARY KEY,
                nos_points INTEGER DEFAULT 0,
                eles_points INTEGER DEFAULT 0,
                updated_at TEXT
              )''');

            await db.insert('score', {
              'id': 1,
              'nos_points': 0,
              'eles_points': 0,
              'updated_at': DateTime.now().toIso8601String(),
            });
          }
        },
      );

      await _loadHistoryFromDatabase();
      await _loadScoreFromDatabase();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context as BuildContext).showSnackBar(
          SnackBar(
            content: Text('Erro ao inicializar banco de dados: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _loadScoreFromDatabase() async {
    try {
      if (_database != null) {
        final List<Map<String, dynamic>> result = await _database!.query(
          'score',
          where: 'id = ?',
          whereArgs: [1],
        );

        if (result.isNotEmpty) {
          setState(() {
            nosPoints = result.first['nos_points'] ?? 0;
            elesPoints = result.first['eles_points'] ?? 0;
          });
        }
      }
    } catch (e) {
      debugPrint('Erro ao carregar pontuação: $e');
    }
  }

  Future<void> _saveScoreToDatabase() async {
    try {
      if (_database != null) {
        await _database!.update(
          'score',
          {
            'nos_points': nosPoints,
            'eles_points': elesPoints,
            'updated_at': DateTime.now().toIso8601String(),
          },
          where: 'id = ?',
          whereArgs: [1],
        );
      }
    } catch (e) {
      debugPrint('Erro ao salvar pontuação: $e');
    }
  }

  Future<void> _loadHistoryFromDatabase() async {
    try {
      if (_database != null) {
        final List<Map<String, dynamic>> maps = await _database!.query(
          'game_history',
          orderBy: 'id ASC',
        );

        setState(() {
          gameHistory =
              maps
                  .map(
                    (map) => {
                      'id': map['id'],
                      'round': map['round'],
                      'timestamp': DateTime.parse(map['timestamp']),
                      'action': map['action'],
                      'player': map['player'],
                      'details': map['details'],
                    },
                  )
                  .toList();
        });

        if (gameHistory.isNotEmpty) {
          final lastEntry = gameHistory.last;
          setState(() {
            roundNumber = lastEntry['round'] ?? 1;
          });
        }
      }
    } catch (e) {
      debugPrint('Erro ao carregar histórico: $e');
    }
  }

  Future<void> addToHistory(
    String action,
    String player, {
    String? details,
  }) async {
    try {
      final timestamp = DateTime.now();
      final entry = {
        'round': roundNumber,
        'timestamp': timestamp,
        'action': action,
        'player': player,
        'details': details,
      };

      if (_database != null) {
        final id = await _database!.insert('game_history', {
          'round': roundNumber,
          'timestamp': timestamp.toIso8601String(),
          'action': action,
          'player': player,
          'details': details,
        });
        entry['id'] = id;
      }

      debugPrint('Ação salva no banco com ID: $entry');
      setState(() {
        gameHistory.add(entry);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context as BuildContext).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar no histórico: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> clearHistory() async {
    try {
      if (_database != null) {
        await _database!.delete('game_history');
      }
      setState(() {
        gameHistory.clear();
      });
    } catch (e) {
      debugPrint('Erro ao limpar histórico: $e');
    }
  }

  Future<void> _resetScore() async {
    setState(() {
      nosPoints = 0;
      elesPoints = 0;
    });
    await _saveScoreToDatabase();

    if (mounted) {
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        SnackBar(
          content: Text('Pontuação resetada!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _addAction() async {
    if (_playerController.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context as BuildContext).showSnackBar(
          SnackBar(
            content: Text('Por favor, insira o nome do jogador'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final details =
        _detailsController.text.isNotEmpty ? _detailsController.text : null;

    await addToHistory(
      _selectedAction,
      _playerController.text,
      details: details,
    );

    _playerController.clear();
    _detailsController.clear();

    if (mounted) {
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        SnackBar(
          content: Text('Ação adicionada ao histórico!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Histórico de Truco'),
        backgroundColor: Colors.grey[800],
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () => showGameHistory(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Marcador de pontos
            Card(
              color: Colors.grey[800],
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Marcador de Pontos',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                'NÓS',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[400],
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '$nosPoints',
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[400],
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        if (nosPoints > 0) nosPoints--;
                                      });
                                      _saveScoreToDatabase();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red[700],
                                      shape: CircleBorder(),
                                      padding: EdgeInsets.all(12),
                                    ),
                                    child: Icon(Icons.remove, size: 20),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        nosPoints++;
                                      });
                                      _saveScoreToDatabase();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green[700],
                                      shape: CircleBorder(),
                                      padding: EdgeInsets.all(12),
                                    ),
                                    child: Icon(Icons.add, size: 20),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 2,
                          height: 120,
                          color: Colors.grey[600],
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                'ELES',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red[400],
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '$elesPoints',
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red[400],
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        if (elesPoints > 0) elesPoints--;
                                      });
                                      _saveScoreToDatabase();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red[700],
                                      shape: CircleBorder(),
                                      padding: EdgeInsets.all(12),
                                    ),
                                    child: Icon(Icons.remove, size: 20),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        elesPoints++;
                                      });
                                      _saveScoreToDatabase();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green[700],
                                      shape: CircleBorder(),
                                      padding: EdgeInsets.all(12),
                                    ),
                                    child: Icon(Icons.add, size: 20),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _resetScore,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[700],
                      ),
                      child: Text('Zerar Pontuação'),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            Card(
              color: Colors.grey[800],
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Adicionar Jogada',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 16),

                    TextField(
                      controller: _playerController,
                      decoration: InputDecoration(
                        labelText: 'Nome do Jogador',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey[700],
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      value: _selectedAction,
                      decoration: InputDecoration(
                        labelText: 'Ação',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey[700],
                      ),
                      items:
                          [
                                'TRUCAR',
                                'ACEITAR',
                                'CORRER',
                                'SEIS',
                                'NOVE',
                                'DOZE',
                              ]
                              .map(
                                (action) => DropdownMenuItem(
                                  value: action,
                                  child: Text(action),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedAction = value!;
                        });
                      },
                      dropdownColor: Colors.grey[700],
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: 12),

                    TextField(
                      controller: _detailsController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Detalhes (opcional)',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey[700],
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _addAction,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[700],
                              padding: EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text('Adicionar Jogada'),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => showGameHistory(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[700],
                              padding: EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text('Ver Histórico'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Controles do jogo
            Card(
              color: Colors.grey[800],
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Controles do Jogo',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                roundNumber++;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple[700],
                            ),
                            child: Text('Próxima Rodada'),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () async {
                        await clearHistory();
                        await _resetScore();
                        setState(() {
                          roundNumber = 1;
                        });
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Jogo resetado!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[700],
                      ),
                      child: Text('Resetar Jogo'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showGameHistory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => StatefulBuilder(
            builder:
                (_, setState) => Container(
                  height: MediaQuery.of(context).size.height * 0.8,
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.history, color: Colors.white, size: 28),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Histórico da Partida',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.close, color: Colors.white),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(16),
                        color: Colors.grey[850],
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text(
                                  'Rodada Atual',
                                  style: TextStyle(color: Colors.grey[400]),
                                ),
                                Text(
                                  '$roundNumber',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  'Total de Ações',
                                  style: TextStyle(color: Colors.grey[400]),
                                ),
                                Text(
                                  '${gameHistory.length}',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child:
                            gameHistory.isEmpty
                                ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.history,
                                        size: 64,
                                        color: Colors.grey[600],
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'Nenhuma ação ainda',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.grey[400],
                                        ),
                                      ),
                                      Text(
                                        'Faça sua primeira jogada!',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                : ListView.builder(
                                  itemCount: gameHistory.length,
                                  reverse: true,
                                  itemBuilder: (context, index) {
                                    final historyIndex =
                                        gameHistory.length - 1 - index;
                                    final entry = gameHistory[historyIndex];
                                    return historyTile(entry, historyIndex);
                                  },
                                ),
                      ),
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          border: Border(
                            top: BorderSide(color: Colors.grey[700]!),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed:
                                    () =>
                                        _clearHistoryWithConfirmation(context),
                                icon: Icon(Icons.delete_sweep),
                                label: Text('Limpar Histórico'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red[700],
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => Navigator.pop(context),
                                icon: Icon(Icons.check),
                                label: Text('Fechar'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue[700],
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  Future<void> _clearHistoryWithConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Confirmar'),
            content: Text('Tem certeza que deseja limpar todo o histórico?'),
            backgroundColor: Colors.grey[800],
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text('Confirmar'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await clearHistory();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Histórico limpo com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Widget historyTile(Map<String, dynamic> entry, int index) {
    String actionText = entry['action'];
    String playerName = entry['player'];
    String? details = entry['details'];
    DateTime timestamp = entry['timestamp'];

    Color actionColor = _getActionColor(actionText);
    IconData actionIcon = _getActionIcon(actionText);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: actionColor.withOpacity(0.2),
          child: Icon(actionIcon, color: actionColor, size: 20),
        ),
        title: Row(
          children: [
            Text(
              playerName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: actionColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                actionText,
                style: TextStyle(
                  color: actionColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (details != null)
              Text(
                details,
                style: TextStyle(color: Colors.grey[400], fontSize: 13),
              ),
            SizedBox(height: 4),
            Row(
              children: [
                Text(
                  'Rodada ${entry['round']}',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
                SizedBox(width: 12),
                Text(
                  '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        dense: true,
      ),
    );
  }

  Color _getActionColor(String action) {
    switch (action.toUpperCase()) {
      case 'TRUCAR':
        return Colors.orange;
      case 'ACEITAR':
        return Colors.green;
      case 'CORRER':
        return Colors.purple;
      case 'SEIS':
        return Colors.blue;
      case 'NOVE':
        return Colors.teal;
      case 'DOZE':
        return Colors.amber;
      default:
        return Colors.white;
    }
  }

  IconData _getActionIcon(String action) {
    switch (action.toUpperCase()) {
      case 'TRUCAR':
        return Icons.flash_on;
      case 'ACEITAR':
        return Icons.check_circle;
      case 'CORRER':
        return Icons.directions_run;
      case 'SEIS':
        return Icons.looks_6;
      case 'NOVE':
        return Icons.looks_3_sharp;
      case 'DOZE':
        return Icons.exposure_plus_1;
      default:
        return Icons.circle;
    }
  }
}
