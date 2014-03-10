import '../bin/hub.dart' as Hub;
import 'dart:io';
main(){

  //start the server and visit localhost:8080/helloworld?user=Cthulhu
  HttpServer.bind("127.0.0.1", 8080).then((HttpServer s){
     s.listen((HttpRequest request){
     Map params = request.uri.queryParameters;
     String path = request.uri.path.substring(1);
     Hub.renderFile(path, params, {"cache":false}).then((res){
       request.response.write(res);
       request.response.close();
     });
     });
  });
}