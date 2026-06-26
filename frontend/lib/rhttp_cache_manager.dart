import 'dart:io';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_cache_manager/src/web/mime_converter.dart';
import 'package:frontend/database_service.dart';
import 'package:rhttp/rhttp.dart' as rhttp;

/// A custom [FileService] that fetches files (images) using the shared [rhttp.RhttpClient].
class RhttpFileService extends FileService {
  @override
  Future<FileServiceResponse> get(String url, {Map<String, String>? headers}) async {
    final response = await DatabaseService.client.getStream(
      url,
      headers: headers != null ? rhttp.HttpHeaders.rawMap(headers) : null,
    );
    return RhttpFileServiceResponse(response);
  }
}

/// A [FileServiceResponse] wrapper around [rhttp.HttpStreamResponse].
class RhttpFileServiceResponse implements FileServiceResponse {
  final rhttp.HttpStreamResponse _response;
  final DateTime _receivedTime = DateTime.now();

  RhttpFileServiceResponse(this._response);

  @override
  int get statusCode => _response.statusCode;

  @override
  Stream<List<int>> get content => _response.body;

  @override
  int? get contentLength {
    final lengthHeader = _getHeader('content-length');
    if (lengthHeader != null) {
      return int.tryParse(lengthHeader);
    }
    return null;
  }

  @override
  DateTime get validTill {
    final cacheControl = _getHeader('cache-control');
    final maxAge = _parseMaxAge(cacheControl);
    if (maxAge != null) {
      return _receivedTime.add(maxAge);
    }
    final expires = _getHeader('expires');
    if (expires != null) {
      try {
        return HttpDate.parse(expires);
      } catch (_) {}
    }
    return _receivedTime.add(const Duration(days: 7));
  }

  Duration? _parseMaxAge(String? cacheControl) {
    if (cacheControl == null) return null;
    final parts = cacheControl.split(RegExp(r',\s*'));
    for (final part in parts) {
      if (part.startsWith('max-age=')) {
        final value = int.tryParse(part.substring('max-age='.length));
        if (value != null) {
          return Duration(seconds: value);
        }
      }
    }
    return null;
  }

  @override
  String? get eTag => _getHeader('etag');

  @override
  String get fileExtension {
    final contentTypeString = _getHeader('content-type');
    if (contentTypeString != null) {
      try {
        final contentType = ContentType.parse(contentTypeString);
        return contentType.fileExtension;
      } catch (_) {}
    }
    return '.jpg';
  }

  String? _getHeader(String name) {
    final lowercaseName = name.toLowerCase();
    for (final entry in _response.headerMap.entries) {
      if (entry.key.toLowerCase() == lowercaseName) {
        return entry.value;
      }
    }
    return null;
  }
}

/// A global singleton for [CacheManager] configured to use the high-performance [RhttpFileService].
class RhttpCacheManager {
  static const key = 'rhttpCacheKey';

  static final CacheManager instance = CacheManager(
    Config(
      key,
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 200,
      fileService: RhttpFileService(),
    ),
  );
}
