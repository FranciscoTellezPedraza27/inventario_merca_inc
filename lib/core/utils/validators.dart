String? validateEmail(String value) {
  if (value.isEmpty) return 'El correo es obligatorio';
  if (!RegExp(r"^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+\.[a-z]").hasMatch(value)) {
    return 'Correo no válido';
  }
  return null;
}
