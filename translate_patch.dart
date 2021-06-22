import 'dart:convert';
import 'dart:io';



var output = File('C:/Users/User/AndroidStudioProjects/svisitom_frontend/translate_output.dart');
var langMap = File('C:/Users/User/AndroidStudioProjects/svisitom_frontend/translate_langmap.dart');
var rootDir = Directory('C:/Users/User/AndroidStudioProjects/svisitom_frontend/lib');


RegExp ruRegExp = new RegExp(
  "['\"]{1}([^'\"]*[а-я]+[^'\"]*)+['\"]{1}",
  caseSensitive: false,
  multiLine: false,
);


void main() {
  if(true) generateLangMap();
  else if(false) generateFirst();
  else replaceCode();
}

void generateLangMap() {
  Map json = jsonDecode(output.readAsStringSync());
  var result = {};
  for(var item in json.values.toList()..sort((a, b) => a['name'].compareTo(b['name']))) {
    result[item['name']] = {};
  }
  for(var item in json.values) {
    String a = (item['name'] as String).replaceAll('_', ' ');
    a = a[0].toUpperCase() + a.substring(1);
    result[item['name']] = '';
  }
  JsonEncoder encoder = new JsonEncoder.withIndent('  ');
  langMap.writeAsStringSync(encoder.convert(result));
}

void replaceCode() {

  Map json = jsonDecode(output.readAsStringSync());

  List<File> files = rootDir.listSync(recursive: true, followLinks: false).whereType<File>().toList();

  for(var file in files) {
    var text = file.readAsStringSync();
    String newText;
    var matches = ruRegExp.allMatches(text);
    if(matches.length > 0) {
      for(var m in matches) {
        var stringMatch = m.group(0);
        if(json.containsKey(stringMatch)) {
          if(newText == null) newText = text;
          var replaceString = "'${json[stringMatch]['name']}'.${json[stringMatch]['method']}";
          newText = newText.replaceFirst(stringMatch, replaceString);
        }
      }
    }
    if(newText != null) {
      if(newText.indexOf("import 'package:get/get.dart';") == -1) {
        newText = "import 'package:get/get.dart';\n" + newText;
      }
      print('write ' + file.path);
      file.writeAsStringSync(newText);
    }
  }
}

void generateFirst() {
  List<File> files = rootDir.listSync(recursive: true, followLinks: false).whereType<File>().toList();

  Map json = jsonDecode(output.readAsStringSync());


  var count = 0;
  var result = {};
  result = json;
  for(var file in files) {
    var text = file.readAsStringSync();
    var matches = ruRegExp.allMatches(text);
    if(matches.length > 0) {
      for(var m in matches) {
        var stringMatch = m.group(0);
        if(!result.containsKey(stringMatch)) {
          count++;
          result[stringMatch] = {
            'name': '', //key in lang map
            'method': 'tr', //replace in code,
            'replace_method' : null,
            'value': stringMatch.substring(1, stringMatch.length-1),
            'new': ''
          };
        }
      }
    }
  }
  JsonEncoder encoder = new JsonEncoder.withIndent('  ');
  output.writeAsStringSync(encoder.convert(result));
  output.create();
  print(count);
}
