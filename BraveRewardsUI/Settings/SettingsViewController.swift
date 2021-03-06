/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import BraveRewards

class SettingsViewController: UIViewController {
  
  var settingsView: View {
    return view as! View
  }
  
  let ledger: BraveLedger
  
  init(ledger: BraveLedger) {
    self.ledger = ledger
    super.init(nibName: nil, bundle: nil)
  }
  
  @available(*, unavailable)
  required init(coder: NSCoder) {
    fatalError()
  }
  
  override func loadView() {
    view = View()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = BATLocalizedString("BraveRewardsSettingsTitle", "Settings")
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(tappedDone))
    
    preferredContentSize = CGSize(width: RewardsUX.preferredPanelSize.width, height: 750)
    
    settingsView.do {
      $0.rewardsToggleSection.toggleSwitch.addTarget(self, action: #selector(rewardsSwitchValueChanged), for: .valueChanged)
      $0.grantSection.claimGrantButton.addTarget(self, action: #selector(tappedClaimGrant), for: .touchUpInside)
      $0.walletSection.viewDetailsButton.addTarget(self, action: #selector(tappedWalletViewDetails), for: .touchUpInside)
      $0.tipsSection.viewDetailsButton.addTarget(self, action: #selector(tappedTipsViewDetails), for: .touchUpInside)
      $0.autoContributeSection.viewDetailsButton.addTarget(self, action: #selector(tappedAutoContributeViewDetails), for: .touchUpInside)
      $0.autoContributeSection.toggleSwitch.addTarget(self, action: #selector(autoContributeToggleValueChanged), for: .valueChanged)
      
      // FIXME: Remove fake values
      $0.walletSection.setWalletBalance("30.0", crypto: "BAT", dollarValue: "0.00 USD")
      
      $0.rewardsToggleSection.toggleSwitch.isOn = ledger.isEnabled
      $0.autoContributeSection.toggleSwitch.isOn = ledger.isAutoContributeEnabled
    }
    
    updateVisualStateOfSections(animated: false)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    // Not sure why this has to be set on the nav controller specifically instead of just this controller
    navigationController?.preferredContentSize = CGSize(width: RewardsUX.preferredPanelSize.width, height: 1000)
  }
  
  // MARK: -
  
  private func updateVisualStateOfSections(animated: Bool) {
    settingsView.do {
      $0.rewardsToggleSection.setRewardsEnabled(ledger.isEnabled, animated: animated)
      $0.autoContributeSection.setSectionEnabled(
        ledger.isEnabled && ledger.isAutoContributeEnabled,
        hidesToggle: !ledger.isEnabled,
        animated: animated
      )
      $0.tipsSection.setSectionEnabled(ledger.isEnabled, animated: animated)
    }
  }
  
  // MARK: - Actions
  
  @objc private func tappedDone() {
    dismiss(animated: true)
  }
  
  @objc private func tappedClaimGrant() {
    // FIXME: Remove fake values
    let controller = GrantClaimedViewController(grantAmount: "30.0 BAT", expirationDate: Date().addingTimeInterval(30*24*60*60))
    let container = PopoverNavigationController(rootViewController: controller)
    
    settingsView.grantSection.claimGrantButton.isLoading = true
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
      self?.present(container, animated: true)
      self?.settingsView.grantSection.claimGrantButton.isLoading = false
    }
  }
  
  @objc private func tappedWalletViewDetails() {
    let controller = WalletDetailsViewController(ledger: ledger)
    controller.preferredContentSize = preferredContentSize
    navigationController?.pushViewController(controller, animated: true)
  }
  
  @objc private func tappedTipsViewDetails() {
    let controller = TipsDetailViewController(ledger: ledger)
    controller.preferredContentSize = preferredContentSize
    navigationController?.pushViewController(controller, animated: true)
  }
  
  @objc private func tappedAutoContributeViewDetails() {
    let controller = AutoContributeDetailViewController(ledger: ledger)
    controller.preferredContentSize = preferredContentSize
    navigationController?.pushViewController(controller, animated: true)
  }
  
  @objc private func rewardsSwitchValueChanged() {
    ledger.isEnabled = settingsView.rewardsToggleSection.toggleSwitch.isOn
    updateVisualStateOfSections(animated: true)
  }
  
  @objc private func autoContributeToggleValueChanged() {
    ledger.isAutoContributeEnabled = settingsView.autoContributeSection.toggleSwitch.isOn
    updateVisualStateOfSections(animated: true)
  }
}
