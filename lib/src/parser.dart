part of lug;

class _Lug{

  Map _options = _Config.options;
  List _imports = [];
  Map _cache = {};
  Future render(String html, [String fileName, Map req]){
    String md5 = CryptoUtils.bytesToHex((new MD5()..add(html.codeUnits)).close());
    String path;
    if(md5 == _cache[fileName]){
      try{
        path = readCache(fileName);
      }catch(exception){
        path = writeNew(html,fileName,req);
      }
    }else{
        path = writeNew(html,fileName,req);
   }

   Future<String> data = runIsolate(path,req);
   return data;
  }

  writeNew(html,fileName,req){
    _cache[fileName] = CryptoUtils.bytesToHex((new MD5()..add(html.codeUnits)).close());
    List tokens = [];

    tokens.add(WRITEHEAD);
    if(req != null){
      tokens.addAll(writeVars(req));
    }
    tokens.addAll(tokenize(html));
    tokens.add(WRITETAIL);
    tokens.insertAll(0, _imports);
    String parsedHtml = tokens.join("");
    return writeCache(parsedHtml,fileName);
  }
  tokenize(String html){
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
        buffer.add("buffer.add('${e}');\n");
      }else{
        e = e.replaceAll(new RegExp('${_options["LUG_OPEN_SYMBOL"]}'), "");
        e = e.replaceAll(new RegExp('${_options["LUG_CLOSE_SYMBOL"]}'), "");
        if(e.startsWith(r'=')){
          e = e.replaceFirst(r'=', "");
          buffer.add("buffer.add(escape(");
          buffer.add(e);
          buffer.add("));\n");
        }else if(e.trim().startsWith(_options["LUG_INCLUDE"])){
           e = e.replaceAll(r"\'", '"');
           var path = e.substring(e.indexOf('"')+1);
           path = path.substring(0,path.indexOf('"'));
           if(_options.containsKey("templatePath"))
             path = _options["templatePath"]+Platform.pathSeparator+path;
               buffer.addAll(tokenize(new File(path).readAsStringSync()));
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


  //TODO make this async
  String writeCache(String fileData,String fileName){
    Directory cacheDir = new Directory(_options["cachePath"]);
    if(cacheDir.existsSync() == false){
      print("Cache directory did not exist, creating it.");
      cacheDir.createSync();
    }
    File writeIt = new File("${cacheDir.path+Platform.pathSeparator}${fileName+'_cache'}.dart");
    if (!writeIt.existsSync()) {
      print("Cache file is being created");
      writeIt.createSync();
    }
    writeIt.openSync();
    writeIt.writeAsStringSync(fileData, mode: FileMode.WRITE, encoding: UTF8, flush: true);
    return writeIt.absolute.path;
  }

  String readCache(String fileName){
    Directory cacheDir = new Directory(_options["cachePath"]);
    if(cacheDir.existsSync() == false){
      throw new Exception("cache does not exist");
    }
    File readIt = new File("${cacheDir.path+Platform.pathSeparator}${fileName+'_cache'}.dart");
    if (readIt.existsSync()) {
        print("Cache exists, using cache");
        return readIt.path;
      }else{
        throw new Exception("File $fileName does not exist in cache directory.");
      }
    }


  Future runIsolate(String path, Map req){
    Completer c = new Completer();

    ReceivePort receivePort = new ReceivePort();
    receivePort.listen((msg){
      c.complete(msg);
    });
    
    Future<Isolate> templatizer = Isolate.spawnUri(Uri.parse(path), [req], receivePort.sendPort);

    return c.future;
  }

  writeVars(Map localVars){
    List l = [];
    localVars.forEach((k,v){
      l.add("var ${k} = args[0]['${k}'];\n");
    });
    return l;
  }

 static String WRITEHEAD = "import 'dart:isolate';\n" +
                            "main(List args,SendPort sendPort) {\n" +
                            "  List buffer = [];\n" +
                            "try {\n";

  static String WRITETAIL = "  sendPort.send(\"\${buffer.join('')}\");\n"+
                            "}catch(e){\n"+
                            "  sendPort.send(e.toString());\n" +
                            "}\n\n"+
                            "}\n\n" +
                            "String escape(html){\n" +
                            "return html is Map ? html[\"unsafe\"] : html.toString().replaceAll(r'&', '&amp;')\n" +
                            ".replaceAll(r'<', '&lt;')\n" +
                            ".replaceAll(r'>', '&gt;')\n" +
                            ".replaceAll(r\"'\", '&#39;')\n" +
                            ".replaceAll('\"', '&quot;');\n" +
                             "}\n\n" +
                             "unsafe(str){\n" +
                             "return {\"unsafe\":str};"
                             "}";

}


