import 'dart:convert';

import 'package:formvalidation/src/shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class UsuarioProvider {
  
  final String _firebaseToken = 'AIzaSyC01l4pM3JX1meF_2sm8xi6HeZUjzg9WIU';
  final _prefs = new PreferenciasUsuario();

  Future<Map<String, dynamic>> loginUsuario(String email, String password) async {
    final authData = {
      'email' : email,
      'password' : password,
      'returnSecureToken' : true
    };

    final resp = await http.post(
      'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$_firebaseToken',
      body: json.encode(authData)
    );

    Map<String, dynamic> decodeResp = json.decode(resp.body) ;

    print(decodeResp);

    if(decodeResp.containsKey('idToken')){
      _prefs.token = decodeResp['idToken'];
      return {'ok' : true, 'token' : decodeResp['idToken']};
    }
    return {'ok' : false, 'mensaje' : decodeResp['error']['message']};
  }

  Future<Map<String, dynamic>> nuevoUsuario(String email, String password) async {
    final authData = {
      'email' : email,
      'password' : password,
      'returnSecureToken' : true
    };

    final resp = await http.post(
      'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$_firebaseToken',
      body: json.encode(authData)
    );

    Map<String, dynamic> decodeResp = json.decode(resp.body) ;

    print(decodeResp);

    if(decodeResp.containsKey('idToken')){
      return {'ok' : true, 'token' : decodeResp['idToken']};
    }
    return {'ok' : false, 'mensaje' : decodeResp['error']['message']};

  }

}