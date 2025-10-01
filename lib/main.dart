import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:io' show Platform;
import 'package:permission_handler/permission_handler.dart';
import 'package:sidebarx/sidebarx.dart';
import 'chat_page_google.dart';
import 'dart:convert';
import 'weather_page.dart';


//inicialização do aplciatvo
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  final prefs = await SharedPreferences.getInstance();
  final isDarkTheme = prefs.getBool('isDarkTheme') ?? false;
  final isLightTheme = prefs.getBool('isLightTheme') ?? true;
  runApp(MyApp(
    isDarkTheme: isDarkTheme,
    isLightTheme: isLightTheme,
  ));
}

class MyApp extends StatefulWidget {
  final bool isDarkTheme;
  final bool isLightTheme;

  const MyApp(
      {super.key, required this.isDarkTheme, required this.isLightTheme});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool _isDarkTheme;
  late bool _isLightTheme;

  @override
  void initState() {
    super.initState();
    _isDarkTheme = widget.isDarkTheme;
    _isLightTheme = widget.isLightTheme;
  }

  Future<void> _toggleTheme() async {
    setState(() {
      _isDarkTheme = !_isDarkTheme;
      _isLightTheme = !_isLightTheme;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkTheme', _isDarkTheme);
    await prefs.setBool('isLightTheme', _isLightTheme);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Elise Agenda',
      theme: _isDarkTheme
          ? ThemeData.dark().copyWith(
              colorScheme: const ColorScheme.dark(
                primary: Colors.deepPurpleAccent,
                secondary: Colors.amberAccent,
                onPrimary: Colors.white,
                onSecondary: Colors.black,
                surface: Color(0xFF1E1E1E),
                onSurface: Colors.white,
              ),
              textTheme: const TextTheme(
                displayMedium: TextStyle(color: Colors.white),
                bodyMedium: TextStyle(color: Colors.white70),
                bodySmall: TextStyle(color: Colors.white),
              ),
              inputDecorationTheme: InputDecorationTheme(
                labelStyle: const TextStyle(color: Colors.white),
                hintStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              tabBarTheme: const TabBarTheme(
                unselectedLabelColor: Colors.white70,
                labelColor: Colors.white,
                indicatorColor: Colors.amberAccent,
              ),
            )
          : ThemeData.light().copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFFAB47BC),
                secondary: Colors.amber,
                onPrimary: Colors.white,
                onSecondary: Colors.black,
                surface: Color.fromARGB(255, 224, 224, 224),
                onSurface: Colors.black,
              ),
              tabBarTheme: const TabBarTheme(
                unselectedLabelColor: Colors.black54,
                labelColor: Colors.black,
                indicatorColor: Color(0xFFAB47BC),
              ),
            ),
      home: MyHomePage(
        title: 'AutoAgenda',
        toggleTheme: _toggleTheme,
        isDarkTheme: _isDarkTheme,
        isLightTheme: _isLightTheme,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  final Function toggleTheme;
  final bool isDarkTheme;
  final bool isLightTheme;

  const MyHomePage({
    required this.title,
    required this.toggleTheme,
    required this.isDarkTheme,
    required this.isLightTheme,
    super.key,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String nome = '', email = '', senha = '';
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  @override
  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(
                widget.isDarkTheme ? Icons.wb_sunny : Icons.nightlight_round),
            onPressed: () => widget.toggleTheme(),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Campo de Nome
                TextField(
                  controller: nomeController,
                  decoration: const InputDecoration(
                    labelText: 'Digite seu nome',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                // Campo de Email
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Digite seu e-mail',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                // Campo de Senha
                TextField(
                  controller: senhaController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Digite sua senha',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                // Botão de Acessar
                ElevatedButton(
                  onPressed: () {
                    nome = nomeController.text.trim();
                    email = emailController.text.trim();
                    senha = senhaController.text.trim();
                    //Validar o email
                    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                    if (senha.isEmpty || nome.isEmpty || email.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Preencha os campos!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    } else if (!emailRegex.hasMatch(email)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Insira um email válido'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    } else if (senha.length < 6) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content:
                            Text('A senha deve ter pelo menos 6 caracteres!'),
                        duration: Duration(seconds: 2),
                      ));
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NoteHomePage(
                            nome: nome.split(' ')[0],
                            email: email,
                            senha: senha,
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text('Acessar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Página Principal com Sidebar e TabBar
class NoteHomePage extends StatefulWidget {
  const NoteHomePage({
    required this.nome,
    required this.email,
    required this.senha,
    super.key,
  });

  final String nome;
  final String email;
  final String senha;

  @override
  State<NoteHomePage> createState() => _NoteHomePageState();
}

class _NoteHomePageState extends State<NoteHomePage> {
  late SidebarXController _sidebarController;

  @override
  void initState() {
    super.initState();
    _sidebarController = SidebarXController(selectedIndex: 0, extended: true);
    _sidebarController.addListener(_onSidebarChange);
  }

  @override
  void dispose() {
    _sidebarController.removeListener(_onSidebarChange);
    _sidebarController.dispose();
    super.dispose();
  }

  void _onSidebarChange() {
    if (_sidebarController.selectedIndex == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const WeatherPage(),
        ),
      );
    } else if (_sidebarController.selectedIndex == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Você já está na página de Notas'),
          duration: Duration(seconds: 2),
        ),
      );
    } else if (_sidebarController.selectedIndex == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Olá, ${widget.nome}"),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Notas'),
              Tab(text: 'Lembretes'),
            ],
          ),
        ),
        drawer: Drawer(
          child: ListView(
            padding: const EdgeInsets.all(0),
            children: <Widget>[
              // Cabeçalho do Drawer
              UserAccountsDrawerHeader(
                accountName: Text(widget.nome),
                accountEmail: Text(widget.email),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                  child: Text(
                    widget.nome[0],
                    style: const TextStyle(
                      fontSize: 40.0,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              // Item do Drawer para Clima
              ListTile(
                leading: const Icon(Icons.wb_sunny),
                title: const Text('Clima'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WeatherPage(),
                    ),
                  );
                },
              ),
              // Item do Drawer para Notas - drawerkkkkk
              ListTile(
                leading: const Icon(Icons.note),
                title: const Text('Notas'),
                onTap: () {
                  Navigator.pop(context); // Fecha o Drawer
                },
              ),

              ListTile(
                leading: const Icon(Icons.chat),
                title: const Text('Elise'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            NoteTab(),
            ReminderPage(),
          ],
        ),
      ),
    );
  }
}

//Pagina de notasss

class NoteTab extends StatefulWidget {
  const NoteTab({super.key});

  @override
  _NoteTabState createState() => _NoteTabState();
}

class _NoteTabState extends State<NoteTab> with SingleTickerProviderStateMixin {
  final TextEditingController _noteController = TextEditingController();
  final List<String> _notes = [];
  final List<Color> _noteColors = [];
  int _selectedNoteIndex = -1;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadNotes(); // Carrega as notas sempre que a aba for exibida
  }

  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final savedNotes = prefs.getStringList('notes') ?? [];
    final savedColors = prefs
            .getStringList('noteColors')
            ?.map((e) => Color(int.parse(e)))
            .toList() ??
        [];

    setState(() {
      _notes
        ..clear()
        ..addAll(savedNotes);
      _noteColors
        ..clear()
        ..addAll(savedColors);
    });
  }

  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('notes', _notes);
    await prefs.setStringList(
      'noteColors',
      _noteColors.map((color) => color.value.toString()).toList(),
    );
  }

  void _addNote() {
    if (_noteController.text.isNotEmpty) {
      setState(() {
        _notes.add(_noteController.text);
        _noteColors.add(const Color.fromARGB(255, 196, 165, 255));
        _noteController.clear();
        _animationController.forward(from: 0);
      });
      _saveNotes();
    }
  }

  void _deleteNote(int index) {
    setState(() {
      _notes.removeAt(index);
      _noteColors.removeAt(index);
      _selectedNoteIndex = -1;
    });
    _saveNotes();
  }

  void _changeNoteColor(int index) {
    showDialog(
      context: context,
      builder: (context) {
        Color currentColor = _noteColors[index];
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text(
            'Escolha uma cor',
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: currentColor,
              onColorChanged: (Color color) {
                setState(() {
                  currentColor = color;
                });
              },
              showLabel: true,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
              ),
              child: const Text('Selecionar'),
              onPressed: () {
                setState(() {
                  _noteColors[index] = currentColor;
                });
                _saveNotes();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _openColorPicker() {
    if (_selectedNoteIndex != -1) {
      _changeNoteColor(_selectedNoteIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Adicionar um diálogo para adicionar uma nova nota
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Adicionar Nota'),
              content: SizedBox(
                width: double.maxFinite,
                child: TextField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                    hintText: 'Digite sua nota',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                  minLines: 3,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _addNote();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Adicionar'),
                ),
              ],
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: _notes.isEmpty
          ? const Center(
              child: Text(
                'Nenhuma nota adicionada',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                itemCount: _notes.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Número de colunas
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  childAspectRatio: 3 / 2, // Proporção do cartão
                ),
                itemBuilder: (context, index) {
                  final note = _notes[index];
                  final color = _noteColors[index];
                  return GestureDetector(
                    onLongPress: () {
                      // Opcional: adicionar ações ao pressionar e segurar o cartão
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => Wrap(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.color_lens),
                              title: const Text('Alterar Cor'),
                              onTap: () {
                                Navigator.of(context).pop();
                                _selectedNoteIndex = index;
                                _openColorPicker();
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.delete),
                              title: const Text('Excluir Nota'),
                              onTap: () {
                                Navigator.of(context).pop();
                                _deleteNote(index);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                    child: Card(
                      color: color,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                child: Text(
                                  note,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.color_lens,
                                      color: Colors.black54),
                                  onPressed: () {
                                    _selectedNoteIndex = index;
                                    _openColorPicker();
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () => _deleteNote(index),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

// Página de Lembretes
//fazer a logica de deletar o lembrete, adicionar o shared preferences também
//erros na notificações, pedir pra que o aplicativo peça alguma permissão de notificação
class ReminderPage extends StatefulWidget {
  const ReminderPage({super.key});

  @override
  _ReminderPageState createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  final TextEditingController _reminderController = TextEditingController();
  final List<Map<String, dynamic>> _reminders = [];
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    _initializeNotifications();
    _requestNotificationPermission();
    _loadReminders(); // Carregar lembretes ao iniciar a tela
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse response) async {
      if (response.payload != null) {
        debugPrint('notification payload: ${response.payload}');
      }
    });
  }

  Future<void> _requestNotificationPermission() async {
    if (Platform.isAndroid) {
      if (await Permission.notification.isDenied) {
        final result = await Permission.notification.request();
        if (result.isGranted) {
          debugPrint('Permissão para notificações concedida');
        } else {
          debugPrint('Permissão para notificações negada');
        }
      } else {
        debugPrint('Permissão para notificações já concedida');
      }
    }
  }

  Future<void> _loadReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final savedReminders = prefs.getStringList('reminders') ?? [];

    setState(() {
      _reminders.clear();
      for (var reminder in savedReminders) {
        final reminderMap = Map<String, dynamic>.from(
            Map<String, dynamic>.from(json.decode(reminder)));
        reminderMap['dateTime'] =
            DateTime.parse(reminderMap['dateTime'] as String);
        _reminders.add(reminderMap);
      }
    });
  }

  Future<void> _saveReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final reminders = _reminders
        .map((reminder) => json.encode({
              'text': reminder['text'],
              'dateTime': reminder['dateTime'].toIso8601String(),
              'id': reminder['id'],
            }))
        .toList();
    await prefs.setStringList('reminders', reminders);
  }

  Future<void> _addReminder(DateTime dateTime) async {
    final reminderText = _reminderController.text.trim();
    if (reminderText.isNotEmpty) {
      final int reminderId = DateTime.now().millisecondsSinceEpoch;
      setState(() {
        _reminders.add({
          'text': reminderText,
          'dateTime': dateTime,
          'id': reminderId,
        });
        _reminderController.clear();
      });
      _saveReminders();

      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'lembrete_channel_id',
        'Lembretes',
        channelDescription: 'Canal para lembretes e alarmes',
        importance: Importance.max,
        priority: Priority.high,
        sound: RawResourceAndroidNotificationSound('alarm_sound'),
        playSound: true,
        icon: '@mipmap/ic_launcher',
      );
      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      await flutterLocalNotificationsPlugin.zonedSchedule(
        reminderId,
        'Lembrete',
        reminderText,
        tz.TZDateTime.from(dateTime, tz.local),
        platformChannelSpecifics,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dateAndTime,
      );
    }
  }

  Future<void> _deleteReminder(int index) async {
    final reminderId = _reminders[index]['id'];
    await flutterLocalNotificationsPlugin.cancel(reminderId);
    setState(() {
      _reminders.removeAt(index);
    });
    _saveReminders();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _reminderController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Digite seu lembrete',
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            ),
            child: const Text(
              'Adicionar Lembrete',
              style: TextStyle(fontSize: 16),
            ),
            onPressed: () async {
              final DateTime? selectedDateTime = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2101),
              );

              if (selectedDateTime != null) {
                final TimeOfDay? selectedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );

                if (selectedTime != null) {
                  final DateTime finalDateTime = DateTime(
                    selectedDateTime.year,
                    selectedDateTime.month,
                    selectedDateTime.day,
                    selectedTime.hour,
                    selectedTime.minute,
                  );

                  _addReminder(finalDateTime);
                }
              }
            },
          ),
          const SizedBox(height: 24),
          Expanded(
            child: _reminders.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhum lembrete adicionado',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    itemCount: _reminders.length,
                    itemBuilder: (context, index) {
                      final reminder = _reminders[index];
                      final reminderText = reminder['text'];
                      final reminderDateTime = reminder['dateTime'];

                      return Card(
                        color: Colors.deepPurple[50],
                        child: ListTile(
                          title: Text(
                            reminderText,
                            style: const TextStyle(color: Colors.black),
                          ),
                          subtitle: Text(
                            '${reminderDateTime.day}/${reminderDateTime.month}/${reminderDateTime.year} - ${reminderDateTime.hour.toString().padLeft(2, '0')}:${reminderDateTime.minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                                color: Colors.black54, fontSize: 14),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteReminder(index),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
