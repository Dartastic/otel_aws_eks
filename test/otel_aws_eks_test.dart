// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:otel_aws_eks/otel_aws_eks.dart';
import 'package:test/test.dart';

void main() {
  group('otel_aws_eks', () {
    test('suppression toggles in zone', () async {
      expect(awsEKSInstrumentationSuppressed(), isFalse);
      await runWithoutAwsEKSInstrumentationAsync(() async {
        expect(awsEKSInstrumentationSuppressed(), isTrue);
      });
      expect(awsEKSInstrumentationSuppressed(), isFalse);
    });

    test('AwsEKSResult fields default null', () {
      const r = AwsEKSResult();
      expect(r.statusCode, isNull);
    });
  });
}
