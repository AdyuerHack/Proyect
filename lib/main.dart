import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:proyect/services/gemini_service.dart';
import 'package:logger/logger.dart';

var logger = Logger();

// Modelo para representar una vacante
class Job {
  final String title;
  final String company;
  final String description;
  final String location;

  // *** CONSTRUCTOR CORREGIDO AQUÍ ***
  const Job({ // Añade 'const' aquí
    required this.title,
    required this.company,
    required this.description,
    required this.location,
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final String configString = await rootBundle.loadString('assets/config.json');
    final Map<String, dynamic> config = jsonDecode(configString);
    final apiKey = config['GEMINI_API_KEY'];

    if (apiKey == null || apiKey.isEmpty) {
      logger.e('Error: La clave API de Gemini no está configurada en config.json');
      return;
    }

    runApp(MyApp(geminiService: GeminiService(apiKey: apiKey)));
  } catch (e) {
    logger.e('Error al cargar config.json: $e');
    return;
  }
}

class MyApp extends StatelessWidget {
  final GeminiService geminiService;

  const MyApp({super.key, required this.geminiService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Job Swipe',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        cardTheme: CardTheme(
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      home: LoginScreen(geminiService: geminiService),
    );
  }
}

//Login Screen
class LoginScreen extends StatefulWidget {
  final GeminiService geminiService;

  const LoginScreen({super.key, required this.geminiService});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isRegistering = false;

  void _toggleMode() {
    setState(() => _isRegistering = !_isRegistering);
  }

  void _submit() {
    if (_emailController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
      if (_isRegistering && _nameController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Por favor, ingresa tu nombre')),
        );
        return;
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => JobSwipeScreen(
            userName: _isRegistering ? _nameController.text : 'Usuario',
            geminiService: widget.geminiService,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, completa todos los campos')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isRegistering ? 'Registrarse' : 'Iniciar Sesión')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isRegistering)
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nombre'),
              ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Correo Electrónico'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              child: Text(_isRegistering ? 'Registrarse' : 'Iniciar Sesión'),
            ),
            TextButton(
              onPressed: _toggleMode,
              child: Text(_isRegistering ? '¿Ya tienes cuenta? Inicia sesión' : '¿No tienes cuenta? Regístrate'),
            ),
          ],
        ),
      ),
    );
  }
}

// Pantalla Principal de Deslizamiento de Vacantes
class JobSwipeScreen extends StatefulWidget {
  final String userName;
  final GeminiService geminiService;

  // *** CONSTRUCTOR CORREGIDO AQUÍ ***
  const JobSwipeScreen({super.key, required this.userName, required this.geminiService}); // Añade 'const' aquí

  @override
  _JobSwipeScreenState createState() => _JobSwipeScreenState();
}

class _JobSwipeScreenState extends State<JobSwipeScreen> {
  final List<Job> jobs = [
    const Job( // Añade const si la clase Job es const
      title: 'Desarrollador Flutter',
      company: 'TechCorp',
      description: 'Trabaja en apps móviles innovadoras.',
      location: 'Remoto',
    ),
    const Job( // Añade const si la clase Job es const
      title: 'Diseñador UX/UI',
      company: 'DesignLabs',
      description: 'Crea interfaces intuitivas y atractivas.',
      location: 'Ciudad de México',
    ),
    const Job( // Añade const si la clase Job es const
      title: 'Analista de Datos',
      company: 'DataWorks',
      description: 'Interpreta datos para tomar decisiones.',
      location: 'Monterrey',
    ),
  ];

  int currentIndex = 0;
  int swipeCount = 0;
  int points = 0;
  final int questionInterval = 3;
  List<String> userPreferences = [];

  // ignore: unused_element
  void _onDismissed(DismissDirection direction) {
    _updatePoints(direction);
    _updateCurrentIndex();

    if (_shouldShowProfilingQuestion()) {
      _showProfilingQuestion();
    }

    if (_shouldGetRecommendations()) {
      _getRecommendations();
    }

    if (_shouldShowAchievement()) {
      _showAchievement();
    }
  }

