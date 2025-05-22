import 'dart:convert'; //
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; //
import 'package:logger/logger.dart'; //
import 'package:supabase_flutter/supabase_flutter.dart';

// --- CUSTOM SERVICES ---
// Placeholder for GeminiService - ensure you have this file and class defined
// import 'package:proyect/services/gemini_service.dart'; //
// Example GeminiService (replace with your actual implementation)
class GeminiService {
  final String apiKey;
  GeminiService({required this.apiKey});

  Future<String> generarRespuesta(String prompt) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    logger.i("Generando respuesta para el prompt: $prompt");
    return """
    **Recomendaciones:**
    1. Software Engineer en Tech Solutions - Developing cutting-edge applications. Ubicación: Remoto. Salario: \$70k - \$90k. Contrato: Fijo. Experiencia: Mid.
    2. Data Analyst en Data Insights - Analyzing complex datasets. Ubicación: Híbrido. Salario: \$60k - \$80k. Contrato: Fijo. Experiencia: Junior.
    3. UX Designer en Creative Co - Designing user-friendly interfaces. Ubicación: Presencial. Salario: \$65k - \$85k. Contrato: Freelance. Experiencia: Senior.

    **Pregunta:** ¿Estás interesado en roles de liderazgo técnico?
    """;
  }
}

var logger = Logger(); //

// --- THEME COLORS ---
const Color kPrimaryColor = Color(0xFF0F1E3A); // Azul oscuro [cite: 2]
const Color kAccentColor = Color(0xFF00C2CB); // Turquesa [cite: 2]
const Color kLightTextColor = Colors.white; // Texto claro para fondos oscuros [cite: 3]
const Color kDarkTextColor = Color(0xFF333333); // Texto oscuro para fondos claros [cite: 3]

// --- DATA MODELS ---

// Profile model from mainproyect_postgresql.txt
class Profile {
  final String id; // UUID de Supabase auth.users [cite: 203]
  final String nombre; // [cite: 203]
  final String correo; // El correo se obtiene de Supabase Auth [cite: 203]
  final String rol; // [cite: 204]
  final DateTime? fechaRegistro; // [cite: 204]

  Profile({
    required this.id, // [cite: 205]
    required this.nombre, // [cite: 205]
    required this.correo, // [cite: 205]
    this.rol = 'postulante', // [cite: 205]
    this.fechaRegistro, // [cite: 205]
  });

  factory Profile.fromMap(Map<String, dynamic> map, String email) { // [cite: 206]
    return Profile(
      id: map['id'] as String, // [cite: 206]
      nombre: map['nombre'] as String, // [cite: 206]
      correo: email, // Pasamos el email del User de Supabase [cite: 206]
      rol: map['rol'] as String, // [cite: 206]
      fechaRegistro: map['fecha_registro'] != null
          ? DateTime.parse(map['fecha_registro'] as String) // [cite: 206]
          : null,
    );
  }
}

// Empresa model from mainproyect_postgresql.txt
class Empresa {
  final int? id; // [cite: 207]
  final String nombre; // [cite: 207]
  final String? descripcion; // [cite: 207]
  final String? sitioWeb; // [cite: 207]
  final String? correoContacto; // [cite: 207]
  final String? telefonoContacto; // [cite: 208]

  Empresa({
    this.id, // [cite: 208]
    required this.nombre, // [cite: 208]
    this.descripcion, // [cite: 208]
    this.sitioWeb, // [cite: 208]
    this.correoContacto, // [cite: 208]
    this.telefonoContacto, // [cite: 208]
  });

  factory Empresa.fromMap(Map<String, dynamic> map) { // [cite: 209]
    return Empresa(
      id: map['id'] as int?, // [cite: 209]
      nombre: map['nombre'] as String, // [cite: 209]
      descripcion: map['descripcion'] as String?, // [cite: 209]
      sitioWeb: map['sitio_web'] as String?, // [cite: 209]
      correoContacto: map['correo_contacto'] as String?, // [cite: 209]
      telefonoContacto: map['telefono_contacto'] as String?, // [cite: 209]
    );
  }
}

// Merged Oferta model (combining Job from mainproyect.txt and Oferta from mainproyect_postgresql.txt)
class Oferta {
  final int? id; // [cite: 210]
  final String titulo; // [cite: 210]
  final String descripcion; // [cite: 210]
  final String? ubicacion; // For work location (e.g., "Remoto", "Híbrido", "Ciudad") [cite: 210]
  final DateTime? fechaPublicacion; // [cite: 211]
  final int empresaId; // [cite: 211]
  final Empresa? empresa; // [cite: 211]

  // Fields from mainproyect.txt's Job model
  final List<String> categories; // [cite: 5]
  final int? minSalary; // [cite: 5]
  final int? maxSalary; // [cite: 6]
  final String? contractType; // For 'Fijo', 'Temporal', 'Freelance' [cite: 7]
  final String? experienceLevel; // For 'Junior', 'Mid', 'Senior', 'Entry', 'Expert' [cite: 8]
  final String? modalidad; // Specific work mode if different from ubicacion, e.g. "Presencial" if ubicacion is a city. Often overlaps with ubicacion. [cite: 211]


  Oferta({
    this.id, // [cite: 212]
    required this.titulo, // [cite: 212]
    required this.descripcion, // [cite: 212]
    this.ubicacion, // [cite: 212]
    this.modalidad, // [cite: 212]
    this.fechaPublicacion, // [cite: 212]
    required this.empresaId, // [cite: 212]
    this.empresa, // [cite: 212]
    this.categories = const [], // [cite: 9]
    this.minSalary, // [cite: 9]
    this.maxSalary, // [cite: 9]
    this.contractType, // [cite: 9]
    this.experienceLevel, // [cite: 9]
  });

  factory Oferta.fromMap(Map<String, dynamic> map, {Empresa? empresa}) { // [cite: 213]
    return Oferta(
      id: map['id'] as int?, // [cite: 213]
      titulo: map['titulo'] as String, // [cite: 213]
      descripcion: map['descripcion'] as String, // [cite: 213]
      ubicacion: map['ubicacion'] as String?, // [cite: 213]
      modalidad: map['modalidad'] as String?, // [cite: 213]
      fechaPublicacion: map['fecha_publicacion'] != null
          ? DateTime.parse(map['fecha_publicacion'] as String) // [cite: 213]
          : null,
      empresaId: map['empresa_id'] as int, // [cite: 214]
      empresa: empresa, // [cite: 214]
      // Assuming these fields might come from the DB or need default values if not present
      categories: map['categories'] != null ? List<String>.from(map['categories']) : [],
      minSalary: map['min_salary'] as int?,
      maxSalary: map['max_salary'] as int?,
      contractType: map['contract_type'] as String?,
      experienceLevel: map['experience_level'] as String?,
    );
  }
}

// QuestionData model from mainproyect.txt
class QuestionData {
  final String question; // [cite: 10]
  final String type; // 'text', 'single_choice', 'range' [cite: 10]
  final List<String>? options; // Para 'single_choice' [cite: 11]
  final String? categoryMapping; // La categoría principal que esta pregunta perfila [cite: 11]

  const QuestionData({
    required this.question, // [cite: 12]
    required this.type, // [cite: 12]
    this.options, // [cite: 12]
    this.categoryMapping, // [cite: 12]
  });
}

