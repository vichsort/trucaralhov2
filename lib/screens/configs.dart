import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

class ConfigPage extends StatefulWidget {
  const ConfigPage({super.key});

  @override
  State<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  bool isVibrationEnabled = true;
  bool isNotificationEnabled = true;
  bool isDarkModeEnabled = true;

  Future<void> _vibrate() async {
    bool? hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true && isVibrationEnabled) {
      Vibration.vibrate(duration: 50);
    }
  }

  Widget buildSwitchTile(
    String title,
    bool value,
    void Function(bool) onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(30),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: const Color.fromARGB(255, 124, 201, 127),
      ),
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
                children: [
                  const Text(
                    'Configurações',
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
                  const SizedBox(height: 40),
                  buildSwitchTile('Ativar Vibração', isVibrationEnabled, (
                    value,
                  ) {
                    setState(() => isVibrationEnabled = value);
                    _vibrate();
                  }),
                  buildSwitchTile(
                    'Ativar Notificações',
                    isNotificationEnabled,
                    (value) {
                      setState(() => isNotificationEnabled = value);
                      _vibrate();
                    },
                  ),
                  buildSwitchTile('Modo Noturno', isDarkModeEnabled, (value) {
                    setState(() => isDarkModeEnabled = value);
                    _vibrate();
                  }),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
