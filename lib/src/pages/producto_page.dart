import 'dart:io';
import 'package:flutter/material.dart';
import 'package:formvalidation/src/blocs/provider.dart';
import 'package:image_picker/image_picker.dart';

import 'package:formvalidation/src/models/producto_model.dart';

import 'package:formvalidation/src/utils/utils.dart' as utils;

class ProductoPage extends StatefulWidget {

  @override
  _ProductoPageState createState() => _ProductoPageState();
}

class _ProductoPageState extends State<ProductoPage> {

  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  ProductosBloc productosBloc;
  ProductoModel producto = new ProductoModel();

  bool _guardando = false;
  File foto;
  

  @override
  Widget build(BuildContext context) {

    productosBloc = Provider.productosBloc(context);

    final ProductoModel prodData = ModalRoute.of(context).settings.arguments;
    if ( prodData != null){
      producto = prodData;
    }

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text('Producto'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.photo_size_select_actual),
            onPressed: _seleccionarFoto,
          ),
          IconButton(
            icon: Icon(Icons.camera_alt),
            onPressed: _tomarFoto,
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(15.0),
          child: Form(
            key: formKey,
            child: Column(
              children: <Widget>[
                _mostrarFoto(),
                _crearNombre(),
                SizedBox(height: 10.0),
                _crearPrecio(),
                _crearDisponible(context),
                SizedBox(height: 30.0),
                _crearBoton(context)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _crearNombre(){
    return TextFormField(
      initialValue: producto.titulo,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        labelText: 'Producto'
      ),
      onSaved: (value) => producto.titulo = value,
      validator: (value){
        if(value.length < 3){
          return 'Ingrese el nombre del producto';
        }else{
          return null;
        }
      },
    );
  }

  Widget _crearPrecio(){
    return TextFormField(
      initialValue: producto.valor.toString(),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: 'Precio',
      ),
      onSaved: (value) => producto.valor = double.parse(value),
      validator: (value){
        if(utils.isNumeric(value)) return null;
        return 'Sólo números';
      },
    );
  }

  Widget _crearDisponible(BuildContext context){
    return SwitchListTile(
      value: producto.disponible,
      title: Text('Disponible'),
      activeColor: Theme.of(context).primaryColor,
      onChanged: (value) => setState((){
        producto.disponible = value;
      }),
    );
  }

  Widget _crearBoton(BuildContext context){
    return RaisedButton.icon(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25.0),
      ),
      color: Theme.of(context).primaryColor,
      textColor: Colors.white,
      label: Text('Guardar', style: TextStyle(fontSize: 16.0)),
      icon: Icon(Icons.save),
      onPressed: ( _guardando ) ? null : _submit,
    );
  }

  void _submit() async {
    if(!formKey.currentState.validate()) return;
    formKey.currentState.save();

    setState(() { _guardando = true; });

    if(foto != null){
      producto.fotoUrl = await productosBloc.subirFoto(foto);
    }

    print('Todo OK');
    print(producto.titulo);
    print(producto.valor);
    print(producto.disponible);

    if (producto.id == null){
      productosBloc.agregarProducto(producto);
    } else {
      productosBloc.editarProducto(producto);
    }
    setState(() { _guardando = false; });
    mostrarSnackbar('Registro Guardado');
    
  }

  void mostrarSnackbar(String mensaje){
    final snackbar = SnackBar(
      content: Text(mensaje),
      duration: Duration(milliseconds: 1500),
    );

    scaffoldKey.currentState.showSnackBar(snackbar);

    Navigator.pop(context);

  }

  _mostrarFoto(){
    if (producto.fotoUrl != null){
      return FadeInImage(
        image: NetworkImage(producto.fotoUrl),
        placeholder: AssetImage('assets/images/jar-loading.gif'),
        height: 300.0,
        fit: BoxFit.cover,
      );
    }
    return Image(
      image: AssetImage(foto?.path ?? 'assets/images/no-image.png'),
      height: 300.0,
      fit: BoxFit.cover,
    );
  }

  _seleccionarFoto() async {
    _procesarImagen(ImageSource.gallery);
  }

  _tomarFoto() async {
    _procesarImagen(ImageSource.camera);
  }

  _procesarImagen(ImageSource origen) async {
    foto = await ImagePicker.pickImage(
      source: origen
    );

    if (foto != null) {
      producto.fotoUrl = null;
    }

    setState(() {});
  }
}