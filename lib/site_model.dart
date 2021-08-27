import 'package:flutter/cupertino.dart';

class SiteModel with ChangeNotifier {
  String _urlImage = '';
  String _urlImageEvent = '';

  String get urlImage => this._urlImage;
  set urlImage(String value) {
    this._urlImage = value;
    notifyListeners();
  }

  String get urlImageEvent => this._urlImageEvent;
  set urlImageEvent(String value) {
    this._urlImageEvent = value;
    notifyListeners();
  }
}