// --- SUPABASE SERVICE --- (from mainproyect_postgresql.txt)
class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal(); // [cite: 215]
  factory SupabaseService() => _instance; // [cite: 215]
  SupabaseService._internal(); // [cite: 215]

  final SupabaseClient _client = Supabase.instance.client; // [cite: 216]

  Future<User?> signUpUser({
    required String email,
    required String password,
    required String nombre,
  }) async {
    try {
      logger.d("Enviando a Supabase signUp, data: ${{ 'nombre': nombre }}"); // [cite: 217]
      final AuthResponse response = await _client.auth.signUp( // [cite: 217]
        email: email, // [cite: 217]
        password: password, // [cite: 217]
        data: { 'nombre': nombre }, // [cite: 217]
      );
      // The trigger in Supabase should handle profile creation.
      return response.user; // [cite: 220]
    } on AuthException catch (e) {
      logger.e('Error de autenticación Supabase (SignUp): ${e.message}'); // [cite: 220]
      throw Exception('Error al registrar: ${e.message}'); // [cite: 221]
    } catch (e) {
      logger.e('Error general (SignUp): $e'); // [cite: 221]
      if (e is PostgrestException) { // [cite: 222]
        logger.e('PostgrestException (SignUp): ${e.message} - Code: ${e.code} - Details: ${e.details}'); // [cite: 222]
        throw Exception('Error de base de datos al registrar: ${e.message}'); // [cite: 223]
      }
      throw Exception('Error inesperado al registrar.'); // [cite: 223]
    }
  }

  Future<User?> signInUser(String email, String password) async {
    try {
      final AuthResponse response = await _client.auth.signInWithPassword( // [cite: 224]
        email: email, // [cite: 224]
        password: password, // [cite: 224]
      );
      return response.user; // [cite: 225]
    } on AuthException catch (e) {
      logger.e('Error de autenticación Supabase (SignIn): ${e.message}'); // [cite: 225]
      throw Exception('Error al iniciar sesión: ${e.message}'); // [cite: 226]
    } catch (e) {
      logger.e('Error general (SignIn): $e'); // [cite: 226]
      throw Exception('Error inesperado al iniciar sesión.'); // [cite: 227]
    }
  }

  Future<void> signOutUser() async {
    try {
      await _client.auth.signOut(); // [cite: 227]
    } on AuthException catch (e) {
      logger.e('Error de autenticación Supabase (SignOut): ${e.message}'); // [cite: 228]
      throw Exception('Error al cerrar sesión: ${e.message}'); // [cite: 229]
    }
  }

  User? getCurrentSupabaseUser() {
    return _client.auth.currentUser; // [cite: 229]
  }

  Future<Profile?> getCurrentUserProfile() async {
    final supabaseUser = getCurrentSupabaseUser(); // [cite: 230]
    if (supabaseUser == null || supabaseUser.email == null) { // [cite: 231]
      return null;
    }
    try {
      final data = await _client // [cite: 232]
          .from('profiles')
          .select()
          .eq('id', supabaseUser.id) // [cite: 232]
          .maybeSingle(); // [cite: 232]

      if (data == null) { // [cite: 233]
        logger.w('PERFIL NO ENCONTRADO para el usuario: ${supabaseUser.id}. Trigger podría no haber creado el perfil.'); // [cite: 233]
        return null; // [cite: 234]
      }
      return Profile.fromMap(data, supabaseUser.email!); // [cite: 234]
    } catch (e) {
      logger.e('Error obteniendo perfil de usuario: $e'); // [cite: 235]
      return null; // [cite: 236]
    }
  }

  Future<List<Oferta>> obtenerOfertas() async {
    try {
      final List<Map<String, dynamic>> results = await _client // [cite: 236]
          .from('ofertas')
          .select('''
            id, titulo, descripcion, ubicacion, modalidad, fecha_publicacion, empresa_id,
            min_salary, max_salary, contract_type, experience_level, categories, 
            empresas ( id, nombre, descripcion, sitio_web, correo_contacto, telefono_contacto ) 
          ''') // [cite: 236]
          .order('fecha_publicacion', ascending: false); // [cite: 237]

      List<Oferta> ofertas = []; // [cite: 238]
      for (final rowData in results) {
        Empresa? empresa;
        if (rowData['empresas'] != null) { // [cite: 239]
          empresa = Empresa.fromMap(rowData['empresas'] as Map<String, dynamic>); // [cite: 239]
        }
        ofertas.add(Oferta.fromMap(rowData, empresa: empresa)); // [cite: 240]
      }
      return ofertas; // [cite: 240]
    } catch (e) {
      logger.e('Error al obtener ofertas: $e'); // [cite: 241]
      throw Exception('No se pudieron cargar las ofertas.'); // [cite: 242]
    }
  }

    Future<Empresa?> obtenerOCrearEmpresa(String nombreEmpresa) async { // [cite: 242]
    try {
      var response = await _client // [cite: 242]
          .from('empresas')
          .select()
          .eq('nombre', nombreEmpresa) // [cite: 242]
          .maybeSingle(); // [cite: 242]

      if (response != null) {
        return Empresa.fromMap(response); // [cite: 243]
      } else {
        final List<Map<String, dynamic>> insertedRows = await _client // [cite: 244]
            .from('empresas')
            .insert({'nombre': nombreEmpresa}).select(); // [cite: 244]

        if (insertedRows.isNotEmpty) { // [cite: 245]
          return Empresa.fromMap(insertedRows.first); // [cite: 245]
        }
      }
    } catch (e) {
      logger.e('Error al obtener o crear empresa: $e'); // [cite: 246]
      throw Exception('Error con la empresa: $e'); // [cite: 247]
    }
    return null; // [cite: 247]
  }

  Future<Oferta?> publicarOferta({
    required String titulo,
    required String descripcion,
    required String ubicacion,
    required String nombreEmpresa,
    List<String>? categories,
    int? minSalary,
    int? maxSalary,
    String? contractType,
    String? experienceLevel,
    String? modalidad,
  }) async {
    try {
      final Empresa? empresa = await obtenerOCrearEmpresa(nombreEmpresa); // [cite: 249]
      if (empresa == null || empresa.id == null) { // [cite: 249]
        throw Exception('No se pudo obtener o crear la empresa.'); // [cite: 249]
      }

      final List<Map<String, dynamic>> insertedRows = await _client // [cite: 250]
          .from('ofertas')
          .insert({
        'titulo': titulo, // [cite: 250]
        'descripcion': descripcion, // [cite: 250]
        'ubicacion': ubicacion, // [cite: 250]
        'empresa_id': empresa.id, // [cite: 250]
        'min_salary': minSalary,
        'max_salary': maxSalary,
        'contract_type': contractType,
        'experience_level': experienceLevel,
        'categories': categories,
        'modalidad': modalidad, // [cite: 250]
      })
          .select('''
            id, titulo, descripcion, ubicacion, modalidad, fecha_publicacion, empresa_id,
            min_salary, max_salary, contract_type, experience_level, categories,
            empresas (id, nombre) 
          '''); // [cite: 251]

      if (insertedRows.isNotEmpty) { // [cite: 252]
        Empresa? empresaInsertada;
        if (insertedRows.first['empresas'] != null) { // [cite: 253]
          empresaInsertada = Empresa.fromMap(insertedRows.first['empresas'] as Map<String, dynamic>); // [cite: 253]
        }
        return Oferta.fromMap(insertedRows.first, empresa: empresaInsertada); // [cite: 254]
      }
    } catch (e) {
      logger.e('Error al publicar oferta: $e'); // [cite: 255]
      throw Exception('Error al publicar oferta: $e'); // [cite: 256]
    }
    return null; // [cite: 256]
  }
}

// --- MAIN APPLICATION ---
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // [cite: 13, 257]

  // Load Gemini API Key
  String? geminiApiKey;
  try {
    final String configString = await rootBundle.loadString('assets/config.json'); // [cite: 13]
    final Map<String, dynamic> config = jsonDecode(configString); // [cite: 14]
    geminiApiKey = config['GEMINI_API_KEY']; // [cite: 14]
    if (geminiApiKey == null || geminiApiKey.isEmpty) { // [cite: 15]
      logger.e('Error: La clave API de Gemini no está configurada en config.json'); // [cite: 15]
      return; // [cite: 16]
    }
  } catch (e) {
    logger.e('Error al cargar config.json: $e'); // [cite: 16]
    return; // [cite: 17]
  }

  // Initialize Supabase
  await Supabase.initialize( // [cite: 258]
    url: 'https://kvvshqbcownicryxpbld.supabase.co', // Replace with your Supabase URL
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt2dnNocWJjb3duaWNyeXhwYmxkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc4ODI0OTksImV4cCI6MjA2MzQ1ODQ5OX0.iXTNN-o6bbON2Li2vQHdRLZILcsUJHFy0pL3vnbVzv8', // Replace with your Supabase Anon Key
  );

  final GeminiService geminiService = GeminiService(apiKey: geminiApiKey);
  final SupabaseService supabaseService = SupabaseService(); // [cite: 259]

  runApp(MyApp(geminiService: geminiService, supabaseService: supabaseService)); // [cite: 16]
}

class MyApp extends StatelessWidget {
  final GeminiService geminiService;
  final SupabaseService supabaseService;

