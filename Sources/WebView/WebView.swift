import SwiftUI
import UIKit
import WebKit

public struct WebView {
  private let url: URL

  public init(url: URL) {
    self.url = url
  }
}

extension WebView: UIViewRepresentable {
  public func makeUIView(context: Context) -> WKWebView {
    return WKWebView()
  }

  public func updateUIView(_ webView: WKWebView, context: Context) {
    let request = URLRequest(url: url)
    webView.load(request)
  }
}
