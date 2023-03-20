extension StringReplacer on String {
  String format(Map<String, String> replace) {
    var result = this;
    for (final entry in replace.entries) {
      result = result.replaceAll('{${entry.key}}', entry.value);
    }

    return result;
  }
}