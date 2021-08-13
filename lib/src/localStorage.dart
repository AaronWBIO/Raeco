import 'package:shared_preferences/shared_preferences.dart';

class localStorage {
  String usuario = "";

  String key = "usuario";
  SharedPreferences pref;

  localStorage() {
    _read();
  }

  String getUser() {
    return this.usuario;
  }

  remove() {
    pref.remove('usuario');
  }

  guardar(nombre) {
    pref.setString('usuario', nombre);
  }

  _read() async {
    pref = await SharedPreferences.getInstance();
    this.usuario = pref.getString(key) ?? "";
    print('read: $usuario');
  }
}
