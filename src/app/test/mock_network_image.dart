import 'dart:io';

import 'mock_image_http.dart';

// wrapper for mocking network images
mockNetworkImages(tests) {
  HttpOverrides.runZoned(
    tests,
    createHttpClient: (securityContext) =>
        createMockImageHttpClient(securityContext),
  );
}
