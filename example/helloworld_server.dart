import '../lib/lug.dart';
import 'dart:io';
main(){

  //start the server and visit localhost:8181/helloworld?user=Cthulhu
  HttpServer.bind("127.0.0.1", 8181).then((HttpServer s){
     s.listen((HttpRequest request){
       request.response.headers.contentType = ContentType.HTML;
      Map params = request.uri.queryParameters;
       String path = request.uri.path.substring(1);
       Lug lug = new Lug({"cache":false});
       new File(path+lug.ext).exists().then((doesExist){
       if(doesExist)
           lug.renderFile(new File(path+lug.ext), params).pipe(request.response).then((res){
                  request.response.close();
           });
       });

     });
  });
}