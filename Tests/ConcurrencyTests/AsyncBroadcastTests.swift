import DuckConcurrency
import Testing

struct AsyncBroadcastTests {
  @Test func holdsValuesUntilTheFirstStreamOpens() async {
    // A cold-launch tap arrives before the app subscribes.
    let broadcast = AsyncBroadcast<String>(holdsUntilSubscribed: true)
    broadcast.yield("a")
    broadcast.yield("b")

    let stream = broadcast.stream()
    broadcast.yield("c")

    var values: [String] = []
    for await value in stream {
      values.append(value)
      if values.count == 3 { break }
    }

    #expect(values == ["a", "b", "c"])
  }

  @Test func holdsValuesAgainOnceEveryStreamEnds() async {
    let broadcast = AsyncBroadcast<String>(holdsUntilSubscribed: true)
    do {
      let stream = broadcast.stream()
      _ = stream
    }

    broadcast.yield("late")

    var iterator = broadcast.stream().makeAsyncIterator()
    #expect(await iterator.next() == "late")
  }

  @Test func dropsValuesWithoutAStreamByDefault() async {
    let broadcast = AsyncBroadcast<String>()
    broadcast.yield("lost")

    let stream = broadcast.stream()
    broadcast.yield("kept")

    var iterator = stream.makeAsyncIterator()
    #expect(await iterator.next() == "kept")
  }
}
