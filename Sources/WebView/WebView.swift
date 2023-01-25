import SwiftUI
import UIKit
import WebKit

public struct WebView: View {
  private let request: URLRequest

  public init(url: URL) {
    self.request = URLRequest(url: url)
  }

  public init(request: URLRequest) {
    self.request = request
  }

  public var body: some View {
    _WebView(request: request)
  }
}

struct _WebView: UIViewRepresentable {
  let request: URLRequest

  func makeUIView(context: Context) -> WKWebView {
    let webView = WKWebView()
    webView.navigationDelegate = context.coordinator

    webView.load(request)

    return webView
  }

  func updateUIView(
    _ webView: WKWebView,
    context: Context
  ) {}

  func makeCoordinator() -> Coordinator {
    Coordinator()
  }

  // MARK: - Coordinator

  final class Coordinator: NSObject, WKNavigationDelegate {}
}