  const MyApp({super.key, required this.geminiService, required this.supabaseService}); // [cite: 17]

  @override
  Widget build(BuildContext context) { // [cite: 18]
    return MaterialApp(
      title: 'Magneto Job Swipe', // [cite: 18]
      theme: ThemeData( // [cite: 18]
        primaryColor: kPrimaryColor, // [cite: 18]
        secondaryHeaderColor: kAccentColor, // [cite: 18]
        scaffoldBackgroundColor: Colors.blueGrey.shade900, // [cite: 18]
        cardColor: kPrimaryColor.withOpacity(0.8), // [cite: 18]
        brightness: Brightness.dark, // [cite: 19]
        appBarTheme: const AppBarTheme( // [cite: 19]
          backgroundColor: kPrimaryColor, // [cite: 19]
          foregroundColor: kLightTextColor, // [cite: 19]
          elevation: 0, // [cite: 19]
          centerTitle: true, // [cite: 19]
        ),
        elevatedButtonTheme: ElevatedButtonThemeData( // [cite: 20]
          style: ElevatedButton.styleFrom(
            backgroundColor: kAccentColor, // [cite: 20]
            foregroundColor: kPrimaryColor, // [cite: 20]
            shape: RoundedRectangleBorder( // [cite: 20]
              borderRadius: BorderRadius.circular(8), // [cite: 21]
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), // [cite: 21]
          ),
        ),
        textButtonTheme: TextButtonThemeData( // [cite: 22]
          style: TextButton.styleFrom(
            foregroundColor: kAccentColor, // [cite: 22]
          ),
        ),
        cardTheme: CardTheme( // [cite: 22]
          elevation: 8, // [cite: 22]
          shape: RoundedRectangleBorder( // [cite: 23]
            borderRadius: BorderRadius.circular(16), // [cite: 23]
          ),
          color: kPrimaryColor.withOpacity(0.8), // [cite: 23]
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), // [cite: 23]
        ),
        inputDecorationTheme: InputDecorationTheme( // [cite: 23]
          filled: true, // [cite: 23]
          fillColor: Colors.blueGrey.shade700, // [cite: 24]
          labelStyle: const TextStyle(color: kLightTextColor), // [cite: 24]
          hintStyle: TextStyle(color: kLightTextColor.withOpacity(0.7)), // [cite: 24]
          border: OutlineInputBorder( // [cite: 24]
            borderRadius: BorderRadius.circular(8), // [cite: 24]
            borderSide: BorderSide.none, // [cite: 24]
          ),
          focusedBorder: OutlineInputBorder( // [cite: 24]
            borderRadius: BorderRadius.circular(8), // [cite: 25]
            borderSide: const BorderSide(color: kAccentColor, width: 2), // [cite: 25]
          ),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity, // [cite: 25]
      ),
      home: StreamBuilder<AuthState>( // [cite: 260]
        stream: supabaseService._client.auth.onAuthStateChange, // [cite: 261]
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) { // [cite: 261]
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          final session = snapshot.data?.session; // [cite: 261]
          if (session != null) { // [cite: 261]
            return FutureBuilder<Profile?>( // [cite: 262]
              future: supabaseService.getCurrentUserProfile(), // [cite: 262]
              builder: (context, profileSnapshot) {
                if (profileSnapshot.connectionState == ConnectionState.waiting) { // [cite: 262]
                  return const Scaffold(body: Center(child: CircularProgressIndicator())); // [cite: 263]
                }
                if (profileSnapshot.hasError || profileSnapshot.data == null) { // [cite: 264]
                  logger.e("Error cargando perfil o no existe: ${profileSnapshot.error}"); // [cite: 264]
                  // If profile loading fails, go back to Login to prevent an inconsistent state.
                  return LoginScreen(supabaseService: supabaseService); // [cite: 266]
                }
                return JobSwipeScreen( // [cite: 266]
                  supabaseService: supabaseService,
                  geminiService: geminiService,
                  currentProfile: profileSnapshot.data!,
                );
              },
            );
          }
          // If no session, go to LoginScreen
          return LoginScreen(supabaseService: supabaseService); // [cite: 268]
        },
      ),
    );
  }
}

// --- LOGIN SCREEN --- (Combined, using Supabase auth and Magneto logo)
class LoginScreen extends StatefulWidget {
  final SupabaseService supabaseService;
  const LoginScreen({super.key, required this.supabaseService}); // [cite: 26, 270]

  @override
  State<LoginScreen> createState() => _LoginScreenState(); // [cite: 26]
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(); // [cite: 27]
  final _passwordController = TextEditingController(); // [cite: 27]
  final _nameController = TextEditingController(); // [cite: 27, 272]
  bool _isRegistering = false; // [cite: 28, 272]
  bool _isLoading = false; // [cite: 272]

  void _toggleMode() {
    setState(() => _isRegistering = !_isRegistering); // [cite: 28, 273]
  }

  Future<void> _submit() async { // [cite: 29]
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    if (email.isEmpty || password.isEmpty) { // [cite: 29]
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa correo y contraseña')), // [cite: 274]
      );
      return; // [cite: 275]
    }
    if (_isRegistering && name.isEmpty) { // [cite: 29]
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa tu nombre para registrarte')), // [cite: 275]
      );
      return; // [cite: 276]
    }

    setState(() => _isLoading = true); // [cite: 276]

    try {
      if (_isRegistering) { // [cite: 277]
        await widget.supabaseService.signUpUser( // [cite: 277]
          email: email,
          password: password,
          nombre: name,
        );
        if (mounted) { // [cite: 278]
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registro exitoso. Revisa tu correo para confirmar (si está habilitado).')), // [cite: 278]
          );
          // Navigation handled by StreamBuilder
        }
      } else {
        await widget.supabaseService.signInUser(email, password); // [cite: 279]
        if (mounted) { // [cite: 280]
          // Navigation handled by StreamBuilder
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Inicio de sesión exitoso.')), // [cite: 280]
          );
        }
      }
    } catch (e) {
      if (mounted) { // [cite: 281]
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst("Exception: ", ""))), // [cite: 281]
        );
      }
    } finally {
      if (mounted) { // [cite: 282]
        setState(() => _isLoading = false); // [cite: 282]
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose(); // [cite: 283]
    _passwordController.dispose(); // [cite: 283]
    _nameController.dispose(); // [cite: 283]
    super.dispose();
  }

  @override
  Widget build(BuildContext context) { // [cite: 32]
    return Scaffold(
      appBar: AppBar(title: Text(_isRegistering ? 'Registrarse' : 'Iniciar Sesión')), // [cite: 32]
      body: Padding(
        padding: const EdgeInsets.all(16.0), // [cite: 32]
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // [cite: 32]
          children: [
            Image.asset( // [cite: 33]
              'assets/images/magneto_logo.png', // Ruta de tu logo [cite: 33]
              height: 100, // [cite: 33]
              // color: kAccentColor, // Example [cite: 33]
            ),
            const SizedBox(height: 40), // [cite: 34]
            if (_isRegistering)
              TextField( // [cite: 34]
                controller: _nameController, // [cite: 34]
                decoration: const InputDecoration(labelText: 'Nombre'), // [cite: 34]
              ),
            TextField( // [cite: 35]
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Correo Electrónico'),
              keyboardType: TextInputType.emailAddress, // [cite: 286]
            ),
            TextField( // [cite: 35]
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Contraseña'), // [cite: 36]
              obscureText: true, // [cite: 36]
            ),
            const SizedBox(height: 20), // [cite: 36]
            _isLoading
                ? const CircularProgressIndicator() // [cite: 288]
                : ElevatedButton( // [cite: 36]
              onPressed: _submit, // [cite: 36]
              child: Text(_isRegistering ? 'Registrarse' : 'Iniciar Sesión'), // [cite: 37]
            ),
            TextButton( // [cite: 37]
              onPressed: _isLoading ? null : _toggleMode, // [cite: 288]
              child: Text(_isRegistering ? '¿Ya tienes cuenta? Inicia sesión' : '¿No tienes cuenta? Regístrate'), // [cite: 37, 289]
            ),
          ],
        ),
      ),
    );
  }
}


// --- JOB SWIPE SCREEN --- (Heavily merged)
class JobSwipeScreen extends StatefulWidget {
  final SupabaseService supabaseService;
  final GeminiService geminiService;
  final Profile currentProfile;

