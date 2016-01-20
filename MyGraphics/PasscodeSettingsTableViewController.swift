//
//  PasscodeSettingsViewController.swift
//  PasscodeLockDemo
//
//  Created by Yanko Dimitrov on 8/29/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import UIKit
import PasscodeLock
import CoreData

class PasscodeSettingsTableViewController: UITableViewController{
    
    var updateCycle : NSManagedObject?
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateCycle = initUpdateCycle()
                // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
        case 0: return 4
        case 1: return 2
        default:return 0
        }
        
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("cycleCell", forIndexPath: indexPath) as! CycleTableViewCell
            cell.accessoryType = UITableViewCellAccessoryType.None
            switch indexPath.row {
            case 0:
                cell.titleLabel.text = "过去一小时"
                if isEqualToCycle(1.0){
                    cell.accessoryType = UITableViewCellAccessoryType.Checkmark
                }
            case 1:
                cell.titleLabel.text = "过去六小时"
                if isEqualToCycle(6.0){
                    cell.accessoryType = UITableViewCellAccessoryType.Checkmark
                }
            case 2:
                cell.titleLabel.text = "过去一天"
                if isEqualToCycle(24.0){
                    cell.accessoryType = UITableViewCellAccessoryType.Checkmark
                }
            case 3:
                cell.titleLabel.text = "过去一周"
                if isEqualToCycle(24.0*7){
                    cell.accessoryType = UITableViewCellAccessoryType.Checkmark
                }
            default:break
            }
            return cell
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("enablePasscodeCell", forIndexPath: indexPath) as! PasscodeTableViewCell
            switch indexPath.row {
            case 0:
                cell.titleLabel.text = "启用密码"
                let hasPasscode = configuration.repository.hasPasscode
                if hasPasscode {
                    cell.titleLabel.textColor = UIColor(white: 0.0, alpha: 1)
                }else{
                    cell.titleLabel.textColor = UIColor(white: 0.5, alpha: 1)
                }
                cell.enablePasscodeSwitch.hidden = false
                cell.enablePasscodeSwitch.on = hasPasscode
                cell.enablePasscodeSwitch.addTarget(self, action: "passcodeSwitchValueChange:", forControlEvents: UIControlEvents.ValueChanged)
            case 1:
                cell.titleLabel.text = "修改密码"
                cell.enablePasscodeSwitch.hidden = true
                let hasPasscode = configuration.repository.hasPasscode
                if hasPasscode {
                    cell.titleLabel.textColor = UIColor(white: 0.0, alpha: 1)
                    cell.userInteractionEnabled = true
                }else{
                    cell.titleLabel.textColor = UIColor(white: 0.5, alpha: 1)
                    cell.userInteractionEnabled = false
                }
            default: break
             
            }
            return cell
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("cycleCell", forIndexPath: indexPath)
            return cell
        }
   
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        print("\(indexPath.section)  \(indexPath.row)")
        switch indexPath.section {
        case 0:
            let cycle:Double?
            switch indexPath.row {
            case 0:
                cycle = 1.0
            case 1:
                cycle = 6.0
            case 2:
                cycle = 24.0
            case 3:
                cycle = 24.0*7
            default:
                cycle = 1.0
            }
            updateCycle!.setValue(cycle, forKey: "cycle")
            saveToCoreData()
            tableView.reloadData()
            
        case 1:
            switch indexPath.row {
            case 1:
                changePasscode()
            default:break
            }
        default:
            break
        }
    }
    // MARK: tableview delegate
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        let font = UIFont.systemFontOfSize(14)
        label.font = font
        label.textColor = UIColor(white: 0.5, alpha: 1)
        if section == 0 {
                    label.text = " 同步时间段"

        }else{
            label.text = " 密码"
        }
        return label
    }
    // MARK: - View
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.reloadData()
//        updatePasscodeView()
    }
    override func  viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        let c = updateCycle?.valueForKey("cycle")
        print("\(c)")
    }
    // MARK: 自定义函数
    func passcodeSwitchValueChange(sender:UISwitch){
        print(sender)
        print("switch")
        let passcodeVC: PasscodeLockViewController
//        let cell = sender.superview as! PasscodeTableViewCell
        if sender.on {
            passcodeVC = PasscodeLockViewController(state: .SetPasscode, configuration: configuration)
        }else{
            passcodeVC = PasscodeLockViewController(state: .RemovePasscode, configuration: configuration)
            
            passcodeVC.successCallback = { lock in
                
                lock.repository.deletePasscode()
            }
        }
        presentViewController(passcodeVC, animated: true, completion: nil)
    }
    func changePasscode() {
        let repo = UserDefaultsPasscodeRepository()
        let config = PasscodeLockConfiguration(repository: repo)
        
        let passcodeLock = PasscodeLockViewController(state: .ChangePasscode, configuration: config)
        presentViewController(passcodeLock, animated: true, completion: nil)
        
    }
    func fetchUpdateCycle()->Double {
        var cycle:Double = 1.0
        let managedContext = getManagedContext()
        let fetchRequest = NSFetchRequest(entityName: "Update")
        do {
            let object = try managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
            if object.count > 0{
                cycle = object[0].valueForKey("cycle") as! Double
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return cycle
    }
    func getManagedContext()->NSManagedObjectContext{
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.managedObjectContext
    }
    func saveToCoreData() {
        let managedContext = getManagedContext()
        do {
            try managedContext.save()
        }
        catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    func initUpdateCycle()->NSManagedObject{
        let managedContext = getManagedContext()
        let fetchRequest = NSFetchRequest(entityName: "Update")
        var object = [NSManagedObject]()
        do {
            object = try managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        if object.count > 0 {
            return object[0]
        }else{
            let entity = NSEntityDescription.entityForName("Update", inManagedObjectContext:managedContext)
            let cycleObject = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
            cycleObject.setValue(1.0, forKey: "cycle")
            do {
                try managedContext.save()
            }
            catch let error as NSError {
                print("Could not save \(error), \(error.userInfo)")
            }
            return cycleObject
        }

    }
    func isEqualToCycle(cycle:Double)->Bool{
        let temp = updateCycle!.valueForKey("cycle") as! Double
        if cycle == temp {
            return true
        }else{
            return false
        }
    }
    

}
