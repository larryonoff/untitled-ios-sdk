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
    let configuration = WKWebViewConfiguration()

    let webView = WKWebView(
      frame: .zero,
      configuration: configuration
    )
    webView.navigationDelegate = context.coordinator

    webView.scrollView.showsHorizontalScrollIndicator = false
    webView.scrollView.showsVerticalScrollIndicator = false

    // WKWebView doesn't work well with HTTPCookieStorage
    // so it's done manually below
    Task(priority: .userInitiated) { [request] in
      if
        let url = request.url,
        let cookies = HTTPCookieStorage.shared.cookies(for: url),
        !cookies.isEmpty
      {
        let httpCookieStore =
          configuration.websiteDataStore.httpCookieStore

        for cookie in cookies {
          await httpCookieStore.setCookie(cookie)
        }
      }

      webView.load(request)
    }

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
