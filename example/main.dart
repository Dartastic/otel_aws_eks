// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_aws_eks/otel_aws_eks.dart';

/// Traces Aws Eks calls with OpenTelemetry.
///
/// `otel_aws_eks` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Aws Eks call in
/// [tracedAwsEKS]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'aws-eks-example');

  // Traces a Aws Eks call.
  final awsEKSId = await tracedAwsEKS<String>(
    operation: 'create',
    invoke: () async {
      // Make the Aws Eks call here, then report what it returned.
      const id = 'aws_eks_8f3a2c';
      return const AwsEKSCallResult(
          value: id,
          result: AwsEKSResult(
              clusterName: 'example',
              clusterArn: 'example',
              version: '1',
              nodeGroup: 'example',
              fargateProfile: 'example',
              podCount: 3,
              region: 'us-east-1',
              statusCode: 201,
              errorCode: 'example',
              errorMessage: 'example'));
    },
  );
  OTelLog.info('tracedAwsEKS create returned $awsEKSId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutAwsEKSInstrumentationAsync.
  await runWithoutAwsEKSInstrumentationAsync(
    () => tracedAwsEKS<String>(
      operation: 'create',
      invoke: () async {
        const id = 'aws_eks_8f3a2c';
        return const AwsEKSCallResult(
            value: id,
            result: AwsEKSResult(
                clusterName: 'example',
                clusterArn: 'example',
                version: '1',
                nodeGroup: 'example',
                fargateProfile: 'example',
                podCount: 3,
                region: 'us-east-1',
                statusCode: 201,
                errorCode: 'example',
                errorMessage: 'example'));
      },
    ),
  );

  await OTel.shutdown();
}
