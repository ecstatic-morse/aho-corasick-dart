The [second-worst][issue] Aho-Corasick implementation on [pub.dev](pub.dev).

[issue]: https://github.com/MaximilianKlein/aho_corasick/issues/1

## Usage

```dart
AhoCorasick.from(['b', 'ab', 'e'])
        .findAll('abe')
        .map((m) => m.contents)
        .toList());
// [b, ab, e]
```