  void _updatePoints(DismissDirection direction) {
    setState(() {
      if (direction == DismissDirection.startToEnd) {
        logger.d('Like: ${jobs[currentIndex].title}');
        points += 10;
      } else {
        logger.d('Dislike: ${jobs[currentIndex].title}');
        points += 5;
      }
    });
  }

  void _updateCurrentIndex() {
    setState(() {
      currentIndex = (currentIndex + 1) % jobs.length;
      swipeCount++;
    });
  }

  bool _shouldShowProfilingQuestion() {
    return swipeCount % questionInterval == 0;
  }

  bool _shouldGetRecommendations() {
    return swipeCount % 6 == 0 && userPreferences.isNotEmpty;
  }

  bool _shouldShowAchievement() {
    return points % 50 == 0 && points > 0;
  }

  void _getRecommendations() async {
    try {
      final respuesta = await obtenerVacantes();
      _showRecommendationDialog(respuesta);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al obtener recomendaciones: $e')),
      );
    }
  }

  Future<String> obtenerVacantes() async {
    final prompt = construirPrompt(userPreferences);

    try {
      final respuesta = await widget.geminiService.generarRespuesta(prompt);
      logger.i("Respuesta de la IA:\n$respuesta");
      return respuesta;
    } catch (e) {
      logger.e("Error al generar respuesta de la IA: $e");
      throw Exception('Error al generar respuesta de la IA: $e');
    }
  }

  void _showRecommendationDialog(String respuesta) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Recomendaciones de IA'),
        content: SingleChildScrollView(child: Text(respuesta)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showProfilingQuestion() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Pregunta Rápida'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('¿Qué tipo de trabajo prefieres?'),
            TextField(
              decoration: InputDecoration(hintText: 'Ej: Remoto, Presencial'),
              onSubmitted: (value) {
                setState(() {
                  userPreferences.add(value);
                  logger.d('Preferencia guardada: $value');
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAchievement() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('¡Logro desbloqueado! Has ganado $points puntos.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Explora Vacantes'),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(
                    userName: widget.userName,
                    points: points,
                    preferences: userPreferences,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.business),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CompanyScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Puntos: $points',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Center(
              child: currentIndex < jobs.length
                  ? Dismissible(
                key: Key(jobs[currentIndex].title),
                onDismissed: _onDismissed,
                background: Container(
                  color: Colors.green,
                  alignment: Alignment.centerLeft,
                  child: Icon(Icons.thumb_up, color: Colors.white),
                ),
                secondaryBackground: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  child: Icon(Icons.thumb_down, color: Colors.white),
                ),
                child: JobCard(job: jobs[currentIndex], onLike: () => _onDismissed(DismissDirection.startToEnd), onDislike: () => _onDismissed(DismissDirection.endToStart)),
              )
                  : Text('No hay más vacantes por ahora.'),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget de Tarjeta de Vacante
class JobCard extends StatelessWidget {
  final Job job;
  final VoidCallback onLike;
  final VoidCallback onDislike;

  // *** CONSTRUCTOR CORREGIDO AQUÍ ***
  const JobCard({required this.job, required this.onLike, required this.onDislike}); // Añade 'const' aquí

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 400,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(128),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            job.title,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          Text(
            job.company,
            style: TextStyle(fontSize: 18, color: Colors.grey[700]),
          ),
          SizedBox(height: 10),
          Text(
            'Ubicación: ${job.location}',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          SizedBox(height: 20),
          Text(
            job.description,
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: onDislike, // Llama a la función onDislike
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text('Dislike'),
              ),
              ElevatedButton(
                onPressed: onLike, // Llama a la función onLike
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: Text('Like'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ### Pantalla de Perfil del Candidato
class ProfileScreen extends StatelessWidget {
  final String userName;
  final int points;
  final List<String> preferences;

  // *** CONSTRUCTOR CORREGIDO AQUÍ ***
  const ProfileScreen({required this.userName, required this.points, required this.preferences}); // Añade 'const' aquí

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mi Perfil')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nombre: $userName', style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text('Puntos: $points', style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            Text('Mis Preferencias:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            preferences.isNotEmpty
                ? Column(
              children: preferences.map((pref) => Text('- $pref')).toList(),
            )
                : Text('Aún no has respondido preguntas.'),
          ],
        ),
      ),
    );
  }
}

// ### Pantalla para Empresas
class CompanyScreen extends StatefulWidget {
  // *** CONSTRUCTOR CORREGIDO AQUÍ ***
  const CompanyScreen({super.key}); // Añade 'const' aquí, y 'super.key' si no tenía un constructor explícito

  @override
  State<CompanyScreen> createState() => _CompanyScreenState();
}

class _CompanyScreenState extends State<CompanyScreen> {
  final _titleController = TextEditingController();
  final _companyController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  void _postJob() {
    if (_titleController.text.isNotEmpty &&
        _companyController.text.isNotEmpty &&
        _descriptionController.text.isNotEmpty &&
        _locationController.text.isNotEmpty) {
      logger.i('Vacante publicada: ${_titleController.text}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vacante publicada con éxito')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, completa todos los campos')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Publicar Vacante')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Título de la Vacante'),
            ),
            TextField(
              controller: _companyController,
              decoration: InputDecoration(labelText: 'Nombre de la Empresa'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Descripción'),
            ),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(labelText: 'Ubicación'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _postJob,
              child: Text('Publicar Vacante'),
            ),
          ],
        ),
      ),
    );
  }
}

//Funcion para llamar a la IA

// Mapa estructura del perfil del usuario
Map<String, int> userPreferences = {
  "Remoto": 0,
  "Presencial": 0,
  "Diseño UX": 0,
  "Ventas": 0,
  "Startups": 0,
  "Salario alto": 0,
};

// Funcion para actualizar puntos
void updatePreference(String categoria, int puntos) {
  if (userPreferences.containsKey(categoria)) {
    userPreferences[categoria] = userPreferences[categoria]! + puntos;
  } else {
    userPreferences[categoria] = puntos;
  }
}

// Construye prompt para la IA
String construirPrompt(List<String> preferencias) {
  String prompt = "Eres un recomendador inteligente de vacantes laborales. Basándote en las siguientes preferencias del usuario:\n";

  if (preferencias.isNotEmpty) {
    prompt += preferencias.map((pref) => "- $pref\n").join();
  } else {
    prompt += "El usuario aún no ha proporcionado preferencias.\n";
  }

  prompt += "Sugiere 3 vacantes ideales y 1 pregunta nueva para seguir entendiendo mejor sus gustos.  Formatea la respuesta de la siguiente manera:\n\n";
  prompt += "**Recomendaciones:**\n";
  prompt += "1. [Título de la vacante] en [Nombre de la empresa] - [Descripción breve]\n";
  prompt += "2. [Título de la vacante] en [Nombre de la empresa] - [Descripción breve]\n";
  prompt += "3. [Título de la vacante] en [Nombre de la empresa] - [Descripción breve]\n\n";
  prompt += "**Pregunta:** [Pregunta para refinar las preferencias]\n";
  return prompt;
}

// Implemantacion de puntos
class SistemaDePuntos {
  final Map<String, int> puntos = {
    'tecnología': 0,
    'datos': 0,
    'diseño': 0,
    'marketing': 0,
    'administración': 0,
  };

  void like(String categoria) {
    puntos[categoria] = (puntos[categoria] ?? 0) + 1;
  }

  void dislike(String categoria) {
    puntos[categoria] = (puntos[categoria] ?? 0) - 1;
  }

  String generarPrompt() {
    final buffer = StringBuffer("Soy un usuario que busca trabajo. Estas son mis preferencias:\n");
    puntos.forEach((categoria, valor) {
      buffer.writeln("- $categoria: $valor");
    });
    buffer.writeln("Sugiere 3 vacantes que se alineen a estas preferencias, con nombre y descripción breve.");
    return buffer.toString();
  }
}