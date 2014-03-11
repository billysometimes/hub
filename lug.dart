library lug;

import 'dart:io';
import 'dart:convert';
import 'dart:isolate';
import 'dart:async';
part 'src/parser.dart';
part 'src/config.dart';

class Lug{
  Future render(html,[path,req,options]) => new _Lug().render(html,path,req,options);

  Future renderFile(path,[req,options]) {
  if(options["templatePath"] != null){
    path = options["templatePath"] + path;
  }
  File f = new File(path+".html.lug");
  String html;
  if(f.existsSync())
    html = f.readAsStringSync(encoding: UTF8);
  else
    html = "";
  return new _Lug().render(html,path,req,options);
  }
}