/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit

public class SwitchRow: UIStackView {
  
  private struct UX {
    static let textColor = Colors.grey200
  }
  
  public let textLabel = UILabel().then {
    $0.font = .systemFont(ofSize: 14.0)
    $0.textColor = UX.textColor
    $0.numberOfLines = 0
  }
  
  public let toggleSwitch = UISwitch().then {
    $0.onTintColor = BraveUX.switchOnColor
    $0.setContentHuggingPriority(.required, for: .horizontal)
  }
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
   
    addArrangedSubview(textLabel)
    addArrangedSubview(toggleSwitch)
  }
  
  @available(*, unavailable)
  required init(coder: NSCoder) {
    fatalError()
  }
}
