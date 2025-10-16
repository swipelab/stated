import 'dart:developer' as dev;

/// We might have different variants for a slug, that can be localized - canonized
/// We expect the [UriCanonicalConverter] to return the local domain form of the slug
/// returns null when no match
typedef UriCanonicalConverter = String? Function(String slug);

/// Iterates configured [UriMap] patterns attempting to build an [Out] result.
///
/// {@tool snippet}
/// ```dart
/// final parser = UriParser<String, void>(
///   routes: [
///     UriMap('/users/{id:#}', (m) => 'User ' + m.pathParameters['id']!),
///     UriMap.many(['/posts/{slug:w}', '/blog/{slug:w}'],
///         (m) => 'Post ' + m.pathParameters['slug']!),
///   ],
/// );
/// final result = parser.parse(Uri.parse('/users/42'), null); // User 42
/// ```
/// {@end-tool}
class UriParser<Out, State> {
  UriParser({
    this.routes = const [],
    this.canonical = const {},
  });

  final List<UriMap> routes;
  final Map<String, UriCanonicalConverter> canonical;

  /// Returns parsed domain object or `null` if no route matches.
  Out? parse(Uri url, State state) {
    for (final route in routes) {
      for (final template in route.matchers) {
        final match = template.match(url.path);
        if (match != null) {
          var isMatch = true;
          if (match.keys.any(canonical.containsKey)) {
            for (final entry in match.entries.toList()) {
              final canonicalValue = canonical[entry.key]?.call(entry.value);
              // not part of the canonical set
              if (canonicalValue == null) {
                isMatch = false;
                break;
              }
              match[entry.key] = canonicalValue;
            }
            if (!isMatch) continue;
          }
          try {
            final result = route.builder(UriMatch(url, match, state));
            if (result != null) {
              return result;
            }
          } catch (e, s) {
            // exceptions are treated as non-matches
            dev.log('''
UriParser.parse failed to build:
  url: $url  
  pattern: ${template.pattern}
  error: $e
  stack: $s
''');
          }
        }
      }
    }
    return null;
  }
}

typedef UriMapBuilder<Out, State> = Out? Function(UriMatch<State> match);

/// Matched values & context provided to a [UriMapBuilder].
class UriMatch<State> {
  UriMatch(this.uri,
      this.pathParameters,
      this.state,);

  final Uri uri;
  final Map<String, String> pathParameters;
  final State state;

  Map<String, String> get queryParameters => uri.queryParameters;
}

/// Associates one (or many) path patterns with a builder.
class UriMap<Out, State> {
  UriMap(String pattern,
      this.builder, {
        bool matchEnd = true,
      }) : matchers = [PathMatcher(pattern, matchEnd: matchEnd)];

  UriMap.many(List<String> patterns,
      this.builder, {
        bool matchEnd = true,
      }) : matchers =
  patterns.map((e) => PathMatcher(e, matchEnd: matchEnd)).toList();

  final List<PathMatcher> matchers;
  final UriMapBuilder builder;
}

/// Starts with `/path/` and has a field name word
/// `/path/{name}`
/// Starts with `/path/` followed by a number
/// `/path/{number:#}`
/// Field regex
/// # - number
/// w - word
/// * - anything
/// Compiles a path pattern with named fields into a matching regex.
class PathMatcher {
  PathMatcher(this.pattern, {
    // match end [$]
    bool matchEnd = true,
  }) {
    var index = 0;
    final regex = StringBuffer();
    final fieldRegex = RegExp(r'{(?<field>([*]|(\w+)?(:[.*+#]+)?)+)}');
    final fieldMatches = fieldRegex.allMatches(pattern);

    for (final fieldMatch in fieldMatches) {
      if (index < fieldMatch.start) {
        regex.write(pattern.substring(index, fieldMatch.start));
      }

      final group = fieldMatch.namedGroup('field');
      if (group == null) {
        throw ArgumentError('Invalid pattern: $pattern', 'pattern');
      }
      final fieldRegexStart = group.indexOf(':');
      var fieldName = group;
      var fieldRegex = '';
      if (fieldRegexStart != -1) {
        fieldName = group.substring(0, fieldRegexStart);
        if (fieldRegexStart < group.length) {
          fieldRegex = group.substring(fieldRegexStart + 1);
        }
      }

      String reg;
      switch (fieldRegex) {
        case '':
          reg = '([-_]|\\w)+';
        case '*':
          reg = '.+';
        case '#':
          reg = '\\d+';
        case 'w':
          reg = '\\w+';
        default:
          reg = fieldRegex;
      }

      if (fieldName.isEmpty) {
        regex.write(reg);
      } else if (fieldName == '*') {
        regex.write('.*');
      } else {
        fields.add(fieldName);
        regex.write('(?<$fieldName>$reg)');
      }
      index = fieldMatch.end;
    }

    if (index < pattern.length) {
      regex.write(pattern.substring(index));
    }
    if (matchEnd) regex.write('\$');
    pathTemplate = RegExp(regex.toString());
  }

  /// Returns null if [pathTemplate] doesn't match the [path]
  Map<String, String>? match(String path) {
    final match = pathTemplate.firstMatch(path);
    if (match == null || path != pathTemplate.stringMatch(path)) {
      return null;
    }
    final map = fields.fold(
      <String, String>{},
          (p, e) => p..[e] = match.namedGroup(e)!,
    );
    return fields.every(map.containsKey) ? map : null;
  }

  late final RegExp pathTemplate;
  final String pattern;
  final Set<String> fields = {};

  @override
  String toString() {
    return '$pathTemplate => (${fields.join(',')})';
  }
}
