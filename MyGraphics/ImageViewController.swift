//
//  ImageViewController.swift
//  MyGraphics
//
//  Created by Linsw on 16/1/2.
//  Copyright © 2016年 Linsw. All rights reserved.
//

import UIKit
import CoreData
import ImageViewer
class ImageViewController: UIViewController {
    var imageObject:[NSManagedObject]?
    @IBAction func backButton(sender: UIBarButtonItem) {
        navigationController!.popViewControllerAnimated(true)
    }
    @IBOutlet weak var imageView: UIImageView!
    var indexPathRow:Int?{
        didSet{
            self.configureView()
        }
    }
    func configureView() {
        // Update the user interface
        if let _ = self.indexPathRow {
            
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        imageView.setupForImageViewer()
//        self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        imageObject = fetchImageObject()
        imageView.image = getImage(imageObject!, indexPathRow: indexPathRow!)
//        imageView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
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

    @IBAction func swipeToPreviousImage(sender: UISwipeGestureRecognizer) {
        print("swipeToPrevious")
        if indexPathRow > 0 {
            indexPathRow = indexPathRow! - 1
            imageView.image = getImage(imageObject!, indexPathRow: indexPathRow!)
        }else{
            print("Is the first image")
            indexPathRow = imageObject!.count - 1
            imageView.image = getImage(imageObject!, indexPathRow: indexPathRow!)
        }
    }
    @IBAction func swipeToNextImage(sender: UISwipeGestureRecognizer) {
        print("swipeToNext")
        if indexPathRow < (imageObject!.count - 1) {
            indexPathRow = indexPathRow! + 1
            imageView.image = getImage(imageObject!, indexPathRow: indexPathRow!)
        }else{
            print("Is the last image")
            indexPathRow = 0
            imageView.image = getImage(imageObject!, indexPathRow: indexPathRow!)
        }
    }
    func fetchImageObject()->[NSManagedObject]{
        var object=[NSManagedObject]()
        let managedContext = getManagedContext()
        let fetchRequest = NSFetchRequest(entityName: "Image")
        do {
            object = try managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return object
    }
    func getManagedContext()->NSManagedObjectContext{
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.managedObjectContext
    }
    func getImage(imageObj:[NSManagedObject],indexPathRow:Int)->UIImage{
        let imageName = imageObj[indexPathRow].valueForKey("name") as! String
        let appFilePath = (NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0]) + "/"
        let path = appFilePath + imageName
        let image = UIImage(contentsOfFile: path)
        return image!
    }
}
