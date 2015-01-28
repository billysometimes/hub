part of lug;


  String escape(html){
  return html is Map ? html["unsafe"] : html.toString().replaceAll(r'&', '&amp;')
    .replaceAll(r'<', '&lt;')
    .replaceAll(r'>', '&gt;')
    .replaceAll(r"'", '&#39;')
    .replaceAll('"', '&quot;');
  }

  unsafe(str){
    return {"unsafe":str};
  }
