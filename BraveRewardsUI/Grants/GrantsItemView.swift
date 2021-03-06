/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit

class GrantsItemView: SettingsSectionView {
  
  init(amount: String, expirationDate date: Date) {
    super.init(frame: .zero)
  
    let dateFormatter = DateFormatter().then {
      $0.dateStyle = .short
      $0.timeStyle = .none
    }
    let stackView = UIStackView().then {
      $0.axis = .vertical
      $0.alignment = .leading
      $0.spacing = 5.0
    }
    let amountView = CurrencyContainerView(amountLabelConfig: {
      $0.textColor = Colors.grey100
      $0.font = .systemFont(ofSize: 16.0, weight: .medium)
      $0.text = amount
    }, kindLabelConfig: {
      $0.textColor = Colors.grey200
      $0.font = .systemFont(ofSize: 13.0)
      $0.text = "BAT"
    })
    let expirationLabel = UILabel().then {
      $0.textColor = Colors.grey300
      $0.font = .systemFont(ofSize: 14.0)
      $0.numberOfLines = 0
      $0.text = String(
        format: BATLocalizedString("BraveRewardsGrantListExpiresOn", "Expires on %@"),
        dateFormatter.string(from: date)
      )
    }
    
    addSubview(stackView)
    stackView.addArrangedSubview(amountView)
    stackView.addArrangedSubview(expirationLabel)
    stackView.snp.makeConstraints {
      $0.edges.equalTo(layoutMarginsGuide)
    }
  }
}