  const JobSwipeScreen({ // [cite: 39]
    super.key,
    required this.supabaseService,
    required this.geminiService,
    required this.currentProfile, // [cite: 290]
  });

  @override
  _JobSwipeScreenState createState() => _JobSwipeScreenState(); // [cite: 39]
}

class _JobSwipeScreenState extends State<JobSwipeScreen> {
  List<Oferta> _ofertas = []; // [cite: 291]
  int currentIndex = 0; // [cite: 57, 292]
  bool _isLoadingOfertas = true; //
  String _errorMessage = ''; // [cite: 292]

  int swipeCount = 0; // [cite: 58, 292]
  int points = 0; // [cite: 58, 292]
  final int questionInterval = 3; // [cite: 58, 293]
  String? nextQuestion; // [cite: 59]
  List<String> userPreferencesList = []; // [cite: 59, 293]

  // User preferences map, initialized with common categories
  Map<String, int> userPreferences = { // [cite: 61]
    "Remoto": 0, "Presencial": 0, "Híbrido": 0, // [cite: 62]
    "tecnologia": 0, "desarrollo_web": 0, "frontend": 0, "backend": 0, "react": 0, "javascript": 0, "typescript": 0, // [cite: 62]
    "python": 0, "django": 0, "api": 0, "bases_de_datos": 0, "node_js": 0, // [cite: 62]
    "diseño": 0, "grafico": 0, "branding": 0, "publicidad": 0, "creatividad": 0, "adobe_suite": 0, "ui_ux": 0, "mobile": 0, "apps": 0, // [cite: 62]
    "marketing": 0, "digital": 0, "seo": 0, "sem": 0, "redes_sociales": 0, "contenidos": 0, "copywriting": 0, "escritura": 0, // [cite: 62]
    "gestion": 0, "proyectos": 0, "agile": 0, "scrum": 0, "kanban": 0, "liderazgo": 0, // [cite: 62]
    "datos": 0, "analisis": 0, "excel": 0, "sql": 0, "power_bi": 0, "ciencia_de_datos": 0, "machine_learning": 0, "estadistica": 0, // [cite: 62, 63]
    "qa": 0, "automation": 0, "testing": 0, "software": 0, "selenium": 0, // [cite: 63]
    "servicio_al_cliente": 0, "atencion": 0, "comunicacion": 0, "zendesk": 0, // [cite: 63]
    "contabilidad": 0, "finanzas": 0, "impuestos": 0, "auditoria": 0, "sap": 0, // [cite: 63]
    "redes": 0, "infraestructura": 0, "seguridad_informatica": 0, "soporte": 0, "ccna": 0, "soporte_tecnico": 0, "hardware": 0, "resolucion_problemas": 0, // [cite: 63]
    "consultoria": 0, "negocios": 0, "erp": 0, "procesos": 0, // [cite: 63]
    "product_manager": 0, "estrategia": 0, // [cite: 63]
    "analisis_financiero": 0, "inversiones": 0, "mercado": 0, // [cite: 63]
    "ciberseguridad": 0, "vulnerabilidades": 0, // [cite: 63]
    "recursos_humanos": 0, "gestion_personal": 0, "reclutamiento": 0, "bienestar": 0, // [cite: 64]
    "desarrollo_software": 0, "juegos": 0, "unity": 0, "csharp": 0, "programacion": 0, // [cite: 64]
    "Entry": 0, "Junior": 0, "Mid": 0, "Senior": 0, "Expert": 0, // Niveles de experiencia [cite: 64]
    "Fijo": 0, "Temporal": 0, "Freelance": 0, // Tipos de contrato [cite: 64]
    "salario_min": 0, "salario_max": 0, // [cite: 64]
  };

  // Predefined profiling questions
  List<QuestionData> predefinedQuestions = [ // [cite: 65]
    const QuestionData( // [cite: 65]
        question: '¿Qué tipo de modalidad de trabajo prefieres?',
        type: 'single_choice',
        options: ['Remoto', 'Presencial', 'Híbrido'],
        categoryMapping: 'modalidad'),
    const QuestionData( // [cite: 65]
        question: '¿Qué tipo de contrato buscas?',
        type: 'single_choice', // [cite: 66]
        options: ['Fijo', 'Temporal', 'Freelance'], // [cite: 66]
        categoryMapping: 'tipo_contrato'), // [cite: 66]
    const QuestionData( // [cite: 66]
        question: '¿Cuál es tu rango de salario anual esperado (en miles, ej. 30-50)?',
        type: 'range', // [cite: 66]
        categoryMapping: 'salario'), // [cite: 66]
    const QuestionData( // [cite: 66]
        question: '¿Cuál es tu nivel de experiencia laboral?',
        type: 'single_choice', // [cite: 67]
        options: ['Entry', 'Junior', 'Mid', 'Senior', 'Expert'], // [cite: 67]
        categoryMapping: 'nivel_experiencia'), // [cite: 67]
    const QuestionData( // [cite: 67]
      question: '¿En qué área de la tecnología tienes más interés?',
      type: 'text', // [cite: 67]
      categoryMapping: 'interes_tecnologico', // [cite: 67]
    ),
  ];
  int currentQuestionIndex = 0; // [cite: 68]

  @override
  void initState() {
    super.initState();
    _cargarOfertas(); // [cite: 293]
  }

  Future<void> _cargarOfertas() async { // [cite: 294]
    try {
      setState(() {
        _isLoadingOfertas = true; // [cite: 294]
        _errorMessage = ''; // [cite: 294]
      });
      final ofertasCargadas = await widget.supabaseService.obtenerOfertas(); // [cite: 295]
      if (mounted) { // [cite: 295]
        setState(() {
          _ofertas = ofertasCargadas; // [cite: 295]
          _isLoadingOfertas = false; // [cite: 295]
          currentIndex = 0; // Reset index when new jobs are loaded
          swipeCount = 0; // Reset swipe count
        });
      }
    } catch (e) {
      if (mounted) { // [cite: 296]
        setState(() {
          _isLoadingOfertas = false; // [cite: 296]
          _errorMessage = 'Error al cargar ofertas: ${e.toString().replaceFirst("Exception: ", "")}'; // [cite: 296]
          logger.e(_errorMessage); // [cite: 296]
        });
      }
    }
  }

  void _onDismissed(DismissDirection direction) { // [cite: 68]
    if (currentIndex >= _ofertas.length) return; // [cite: 297]

    _updatePointsAndPreferences(direction); // [cite: 68]
    _updateCurrentIndex(); // [cite: 69]

    if (_shouldShowProfilingQuestion()) { // [cite: 70]
      _showProfilingQuestion(); // [cite: 70]
    }

    if (_shouldGetRecommendations()) { // [cite: 71]
      _getRecommendations(); // [cite: 71]
    }

    if (_shouldShowAchievement()) { // [cite: 72]
      _showAchievement(); // [cite: 72]
    }
  }

