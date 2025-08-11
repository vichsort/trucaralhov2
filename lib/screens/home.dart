import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'package:trucaralho/screens/truco.dart';
import 'package:trucaralho/screens/configs.dart';
import 'package:trucaralho/screens/counting games/home.dart';
import 'package:trucaralho/logic/notifications.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Widget _buildGameButton(String text, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: () async {
          await _vibrate();
          SimpleNotification.startTimer();
          onPressed();
        },
        child: Text(text),
      ),
    );
  }

  Future<void> _vibrate() async {
    bool? hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      Vibration.vibrate(duration: 50);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/fundo.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'Trucaralho',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.black54,
                          offset: Offset(2.0, 2.0),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  Container(
                    width: 250,
                    height: 250,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('images/logo.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  Column(
                    children: [
                      _buildGameButton(
                        'Jogar de 2',
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TrucoPage(),
                          ),
                        ),
                      ),
                      _buildGameButton(
                        'Jogar de 4',
                        () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Modo Jogar de 4 ainda não implementado.',
                            ),
                          ),
                        ),
                      ),
                      _buildGameButton(
                        'Outros Jogos',
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CounterHomePage(),
                          ),
                        ),
                      ),
                      _buildGameButton(
                        'Configurações',
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ConfigPage(),
                          ),
                        ),
                      ),
                      _buildGameButton(
                        'Histórico',
                        () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Histórico ainda não implementado.'),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => SimpleNotification.testNotification(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                        child: const Text(
                          'Teste',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
