import 'package:flutter/material.dart';
import 'truco.dart';
import './counting games/home.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Widget _buildGameButton(String text, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(onPressed: onPressed, child: Text(text)),
    );
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
                  // Título do jogo
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

                  // Logo do jogo
                  Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      image: const DecorationImage(
                        image: AssetImage('assets/logo.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Botões do menu
                  Column(
                    children: [
                      _buildGameButton(
                        'Jogar de 2',
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => TrucoPage()),
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
                            builder: (context) => CounterHomePage(),
                          ),
                        ),
                      ),
                      _buildGameButton(
                        'Configurações',
                        () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Config não implementado.'),
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
