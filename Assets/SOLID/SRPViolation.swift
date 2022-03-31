//
//  PrivacyConsentsViewController.swift
//  People.Club
//
//  Created by developer03 on 16.02.2021.
//

import UIKit
import PKHUD

class PrivacyConsentsViewController: PFMSViewController {
	
	// MARK: - Properties
	
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var privacyConsentsTableView: UITableView!
	@IBOutlet weak var backButton: UIButton!
	@IBOutlet weak var saveButton: PFMSButton!
	
	private var currentConsentsSettings: Consents   { return AccountLocal.shared.consents! }
	private var currentPrivacySettings: Privacy     { return AccountLocal.shared.privacy!  }
	
	var updatedPrivacySettings: Privacy!
	var updatedConsentsSettings = [String: [String: Bool]]()
	
	// MARK: - Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.titleLabel.text = "pc_vc_titleLabel_text".localized().uppercased()
		
		self.privacyConsentsTableView.register(
			UINib(nibName: "ProfileSwitchTableViewCell", bundle: nil),
			forCellReuseIdentifier: "switchCell"
		)
		self.saveButton.setTitle(
			"schedule_filters_vc_apply_button".localized().uppercased(),
			for: .normal
		)
	}
	
	@IBAction func backAction(_ sender: Any) {
		self.navigationController?.popViewController(animated: true)
	}
	
	// MARK: - Business Logic
	
	@IBAction func applyAction() {
		HUD.show(.progress)
		
		self.populatePrivacy()
		self.popeualteConsents()
		
		let dispatchGroup = DispatchGroup()
		var privacyError = false
		var consentError = false
		var tasks = [() -> Void]()
		
		tasks.append { PFMSClient.clientsSetPrivacy(
			visibleToOthers: self.updatedPrivacySettings.visibleToOthers,
			showContactInfoToOthers: self.updatedPrivacySettings.showContactInfoToOthers,
			{ success, _ in
				if success {
					dispatchGroup.leave()
				} else {
					dispatchGroup.leave()
					privacyError = true
				}
			}
		)}
		tasks.append { PFMSClient.clientsSetClientConsents(
			self.updatedConsentsSettings,
			{ success, _ in
				if success {
					dispatchGroup.leave()
				} else {
					dispatchGroup.leave()
					consentError = true
				}
			}
		)}
		
		tasks.forEach({
			$0()
			dispatchGroup.enter()
		})
		
		dispatchGroup.notify(queue: .main, execute: {
			if !privacyError && !consentError {
				HUD.show(.progress)
				PFMSClient.clientsGetCurrentClientInfo({ success, data, _ in
					if success, let data = data {
						HUD.flash(.success)
						UserDefaults.currentClientInfo = data
                        AccountLocal.shared.setCurrentInfo(data: data)
						self.navigationController?.popViewController(animated: true)
					}
				})
			} else {
				HUD.flash(.error)
			}
		})
	}
	
	func populatePrivacy() {
		let rowCount = self.privacyConsentsTableView.numberOfRows(inSection: 0)
		var visibleToOthers = false
		var showContactInfoToOthers = false
		
		for row in 0..<rowCount {
			let cell = self.privacyConsentsTableView.cellForRow(
				at: IndexPath(row: row, section: 0)
			) as! ProfileSwitchTableViewCell
			
			if row == 0 {
				visibleToOthers = cell.switchControl.isOn
			} else if row == 1 {
				showContactInfoToOthers = cell.switchControl.isOn
			}
		}
		
		self.updatedPrivacySettings = Privacy(
			visibleToOthers: visibleToOthers,
			showContactInfoToOthers: showContactInfoToOthers
		)
	}
	
	func popeualteConsents() {
		let rowCount = self.privacyConsentsTableView.numberOfRows(inSection: 1)
		var consentsSnapshot = [String: Bool]()
		
		for row in 0..<rowCount {
			let cell = self.privacyConsentsTableView.cellForRow(
				at: IndexPath(row: row, section: 1)
			) as! ProfileSwitchTableViewCell
			
			consentsSnapshot["\(cell.consentKey ?? "")"] = cell.switchControl.isOn
		}
		
		self.updatedConsentsSettings["consents"] = consentsSnapshot
	}
}

// MARK: - Table View

extension PrivacyConsentsViewController: UITableViewDelegate, UITableViewDataSource {
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 0 { return 2 } else { return self.currentConsentsSettings.count }
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(
			withIdentifier: "switchCell", for: indexPath
		) as! ProfileSwitchTableViewCell
		
		let section = indexPath.section
		let row = indexPath.row
		
		let visibleToOthers = self.currentPrivacySettings.visibleToOthers
		let showContactInfoToOthers = self.currentPrivacySettings.showContactInfoToOthers
		
		let currentConsentStatus = self.currentConsentsSettings[indexPath.row].state
		let currentConsentKey = self.currentConsentsSettings[indexPath.row].key
		
		if section == 0 && row == 0 {
			cell.label?.text = "pc_vc_privacy_visible_to_all".localized().uppercased()
			cell.switchControl.isOn = visibleToOthers
			cell.delegate = self
		} else if section == 0 && row == 1 {
			cell.label?.text = "pc_vc_privacy_visible_contacts".localized().uppercased()
			cell.switchControl.isOn = showContactInfoToOthers
			
			if !visibleToOthers {
				cell.isUserInteractionEnabled = false
				cell.alpha = 0.5
				cell.switchControl.isOn = false
				cell.layoutIfNeeded()
			}
		} else if section > 0 {
			cell.label.text = PFMSConesnts(rawValue: (currentConsentKey))?.localizedString
			cell.consentKey = currentConsentKey
			cell.switchControl.isOn = currentConsentStatus
		}
		
		cell.indexPath = indexPath
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 65
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let headerView = Bundle.main.loadNibNamed(
			"ContractInfoHeaderView", owner: self, options: nil
		)?.last as! ContractInfoHeaderView
		
		headerView.setAsDummySectionHeader()
		
		if section == 0 {
			headerView.titleLabel.text = "pc_vc_privacy_section_title".localized().uppercased()
		} else if section == 1 {
			headerView.titleLabel.text = "pc_vc_consents_section_title".localized().uppercased()
		}
		
		return headerView
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 40
	}
}

extension PrivacyConsentsViewController: ProfileSwitchTableViewCellDelegate {
	func switchCellUpdated(_ cell: ProfileSwitchTableViewCell) {
		""
	}
	
	func propagateSwitchStatus(_ cell: ProfileSwitchTableViewCell, indexPath: IndexPath) {
		let section = indexPath.section
		let row = indexPath.row
		
		guard
			section == 0 && row == 0,
			let controlledCell = self.privacyConsentsTableView.cellForRow(
				at: IndexPath(row: 1, section: 0)) as? ProfileSwitchTableViewCell
		else { return }
		
		if !cell.switchControl.isOn {
			controlledCell.isUserInteractionEnabled = false
			
			UIView.animate(withDuration: 0.3, animations: {
				controlledCell.switchControl.setOn(false, animated: true)
				controlledCell.alpha = 0.5
			})
		} else {
			controlledCell.isUserInteractionEnabled = true
			
			UIView.animate(withDuration: 0.3, animations: {
				controlledCell.alpha = 1
			})
		}
	}
}

