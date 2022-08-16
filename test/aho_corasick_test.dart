import 'package:aho_corasick_trie/aho_corasick_trie.dart';
import 'package:glados/glados.dart';

void main() {
  test("Abe's a babe", () {
    expect(
        'ab, b, e',
        AhoCorasick.from(['b', 'ab', 'e'])
            .findAll('abe')
            .map((m) => m.contents)
            .join(', '));
  });

  test('saved', () {
    expect(
        'c',
        AhoCorasick.from(['ca', 'c'])
            .findAll('c')
            .map((m) => m.contents)
            .join(', '));
  });

  Glados2<List<String>, List<String>>(
          any.list(any.nonEmptyLetters), any.nonEmptyList(any.letters))
      .test('oracle', (needles, haystacks) {
    var aho = AhoCorasick.from(needles);
    for (var h in haystacks) {
      expect(aho.findAll(h).toList(), findAll(needles, h));
    }
  });
}

List<Match> findAll(List<String> needles, String haystack) {
  needles = needles.toSet().toList();
  List<Match> allMatches = [];
  for (var needle in needles) {
    final matches =
        needle.allMatches(haystack).map((m) => Match(m.start, m.end, needle));
    allMatches.addAll(matches);
  }

  allMatches.sort((a, b) => a.end.compareTo(b.end));
  return allMatches;
}
