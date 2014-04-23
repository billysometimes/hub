library lug;

import 'dart:io';
import 'dart:convert';
import 'dart:isolate';
import 'dart:async';
part 'src/parser.dart';
part 'src/config.dart';

class Lug{

  _Lug lug;

  Lug([Map options]){
    lug = new _Lug();
    if(options != null)
      options.forEach((k,v){
        lug._options[k] = v;
      });
  }


  Future render(path,[req]) {
  Completer c = new Completer();
  String fileName = path;
  if(lug._options["templatePath"] != null){
    path = lug._options["templatePath"] + Platform.pathSeparator+path;
  }

  File f = new File(path+".html.lug");
  String html;
  if(f.existsSync()){
    html = f.readAsStringSync(encoding: UTF8);
    c.complete(lug.render(html,fileName,req));
  }
  else
    c.complete(new Exception("File Does not exist"));

  return c.future;
  }

  Future renderFromString(html,[path,req]){
    return lug.render(html,path,req);
  }
}