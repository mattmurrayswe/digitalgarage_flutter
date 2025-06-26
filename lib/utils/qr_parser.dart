import 'dart:convert';

dynamic tryParseJson(String data) {
  try {
    return json.decode(data);
  } catch (_) {
    return null;
  }
}
