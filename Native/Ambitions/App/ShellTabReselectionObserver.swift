import SwiftUI

#if canImport(UIKit)
import UIKit

struct ShellTabReselectionObserver: UIViewControllerRepresentable {
    let onReselect: (AppTab) -> TopLevelTabReselectionAction

    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        context.coordinator.onReselect = onReselect
        DispatchQueue.main.async {
            context.coordinator.install(from: uiViewController)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onReselect: onReselect)
    }

    final class Coordinator: NSObject, UITabBarControllerDelegate {
        var onReselect: (AppTab) -> TopLevelTabReselectionAction
        private weak var tabBarController: UITabBarController?

        init(onReselect: @escaping (AppTab) -> TopLevelTabReselectionAction) {
            self.onReselect = onReselect
        }

        func install(from viewController: UIViewController) {
            guard let tabBarController = viewController.findTabBarController() else { return }
            guard self.tabBarController !== tabBarController || tabBarController.delegate !== self else { return }
            self.tabBarController = tabBarController
            tabBarController.delegate = self
        }

        func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
            guard let index = tabBarController.viewControllers?.firstIndex(of: viewController),
                  tabBarController.selectedIndex == index,
                  AppTab.allCases.indices.contains(index)
            else {
                return true
            }

            let tab = AppTab.allCases[index]
            _ = onReselect(tab)
            DispatchQueue.main.async {
                tabBarController.selectedViewController?.view.scrollFirstScrollableViewToTop()
            }
            return false
        }
    }
}

private extension UIViewController {
    func findTabBarController() -> UITabBarController? {
        if let tabBarController {
            return tabBarController
        }
        return parent?.findTabBarController()
    }
}

private extension UIView {
    func scrollFirstScrollableViewToTop() {
        if let scrollView = firstScrollableView() {
            let topInset = scrollView.adjustedContentInset.top
            scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x, y: -topInset), animated: true)
        }
    }

    func firstScrollableView() -> UIScrollView? {
        if let scrollView = self as? UIScrollView {
            return scrollView
        }

        for subview in subviews {
            if let scrollView = subview.firstScrollableView() {
                return scrollView
            }
        }

        return nil
    }
}
#endif
