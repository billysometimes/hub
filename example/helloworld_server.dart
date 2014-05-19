import 'package:lug/lug.dart';
import 'dart:io';
main(){

  //start the server and visit localhost:8181/helloworld?user=Cthulhu
  HttpServer.bind("127.0.0.1", 8181).then((HttpServer s){
     s.listen((HttpRequest request){
     Map params = request.uri.queryParameters;
     String path = request.uri.path.substring(1);
     Lug lug = new Lug({"cache":false});
     new File(path+".html.lug").exists().then((doesExist){
         new File(path+".html.lug").readAsString().then((html){
           lug.render(html,path, params).then((res){
                  request.response.write(res);
                  request.response.close();
                });
         });

     });

     });
  });
}