class ErrorMessage {
  bool? _isError;
  String? _errorMessage;

  ErrorMessage(this._isError, this._errorMessage);

  String get errorMessage => _errorMessage!;
  bool get isError => _isError!;
}
