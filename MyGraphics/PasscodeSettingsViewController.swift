//
//  PasscodeSettingsViewController.swift
//  PasscodeLockDemo
//
//  Created by Yanko Dimitrov on 8/29/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import UIKit
import PasscodeLock

class PasscodeSettingsViewController: UIViewController {
    
    @IBOutlet weak var passcodeSwitch: UISwitch!
    @IBOutlet weak var changePasscodeButton: UIButton!
    
    private let configuration: PasscodeLockConfigurationType
    
    init(configuration: PasscodeLockConfigurationType) {
        
        self.configuration = configuration
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        let repository = UserDefaultsPasscodeRepository()
        configuration = PasscodeLockConfiguration(repository: repository)
        
        super.init(coder: aDecoder)
    }
    
    // MARK: - View
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        updatePasscodeView()
    }
    
    func updatePasscodeView() {
        
        let hasPasscode = configuration.repository.hasPasscode
        
        changePasscodeButton.hidden = !hasPasscode
        passcodeSwitch.on = hasPasscode
    }
    
    // MARK: - Actions
    
    @IBAction func passcodeSwitchValueChange(sender: UISwitch) {
        
        let passcodeVC: PasscodeLockViewController
        
        if passcodeSwitch.on {
            
            passcodeVC = PasscodeLockViewController(state: .SetPasscode, configuration: configuration)
            
        } else {
            
            passcodeVC = PasscodeLockViewController(state: .RemovePasscode, configuration: configuration)
            
            passcodeVC.successCallback = { lock in
                
                lock.repository.deletePasscode()
            }
        }

        presentViewController(passcodeVC, animated: true, completion: nil)
    }
    
    @IBAction func changePasscodeButtonTap(sender: UIButton) {
        
        let repo = UserDefaultsPasscodeRepository()
        let config = PasscodeLockConfiguration(repository: repo)
        
        let passcodeLock = PasscodeLockViewController(state: .ChangePasscode, configuration: config)
        presentViewController(passcodeLock, animated: true, completion: nil)
    }
    


}
