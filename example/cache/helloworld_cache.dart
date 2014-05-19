import 'dart:isolate';
main(List args,SendPort sendPort) {
  List buffer = [];
try {
var user = args[0]['user'];
buffer.add('<h1>Hello, ');
buffer.add(escape(user));
buffer.add('!</h1>');
  sendPort.send("${buffer.join('')}");
}catch(e){
  sendPort.send(e.toString());
}

}

String escape(html){
return html is Map ? html["unsafe"] : html.toString().replaceAll(r'&', '&amp;')
.replaceAll(r'<', '&lt;')
.replaceAll(r'>', '&gt;')
.replaceAll(r"'", '&#39;')
.replaceAll('"', '&quot;');
}

unsafe(str){
return {"unsafe":str};}