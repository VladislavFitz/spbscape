//
//  ToolbarDelegate.swift
//  Spbscape
//
//  Created by Vladislav Fitc on 13/03/2021.
//  Copyright © 2021 Vladislav Fitc. All rights reserved.
//

import Foundation
import UIKit

class ToolbarDelegate: NSObject {}

#if targetEnvironment(macCatalyst)

  extension NSToolbarItem.Identifier {
    static let filters = NSToolbarItem.Identifier("com.spbscape.filters")
  }

  extension ToolbarDelegate {
    @objc
    func showFilters(_ sender: Any?) {
      NotificationCenter.default.post(name: .showFilters, object: sender)
    }
  }

  extension ToolbarDelegate: NSToolbarDelegate {
    func toolbarDefaultItemIdentifiers(_: NSToolbar) -> [NSToolbarItem.Identifier] {
      let identifiers: [NSToolbarItem.Identifier] = [
        .toggleSidebar,
        .flexibleSpace,
        .filters
      ]
      return identifiers
    }

    func toolbarAllowedItemIdentifiers(_ toolbarContainer: NSToolbar) -> [NSToolbarItem.Identifier] {
      return toolbarDefaultItemIdentifiers(toolbarContainer)
    }

    func toolbar(_: NSToolbar,
                 itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
                 willBeInsertedIntoToolbar _: Bool) -> NSToolbarItem? {
      var toolbarItem: NSToolbarItem?

      switch itemIdentifier {
      case .toggleSidebar:
        toolbarItem = NSToolbarItem(itemIdentifier: itemIdentifier)

      case .filters:
        let item = NSToolbarItem(itemIdentifier: itemIdentifier)
        item.image = UIImage(systemName: "line.horizontal.3.decrease.circle")?
          .resizeImageTo(size: CGSize(width: 40, height: 40))?
          .withRenderingMode(.alwaysTemplate)
        item.label = "filters".localize()
        item.action = #selector(showFilters(_:))
        item.target = self
        toolbarItem = item

      default:
        toolbarItem = nil
      }

      return toolbarItem
    }
  }

#endif
