main(){

  print(escape("<&\""));
}

escape(html){html = html.replaceAll(r'&', '&amp;').replaceAll(r'<', '&lt;').replaceAll(r'>', '&gt;').replaceAll(new RegExp("'"), '&#39;').replaceAll(new RegExp('"'), "&quot;");return html;}