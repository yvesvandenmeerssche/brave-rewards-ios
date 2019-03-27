/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation

public class Button: UIButton {
  
  // MARK: - Activity
  
  /// Where the loader should go when it begins animating
  public enum LoaderPlacement {
    /// Hides any title/image and centers the loader
    case replacesContent
    /// To the right of the title
    case right
  }
  
  /// Set an activity indicator you would like to see in this button
  public var loaderView: LoaderView?
  
  public var loaderPlacement: LoaderPlacement = .replacesContent
  
  @objc(loading) public var isLoading: Bool = false {
    didSet {
      guard let loaderView = loaderView else {
        fatalError()
      }
      
      if loaderPlacement == .replacesContent && buttonType == .system {
        assertionFailure("System buttons cannot replace their content because the titleLabel/imageView's are managed")
        return
      }
      
      loaderView.tintColor = tintColor
      
      if isLoading {
        addSubview(loaderView)
        loaderView.snp.makeConstraints {
          $0.center.equalToSuperview()
        }
        layoutIfNeeded()
        loaderView.start()
      }
      if loaderPlacement == .replacesContent, isLoading {
        loaderView.alpha = 0.0
      }
      switch loaderPlacement {
      case .replacesContent:
        let animatingOutViews = isLoading ? [self.titleLabel, self.imageView].compactMap { $0 } : [loaderView]
        let animatingInViews = isLoading ? [loaderView] : [self.titleLabel, self.imageView].compactMap { $0 }
        UIView.animateKeyframes(withDuration: 0.45, delay: 0, options: [], animations: {
          UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.2, animations: {
            animatingOutViews.forEach { $0.alpha = 0.0 }
          })
          UIView.addKeyframe(withRelativeStartTime: 0.25, relativeDuration: 0.2, animations: {
            animatingInViews.forEach { $0.alpha = 1.0 }
          })
        }, completion: { _ in
          if !self.isLoading {
            loaderView.stop()
            loaderView.removeFromSuperview()
          }
        })
      case .right:
        break
      }
    }
  }
  
  // MARK: - Image Placement
  
  public var flipImageOrigin: Bool = false
  
  public override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
    var frame = super.imageRect(forContentRect: contentRect)
    if flipImageOrigin {
      frame.origin.x = super.titleRect(forContentRect: contentRect).maxX - frame.width - imageEdgeInsets.right + imageEdgeInsets.left + titleEdgeInsets.right - titleEdgeInsets.left
    }
    return frame
  }
  
  public override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
    var frame = super.titleRect(forContentRect: contentRect)
    if flipImageOrigin {
      frame.origin.x -= imageRect(forContentRect: contentRect).width
    }
    return frame
  }
  
  public override var intrinsicContentSize: CGSize {
    var size = super.intrinsicContentSize
    size.width += abs(imageEdgeInsets.left) + abs(imageEdgeInsets.right) +
      abs(titleEdgeInsets.left) + abs(titleEdgeInsets.right)
    return size
  }
  
  // MARK: - Touch Extension
  
  var hitTestSlop: UIEdgeInsets = .zero
  
  public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
    if bounds.inset(by: hitTestSlop).contains(point) {
      return true
    }
    return super.point(inside: point, with: event)
  }
}
