library hub;

import 'dart:io';
import 'dart:convert';
import 'dart:isolate';
import 'dart:async';
part '../lib/parser.dart';
part '../lib/config.dart';

Future render(html,[path,req,options]) => new _Hub().render(html,path,req,options);

Future renderFile(path,[req,options]) {
  File f = new File(path);
  String html = f.readAsStringSync(encoding: UTF8);
  return new _Hub().render(html,path,req,options);
  }