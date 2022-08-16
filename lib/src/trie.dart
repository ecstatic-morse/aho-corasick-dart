import 'dart:collection';

class Trie<T> {
  TrieNode<T>? root;

  Trie();

  bool get isEmpty => root == null;

  bool update(
    Iterable<int> key, {
    required T Function() newLeaf,
    required T Function() newInternal,
    void Function(T)? updateLeaf,
    void Function(T)? updateInternal,
  }) {
    var iter = key.iterator;
    if (iter.moveNext()) {
      root ??= TrieNode.root(newInternal());
      return root!.update(iter,
          newLeaf: newLeaf,
          newInternal: newInternal,
          updateLeaf: updateLeaf,
          updateInternal: updateInternal);
    }

    if (root == null) {
      root = TrieNode.root(newLeaf());
      return true;
    } else {
      updateLeaf?.call(root!.data);
      return false;
    }
  }

  Iterable<TrieNode<T>> get bfs => root?._bfs() ?? Iterable.empty();
  Iterable<TrieNode<T>> get dfs => root?._dfs() ?? Iterable.empty();
}

class TrieNode<T> {
  final int charCode;
  final int depth;
  final Map<int, TrieNode<T>> _children = {};
  final T data;
  final TrieNode<T>? parent;

  TrieNode(this.data, this.charCode, this.parent, this.depth);
  TrieNode.root(T data) : this(data, -1, null, 0);

  bool get isRoot => parent == null;

  TrieNode<T>? child(int charCode) => _children[charCode];

  bool update(
    Iterator<int> key, {
    required T Function() newLeaf,
    required T Function() newInternal,
    void Function(T)? updateLeaf,
    void Function(T)? updateInternal,
  }) {
    final charCode = key.current;
    final hasNext = key.moveNext();

    if (!hasNext) {
      bool isUpdated = false;
      _children.update(charCode, (x) {
        isUpdated = true;
        updateLeaf?.call(x.data);
        return x;
      }, ifAbsent: () => TrieNode(newLeaf(), charCode, this, depth + 1));

      return isUpdated;
    }

    final child = _children.update(charCode, (x) {
      updateInternal?.call(x.data);
      return x;
    }, ifAbsent: () => TrieNode(newInternal(), charCode, this, depth + 1));

    return child.update(key,
        newLeaf: newLeaf,
        updateLeaf: updateLeaf,
        newInternal: newInternal,
        updateInternal: updateInternal);
  }

  Iterable<TrieNode<T>> _bfs() sync* {
    final q = Queue<TrieNode<T>>();
    q.add(this);

    while (q.isNotEmpty) {
      final n = q.removeFirst();
      yield n;
      q.addAll(n._children.values);
    }
  }

  Iterable<TrieNode<T>> _dfs() sync* {
    final q = [this];
    while (q.isNotEmpty) {
      final n = q.removeLast();
      yield n;
      q.addAll(n._children.values);
    }
  }

  Iterable<int> _charCodesRev() sync* {
    var node = this;
    while (!node.isRoot) {
      yield node.charCode;
      node = parent!;
    }
  }

  List<int> get key => _charCodesRev().toList().reversed.toList();
}
