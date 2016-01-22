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
    
    var settingObject : NSManagedObject?
    
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
        self.tableView.backgroundView = UIView.init()
        self.tableView.backgroundView?.backgroundColor = UIColor(white: 0.95, alpha: 1)
        settingObject = initsettingObject()
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
        return 3
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
        case 0: return 4
        case 1: return 2
        case 2: return 3
        default:return 0
        }
        
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("checkMarkCell", forIndexPath: indexPath) as! CycleTableViewCell
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
        case 2:
            let cell = tableView.dequeueReusableCellWithIdentifier("checkMarkCell", forIndexPath: indexPath) as! CycleTableViewCell
            cell.accessoryType = UITableViewCellAccessoryType.None
            switch indexPath.row {
            case 0:
                cell.titleLabel.text = "分成三列"
                if isEqualToColumnCount(3){
                    cell.accessoryType = UITableViewCellAccessoryType.Checkmark
                }
            case 1:
                cell.titleLabel.text = "分成四列"
                if isEqualToColumnCount(4){
                    cell.accessoryType = UITableViewCellAccessoryType.Checkmark
                }
            case 2:
                cell.titleLabel.text = "分成五列"
                if isEqualToColumnCount(5){
                    cell.accessoryType = UITableViewCellAccessoryType.Checkmark
                }
            default:break
            }
            return cell
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("checkMarkCell", forIndexPath: indexPath)
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
            settingObject!.setValue(cycle, forKey: "updateCycle")
            saveToCoreData()
            tableView.reloadData()
            
        case 1:
            switch indexPath.row {
            case 1:
                changePasscode()
            default:break
            }
        case 2:
            let columnCount:Int?
            switch indexPath.row {
            case 0:
                columnCount = 3
            case 1:
                columnCount = 4
            case 2:
                columnCount = 5
            default:
                columnCount = 3
            }
            settingObject!.setValue(columnCount, forKey: "columnCount")
//            saveToCoreData()
            tableView.reloadData()
        default:
            break
        }
    }
    // MARK: tableview delegate
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        let font = UIFont.systemFontOfSize(14)
        label.font = font
        label.textColor = UIColor(white: 0.5, alpha: 1)
        switch section {
        case 0: label.text = "    同步时间段"
        case 1: label.text = "    密码"
        default:label.text = "    照片列数"
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
        let c = settingObject?.valueForKey("updateCycle")
        print("\(c)")
    }
    // MARK: 自定义函数
    func passcodeSwitchValueChange(sender:UISwitch){
    
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
    /*
    func fetchUpdateCycle()->Double {
        var cycle:Double = 1.0
        let managedContext = getManagedContext()
        let fetchRequest = NSFetchRequest(entityName: "Setting")
        do {
            let object = try managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
            if object.count > 0{
                cycle = object[0].valueForKey("updateCycle") as! Double
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return cycle
    }*/
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
    func initsettingObject()->NSManagedObject{
        let managedContext = getManagedContext()
        let fetchRequest = NSFetchRequest(entityName: "Setting")
        var object = [NSManagedObject]()
        do {
            object = try managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return object[0]
    }
    func isEqualToCycle(cycle:Double)->Bool{
        let temp = settingObject!.valueForKey("updateCycle") as! Double
        if cycle == temp {
            return true
        }else{
            return false
        }
    }
    func isEqualToColumnCount(count:Int)->Bool{
        let temp = settingObject!.valueForKey("columnCount") as! Int
        if count == temp {
            return true
        }else{
            return false
        }
    }
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if (cell.respondsToSelector(Selector("tintColor"))){
            if (tableView == self.tableView) {
                let cornerRadius : CGFloat = 12.0
                cell.backgroundColor = UIColor.clearColor()
                let layer: CAShapeLayer = CAShapeLayer()
                let pathRef:CGMutablePathRef = CGPathCreateMutable()
                let bounds: CGRect = CGRectInset(cell.bounds, 10, 0) //25->10
                var addLine: Bool = false
                
                if (indexPath.row == 0 && indexPath.row == tableView.numberOfRowsInSection(indexPath.section)-1) {
                    CGPathAddRoundedRect(pathRef, nil, bounds, cornerRadius, cornerRadius)
                } else if (indexPath.row == 0) {
                    CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds))
                    CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds), CGRectGetMidX(bounds), CGRectGetMinY(bounds), cornerRadius)
                    CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius)
                    CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds))
                    addLine = true
                } else if (indexPath.row == tableView.numberOfRowsInSection(indexPath.section)-1) {
                    CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds))
                    CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds), CGRectGetMidX(bounds), CGRectGetMaxY(bounds), cornerRadius)
                    CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius)
                    CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds))
                } else {
                    CGPathAddRect(pathRef, nil, bounds)
                    addLine = true
                }
                
                layer.path = pathRef
                layer.fillColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 0.8).CGColor
                
                if (addLine == true) {
                    let lineLayer: CALayer = CALayer()
                    let lineHeight: CGFloat = (1.0 / UIScreen.mainScreen().scale)
                    lineLayer.frame = CGRectMake(CGRectGetMinX(bounds)+10, bounds.size.height-lineHeight, bounds.size.width-10, lineHeight)
                    lineLayer.backgroundColor = tableView.separatorColor!.CGColor
                    layer.addSublayer(lineLayer)
                }
                let testView: UIView = UIView(frame: bounds)
                testView.layer.insertSublayer(layer, atIndex: 0)
                testView.backgroundColor = UIColor.clearColor()
                cell.backgroundView = testView
            }
        }
    }
}
