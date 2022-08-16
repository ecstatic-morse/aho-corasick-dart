import 'trie.dart';

part 'match.dart';

typedef _AhoTrie = Trie<_AhoCorasickNodeData>;
typedef _AhoTrieNode = TrieNode<_AhoCorasickNodeData>;

/// Holds the state machine for Aho-Corasick string matching.
class AhoCorasick {
  final _AhoTrie _trie;

  /// Initializes a state machine with the given keys.
  ///
  /// The empty string is not a valid key.
  AhoCorasick.from(Iterable<String> keys) : _trie = _buildAhoTrie(keys);

  /// Iterates over all occurrences in `input` of any key in the dictionary.
  Iterable<Match> findAll(String input) sync* {
    if (_trie.isEmpty) {
      return;
    }

    var curr = _trie.root!;

    outer:
    for (var i = 0; i < input.codeUnits.length; i++) {
      final c = input.codeUnitAt(i);

      final candidates = [curr].followedBy(curr.data.nearestSuffixes);
      for (final cand in candidates) {
        var child = cand.child(c);
        if (child == null) {
          continue;
        }

        curr = child;
        if (curr.data.inDict) {
          yield Match._fromCodeUnits(
              input.codeUnits, i + 1 - curr.depth, i + 1);
        }

        for (final m in curr.data.nearestDictSuffixes) {
          yield Match._fromCodeUnits(input.codeUnits, i + 1 - m.depth, i + 1);
        }

        continue outer;
      }

      curr = _trie.root!;
    }
  }
}

class _AhoCorasickNodeData {
  bool inDict;
  _AhoTrieNode? nearestSuffix;
  _AhoTrieNode? nearestDictSuffix;

  _AhoCorasickNodeData(this.inDict);

  Iterable<_AhoTrieNode> get nearestSuffixes sync* {
    var curr = nearestSuffix;
    while (curr != null) {
      yield curr;
      curr = curr.data.nearestSuffix;
    }
  }

  Iterable<_AhoTrieNode> get nearestDictSuffixes sync* {
    var curr = nearestDictSuffix;
    while (curr != null) {
      yield curr;
      curr = curr.data.nearestDictSuffix;
    }
  }
}

_AhoTrie _buildAhoTrie(Iterable<String> keys) {
  var trie = _AhoTrie();

  for (final key in keys) {
    if (key.isEmpty) {
      throw Exception('Empty string not valid as Aho-Corasick matcher');
    }

    trie.update(
      key.codeUnits,
      newLeaf: () => _AhoCorasickNodeData(true),
      newInternal: () => _AhoCorasickNodeData(false),
      updateLeaf: (data) => data.inDict = true,
    );
  }

  for (final node in trie.bfs.skip(1)) {
    final data = node.data;
    final parent = node.parent!;

    if (parent.isRoot) {
      data.nearestSuffix = node.parent!;
      continue;
    }

    var near = parent.data.nearestSuffix!;
    while (true) {
      final child = near.child(node.charCode);
      if (child != null) {
        near = child;
        break;
      }

      if (near.isRoot) {
        break;
      }

      near = near.data.nearestSuffix!;
    }

    data.nearestSuffix = near;
  }

  // `nearestDictSuffix` is computed by traversing `nearestSuffix` until we find
  // one that is

  // `null` is a valid value for `nearestDictSuffix`, so use the current node as
  // a dummy value.
  for (final node in trie.dfs.skip(1)) {
    node.data.nearestDictSuffix = node;
  }

  assert(trie.root?.data.nearestDictSuffix == null);

  // For each node, traverse `nearestSuffix` links until we find one that's in
  // the dict.
  List<_AhoTrieNode> toUpdate = [];
  for (final node in trie.dfs.skip(1)) {
    toUpdate.add(node);
    var curr = node.data.nearestSuffix!;

    _AhoTrieNode? nearestDictSuffix;
    while (true) {
      if (curr.data.inDict) {
        nearestDictSuffix = curr;
        break;
      }

      if (curr.isRoot) {
        break;
      }

      if (curr.data.nearestDictSuffix != curr) {
        nearestDictSuffix = curr.data.nearestDictSuffix;
        break;
      }

      curr = curr.data.nearestSuffix!;
    }

    for (final n in toUpdate) {
      n.data.nearestDictSuffix = nearestDictSuffix;
    }

    toUpdate.clear();
  }

  return trie;
}
