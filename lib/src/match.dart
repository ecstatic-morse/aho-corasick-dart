part of 'aho_corasick.dart';

/// A match in the input string.
class Match {
  final int start;
  final int end;
  final String contents;

  Match(this.start, this.end, this.contents);

  Match._fromCodeUnits(List<int> units, [int start = 0, int? end])
      : this(start, end ?? units.length,
            String.fromCharCodes(units, start, end ?? units.length));

  @override
  String toString() => '"$contents" @ [$start:$end]';

  @override
  bool operator ==(Object other) =>
      other is Match &&
      other.runtimeType == runtimeType &&
      other.contents == contents &&
      other.start == start &&
      other.end == end;

  @override
  int get hashCode => Object.hash(runtimeType, contents, start, end);
}
