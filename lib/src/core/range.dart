class Range {
  Range(this.a, this.b) : assert(a <= b);

  double a;
  double b;

  bool contains(double y) => a <= y && y <= b;

  bool intersects(double x0, double x1) {
    return contains(x0) || contains(x1) || (x0 < a && b < x1);
  }

  Range shift(double offset) {
    a += offset;
    b += offset;
    return this;
  }

  Range inflate(double extent) {
    a -= extent;
    b += extent;
    return this;
  }
}
