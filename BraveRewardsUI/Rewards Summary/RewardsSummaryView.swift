/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit

class RewardsSummaryView: UIView {
  private struct UX {
    static let monthYearColor = Colors.blurple400
    static let gradientColors: [UIColor] = [Colors.blurple800, .white, .white]
    static let gradientLocations: [NSNumber] = [ 0.0, 0.4, 1.0 ]
    static let buttonHeight = 48.0
  }
  
  let rewardsSummaryButton = RewardsSummaryViewButton()
  let monthYearLabel = UILabel().then {
    $0.textColor = UX.monthYearColor
    $0.font = .systemFont(ofSize: 22.0)
    $0.isHidden = true
  }
  let scrollView = UIScrollView()
  let gradientView = GradientView().then {
    $0.gradientLayer.colors = UX.gradientColors.map { $0.cgColor }
    $0.gradientLayer.locations = UX.gradientLocations
  }
  let stackView = UIStackView().then {
    $0.axis = .vertical
  }
  
  var rows: [RowView] = [] {
    willSet {
      stackView.arrangedSubviews.forEach {
        $0.removeFromSuperview()
      }
    }
    didSet {
      rows.forEach {
        stackView.addArrangedSubview($0)
        if $0 !== rows.last {
          stackView.addArrangedSubview(SeparatorView())
        }
      }
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    addSubview(gradientView)
    addSubview(rewardsSummaryButton)
    addSubview(monthYearLabel)
    addSubview(scrollView)
    scrollView.addSubview(stackView)
    
    rewardsSummaryButton.snp.makeConstraints {
      $0.top.leading.trailing.equalTo(self)
      $0.height.equalTo(UX.buttonHeight)
    }
    monthYearLabel.snp.makeConstraints {
      $0.top.equalTo(self.rewardsSummaryButton.titleLabel.snp.bottom).offset(4.0)
      $0.leading.equalTo(self.rewardsSummaryButton.titleLabel)
      $0.trailing.equalTo(self.rewardsSummaryButton)
    }
    scrollView.snp.makeConstraints {
      $0.top.equalTo(self.monthYearLabel.snp.bottom).offset(20.0)
      $0.leading.trailing.bottom.equalTo(self)
    }
    scrollView.contentLayoutGuide.snp.makeConstraints {
      $0.width.equalTo(self)
      $0.bottom.equalTo(self.stackView)
    }
    stackView.snp.makeConstraints {
      $0.top.equalTo(self.scrollView.contentLayoutGuide.snp.top)
      $0.leading.trailing.equalTo(self).inset(22.0)
    }
  }
  
  @available(*, unavailable)
  required init(coder: NSCoder) {
    fatalError()
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    scrollView.layoutIfNeeded()
    gradientView.frame = scrollView.frame
  }
}
