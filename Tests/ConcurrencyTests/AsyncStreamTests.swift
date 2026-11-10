import DuckConcurrency
import Testing

struct AsyncStreamTests {
  private final class TransferredValue {
    var integer = 42
  }

  @Test func `a single element stream finishes after its value`() async {
    var values: [String] = []
    for await value in AsyncStream("value") { values.append(value) }
    #expect(values == ["value"])
  }

  @Test func `a single element stream accepts a transferred nonsendable value`() async {
    let value = TransferredValue()
    let stream = AsyncStream(value)
    var iterator = stream.makeAsyncIterator()
    let received = await iterator.next()
    #expect(received?.integer == 42)
  }
}
