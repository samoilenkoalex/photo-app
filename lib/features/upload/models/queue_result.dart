import '../../../network/network.dart';

class QueueProcessResult {
  final NetworkResponse<dynamic> response;
  final int successCount;

  QueueProcessResult(this.response, this.successCount);
}
