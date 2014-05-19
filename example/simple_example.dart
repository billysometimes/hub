import 'package:lug/lug.dart';
import 'dart:io';
main(){
  String path = "simple_example";

  var req = {"users":[{"name":"billy","age":30},{"name":"sally","age":38},{"name":"bob","age":22}],"thatNum":4,"treasure":{"map":true}};

  new Lug({"cache":false}).render(new File("simple_example.html.lug").readAsStringSync(),path,req).then(
      (tmp)=>print(tmp));
}