/// Optional mixin for services needing asynchronous post-construction setup.
mixin AsyncInit {
  /// Performs initialisation; awaited automatically for lazy registrations.
  Future<void> init();
}
