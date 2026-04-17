import 'package:flutter/foundation.dart';
import '../data/checkin_repository.dart';
import '../services/auth_service.dart';


class HistoryViewModel extends ChangeNotifier {
  List<Map<String, dynamic>> entries = [];
  bool isLoading = false;
  String? errorMessage;

  final AuthService _authService;
  final CheckInRepository _repository;

  HistoryViewModel({
    required AuthService authService,
    required CheckInRepository repository,
  })  : _authService = authService,
        _repository = repository;

  Future<void> load({bool forceServer = false}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final uid = _authService.uid;
      debugPrint('[HistoryVM] load uid=$uid forceServer=$forceServer');
      entries = await _repository.getAll(uid, forceServer: forceServer);
      debugPrint('[HistoryVM] load DONE entries=${entries.length}');
    } catch (e) {
      debugPrint('[HistoryVM] load ERROR: $e');
      errorMessage = 'Failed to load history.';
    }

    isLoading = false;
    notifyListeners();
  }
}
