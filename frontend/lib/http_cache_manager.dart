import 'dart:io';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:frontend/database_service.dart';
import 'package:http/http.dart' as http;

class HttpFileService extends FileService {
  @override
  Future<FileServiceResponse> get(
    String url, {
    Map<String, String>? headers,
  }) async {
    final request = http.Request('GET', Uri.parse(url));
    if (headers != null) {
      request.headers.addAll(headers);
    }
    final streamedResponse = await DatabaseService.client.send(request);
    return HttpFileServiceResponse(streamedResponse);
  }
}

class HttpFileServiceResponse implements FileServiceResponse {
  final http.StreamedResponse _response;
  final DateTime _receivedTime = DateTime.now();

  HttpFileServiceResponse(this._response);

  @override
  int get statusCode => _response.statusCode;

  @override
  Stream<List<int>> get content => _response.stream;

  @override
  int? get contentLength => _response.contentLength;

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
        final subType = contentType.subType.toLowerCase();
        if (subType == 'jpeg') return '.jpg';
        return '.$subType';
      } catch (_) {}
    }
    return '.jpg';
  }

  String? _getHeader(String name) {
    final lowercaseName = name.toLowerCase();
    for (final entry in _response.headers.entries) {
      if (entry.key.toLowerCase() == lowercaseName) {
        return entry.value;
      }
    }
    return null;
  }
}

/// A global singleton for [CacheManager] configured to use the high-performance [HttpFileService].
class HttpCacheManager {
  static const key = 'httpCacheKey';

  static final CacheManager instance = CacheManager(
    Config(
      key,
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 200,
      fileService: HttpFileService(),
    ),
  );
}
