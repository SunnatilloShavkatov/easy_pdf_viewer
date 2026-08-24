// Async file access is intentional here because cache reads, writes, and cleanup
// are part of the network download flow.
// ignore_for_file: avoid_slow_async_io

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

enum FileSource { cache, online }

abstract class FileResponse {
  const new();
}

class DownloadProgress extends FileResponse {
  const new(this.url, this.downloaded, this.totalSize);

  final String url;
  final int downloaded;
  final int? totalSize;

  double get progress {
    if (totalSize == null || totalSize == 0) {
      return 0;
    }

    return downloaded / totalSize!;
  }
}

class FileInfo extends FileResponse {
  const new(this.file, this.source, this.validTill, this.originalUrl);

  final File file;
  final FileSource source;
  final DateTime validTill;
  final String originalUrl;
}

abstract class CacheManager {
  Future<void> emptyCache();

  Stream<FileResponse> getFileStream(
    String url, {
    String? key,
    Map<String, String>? headers,
    bool withProgress = false,
  });

  Future<File> getSingleFile(String url, {String? key, Map<String, String>? headers});

  Future<void> removeFile(String key);
}

class DefaultCacheManager implements CacheManager {
  factory() => _instance;

  new _();

  static final DefaultCacheManager _instance = DefaultCacheManager._();

  static const Duration _cacheLifetime = Duration(days: 3650);
  static const String _cacheFolderName = 'easy_pdf_viewer_network_cache';

  @override
  Future<void> emptyCache() async {
    final Directory directory = await _cacheDirectory();
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  }

  @override
  Stream<FileResponse> getFileStream(
    String url, {
    String? key,
    Map<String, String>? headers,
    bool withProgress = false,
  }) async* {
    final _CacheEntry? cachedEntry = await _getCachedEntry(url, key: key);
    if (cachedEntry != null) {
      yield FileInfo(cachedEntry.file, FileSource.cache, DateTime.now().add(_cacheLifetime), url);
      return;
    }

    yield* _download(url, key: key, headers: headers, withProgress: withProgress);
  }

  @override
  Future<File> getSingleFile(String url, {String? key, Map<String, String>? headers}) async {
    final _CacheEntry? cachedEntry = await _getCachedEntry(url, key: key);
    if (cachedEntry != null) {
      return cachedEntry.file;
    }

    await for (final FileResponse response in getFileStream(url, key: key, headers: headers)) {
      if (response is FileInfo) {
        return response.file;
      }
    }

    throw StateError('Failed to download file for $url');
  }

  @override
  Future<void> removeFile(String key) async {
    final Directory directory = await _entryDirectory(key);
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  }

  Future<Directory> _cacheDirectory() async {
    final Directory root = await getTemporaryDirectory();
    final Directory directory = Directory('${root.path}${Platform.pathSeparator}$_cacheFolderName');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  Future<Directory> _entryDirectory(String cacheKey) async {
    final Directory root = await _cacheDirectory();
    return Directory('${root.path}${Platform.pathSeparator}${_hash(cacheKey)}');
  }

  Future<_CacheEntry?> _getCachedEntry(String url, {String? key}) async {
    final Directory directory = await _entryDirectory(key ?? url);
    if (!await directory.exists()) {
      return null;
    }

    final List<FileSystemEntity> entities = await directory.list().toList();
    final Iterable<File> files = entities.whereType<File>().where((File file) => !file.path.endsWith('.part'));
    if (files.isEmpty) {
      return null;
    }

    final File file = files.first;
    if (!await file.exists() || await file.length() == 0) {
      return null;
    }

    return _CacheEntry(file);
  }

  Stream<FileResponse> _download(
    String url, {
    String? key,
    Map<String, String>? headers,
    required bool withProgress,
  }) async* {
    final HttpClient client = HttpClient();
    IOSink? sink;

    try {
      final HttpClientRequest request = await client.getUrl(Uri.parse(url));
      headers?.forEach(request.headers.add);

      final HttpClientResponse response = await request.close();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException('Failed to download file. HTTP ${response.statusCode}', uri: Uri.parse(url));
      }

      final Directory entryDirectory = await _entryDirectory(key ?? url);
      if (await entryDirectory.exists()) {
        await entryDirectory.delete(recursive: true);
      }
      await entryDirectory.create(recursive: true);

      final File tempFile = File('${entryDirectory.path}${Platform.pathSeparator}download.part');
      sink = tempFile.openWrite();

      int downloaded = 0;
      final int? totalSize = response.contentLength >= 0 ? response.contentLength : null;

      await for (final List<int> chunk in response) {
        sink.add(chunk);
        downloaded += chunk.length;

        if (withProgress) {
          yield DownloadProgress(url, downloaded, totalSize);
        }
      }

      await sink.close();
      sink = null;

      final String extension = _resolveExtension(url, response);
      final File finalFile = File('${entryDirectory.path}${Platform.pathSeparator}document$extension');
      if (await finalFile.exists()) {
        await finalFile.delete();
      }
      await tempFile.rename(finalFile.path);

      yield FileInfo(finalFile, FileSource.online, DateTime.now().add(_cacheLifetime), url);
    } finally {
      await sink?.close();
      client.close(force: true);
    }
  }

  String _resolveExtension(String url, HttpClientResponse response) {
    final String path = Uri.parse(url).path;
    final int dotIndex = path.lastIndexOf('.');
    if (dotIndex >= 0 && dotIndex > path.lastIndexOf('/')) {
      return path.substring(dotIndex);
    }

    final ContentType? contentType = response.headers.contentType;
    if (contentType?.mimeType == 'application/pdf') {
      return '.pdf';
    }

    return '.bin';
  }

  String _hash(String value) {
    int hash = 0x811c9dc5;
    for (final int byte in utf8.encode(value)) {
      hash ^= byte;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return hash.toRadixString(16).padLeft(8, '0');
  }
}

class _CacheEntry {
  const new(this.file);

  final File file;
}
