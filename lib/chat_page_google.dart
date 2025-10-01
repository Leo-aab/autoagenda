import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

const apiKey = 'coloque sua key aqui';

Future<void> main() async {
  runApp(MaterialApp(
    home: ChatPage(),
  ));
}

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat com IA',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        fontFamily: 'Montserrat',
        scaffoldBackgroundColor: Colors.white,
      ),
      home: ChatPage(),
    );
  }
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  Future<void> _generateResponse(String prompt) async {
    setState(() {
      _isLoading = true;
    });

    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );

    try {
      final response = await model.generateContent([Content.text(prompt)]);
      setState(() {
        _messages.add({
          'sender': 'Elise',
          'text': response.text ?? 'Erro ao gerar resposta.'
        });
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add({'sender': 'Elise', 'text': 'Erro ao gerar resposta.'});
        _isLoading = false;
      });
    }
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'sender': 'Você', 'text': text});
      _controller.clear();
    });

    _generateResponse(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Chat com IA', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple[500],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUserMessage = message['sender'] == 'Você';
                return Align(
                  alignment: isUserMessage
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isUserMessage
                          ? Colors.deepPurple[
                              200] // Cor de fundo da mensagem do usuário
                          : Colors.grey[300], // Cor de fundo da mensagem da IA
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message['sender']!,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: isUserMessage
                                ? Colors
                                    .deepPurple[900] // Cor do texto do usuário
                                : Colors.black87, // Cor do texto da IA
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          message['text']!,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.0,
                            color: isUserMessage
                                ? Colors
                                    .deepPurple[900] // Cor do texto do usuário
                                : Colors.black87, // Cor do texto da IA
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[100],
                      hintText: 'Digite sua mensagem...',
                      hintStyle: const TextStyle(color: Colors.black),
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(
                        color:
                            Colors.black), // Define a cor da fonte como preta
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.deepPurple,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
