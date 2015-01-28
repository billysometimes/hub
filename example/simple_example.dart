import '../lib/lug.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';
main(){
  String path = "simple_example";

  var req = {"users":[{"name":"billy","age":30},{"name":"sally","age":38},{"name":"bob","age":22}],"thatNum":4,"treasure":{"map":true}};

  new Lug({"cache":false}).render(new File("simple_example.html.lug").readAsStringSync(),"simple_example",req).transform(UTF8.decoder).listen((data){
      print(data);
    });
}