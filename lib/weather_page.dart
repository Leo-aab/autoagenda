import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  _WeatherPageState createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  String _city = "Campinas"; // Cidade padrão
  String? _weatherDescription;
  double? _temperature;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _fetchWeather() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final coordinatesResponse = await http.get(
        Uri.parse(
            'https://nominatim.openstreetmap.org/search?q=$_city&format=json'),
      );

      if (coordinatesResponse.statusCode == 200) {
        final coordinatesData = jsonDecode(coordinatesResponse.body);
        print(coordinatesData); // Verificar dados retornados

        if (coordinatesData.isEmpty) {
          throw Exception("Cidade não encontrada.");
        }

        if (coordinatesData[0]['lat'] == null ||
            coordinatesData[0]['lon'] == null) {
          throw Exception("Coordenadas não encontradas para a cidade.");
        }

        double latitude = double.parse(coordinatesData[0]['lat']);
        double longitude = double.parse(coordinatesData[0]['lon']);

        final weatherResponse = await http.get(Uri.parse(
            'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current_weather=true'));

        if (weatherResponse.statusCode == 200) {
          final data = jsonDecode(weatherResponse.body);
          print(data); // Verificar os dados retornados da API de clima
          setState(() {
            _temperature = data['current_weather']
                ['temperature']; // Acessar a temperatura atual
            _weatherDescription = "Clima em $_city";
            _isLoading = false;
          });
        } else {
          setState(() {
            _weatherDescription = null;
            _temperature = null;
            _errorMessage = "Erro ao buscar o clima para a cidade $_city.";
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = "Erro ao buscar as coordenadas para a cidade $_city.";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage =
            "Erro ao buscar as coordenadas para a cidade $_city: ${e.toString()}";
        _isLoading = false;
      });
    } finally {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Page'),
        backgroundColor: const Color.fromARGB(255, 110, 142, 168),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Digite a cidade',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _city = value;
                });
              },
              onSubmitted: (value) {
                _fetchWeather();
              },
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const CircularProgressIndicator()
            else ...[
              Text(
                'Cidade: $_city',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              if (_temperature != null) ...[
                Text(
                  'Temperatura: ${_temperature!.toStringAsFixed(1)} °C',
                  style: const TextStyle(fontSize: 20),
                ),
                Text(
                  'Descrição: $_weatherDescription',
                  style: const TextStyle(fontSize: 20),
                ),
              ] else if (_errorMessage != null) ...[
                Text(
                  _errorMessage!,
                  style: const TextStyle(fontSize: 20, color: Colors.red),
                ),
              ] else
                const Text(
                  'Dados não disponíveis',
                  style: TextStyle(fontSize: 20),
                ),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchWeather,
              child: const Text('Atualizar Clima'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: WeatherPage(),
  ));
}