  void _updatePointsAndPreferences(DismissDirection direction) { // [cite: 73]
    setState(() {
      final Oferta currentOferta = _ofertas[currentIndex];
      if (direction == DismissDirection.startToEnd) { // LIKE
        logger.d('LIKE a ${currentOferta.titulo}'); // [cite: 73]
        points += 10; // [cite: 73]

        for (var category in currentOferta.categories) { // [cite: 73]
          userPreferences[category] = (userPreferences[category] ?? 0) + 5; // [cite: 74]
          logger.d('  -> Pref: $category aumentado a ${userPreferences[category]}'); // [cite: 74]
        }
        if (currentOferta.ubicacion != null) {
             userPreferences[currentOferta.ubicacion!] = (userPreferences[currentOferta.ubicacion!] ?? 0) + 3; // [cite: 74]
             logger.d('  -> Ubicacion: ${currentOferta.ubicacion} aumentado a ${userPreferences[currentOferta.ubicacion!]}'); // [cite: 74]
        }
        if (currentOferta.minSalary != null) userPreferences['salario_min'] = (userPreferences['salario_min'] ?? 0) + (currentOferta.minSalary! ~/ 1000); // [cite: 75]
        if (currentOferta.maxSalary != null) userPreferences['salario_max'] = (userPreferences['salario_max'] ?? 0) + (currentOferta.maxSalary! ~/ 1000); // [cite: 76]
        if (currentOferta.contractType != null) userPreferences[currentOferta.contractType!] = (userPreferences[currentOferta.contractType!] ?? 0) + 3; // [cite: 77]
        if (currentOferta.experienceLevel != null) userPreferences[currentOferta.experienceLevel!] = (userPreferences[currentOferta.experienceLevel!] ?? 0) + 3; // [cite: 78]

      } else { // DISLIKE
        logger.d('DISLIKE a ${currentOferta.titulo}'); // [cite: 79]
        points += 5; // Or 0 if no points for dislike [cite: 79]
        for (var category in currentOferta.categories) { // [cite: 80]
          userPreferences[category] = (userPreferences[category] ?? 0) - 3; // [cite: 80]
          logger.d('  -> Pref: $category disminuido a ${userPreferences[category]}'); // [cite: 81]
        }
         if (currentOferta.ubicacion != null) {
            userPreferences[currentOferta.ubicacion!] = (userPreferences[currentOferta.ubicacion!] ?? 0) - 2; // [cite: 82]
            logger.d('  -> Ubicacion: ${currentOferta.ubicacion} disminuido a ${userPreferences[currentOferta.ubicacion!]}'); // [cite: 83]
         }
        if (currentOferta.minSalary != null) userPreferences['salario_min'] = (userPreferences['salario_min'] ?? 0) - (currentOferta.minSalary! ~/ 2000); // [cite: 84]
        if (currentOferta.maxSalary != null) userPreferences['salario_max'] = (userPreferences['salario_max'] ?? 0) - (currentOferta.maxSalary! ~/ 2000); // [cite: 85]
        if (currentOferta.contractType != null) userPreferences[currentOferta.contractType!] = (userPreferences[currentOferta.contractType!] ?? 0) - 2; // [cite: 86]
        if (currentOferta.experienceLevel != null) userPreferences[currentOferta.experienceLevel!] = (userPreferences[currentOferta.experienceLevel!] ?? 0) - 2; // [cite: 87]
      }
    });
  }

  void _updateCurrentIndex() { // [cite: 88]
    setState(() {
      currentIndex = (currentIndex + 1); // Don't loop back immediately, handle exhaustion separately
      swipeCount++; // [cite: 88]
    });
  }

  bool _shouldShowProfilingQuestion() => swipeCount % questionInterval == 0; // [cite: 89]
  bool _shouldGetRecommendations() => swipeCount % 6 == 0 && userPreferences.values.any((value) => value != 0); // [cite: 90]
  bool _shouldShowAchievement() => points % 50 == 0 && points > 0; // [cite: 91]

