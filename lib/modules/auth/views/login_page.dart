import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _signIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError("Por favor, completa todos los campos.");
      return;
    }

    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      Navigator.pushReplacementNamed(context, '/dashboard');
    } catch (e) {
      _showError("Error al iniciar sesión. Verifica tus credenciales.");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sección de imagen (50%)
          Container(
            width: MediaQuery.of(context).size.width * 0.5,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/images/FondoLogin.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Espacio restante + formulario centrado
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 90),
              color: Colors.white,
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Iniciar Sesión',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[900],
                          ),
                        ),
                        const SizedBox(height: 30),
                        _buildInputField('Correo', _emailController),
                        const SizedBox(height: 15),
                        _buildInputField('Contraseña', _passwordController, isPassword: true),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _signIn,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              backgroundColor: Colors.blue[800],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Continuar',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        /*TextButton(
                          onPressed: () => Navigator.pushNamed(context, '/register'),
                          child: Text(
                            '¿Aún no tienes una cuenta? Regístrate',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[800],
                            ),
                          ),
                        ),*/
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.blue[800]!),
        ))
    );
  }
}