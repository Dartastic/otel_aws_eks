// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_aws_eks_suppression.dart';

class AwsEKSResult {
  const AwsEKSResult({
    this.clusterName,
    this.clusterArn,
    this.version,
    this.nodeGroup,
    this.fargateProfile,
    this.podCount,
    this.region,
    this.statusCode,
    this.errorCode,
    this.errorMessage,
  });

  final String? clusterName;
  final String? clusterArn;
  final String? version;
  final String? nodeGroup;
  final String? fargateProfile;
  final int? podCount;
  final String? region;
  final int? statusCode;
  final String? errorCode;
  final String? errorMessage;
}

class AwsEKSCallResult<T> {
  const AwsEKSCallResult({required this.value, this.result});
  final T value;
  final AwsEKSResult? result;
}

Future<T> tracedAwsEKS<T>({
  required String operation,
  required Future<AwsEKSCallResult<T>> Function() invoke,
  Tracer? tracer,
}) async {
  if (awsEKSInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTel.tracerProvider().getTracer('otel_aws_eks');
  final span = t.startSpan('eks $operation', kind: SpanKind.client);
  try {
    span.setStringAttribute('rpc.system', 'aws-api');
    span.setStringAttribute('rpc.service', 'EKS');
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.clusterName != null) {
        span.setStringAttribute('k8s.cluster.name', res.clusterName!);
      }
      if (res.clusterArn != null) {
        span.setStringAttribute('aws.eks.cluster.arn', res.clusterArn!);
      }
      if (res.version != null) {
        span.setStringAttribute('k8s.cluster.version', res.version!);
      }
      if (res.nodeGroup != null) {
        span.setStringAttribute('aws.eks.nodegroup', res.nodeGroup!);
      }
      if (res.fargateProfile != null) {
        span.setStringAttribute('aws.eks.fargate_profile', res.fargateProfile!);
      }
      if (res.podCount != null) {
        span.setIntAttribute('k8s.cluster.pod.count', res.podCount!);
      }
      if (res.region != null) {
        span.setStringAttribute('cloud.region', res.region!);
      }
      if (res.statusCode != null) {
        span.setIntAttribute('http.response.status_code', res.statusCode!);
      }
      if (res.errorCode != null) {
        span.setStringAttribute('eks.error.code', res.errorCode!);
      }
      final fail =
          res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.setStringAttribute(
          ErrorResource.errorType.key,
          res.errorCode ?? 'eks.error',
        );
        span.setStatus(SpanStatusCode.Error, res.errorMessage);
      }
    }
    return r.value;
  } catch (e, st) {
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
