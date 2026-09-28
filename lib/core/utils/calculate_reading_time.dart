int calculateReadingTime(String content) {
  final wordCount = content.split(RegExp(r'\s+')).length;
  // speed = distance / time; human avarage reading time = 225 words/min
  final readingTime = wordCount / 200;
  return readingTime.ceil();
}
