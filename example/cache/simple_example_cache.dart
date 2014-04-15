import 'dart:isolate';
main(List args,SendPort sendPort) {
  List buffer = [];
var users = args[0]['users'];
var thatNum = args[0]['thatNum'];
var treasure = args[0]['treasure'];
buffer.add('<html>\n  ');
var t = 100;
buffer.add('\n  <ul>\n    ');
users.forEach((user){
buffer.add('\n      <li>');
buffer.add(escape(user["name"]));
buffer.add('</li>\n    ');
});
buffer.add('\n  </ul>\n  ');
buffer.add(escape(treasure["map"]));
buffer.add('\n  ');
if(2 == 2){
buffer.add('\n    ');
buffer.add(escape(thatNum + t));
buffer.add('\n  ');
}
buffer.add('\n  ');
buffer.add(escape("<h1>NOT YELLING YELLING</h1>"));
buffer.add('\n  ');
buffer.add(escape(unsafe("<h1>YELLING</h1>")));
buffer.add('\n  ');
buffer.add('<p>included from another file</p>');
buffer.add('\n</html>\n');
  sendPort.send("${buffer.join('')}");
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