List<int> range(int start) {
  return List<int>.generate(start, (index) => index);
}

List<String> getSearchIndex(String text) {
  List<String> split = text.split(" ");
  List<String> searchIndex = [];

  for (String word in split) {
    for (int size in range(word.length)) {
      for (int index in range(word.length - size)) {
        searchIndex.add(
          word.substring(index, index + size + 1).toLowerCase(),
        );
      }
    }
  }

  return searchIndex.toSet().toList();
}
