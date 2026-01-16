void main() {
  try {
    final result = DateTime.parse("4:55 PM");
    print("Parsed successfully: $result");
  } catch (e) {
    print("Parse failed: $e");
  }

  try {
    final result = DateTime.parse("04:55");
    print("Parsed successfully: $result");
  } catch (e) {
    print("Parse failed: $e");
  }

  // ISO 8601
  try {
    final result = DateTime.parse("2023-10-10T16:55:00.000Z");
    print("Parsed ISO successfully: $result");
  } catch (e) {
    print("Parse ISO failed: $e");
  }
}
