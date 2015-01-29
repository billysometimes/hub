part of lug;

class _Lug{

  Map _options = _Config.options;
  List _imports = [];
  Map _cache = {};
  
  Stream renderFile(File file,params,[imports=null]){
    StreamController sc = new StreamController();
    if(imports != null){
      imports.forEach((imprt){
        _imports.add("import '$imprt';\n");
      });
    }
    
    if(_cache[file.path] != null){
      //file is cached.
      file.lastModified().then((DateTime lastModified){
        if(lastModified == _cache[file.path]){
          //file has not changed since cache.
          _readCache(file.path).then((String targetPath){
                 _runIsolate(targetPath,params,sc);
               }).catchError((Error){
                 //TODO log the error
                 _writeNew(null, file,params).then((String targetPath){
                   _runIsolate(targetPath,params,sc);
                 });
               });
        }
      });
    }else{
      //file has not been cached or cache is out of date
      _writeNew(null,file,params).then((String targetPath){
        _runIsolate(targetPath,params,sc);
        file.lastModified().then((DateTime lastModified){
          _cache[file.path] = lastModified;  
        });  
      });
    }
    return sc.stream;
    
  }
  Stream render(String html, [String fileName, Map req,List imports]){
    StreamController sc = new StreamController();

    if(imports != null){
      imports.forEach((imprt){
        _imports.add("import '$imprt';\n");
      });
    }
    
    String md5 = CryptoUtils.bytesToHex((new MD5()..add(html.codeUnits)).close());
    String path;
    if(md5 == _cache[fileName]){
      _readCache(fileName).then((String targetPath){
        _runIsolate(targetPath,req,sc);
      }).catchError((Error){
        //TODO log the error
        _writeNew(html, new File(fileName),req).then((String targetPath){
          _runIsolate(targetPath,req,sc);
        });
      });
    }else{
      _writeNew(html, new File(fileName),req).then((String targetPath){
        _runIsolate(targetPath,req,sc);
      });
   }

   return sc.stream;
  }

  Future _writeNew(String html,File file,req){
    Completer<String> c = new Completer();
    _getWriteFile(file).then((File ff){
      IOSink writer = ff.openWrite();

      writer.done.then((_){
        c.complete(ff.absolute.path);
      });  


    List tokens = [];

    if(html != null){
      tokens.addAll(_tokenize(html));
    }else{
      tokens.addAll(_tokenize(file.readAsStringSync()));
    }
    for(int i=0;i<_imports.length; i++){
      writer.add(_imports[i].codeUnits);
    }
    writer.add(WRITEHEAD.codeUnits);
    
    if(req != null){
      req.forEach((k,v){
        writer.add("var ${k} = args[0]['${k}'];\n".codeUnits);
      });
    }

    writer.add(tokens.join("").codeUnits);
    writer.add(WRITETAIL.codeUnits);
    writer.close();
    });
    return c.future;
  }
  
  List _tokenize(String html){
    var htmlcp = html;
    List buffer = [];
    var addToBuffer = false;
    htmlcp = htmlcp.replaceAll(new RegExp('${_options["LUG_OPEN_SYMBOL"]}'), "LUGTAG"+_options["LUG_OPEN_SYMBOL"]);
    htmlcp = htmlcp.replaceAll(new RegExp('${_options["LUG_CLOSE_SYMBOL"]}'), _options["LUG_CLOSE_SYMBOL"]+"LUGTAG");
    htmlcp = htmlcp.replaceAll(r"'", r"\'");

    if(Platform.isWindows)
      htmlcp = htmlcp.replaceAll(new RegExp(r'\r\n+'), '\\n');
    else
      htmlcp = htmlcp.replaceAll(new RegExp(r'\n+'), '\\n');


    List l = htmlcp.split("LUGTAG");
    l.forEach((e){
      if(!e.trim().startsWith(new RegExp('${_options["LUG_OPEN_SYMBOL"]}'))){
        buffer.add("sendPort.send('${e}'.codeUnits);\n");
      }else{
        e = e.replaceAll(new RegExp('${_options["LUG_OPEN_SYMBOL"]}'), "");
        e = e.replaceAll(new RegExp('${_options["LUG_CLOSE_SYMBOL"]}'), "");
        if(e.startsWith(r'=')){
          e = e.replaceFirst(r'=', "");
          buffer.add("sendPort.send(escape(");
          buffer.add(e);
          buffer.add(").codeUnits);\n");
        }else if(e.trim().startsWith(_options["LUG_INCLUDE"])){
           e = e.replaceAll(r"\'", '"');
           var path = e.substring(e.indexOf('"')+1);
           path = path.substring(0,path.indexOf('"'));
           if(_options.containsKey("templatePath"))
             path = _options["templatePath"]+Platform.pathSeparator+path;
               buffer.addAll(_tokenize(new File(path).readAsStringSync()));
        }else if(e.trim().startsWith(_options["LUG_IMPORT"])){
          e = e.replaceAll(r"\'", '"');
          var path = e.substring(e.indexOf('"')+1);
          path = path.substring(0,path.indexOf('"'));
          _imports.add("import '$path';\n");
        }else{
          e = e.replaceAll("\\n", "\n");
          buffer.add(e);
        }
      }
    });
    return buffer;
  }

