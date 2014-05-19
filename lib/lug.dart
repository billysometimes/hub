library lug;

import 'dart:io';
import 'dart:convert';
import 'dart:isolate';
import 'dart:async';
import 'package:crypto/crypto.dart';
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

  Future render(html,[path,req]){
    return lug.render(html,path,req);
  }
}