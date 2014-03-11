part of lug;

class _Lug{

  Map _options = Config.options;

  Future render(String html, [String ogPath, Map req, Map options]){
   if(options != null){
     options.forEach((k,v){
       _options[k] = v;
     });
   }
   List tokens = [WRITEHEAD];
   if(req != null){
     tokens.addAll(writeVars(req));
   }
   tokens.addAll(tokenize(html));
   tokens.add(WRITETAIL);
   String parsedHtml = tokens.join("");
   String path = writeCache(parsedHtml,ogPath);
   Future<String> data = runIsolate(path,req);
   return data;
  }

  tokenize(String html){
    List buffer = [];
    String stringBuf = "";
    String lugBuf = "";
    bool inLug = false;
    bool doWrap = false;

    var i=0;
    html = html.replaceAll(new RegExp(r'\n+'), '\\n');
    while(i<html.length){
      if(i+Config.LUG_OPEN_SYMBOL.length <= html.length && html.substring(i, i+Config.LUG_OPEN_SYMBOL.length) == Config.LUG_OPEN_SYMBOL){
        if(inLug == true){
          throw new Exception("Cannot open lug tag inside of lug block");
        } else{
          i += Config.LUG_OPEN_SYMBOL.length;
          if(html[i] == "="){
            i++;
            doWrap = true;
          }
          inLug = true;
          if(stringBuf.trim() != "")
            buffer.add("buffer.add('${stringBuf}');\n");
          stringBuf = "";
        }
      }else if(i+Config.LUG_CLOSE_SYMBOL.length <= html.length && html.substring(i, i+Config.LUG_CLOSE_SYMBOL.length) == Config.LUG_CLOSE_SYMBOL && inLug){
        inLug = false;
        if(doWrap){
          if(lugBuf.trim() != "")
            buffer.add("buffer.add(escape("+ lugBuf + "));\n");
          doWrap = false;
        }
        else
          if(lugBuf.trim() != "")
            buffer.add(lugBuf+"\n");
        lugBuf = "";
        i += Config.LUG_CLOSE_SYMBOL.length;
      }else{

      if(inLug)
        lugBuf += html[i];
      else
        stringBuf += html[i];
      i++;
      }
    }
    if(stringBuf.trim() != "")
      buffer.add("buffer.add('${stringBuf}');\n");
    if(lugBuf.trim() != "")
      throw new Exception("Unclosed lug tag");

    return buffer;
  }

  //TODO make this async
  String writeCache(String fileData,String ogPath){
    Directory cacheDir = new Directory(_options["cachePath"]);
    if(cacheDir.existsSync() == false){
      print("Cache directory did not exist, creating it.");
      cacheDir.createSync();
    }
    File writeIt = new File("${cacheDir.path}${ogPath.split(".")[0]+'_cache'}.dart");
    if (writeIt.existsSync()) {
      if(_options["cache"] == false){
        print("Cache file exists, but will be overwritten");
      }else{
        print("Cache exists, using cache");
        return writeIt.path;
      }
    }
    else {
     print("Cache file is being created");
     writeIt.createSync(); //not currently implemented in trunk - manually create the file!
    }
    writeIt.openSync();
    writeIt.writeAsStringSync(fileData, mode: FileMode.WRITE, encoding: UTF8, flush: true);
    return writeIt.path;
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
                            "  List buffer = [];\n";

  static String WRITETAIL = "  sendPort.send(\"\${buffer.join('')}\");\n"+
                            "}\n\n" +
                            "String escape(html){\n" +
                            "return html is Map ? html[\"unsafe\"] : html.toString().replaceAll(r'&', '&amp;')\n" +
                            ".replaceAll(r'<', '&lt;')\n" +
                            ".replaceAll(r'>', '&gt;')\n" +
                            ".replaceAll(r\"'\", '&#39;')\n" +
                            ".replaceAll('\"', '&quot;');\n" +
                            "return html;\n"+
                             "}\n\n" +
                             "unsafe(str){\n" +
                             "return {\"unsafe\":str};"
                             "}";

}

