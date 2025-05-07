class BaseState {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const BaseState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  // This will be overridden by subclasses
  BaseState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  }) {
    throw UnimplementedError('copyWith() has not been implemented');
  }
}