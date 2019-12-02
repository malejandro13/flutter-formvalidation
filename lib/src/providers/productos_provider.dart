import 'dart:convert';
import 'dart:io';
import 'package:formvalidation/src/shared_preferences/shared_preferences.dart';
import 'package:mime_type/mime_type.dart';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import 'package:formvalidation/src/models/producto_model.dart';

class ProductosProvider {

  final String _url = 'https://flutter-59ff8.firebaseio.com';
  final _prefs = new PreferenciasUsuario();

  Future<bool> crearProducto( ProductoModel producto) async { 
    final url = '$_url/productos.json?auth=${_prefs.token}';

    final res = await http.post(url, body: productoModelToJson(producto));

    final decodeData = json.decode(res.body);

    print(decodeData);
    return true;
  }

  Future<bool> editarProducto( ProductoModel producto) async { 
    final url = '$_url/productos/${ producto.id }.json?auth=${_prefs.token}';

    final res = await http.put(url, body: productoModelToJson(producto));

    final decodeData = json.decode(res.body);

    print(decodeData);
    return true;
  }


  Future<List<ProductoModel>> cargarProductos() async {
    final url = '$_url/productos.json?auth=${_prefs.token}';

    final res = await http.get(url);

    final Map<String, dynamic> decodeData = json.decode(res.body);
    final List<ProductoModel> productos = new List();

    if( decodeData == null) return [];

    if( decodeData['error'] != null) return [];

    decodeData.forEach((id, prod) {
      final prodTemp = ProductoModel.fromJson(prod);
      prodTemp.id = id;

      productos.add(prodTemp);
    });

    return productos;

  }

  Future<int> borrarProducto( String id) async { 
    final url = '$_url/productos/$id.json?auth=${_prefs.token}';

    final res = await http.delete(url);

    final decodeData = json.decode(res.body);

    print(decodeData);
    return 1;
  }

  Future<String> subirImagen(File imagen) async {
    final url = Uri.parse('https://api.cloudinary.com/v1_1/dhbzqovw4/image/upload?upload_preset=riebzwdc');
    final mimeType = mime(imagen.path).split('/'); // image/jpeg
    final imageUploadRequest = http.MultipartRequest(
      'POST',
      url
    );
    final file = await http.MultipartFile.fromPath(
      'file', 
      imagen.path,
      contentType: MediaType(mimeType[0], mimeType[1])
    );

    imageUploadRequest.files.add(file);

    final streamResponse = await imageUploadRequest.send();
    final res = await http.Response.fromStream(streamResponse);

    if(res.statusCode != 200 && res.statusCode != 201){
      print('algo salió mal');
      print(res.body);
      return null;
    }

    final respData = json.decode(res.body);
    print(respData);

    return respData['secure_url'];

  }
  
}

//https://api.cloudinary.com/v1_1/dhbzqovw4/image/upload

//tq7nbo8v : tq7nbo8v
//file : 
//https://res.cloudinary.com/demo/image/upload/v1473596672/eneivicys42bq5f2jpn2.jpg