import '../bin/hub.dart' as Hub;

main(){
  String path = "home.html.hub";

  var req = {"users":[{"name":"billy","age":30},{"name":"sally","age":38},{"name":"bob","age":22}],"thatNum":4,"treasure":{"map":true}};

  Hub.renderFile(path,req,{"cache":false}).then((tmp)=>print(tmp));
}