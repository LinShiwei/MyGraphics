//
//  CollectionViewController.swift
//  MyGraphics
//
//  Created by Linsw on 16/1/2.
//  Copyright © 2016年 Linsw. All rights reserved.
//

import UIKit
import CoreData
import Photos

class CollectionViewController: UICollectionViewController,CollectionViewWaterfallLayoutDelegate  {

    let appFilePath = (NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0]) + "/"
    var myImageCollection=[NSManagedObject]()
    let hour:Double=1.0
    
    @IBAction func saveToPhotoAlbum(sender: UIBarButtonItem) {
        
    }
    @IBAction func addImage(sender: AnyObject) {
        let fetchOptions = PHFetchOptions()
        let date = NSDate(timeInterval: -3600*hour, sinceDate: NSDate())
        let predicate = NSPredicate(format: "creationDate < %@", date)
        
        fetchOptions.predicate = predicate
        let assets = PHAsset.fetchAssetsWithMediaType(.Image, options: fetchOptions)
        let imageRequestOptions = PHImageRequestOptions()
        imageRequestOptions.synchronous = true
        if assets.count == 0 {
        
        }else{
            for index in 0 ... assets.count-1 {
                let imageManager = PHImageManager.defaultManager()
                
                let imageAssets = assets.objectAtIndex(index) as! PHAsset
                let imageSize = CGSize(width: CGFloat(imageAssets.pixelWidth),height: CGFloat(imageAssets.pixelHeight))
                imageManager.requestImageForAsset(imageAssets, targetSize: imageSize, contentMode: .AspectFill, options: imageRequestOptions, resultHandler: {image,_ in
                    let name = imageAssets.valueForKey("filename")!
                    let path = self.appFilePath + (name as! String)
                    let data = UIImageJPEGRepresentation(image!, 0)
                    data!.writeToFile(path, atomically: true)
                    let managedContext = self.getManagedContext()
                    let entity = NSEntityDescription.entityForName("Image", inManagedObjectContext:managedContext)
                    let imageObject = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
                    imageObject.setValue(name, forKey: "name")
                    do {
                        try managedContext.save()
                        self.myImageCollection.append(imageObject)
                        
                    }
                    catch let error as NSError {
                        print("Could not save \(error), \(error.userInfo)")
                    }
                })
            }
            self.collectionView?.reloadData()
        }
        
       
    }
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.collectionView?.collectionViewLayout
        let layout = CollectionViewWaterfallLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.headerInset = UIEdgeInsetsMake(20, 0, 0, 0)
        layout.headerHeight = 0
        layout.footerHeight = 0
        layout.minimumColumnSpacing = 10
        layout.minimumInteritemSpacing = 10
        self.collectionView!.collectionViewLayout = layout
        self.collectionView?.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        myImageCollection = fetchImageObject()
 
//        self.collectionView!.allowsSelection = true
//        self.collectionView!.allowsMultipleSelection = true
  
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if segue.identifier == "showImage" {
            //            self.tableView.reloadData()
            if let indexPath = self.collectionView?.indexPathsForSelectedItems() {
                let controller = segue.destinationViewController as! ImageViewController
                controller.indexPathRow = indexPath[0].row
                
            }
        }else{
            if segue.identifier == "setPassword" {
               
            }
        }
    }
    

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return myImageCollection.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("imageCell", forIndexPath: indexPath) as! CollectionViewCell
        // Configure the cell
        cell.backgroundColor = UIColor(red: 0.5, green: 0, blue: 0, alpha: 1)
//        cell.label.text = String(indexPath.row)
        cell.cellImage.image = getImage(myImageCollection, indexPathRow: indexPath.row)
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return true
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
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
    // MARK: WaterfallLayoutDelegate
    
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return cellSize(myImageCollection,indexPathRow: indexPath.item)
    }
    //MARK: 自定义函数
    func cellSize(imageObj:[NSManagedObject],indexPathRow:Int)->CGSize{
        let image = getImage(myImageCollection, indexPathRow: indexPathRow)
        return image.size
    }
//    lazy var cellSizes: [CGSize] = {
//        var _cellSizes = [CGSize]()
//        
//        for index in 0...self.myImageCollection.count - 1 {
//            //            let random = Int(arc4random_uniform((UInt32(100))))
//            let image = getMyImage(self.myImageCollection)
//            _cellSizes.append(CGSize(width: 10, height: 10))
//        }
//        
//        return _cellSizes
//    }()

}

