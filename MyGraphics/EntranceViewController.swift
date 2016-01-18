//
//  EntranceViewController.swift
//  MyGraphics
//
//  Created by Linsw on 16/1/16.
//  Copyright © 2016年 Linsw. All rights reserved.
//

import UIKit
import CoreData
class EntranceViewController: UIViewController {
    let defaultKey = 10000
    @IBOutlet weak var entranceButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        entranceButton.enabled = true
        textField.text = String(fetchPassword())
        
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let st = UIStoryboard.init(name: "Main", bundle: nil)
        let navi = st.instantiateViewControllerWithIdentifier("Navigation1")
        self.presentViewController(navi, animated: true, completion: nil)

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func fetchPassword()->Int{
        var object=[NSManagedObject]()
        let managedContext = getManagedContext()
        let fetchRequest = NSFetchRequest(entityName: "Password")
        do {
            object = try managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        if object.count > 0{
            return object[0].valueForKey("key") as! Int
        }else{
            return defaultKey
        }
    }
    func getManagedContext()->NSManagedObjectContext{
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.managedObjectContext
    }

}
