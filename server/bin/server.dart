import 'dart:convert';
import 'dart:io';

import 'package:namer/namer.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_static/shelf_static.dart';

// Configure routes.
final _router =
    Router()
      ..get('/', _rootHandler)
      ..get('/api/name', _nameHandler);

Response _rootHandler(Request req) {
  // todo: static route to flutter web
  return Response.ok('Hello, World!\n');
}

Response _nameHandler(Request req) {
  return Response.ok(json.encode({'name': animal(adjectives: 0, verbs: 1)}));
}

void main(List<String> args) async {
  // Use any available host or container IP (usually `0.0.0.0`).
  final ip = InternetAddress.anyIPv4;

  final statichandler = createStaticHandler(
    '../static',
    defaultDocument: 'index.html',
  );

  final cascadeHandler =
      Cascade() //
          .add(statichandler)
          .add(_router.call)
          .handler;

  // Configure a pipeline that logs requests.
  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addHandler(cascadeHandler);

  // For running in containers, we respect the PORT environment variable.
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await serve(handler, ip, port);
  print('Server listening on port ${server.port}');
}