  void _getRecommendations() async { // [cite: 92]
    try {
      final prompt = _construirPromptParaGemini(userPreferencesList, userPreferences); // [cite: 93]
      final respuesta = await widget.geminiService.generarRespuesta(prompt); // [cite: 93]
      logger.i("Respuesta de la IA:\n$respuesta"); // [cite: 93]
      _showRecommendationDialog(respuesta); // [cite: 93]
    } catch (e) {
      if (mounted) { // [cite: 94]
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al obtener recomendaciones: $e')), // [cite: 94]
        );
      }
      logger.e('Error al llamar a la IA para recomendaciones: $e'); // [cite: 95]
    }
  }

  void _showRecommendationDialog(String respuesta) { // [cite: 95]
    final recommendationsMatch = RegExp(r'\*\*Recomendaciones:\*\*([\s\S]*?)\*\*Pregunta:\*\*').firstMatch(respuesta); // [cite: 95]
    final questionMatch = RegExp(r'\*\*Pregunta:\*\* (.*)').firstMatch(respuesta); // [cite: 96]

    String recommendationsText = recommendationsMatch?.group(1)?.trim() ?? "No se pudieron obtener recomendaciones."; // [cite: 96]
    nextQuestion = questionMatch?.group(1)?.trim(); // [cite: 96]

    showDialog( // [cite: 97]
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Recomendaciones de IA'), // [cite: 97]
        content: SingleChildScrollView(child: Text(recommendationsText)), // [cite: 97]
        actions: [
          TextButton( // [cite: 97]
            onPressed: () => Navigator.of(context).pop(), // [cite: 97]
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showProfilingQuestion() { // [cite: 99]
    if (nextQuestion == null && currentQuestionIndex < predefinedQuestions.length) { // [cite: 100]
      QuestionData currentPredefinedQuestion = predefinedQuestions[currentQuestionIndex]; // [cite: 100]
      _showProfilingQuestionContent(currentPredefinedQuestion); // [cite: 101]
      currentQuestionIndex++; // [cite: 101]
      if (currentQuestionIndex >= predefinedQuestions.length) { // [cite: 101]
        currentQuestionIndex = 0; // Reiniciar ciclo [cite: 102]
      }
    } else if (nextQuestion != null) {
      _showProfilingQuestionContent(QuestionData( // [cite: 103]
        question: nextQuestion!, // [cite: 103]
        type: 'text', // Asumimos que la pregunta de la IA es de texto abierto [cite: 103]
      ));
      nextQuestion = null; // [cite: 104]
    }
    // If nextQuestion is null and predefinedQuestions is exhausted, can add a small cooldown or simply not ask.
  }

 void _showProfilingQuestionContent(QuestionData qData) { // [cite: 104]
    TextEditingController textController = TextEditingController(); // [cite: 104]
    String? dialogSelectedOption;
    RangeValues? dialogSelectedRange; // Keep this here

    showDialog(
      context: context,
      builder: (context) => AlertDialog( // [cite: 105]
        title: Text(qData.question), // [cite: 105]
        content: StatefulBuilder( // [cite: 105]
          builder: (BuildContext context, StateSetter setStateDialog) {
            if (qData.type == 'single_choice' && qData.options != null) { // [cite: 106]
              dialogSelectedOption ??= qData.options!.firstWhereOrNull( // [cite: 106]
                    (option) => (userPreferences[option] ?? 0) > 0,
                  ) ??
                  qData.options!.first; // [cite: 106]
            }
            if (qData.type == 'range') { // [cite: 107]
              // MODIFICATION START (RangeSlider Fix)
              double initialStart = (userPreferences['salario_min'] ?? 20).toDouble(); // [cite: 107]
              double initialEnd = (userPreferences['salario_max'] ?? 100).toDouble(); // [cite: 108]

              // Define slider min/max bounds
              const double sliderMinBound = 0.0;
              const double sliderMaxBound = 200.0;

              // Clamp initial values to slider bounds
              initialStart = initialStart.clamp(sliderMinBound, sliderMaxBound);
              initialEnd = initialEnd.clamp(sliderMinBound, sliderMaxBound);

              // Ensure start <= end
              if (initialStart > initialEnd) {
                initialStart = initialEnd;
              }
              // Initialize dialogSelectedRange only if it's null with the corrected values
              dialogSelectedRange ??= RangeValues(initialStart, initialEnd);
              // MODIFICATION END (RangeSlider Fix)
            }

            Widget contentWidget;
            switch (qData.type) { // [cite: 109]
              case 'single_choice': // [cite: 109]
                contentWidget = Column( // [cite: 109]
                  mainAxisSize: MainAxisSize.min,
                  children: qData.options!.map((option) {
                    return RadioListTile<String>( // [cite: 109]
                      title: Text(option), // [cite: 110]
                      value: option, // [cite: 110]
                      groupValue: dialogSelectedOption, // [cite: 110]
                      onChanged: (value) { // [cite: 110]
                        setStateDialog(() { // [cite: 111]
                          dialogSelectedOption = value; // [cite: 111]
                        });
                      },
                    );
                  }).toList(),
                );
                break; // [cite: 112]
              case 'range': // [cite: 113]
                 if (dialogSelectedRange == null) {
                  dialogSelectedRange = const RangeValues(20, 100); // Fallback
                }
                contentWidget = Column( // [cite: 113]
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Rango actual: \$${dialogSelectedRange!.start.round()}k - \$${dialogSelectedRange!.end.round()}k anuales'), // [cite: 113]
                    RangeSlider( // [cite: 114]
                      values: dialogSelectedRange!, // [cite: 114]
                      min: 0, // [cite: 114]
                      max: 200, // [cite: 114]
                      divisions: 20, // [cite: 115]
                      labels: RangeLabels( // [cite: 115]
                        dialogSelectedRange!.start.round().toString(), // [cite: 115]
                        dialogSelectedRange!.end.round().toString(), // [cite: 115]
                      ),
                      onChanged: (values) { // [cite: 116]
                        setStateDialog(() { // [cite: 116]
                          dialogSelectedRange = values; // [cite: 116]
                        });
                      },
                    ),
                  ],
                );
                break; // [cite: 118]
              case 'text': // [cite: 119]
              default:
                contentWidget = TextField( // [cite: 119]
                  controller: textController, // [cite: 119]
                  decoration: const InputDecoration(hintText: 'Tu respuesta'), // [cite: 119]
                );
                break; // [cite: 120]
            }
            return Column( // [cite: 120]
              mainAxisSize: MainAxisSize.min,
              children: [
                contentWidget,
                const SizedBox(height: 20), // [cite: 120]
                ElevatedButton( // [cite: 120]
                  onPressed: () { // [cite: 121]
                    String valueToSave = '';
                    if (qData.type == 'single_choice' && dialogSelectedOption != null) { // [cite: 121]
                      valueToSave = dialogSelectedOption!; // [cite: 121]
                      setState(() {
                          qData.options?.forEach((opt) { // [cite: 122]
                            userPreferences[opt] = 0; // [cite: 122]
                          });
                          userPreferences[valueToSave] = (userPreferences[valueToSave] ?? 0) + 10; // Higher weight for direct answer [cite: 123]
                          userPreferencesList.add("${qData.question}: $valueToSave");
                          logger.d('Preferencias de opción única actualizadas: $userPreferences'); // [cite: 123]
                      });
                    } else if (qData.type == 'range' && dialogSelectedRange != null) { // [cite: 123]
                      double finalStart = dialogSelectedRange!.start.round().toDouble();
                      double finalEnd = dialogSelectedRange!.end.round().toDouble();
                      valueToSave = '${finalStart.round()}-${finalEnd.round()}k'; // [cite: 124]
                       setState(() {
                          userPreferences['salario_min'] = finalStart.round(); // [cite: 125]
                          userPreferences['salario_max'] = finalEnd.round(); // [cite: 126]
                          userPreferencesList.add("${qData.question}: $valueToSave");
                          logger.d('Salario perfilado: ${userPreferences['salario_min']} - ${userPreferences['salario_max']}'); // [cite: 126]
                       });
                    } else if (qData.type == 'text') { // [cite: 127]
                      valueToSave = textController.text; // [cite: 127]
                      if (valueToSave.isNotEmpty) {
                        setState(() {
                           userPreferencesList.add("${qData.question}: $valueToSave"); // [cite: 128]
                           if (qData.categoryMapping != null) { // [cite: 128]
                               userPreferences[qData.categoryMapping!] = (userPreferences[qData.categoryMapping!] ?? 0) + 5;
                           }
                           logger.d('Respuesta de texto guardada: $valueToSave'); // [cite: 128]
                        });
                      }
                    }

                    if (valueToSave.isNotEmpty || qData.type == 'range') { // [cite: 129]
                      Navigator.of(context).pop(); // [cite: 129]
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar( // [cite: 130]
                        const SnackBar(content: Text('Por favor, selecciona o ingresa una respuesta')), // [cite: 130]
                      );
                    }
                  },
                  child: const Text('Guardar'), // [cite: 131]
                ),
              ],
            );
          },
        ),
      ),
    );
  }


  void _showAchievement() { // [cite: 133]
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar( // [cite: 133]
        content: Text('¡Logro desbloqueado! Has ganado $points puntos.'), // [cite: 133]
        backgroundColor: Colors.green, // [cite: 133]
      ),
    );
  }

  @override
  Widget build(BuildContext context) { // [cite: 134]
    return Scaffold(
      appBar: AppBar( // [cite: 134]
        title: Row( // [cite: 134]
          mainAxisAlignment: MainAxisAlignment.center, // [cite: 134]
          children: [
            Image.asset( // [cite: 134]
              'assets/images/magneto_logo.png', // [cite: 134]
              height: 35, // [cite: 135]
            ),
            // const SizedBox(width: 8), // [cite: 135]
            // const Text('Job Swipe'), // [cite: 136]
          ],
        ),
        actions: [ // [cite: 136]
          IconButton( // [cite: 136]
            icon: const Icon(Icons.person), // [cite: 136]
            onPressed: () { // [cite: 137]
              logger.d('Estado actual de userPreferences: $userPreferences'); // [cite: 137]
              Navigator.push( // [cite: 138]
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen( // [cite: 138]
                    userProfile: widget.currentProfile, // [cite: 305]
                    points: points, // [cite: 139, 305]
                    directAnswers: userPreferencesList, // [cite: 139]
                    aiPreferences: userPreferences,
                  ),
                ),
              );
            },
          ),
          IconButton( // [cite: 140]
            icon: const Icon(Icons.business), // [cite: 140]
            onPressed: () { // [cite: 140]
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CompanyScreen(supabaseService: widget.supabaseService)), // [cite: 140, 307]
              );
            },
          ),
          IconButton( // [cite: 308]
            icon: const Icon(Icons.logout), // [cite: 308]
            onPressed: () async {
              await widget.supabaseService.signOutUser(); // [cite: 308]
              // StreamBuilder in MyApp will handle navigation
            },
          ),
        ],
      ),
      body: Column( // [cite: 141]
        children: [
          Padding( // [cite: 141]
            padding: const EdgeInsets.all(8.0), // [cite: 141]
            child: Text( // [cite: 142]
              'Puntos: $points', // [cite: 142]
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kLightTextColor), // [cite: 142]
            ),
          ),
          Expanded( // [cite: 142]
            child: _isLoadingOfertas
                ? const Center(child: CircularProgressIndicator()) // [cite: 310]
                : _errorMessage.isNotEmpty
                ? Center(child: Padding( // [cite: 311]
                    padding: const EdgeInsets.all(16.0),
                    child: Text(_errorMessage, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center), // [cite: 311]
                  ))
                : _ofertas.isEmpty
                ? Center( // [cite: 311]
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('No hay vacantes por ahora. ¡Vuelve pronto!', style: TextStyle(color: kLightTextColor)), // [cite: 312]
                        const SizedBox(height: 10),
                        ElevatedButton(onPressed: _cargarOfertas, child: const Text("Recargar")) // [cite: 316]
                      ],
                    )
                  )
                : currentIndex < _ofertas.length
                ? Dismissible( // [cite: 143, 312]
              key: ValueKey(_ofertas[currentIndex].id ?? UniqueKey()), // [cite: 143, 312]
              onDismissed: _onDismissed, // [cite: 143, 313]
              background: Container( // [cite: 143]
                color: Colors.green, // [cite: 143]
                alignment: Alignment.centerLeft, // [cite: 144]
                child: const Icon(Icons.thumb_up, color: Colors.white), // [cite: 144]
              ),
              secondaryBackground: Container( // [cite: 144]
                color: Colors.red, // [cite: 144]
                alignment: Alignment.centerRight, // [cite: 145]
                child: const Icon(Icons.thumb_down, color: Colors.white), // [cite: 145]
              ),
              child: JobCard(oferta: _ofertas[currentIndex]), // [cite: 145, 314]
            )
                : Center( // [cite: 315]
              child: Column( // [cite: 315]
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('¡Has visto todas las vacantes!', style: TextStyle(color: kLightTextColor)), // [cite: 315]
                  const SizedBox(height: 10), // [cite: 316]
                  ElevatedButton(onPressed: _cargarOfertas, child: const Text("Recargar")) // [cite: 316]
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper to build prompt for Gemini, using the structure from mainproyect.txt
  String _construirPromptParaGemini(List<String> directAnswers, Map<String, int> preferences) { // [cite: 185]
    String prompt = "Eres un recomendador inteligente de vacantes laborales. Considera estos intereses y preferencias del usuario con sus respectivos pesos (mayor peso = mayor interés, peso negativo = desinterés):\n"; // [cite: 185]
    preferences.forEach((key, value) { // [cite: 186]
      if (value != 0) { // [cite: 186]
        prompt += "- $key (peso: $value)\n"; // [cite: 186]
      }
    });

    if (directAnswers.isEmpty && preferences.values.every((element) => element == 0)) { // [cite: 187]
      prompt += "El usuario aún no ha proporcionado preferencias o interacciones.\n"; // [cite: 187]
    } else if (directAnswers.isNotEmpty) { // [cite: 188]
      prompt += "\nAdemás, el usuario ha respondido directamente lo siguiente a preguntas específicas:\n"; // [cite: 188]
      prompt += directAnswers.map((pref) => "- $pref\n").join(); // [cite: 189]
    }

    // Add salary, contract, experience from preferences map
    if ((preferences['salario_min'] ?? 0) > 0 || (preferences['salario_max'] ?? 0) > 0) { // [cite: 189]
      prompt += "\nEl usuario busca un salario entre \$${preferences['salario_min'] ?? 'N/A'}k y \$${preferences['salario_max'] ?? 'N/A'}k anuales.\n"; // [cite: 189]
    }
    preferences.forEach((key, value) { // [cite: 190]
      if (["Fijo", "Temporal", "Freelance"].contains(key) && value > 0) { // [cite: 190]
        prompt += "Prefiere contrato de tipo: $key (peso: $value).\n"; // [cite: 190]
      }
      if (["Entry", "Junior", "Mid", "Senior", "Expert"].contains(key) && value > 0) { // [cite: 190]
        prompt += "Tiene nivel de experiencia: $key (peso: $value).\n"; // [cite: 190]
      }
    });

    prompt += "\nBasado en esto, sugiere 3 vacantes ideales con Título, Empresa, Descripción breve, Ubicación, Salario (rango anual en miles, ej 50k-70k), Tipo de Contrato y Nivel de Experiencia. Formatea la respuesta estrictamente así:\n\n"; // [cite: 191]
    prompt += "**Recomendaciones:**\n"; // [cite: 192]
    prompt += "1. [Título] en [Empresa] - [Descripción]. Ubicación: [Ubicación]. Salario: [Rango Salarial]. Contrato: [Tipo Contrato]. Experiencia: [Nivel Experiencia].\n"; // [cite: 192]
    prompt += "2. [Título] en [Empresa] - [Descripción]. Ubicación: [Ubicación]. Salario: [Rango Salarial]. Contrato: [Tipo Contrato]. Experiencia: [Nivel Experiencia].\n"; // [cite: 193]
    prompt += "3. [Título] en [Empresa] - [Descripción]. Ubicación: [Ubicación]. Salario: [Rango Salarial]. Contrato: [Tipo Contrato]. Experiencia: [Nivel Experiencia].\n\n"; // [cite: 194]
    prompt += "**Pregunta:** [La pregunta que quieres hacer]\n"; // [cite: 195]
    return prompt; // [cite: 195]
  }
}

// --- JOB CARD WIDGET --- (Adapted for Oferta and theme)
class JobCard extends StatelessWidget {
  final Oferta oferta;
  // onLike and onDislike are handled by Dismissible's onDismissed
  const JobCard({super.key, required this.oferta}); // [cite: 149, 318]

  @override
  Widget build(BuildContext context) { // [cite: 149]
    return Container( // [cite: 149]
      width: 300, // [cite: 149]
      height: 450, // Adapted height
      padding: const EdgeInsets.all(16), // [cite: 149]
      decoration: BoxDecoration( // [cite: 149]
        color: Theme.of(context).cardColor, // Use themed card color [cite: 149]
        borderRadius: BorderRadius.circular(16), // [cite: 149]
        boxShadow: [ // [cite: 149]
          BoxShadow( // [cite: 150]
            color: Colors.black.withOpacity(0.3), // [cite: 150]
            spreadRadius: 3, // [cite: 150]
            blurRadius: 10, // [cite: 150]
            offset: const Offset(0, 4), // [cite: 150]
          ),
        ],
      ),
      child: Column( // [cite: 150]
        mainAxisAlignment: MainAxisAlignment.center, // [cite: 150]
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text( // [cite: 151]
            oferta.titulo, // [cite: 151]
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: kAccentColor), // [cite: 151, 320]
            textAlign: TextAlign.center, // [cite: 151]
          ),
          const SizedBox(height: 8), // [cite: 151]
          Text( // [cite: 151]
            oferta.empresa?.nombre ?? 'Empresa Desconocida', // [cite: 152, 320]
            style: TextStyle(fontSize: 18, color: kLightTextColor.withOpacity(0.85)), // [cite: 152]
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8), // [cite: 152]
          if (oferta.ubicacion != null && oferta.ubicacion!.isNotEmpty)
            Text( // [cite: 152]
              'Ubicación: ${oferta.ubicacion}', // [cite: 152]
              style: TextStyle(fontSize: 16, color: kLightTextColor.withOpacity(0.7)), // [cite: 152]
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 4), // [cite: 153]

          if (oferta.modalidad != null && oferta.modalidad!.isNotEmpty) ...[ // [cite: 322]
            Text(
              'Modalidad: ${oferta.modalidad}', // [cite: 322]
              style: TextStyle(fontSize: 16, color: kLightTextColor.withOpacity(0.7)), // [cite: 322]
               textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
          ],

          if (oferta.minSalary != null || oferta.maxSalary != null) ...[ // [cite: 153]
            Text(
              'Salario: \$${oferta.minSalary ?? 'N/A'}k - \$${oferta.maxSalary ?? 'N/A'}k anuales', // [cite: 153]
              style: TextStyle(fontSize: 16, color: Colors.greenAccent.withOpacity(0.9), fontWeight: FontWeight.w500), // [cite: 153]
              textAlign: TextAlign.center,
            ),
             const SizedBox(height: 4),
          ],


          if (oferta.contractType != null && oferta.contractType!.isNotEmpty) ...[ // [cite: 154]
            Text(
              'Contrato: ${oferta.contractType}', // [cite: 154]
              style: TextStyle(fontSize: 16, color: kLightTextColor.withOpacity(0.7)), // [cite: 154]
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
          ],

          if (oferta.experienceLevel != null && oferta.experienceLevel!.isNotEmpty) ...[ // [cite: 154]
            Text(
              'Experiencia: ${oferta.experienceLevel}', // [cite: 155]
              style: TextStyle(fontSize: 16, color: kLightTextColor.withOpacity(0.7)), // [cite: 155]
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 10), // [cite: 155]
          Expanded( // [cite: 155]
            child: SingleChildScrollView( // [cite: 155]
              child: Text( // [cite: 156]
                oferta.descripcion, // [cite: 156]
                style: TextStyle(fontSize: 15, color: kLightTextColor.withOpacity(0.9)), // [cite: 156]
                textAlign: TextAlign.center, // [cite: 156]
              ),
            ),
          ),
          // Like/Dislike buttons are removed as swipe handles this. [cite: 157, 158, 159]
          const SizedBox(height: 20), // [cite: 157]
        ],
      ),
    );
  }
}


// --- PROFILE SCREEN --- (Combined)
class ProfileScreen extends StatelessWidget {
  final Profile userProfile; // [cite: 160, 326]
  final int points; // [cite: 160, 327]
  final List<String> directAnswers; // From mainproyect.txt (userPreferencesList) [cite: 161]
  final Map<String, int> aiPreferences; // From mainproyect.txt (userPreferences map)

  const ProfileScreen({ // [cite: 161]
    super.key,
    required this.userProfile, // [cite: 161, 327]
    required this.points, // [cite: 161, 327]
    required this.directAnswers, // [cite: 161]
    required this.aiPreferences,
  });

  @override
  Widget build(BuildContext context) { // [cite: 162]
    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil')), // [cite: 162]
      body: Padding( // [cite: 162]
        padding: const EdgeInsets.all(16.0),
        child: ListView( // Changed to ListView for scrollability
          children: [
            Text('Nombre: ${userProfile.nombre}', style: const TextStyle(fontSize: 20, color: kLightTextColor)), // [cite: 162]
            const SizedBox(height: 10), // [cite: 163]
            Text('Correo: ${userProfile.correo}', style: TextStyle(fontSize: 18, color: kLightTextColor.withOpacity(0.8))), // [cite: 328]
            const SizedBox(height: 10),
            Text('Rol: ${userProfile.rol}', style: TextStyle(fontSize: 18, color: kLightTextColor.withOpacity(0.8))), // [cite: 329]
             const SizedBox(height: 10),
            Text('Miembro desde: ${userProfile.fechaRegistro?.toLocal().toString().substring(0, 10) ?? 'N/A'}', // [cite: 329]
                style: TextStyle(fontSize: 18, color: kLightTextColor.withOpacity(0.8))),
            const SizedBox(height: 10),
            Text('Puntos de Gamificación: $points', style: TextStyle(fontSize: 18, color: kLightTextColor.withOpacity(0.9), fontWeight: FontWeight.bold)), // [cite: 163, 330]
            const SizedBox(height: 20), // [cite: 163]

            const Text('Intereses perfilados por IA (basado en swipes):', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kAccentColor)), // [cite: 163]
            const SizedBox(height: 10), // [cite: 163]
            if (aiPreferences.isNotEmpty && aiPreferences.values.any((element) => element != 0)) // [cite: 164]
              Column( // [cite: 164]
                crossAxisAlignment: CrossAxisAlignment.start,
                children: aiPreferences.entries // [cite: 164]
                    .where((e) => e.value != 0 && !["salario_min", "salario_max"].contains(e.key)) // Filter out non-displayable or zero-value preferences
                    .map((entry) => Text('- ${entry.key}: ${entry.value}', style: TextStyle(fontSize: 16, color: kLightTextColor.withOpacity(0.85)))) // [cite: 164]
                    .toList(),
              )
            else
              const Text('Aún no hay intereses perfilados por tus swipes.', style: TextStyle(color: kLightTextColor)), // [cite: 165]
            const SizedBox(height: 20), // [cite: 165]

            const Text('Respuestas Directas a Preguntas:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kAccentColor)), // [cite: 165]
            const SizedBox(height: 10), // [cite: 166]
            directAnswers.isNotEmpty // [cite: 166]
                ? Column( // [cite: 167]
              crossAxisAlignment: CrossAxisAlignment.start,
              children: directAnswers.map((pref) => Text('- $pref', style: TextStyle(fontSize: 16, color: kLightTextColor.withOpacity(0.85)))).toList(), // [cite: 167]
            )
                : const Text('Aún no has respondido preguntas directas.', style: TextStyle(color: kLightTextColor)), // [cite: 167]
          ],
        ),
      ),
    );
  }
}


// --- COMPANY SCREEN --- (For posting jobs, using Supabase)
class CompanyScreen extends StatefulWidget {
  final SupabaseService supabaseService;
  const CompanyScreen({super.key, required this.supabaseService}); // [cite: 168, 332]

  @override
  State<CompanyScreen> createState() => _CompanyScreenState(); // [cite: 169]
}

class _CompanyScreenState extends State<CompanyScreen> {
  final _titleController = TextEditingController(); // [cite: 169]
  final _companyController = TextEditingController(); // [cite: 169]
  final _descriptionController = TextEditingController(); // [cite: 170]
  final _locationController = TextEditingController(); // [cite: 170]
  final _minSalaryController = TextEditingController();
  final _maxSalaryController = TextEditingController();
  final _contractTypeController = TextEditingController();
  final _experienceLevelController = TextEditingController();
  final _categoriesController = TextEditingController(); // Comma-separated
  final _modalidadController = TextEditingController(); // [cite: 334]
  bool _isLoading = false; // [cite: 334]

  void _postJob() async { // [cite: 170, 335]
    if (_titleController.text.isNotEmpty && // [cite: 170]
        _companyController.text.isNotEmpty && // [cite: 170]
        _descriptionController.text.isNotEmpty && // [cite: 170]
        _locationController.text.isNotEmpty) { // [cite: 170]
      setState(() => _isLoading = true); // [cite: 335]
      try {
        final nuevaOferta = await widget.supabaseService.publicarOferta( // [cite: 336]
          titulo: _titleController.text, // [cite: 336]
          descripcion: _descriptionController.text, // [cite: 336]
          ubicacion: _locationController.text, // [cite: 336]
          nombreEmpresa: _companyController.text, // [cite: 336]
          minSalary: int.tryParse(_minSalaryController.text),
          maxSalary: int.tryParse(_maxSalaryController.text),
          contractType: _contractTypeController.text.isEmpty ? null : _contractTypeController.text,
          experienceLevel: _experienceLevelController.text.isEmpty ? null : _experienceLevelController.text,
          categories: _categoriesController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
          modalidad: _modalidadController.text.isEmpty ? null : _modalidadController.text, // [cite: 336]
        );
        if (mounted && nuevaOferta != null) { // [cite: 337]
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Vacante "${nuevaOferta.titulo}" publicada con éxito')), // [cite: 337]
          );
          Navigator.pop(context); // [cite: 172, 338]
        } else if (mounted) { // [cite: 338]
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se pudo publicar la vacante.')), // [cite: 338]
          );
        }
      } catch (e) {
        if (mounted) { // [cite: 339]
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString().replaceFirst("Exception: ", ""))), // [cite: 339]
          );
        }
      } finally {
        if (mounted) { // [cite: 340]
          setState(() => _isLoading = false); // [cite: 340]
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar( // [cite: 172, 341]
        const SnackBar(content: Text('Por favor, completa todos los campos obligatorios (*)')), // [cite: 172]
      );
    }
  }

 @override
  void dispose() {
    _titleController.dispose(); // [cite: 342]
    _companyController.dispose(); // [cite: 342]
    _descriptionController.dispose(); // [cite: 342]
    _locationController.dispose(); // [cite: 342]
    _minSalaryController.dispose();
    _maxSalaryController.dispose();
    _contractTypeController.dispose();
    _experienceLevelController.dispose();
    _categoriesController.dispose();
    _modalidadController.dispose(); // [cite: 342]
    super.dispose(); // [cite: 342]
  }


  @override
  Widget build(BuildContext context) { // [cite: 173]
    return Scaffold(
      appBar: AppBar(title: const Text('Publicar Vacante')), // [cite: 173]
      body: Padding( // [cite: 173]
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView( // [cite: 173]
          child: Column(
            children: [
              TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Título de la Vacante *')), // [cite: 173, 344]
              TextField(controller: _companyController, decoration: const InputDecoration(labelText: 'Nombre de la Empresa *')), // [cite: 174, 344]
              TextField(controller: _descriptionController, decoration: const InputDecoration(labelText: 'Descripción de la Vacante *'), maxLines: 3), // [cite: 175, 345]
              TextField(controller: _locationController, decoration: const InputDecoration(labelText: 'Ubicación (Ciudad o Remoto/Híbrido) *')), // [cite: 175, 346]
              TextField(controller: _modalidadController, decoration: const InputDecoration(labelText: 'Modalidad específica (Ej: Presencial, Híbrido, Remoto) (Opcional)')), // [cite: 347]
              TextField(controller: _minSalaryController, decoration: const InputDecoration(labelText: 'Salario Mínimo Anual (miles, ej: 30) (Opcional)'), keyboardType: TextInputType.number),
              TextField(controller: _maxSalaryController, decoration: const InputDecoration(labelText: 'Salario Máximo Anual (miles, ej: 50) (Opcional)'), keyboardType: TextInputType.number),
              TextField(controller: _contractTypeController, decoration: const InputDecoration(labelText: 'Tipo de Contrato (Ej: Fijo, Temporal) (Opcional)')),
              TextField(controller: _experienceLevelController, decoration: const InputDecoration(labelText: 'Nivel Experiencia (Ej: Junior, Mid, Senior) (Opcional)')),
              TextField(controller: _categoriesController, decoration: const InputDecoration(labelText: 'Categorías (separadas por coma, ej: tech,frontend) (Opcional)')),
              const SizedBox(height: 20), // [cite: 176, 348]
              _isLoading
                  ? const CircularProgressIndicator() // [cite: 349]
                  : ElevatedButton( // [cite: 176, 349]
                onPressed: _postJob, // [cite: 176]
                child: const Text('Publicar Vacante'), // [cite: 176]
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- HELPER EXTENSIONS --- (from mainproyect.txt)
extension IterableExtension<T> on Iterable<T> { // [cite: 182]
  T? firstWhereOrNull(bool Function(T element) test) { // [cite: 183]
    for (var element in this) { // [cite: 183]
      if (test(element)) { // [cite: 183]
        return element; // [cite: 183]
      }
    }
    return null; // [cite: 184]
  }
}
