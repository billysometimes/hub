import '../bin/lug.dart' as Lug;

main(){
  String path = "simple_example";

  var req = {"users":[{"name":"billy","age":30},{"name":"sally","age":38},{"name":"bob","age":22}],"thatNum":4,"treasure":{"map":true}};

  Lug.renderFile(path,req,{"cache":false}).then(
      (tmp)=>print(tmp));
}