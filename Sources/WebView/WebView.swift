import SwiftUI
import UIKit
import WebKit

public struct WebView: View {
  public enum ReadyState: String, Equatable, Hashable, Sendable {
    case unknown
    case loading
    case complete

    public var isLoading: Bool {
      switch self {
      case .unknown: false
      case .loading: true
      case .complete: false
      }
    }
  }

  private let request: URLRequest

  private var onReadyStateChange: (ReadyState) -> Void = { _ in }

  public init(url: URL) {
    self.request = URLRequest(url: url)
  }

  public init(request: URLRequest) {
    self.request = request
  }

  public func onReadyStateChange(
    _ perform: @escaping (ReadyState) -> Void
  ) -> Self {
    var copy = self
    copy.onReadyStateChange = onReadyStateChange
    return copy
  }

  public var body: some View {
    _WebView(
      request: request,
      onReadyStateChange: onReadyStateChange
    )
    .equatable()
  }
}

struct _WebView: UIViewRepresentable {
  let request: URLRequest
  let onReadyStateChange: (WebView.ReadyState) -> Void

  func makeUIView(context: Context) -> WKWebView {
    let configuration = WKWebViewConfiguration()

    let webView = WKWebView(
      frame: .zero,
      configuration: configuration
    )

    webView.backgroundColor = .clear
    webView.isOpaque = false

    webView.scrollView.showsHorizontalScrollIndicator = false
    webView.scrollView.showsVerticalScrollIndicator = false

    webView.navigationDelegate = context.coordinator

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
    Coordinator(
      onReadyStateChange: onReadyStateChange
    )
  }

  // MARK: - Coordinator

  final class Coordinator: NSObject, WKNavigationDelegate {
    let onReadyStateChange: (WebView.ReadyState) -> Void

    init(
      onReadyStateChange: @escaping (WebView.ReadyState) -> Void
    ) {
      self.onReadyStateChange = onReadyStateChange
    }

    // MARK: - WKNavigationDelegate

    func webView(
      _ webView: WKWebView,
      didStartProvisionalNavigation navigation: WKNavigation!
    ) {
      onReadyStateChange(.loading)
    }

    func webView(
      _ webView: WKWebView,
      didFailProvisionalNavigation navigation: WKNavigation!,
      withError error: Error
    ) {
      checkReadyState(for: webView)
    }

    func webView(
      _ webView: WKWebView,
      didFail navigation: WKNavigation!,
      withError error: Error
    ) {
      checkReadyState(for: webView)
    }

    func webView(
      _ webView: WKWebView,
      didFinish navigation: WKNavigation!
    ) {
      // sometimes scrollView.contentSize doesn't fit all the frame.size available
      // so, we call setNeedsLayout to redraw the layout
      let webViewFrameSize = webView.frame.size
      let scrollViewSize = webView.scrollView.contentSize
      if scrollViewSize.width < webViewFrameSize.width || scrollViewSize.height < webViewFrameSize.height {
        webView.setNeedsLayout()
      }

      checkReadyState(for: webView)
    }

    // MARK: - Internals

    private func checkReadyState(for webView: WKWebView) {
      webView.evaluateJavaScript("document.readyState") { [weak self] response, error in
        let readyState = response
          .flatMap { $0 as? String }
          .flatMap(WebView.ReadyState.init(rawValue:)) ?? .unknown
        self?.onReadyStateChange(readyState)
      }
    }
  }
}

extension _WebView: Equatable {
  static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.request == rhs.request
  }
}
