extension BoolExtension on bool? {
  String? serialize() {
    switch (this) {
      case true:
        return 'true';
      case false:
        return 'false';
      case null:
        return null;
    }
    return null;
  }
}

extension BoolStringExtension on String? {
  bool? parseBool() {
    switch (this?.toLowerCase()) {
      case 'true':
        return true;
      case 'false':
        return false;
      default:
        return null;
    }
  }
}
