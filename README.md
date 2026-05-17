# otel_aws_eks

Dartastic OpenTelemetry bridge for AWS EKS (managed Kubernetes).

Wraps each call in a CLIENT-kind span with vendor-specific attributes following OpenTelemetry semantic conventions where applicable.

```dart
import 'package:otel_aws_eks/otel_aws_eks.dart';

await tracedAwsEKS<void>(
  operation: 'someOp',
  invoke: () async {
    final r = await client.someOp();
    return AwsEKSCallResult(value: r, result: AwsEKSResult(statusCode: 200));
  },
);
```

Suppress instrumentation within a block:

```dart
await runWithoutAwsEKSInstrumentationAsync(() async {
  await client.someInternalSync();
});
```
