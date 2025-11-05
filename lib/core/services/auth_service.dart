import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  Dio? _dio;
  PersistCookieJar? _cookieJar;
  bool _isInitialized = false;

  Future<Dio> getDio() async {
    if (_dio == null || !_isInitialized) {
      _dio = Dio();
      
      if (!kIsWeb) {
        // For Android/iOS - use PersistCookieJar to save cookies to disk
        final Directory appDocDir = await getApplicationDocumentsDirectory();
        final String appDocPath = appDocDir.path;
        _cookieJar = PersistCookieJar(
          storage: FileStorage(appDocPath + "/.cookies/"),
        );
        _dio!.interceptors.add(CookieManager(_cookieJar!));
      } else {
        // For web - enable credentials
        _dio!.options.extra['withCredentials'] = true;
      }
      
      _isInitialized = true;
    }
    
    return _dio!;
  }
  
  // Synchronous version for backward compatibility (initializes in background)
  Dio getDioSync() {
    if (_dio == null) {
      _dio = Dio();
      if (kIsWeb) {
        _dio!.options.extra['withCredentials'] = true;
      }
      // Initialize cookies asynchronously
      _initializeCookies();
    }
    return _dio!;
  }
  
  Future<void> _initializeCookies() async {
    if (!_isInitialized && !kIsWeb) {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String appDocPath = appDocDir.path;
      _cookieJar = PersistCookieJar(
        storage: FileStorage(appDocPath + "/.cookies/"),
      );
      _dio!.interceptors.add(CookieManager(_cookieJar!));
      _isInitialized = true;
    }
  }

  /// Check if patient session is valid by calling /me endpoint
  Future<Map<String, dynamic>?> checkPatientSession() async {
    try {
      final dio = await getDio();
      final response = await dio.get(
        "http://10.0.2.2:8080/api/patient/auth/me",
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      // Session invalid or network error
      return null;
    }
  }

  /// Check if clinic session is valid by calling clinic /me endpoint
  Future<Map<String, dynamic>?> checkClinicSession() async {
    try {
      final dio = await getDio();
      final response = await dio.get(
        "http://10.0.2.2:8080/api/clinic/auth/me",
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      // Session invalid or network error
      return null;
    }
  }

  /// Clear session (for logout)
  Future<void> clearSession() async {
    if (_cookieJar != null) {
      await _cookieJar!.deleteAll();
    }
    _dio = null;
    _cookieJar = null;
  }
}
