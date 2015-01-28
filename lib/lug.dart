library lug;

import 'dart:io';
import 'dart:convert';
import 'dart:isolate';
import 'dart:async';
import 'package:crypto/crypto.dart';
part 'src/parser.dart';
part 'src/config.dart';
part 'src/utils.dart';


class Lug{

  _Lug lug;
  Lug([Map options]){
    lug = new _Lug();
    if(options != null)
      options.forEach((k,v){
        lug._options[k] = v;
      });
  }

  render(String html,[String path,var req,List imports]){
    return lug.render(html,path,req,imports);
  }
  
  renderFile(File file,var params,[List imports]){
    return lug.renderFile(file,params,imports);
  }
  
  String get ext => ".html.lug";
  
  Map get opts => lug._options;
}