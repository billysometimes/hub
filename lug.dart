library lug;

import 'dart:io';
import 'dart:convert';
import 'dart:isolate';
import 'dart:async';
part 'src/parser.dart';
part 'src/config.dart';

class Lug{
  Future renderFromString(html,[path,req,options]) => new _Lug().render(html,path,req,options);

  Future render(path,[req,options]) {
  String fileName = path;
  if(options["templatePath"] != null){
    path = options["templatePath"] + path;
  }
  File f = new File(path+".html.lug");
  String html;
  if(f.existsSync())
    html = f.readAsStringSync(encoding: UTF8);
  else
    html = "";
  return new _Lug().render(html,fileName,req,options);
  }
}