  Future _getWriteFile(File file){
    Completer c = new Completer();
    Directory cacheDir = new Directory(_options["cachePath"]);
    cacheDir.exists().then((bool exists){
      if(!exists){
        //TODO switch this to a log.
        print("Cache directory did not exist, creating it.");
        cacheDir.create().then((Directory dir){
          c.complete(_grabFile(dir,file));
        });
      }else{
        //the directory exists, grab the file
        c.complete(_grabFile(cacheDir,file));
      }
    });
    return c.future;
  }
  
  Future _grabFile(Directory dir,File file){
    Completer<File> c = new Completer();
    int end = file.path.indexOf(".") > -1 ? file.path.indexOf(".") : file.path.length;
    String fileName = file.path.substring(0,end);
    File writeIt = new File("${dir.absolute.path}${fileName+'_cache'}.dart");
        writeIt.exists().then((bool exists){
          if(!exists){
            print("Cache file is being created");
            writeIt.create().then((File file){
              c.complete(file);
              });
          }else{
            c.complete(writeIt);
          }
        });
        return c.future;
  }
  Future _writeCache(String fileData,String fileName){
    Completer c = new Completer();
    Directory cacheDir = new Directory(_options["cachePath"]);
    cacheDir.exists().then((bool exists){
      if(!exists){
        //TODO switch this to a log.
        print("Cache directory did not exist, creating it.");
        cacheDir.create().then((Directory d){
          c.complete(_writeFile(d.absolute.path,fileName,fileData));
        });
      }else{
        c.complete(_writeFile(cacheDir.absolute.path,fileName,fileData));
      }
    });

    return c.future;
  }

  Future _writeFile(String path,String fileName, String fileData){
    Completer c = new Completer();
    File writeIt = new File("${path+Platform.pathSeparator}${fileName+'_cache'}.dart");
    writeIt.exists().then((bool exists){
      if(!exists){
        print("Cache file is being created");
        writeIt.create().then((File file){
          c.complete(_actuallyWriteFile(file,fileData));
          });
      }else{
        c.complete(_actuallyWriteFile(writeIt,fileData));
      }
    });
    return c.future;
  }
  
  Future _actuallyWriteFile(File writeIt, String fileData){
    Completer c = new Completer();
    writeIt.open(mode: FileMode.WRITE).then((RandomAccessFile raFile){
      raFile.writeString(fileData,encoding: UTF8).then((RandomAccessFile writtenFile){
        writtenFile.close().then((d){
          c.complete(writeIt.absolute.path);
        });
      });
  });
    return c.future;
  }
  
  Future _readCache(String fileName){
    Completer c = new Completer();
    Directory cacheDir = new Directory(_options["cachePath"]);
    cacheDir.exists().then((bool exists){
      if(!exists){
        return c.completeError(new Exception("cache does not exist"));
      }else{
        File readIt = new File("${cacheDir.path+Platform.pathSeparator}${fileName+'_cache'}.dart");
        readIt.exists().then((bool exists){
          if(exists){
            //TODO log this
            print("Cache exists, using cache");
            return c.complete(readIt.absolute.path);
          }else{
            return c.completeError(new Exception("File $fileName does not exist in cache directory."));
          }
        });
      }
    });
   return c.future;
  }


  void _runIsolate(String path, Map req, StreamController sc){
  
    
    ReceivePort receivePort = new ReceivePort();
    receivePort.listen((msg){
     if(msg == null){
       receivePort.close();
     }else{
       sc.add(msg);
     }
    },onDone:()=>sc.close());
    
    Future<Isolate> templatizer = Isolate.spawnUri(Uri.parse(path), [req], receivePort.sendPort);

  }

  _writeVars(Map localVars){
    List l = [];
    localVars.forEach((k,v){
      l.add("var ${k} = args[0]['${k}'];\n");
    });
    return l;
  }

 static String WRITEHEAD = "import 'dart:isolate';\n" +
                           "import 'import 'package:lug/utils.dart';\n" +
                            "main(List args,SendPort sendPort) {\n" +
                            "  List buffer = [];\n" +
                            "  try {\n";

  static String WRITETAIL = "  }catch(e){\n"+
                            "    sendPort.send(e.toString().codeUnits);\n" +
                            "  }\nfinally{sendPort.send(null);}\n"+
                            "}\n\n";

}


