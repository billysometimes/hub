part of hub;

class _Hub{

  var HUB_OPEN_SYMBOL = "<%";
  var HUB_CLOSE_SYMBOL = "%>";
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
    String hubBuf = "";
    bool inHub = false;
    bool doWrap = false;
    _HubToken hubToken;
    var i=0;
    html = html.replaceAll(new RegExp(r'\n+'), '\\n');
    while(i<html.length){
      if(i+HUB_OPEN_SYMBOL.length <= html.length && html.substring(i, i+HUB_OPEN_SYMBOL.length) == HUB_OPEN_SYMBOL){
        if(inHub == true){
          throw new Exception("Cannot open hub tag inside of hub block");
        } else{
          i += HUB_OPEN_SYMBOL.length;
          if(html[i] == "="){
            i++;
            doWrap = true;
          }
          inHub = true;
          if(stringBuf.trim() != "")
            buffer.add("buffer.add('${stringBuf}');\n");
          stringBuf = "";
          hubToken = new _HubToken();
          //buffer.add(hubToken._currentToken);
        }
      }else if(i+HUB_CLOSE_SYMBOL.length <= html.length && html.substring(i, i+HUB_CLOSE_SYMBOL.length) == HUB_CLOSE_SYMBOL && inHub){
        inHub = false;
        hubToken.add(hubBuf);
        if(doWrap){
          if(hubBuf.trim() != "")
            buffer.add("buffer.add("+ hubBuf + ");\n");
          doWrap = false;
        }
        else
          if(hubBuf.trim() != "")
            buffer.add(hubBuf+"\n");
        hubBuf = "";
        i += HUB_CLOSE_SYMBOL.length;
      }else{

      if(inHub)
        hubBuf += html[i];
      else
        stringBuf += html[i];
      i++;
      }
    }
    if(stringBuf.trim() != "")
      buffer.add("buffer.add('${stringBuf}');\n");
    if(hubBuf.trim() != "")
      throw new Exception("Unclosed hub tag");

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
                            "}";


}







class _HubToken {
  static int _tokenCount = 0;
  static Map tokenValue = {};
  int _currentToken;

  _HubToken(){
    _currentToken = _tokenCount;
    _tokenCount++;
  }

  add(buff){
    tokenValue[_currentToken] = buff;
  }

}


