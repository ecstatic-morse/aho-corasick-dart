The second-worst Aho-Corasick implementation on [pub.dev](pub.dev).

## Usage

```dart
AhoCorasick.from(['b', 'ab', 'e'])
        .findAll('abe')
        .map((m) => m.contents)
        .toList());
// [b, ab, e]
```

