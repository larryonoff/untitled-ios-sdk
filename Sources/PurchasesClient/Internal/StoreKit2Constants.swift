import Foundation

let stK2ReleaseDateString = "2025-01-14"

let sk2ReleaseDate: Date = {
  let dateFormatter = DateFormatter()
  dateFormatter.dateFormat = "yyyy-MM-dd"
  dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

  return dateFormatter.date(from: stK2ReleaseDateString) ?? Date()
}()
