import SwiftUI

public enum ListSeparatorStyle {
  case hidden
  case visible

  @available(iOS 15, macOS 12, tvOS 15, watchOS 8, *)
  var toSwiftUI: SwiftUI.Visibility {
    switch self {
    case .hidden:
        return .hidden
    case .visible:
        return .visible
    }
  }

  var toUIKit: UITableViewCell.SeparatorStyle {
    switch self {
    case .hidden:
      return .none
    case .visible:
      return .singleLine
    }
  }
}

extension View {
  public func listSeparatorStyle(
    _ style: ListSeparatorStyle
  ) -> some View {
    modifier(
      ListSeparatorStyleNoneModifier(
        separatorStyle: style
      )
    )
  }
}

private struct ListSeparatorStyleNoneModifier: ViewModifier {
  let separatorStyle: ListSeparatorStyle

  func body(content: Content) -> some View {
    if #available(iOS 15, *) {
      // WORKAROUND
      // swift availiability check crash
      // link: https://stackoverflow.com/questions/70506330/swiftui-app-crashes-with-different-searchbar-viewmodifier-on-ios-14-15
      Group {
        if #available(iOS 15, *) {
          content.listRowSeparator(separatorStyle.toSwiftUI)
        }
      }
    } else {
      content.onAppear {
        if #available(iOS 14, *) {} else {
          UITableView.appearance().tableFooterView = UIView()
        }

        UITableView.appearance().separatorStyle =
          separatorStyle.toUIKit
      }
      .onDisappear {
        UITableView.appearance().separatorStyle = .singleLine
      }
    }
  }
}
