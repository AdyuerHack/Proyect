import 'package:flutter/material.dart';

void main() {
  runApp(JobSwipeApp());
}

class JobSwipeApp extends StatelessWidget {
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
      home: LoginScreen(),
    );
  }
}

// ### Pantalla de Inicio de Sesión (Autenticación)
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
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
      // Simulación de autenticación/registro
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => JobSwipeScreen(
            userName: _isRegistering ? _nameController.text : 'Usuario',
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

// ### Pantalla Principal de Deslizamiento de Vacantes
class JobSwipeScreen extends StatefulWidget {
  final String userName;

  JobSwipeScreen({required this.userName});

  @override
  _JobSwipeScreenState createState() => _JobSwipeScreenState();
}

class _JobSwipeScreenState extends State<JobSwipeScreen> {
  // Lista de vacantes simuladas
  final List<Map<String, String>> jobs = [
    {
      'title': 'Desarrollador Flutter',
      'company': 'TechCorp',
      'description': 'Trabaja en apps móviles innovadoras.',
      'location': 'Remoto',
    },
    {
      'title': 'Diseñador UX/UI',
      'company': 'DesignLabs',
      'description': 'Crea interfaces intuitivas y atractivas.',
      'location': 'Ciudad de México',
    },
    {
      'title': 'Analista de Datos',
      'company': 'DataWorks',
      'description': 'Interpreta datos para tomar decisiones.',
      'location': 'Monterrey',
    },
  ];

  int currentIndex = 0;
  int swipeCount = 0;
  int points = 0; // Gamificación: puntos por interacción
  final int questionInterval = 3; // Pregunta cada 3 deslizamientos
  List<String> userPreferences = []; // Almacenar respuestas de profiling

  void _onDismissed(DismissDirection direction) {
    setState(() {
      if (direction == DismissDirection.startToEnd) {
        print('Like: ${jobs[currentIndex]['title']}');
        points += 10; // Gamificación: +10 puntos por like
      } else {
        print('Dislike: ${jobs[currentIndex]['title']}');
        points += 5; // Gamificación: +5 puntos por dislike
      }
      currentIndex = (currentIndex + 1) % jobs.length;
      swipeCount++;
      if (swipeCount % questionInterval == 0) {
        _showProfilingQuestion();
      }
      if (points % 50 == 0 && points > 0) {
        _showAchievement();
      }
    });
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
                  print('Preferencia guardada: $value');
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
                key: Key(jobs[currentIndex]['title']!),
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
                child: JobCard(job: jobs[currentIndex]),
              )
                  : Text('No hay más vacantes por ahora.'),
            ),
          ),
        ],
      ),
    );
  }
}

// ### Widget de Tarjeta de Vacante
class JobCard extends StatelessWidget {
  final Map<String, String> job;

  JobCard({required this.job});

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
            color: Colors.grey.withOpacity(0.5),
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
            job['title']!,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          Text(
            job['company']!,
            style: TextStyle(fontSize: 18, color: Colors.grey[700]),
          ),
          SizedBox(height: 10),
          Text(
            'Ubicación: ${job['location']}',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          SizedBox(height: 20),
          Text(
            job['description']!,
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  // Simular deslizamiento a la izquierda
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => JobSwipeScreen(userName: 'Usuario')),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text('Dislike'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Simular deslizamiento a la derecha
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => JobSwipeScreen(userName: 'Usuario')),
                  );
                },
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

  ProfileScreen({required this.userName, required this.points, required this.preferences});

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
  @override
  _CompanyScreenState createState() => _CompanyScreenState();
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
      print('Vacante publicada: ${_titleController.text}');
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