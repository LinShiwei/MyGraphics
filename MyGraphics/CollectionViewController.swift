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
import ImageViewer

class CollectionViewController: UICollectionViewController,CollectionViewWaterfallLayoutDelegate  {

    enum ProviderEditState {
        case Normal
        case Delete
    }
    var currentEditState = ProviderEditState.Normal
    let appFilePath = (NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0]) + "/"
    var myImageCollection=[NSManagedObject]()
    let hour:Double=0.0
    var imagePaths = [String]()
    
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    @IBAction func cellCloseButton(sender: UIButton) {
        let cell = (sender.superview)!.superview as! CollectionViewCell
        let indexPath = self.collectionView!.indexPathForCell(cell)
        
        let managedContext = getManagedContext()
        managedContext.deleteObject(myImageCollection[indexPath!.row])
        do {
            try managedContext.save()
        }
        catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
        
        self.myImageCollection.removeAtIndex(indexPath!.row)
        self.collectionView!.performBatchUpdates({
            self.collectionView!.deleteItemsAtIndexPaths([indexPath!])
            return
            }, completion: nil)
    }
    @IBAction func chooseImageToDelete(sender: UIBarButtonItem) {
        if (self.currentEditState == ProviderEditState.Normal)
        {
            self.deleteButton.title = "OK";
            self.currentEditState = ProviderEditState.Delete;
            
            for cell in self.collectionView!.visibleCells() as! [CollectionViewCell]
            {
                cell.closeButton.hidden = false
                cell.cellImage.userInteractionEnabled = false
            }
        }else{
            self.deleteButton.title = "delete"
            self.currentEditState = ProviderEditState.Normal
            
            for cell in self.collectionView!.visibleCells() as! [CollectionViewCell]
            {
                cell.closeButton.hidden = true
                cell.cellImage.userInteractionEnabled = true
            }
        }

    }
    @IBAction func saveToPhotoAlbum(sender: UIBarButtonItem) {
        if myImageCollection.count > 0{
            for index in 0...myImageCollection.count - 1 {
                let imageURL = getImageURL(myImageCollection, indexPathRow: index)
                imagePaths.append(imageURL)
               
            }
            self.saveNextImage()
           
        }else{
            let alert = UIAlertController(title: "Fail", message: "There is no photo to save", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "OK", style: .Default) { (action: UIAlertAction) -> Void in }
            alert.addAction(okAction)
            presentViewController(alert, animated: true, completion: nil)

        }
    }
    func saveNextImage(){
        if imagePaths.count > 0 {
            let image = getImage(imagePaths.last!)
             UIImageWriteToSavedPhotosAlbum(image, self, "imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:", nil)
            imagePaths.removeLast()
        }
        
    }
    func imageSavedToPhotosAlbum(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafePointer<Void>) {
        if imagePaths.count > 0 {
            saveNextImage()
        } else {
            if imagePaths.count == 0 {
                let alert = UIAlertController(title: "Success!", message: "Photos have been saved to Album", preferredStyle: .Alert)
                
                let okAction = UIAlertAction(title: "OK", style: .Default) { (action: UIAlertAction) -> Void in }
                alert.addAction(okAction)
                presentViewController(alert, animated: true, completion: nil)
            }
        }
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
                    let data = UIImageJPEGRepresentation(image!, 1)
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
        let layout = CollectionViewWaterfallLayout()
        layout.sectionInset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
        layout.headerInset = UIEdgeInsetsMake(20, 0, 0, 0)
        layout.headerHeight = 0
        layout.footerHeight = 0
        layout.minimumColumnSpacing = 1
        layout.minimumInteritemSpacing = 1
        self.collectionView!.collectionViewLayout = layout
        self.collectionView!.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        myImageCollection = fetchImageObject()
  
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

/*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
       
        if segue.identifier == "setPassword" {
           
        }
        
    }
    */

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
        cell.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        
        let imageURL = getImageURL(myImageCollection, indexPathRow: indexPath.row)
        
        cell.cellImage.setupForImageViewer(NSURL(string: imageURL)!, backgroundColor: UIColor.blackColor())
        cell.cellImage.image = getImage(imageURL)
        cell.closeButton.tag = indexPath.row
//        cellPaths[indexPath.row] =indexPath
        if(self.currentEditState == ProviderEditState.Normal)
        {
            cell.closeButton.hidden = true
            cell.cellImage.userInteractionEnabled = true

        }
        else
        {
            cell.closeButton.hidden = false
            cell.cellImage.userInteractionEnabled = false

        }
        
    
        
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
    func getImage(imageURL:String)->UIImage{
        return UIImage(contentsOfFile: imageURL)!
    }
    func getImageURL(imageObj:[NSManagedObject],indexPathRow:Int)->String{
        let imageName = imageObj[indexPathRow].valueForKey("name") as! String
        let appFilePath = (NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0]) + "/"
        let path = appFilePath + imageName
        return path
        
    }
    // MARK: WaterfallLayoutDelegate
    
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return cellSize(myImageCollection,indexPathRow: indexPath.item)
    }
    //MARK: 自定义函数
    func cellSize(imageObj:[NSManagedObject],indexPathRow:Int)->CGSize{
        let imageURL = getImageURL(myImageCollection, indexPathRow: indexPathRow)
        let image = getImage(imageURL)
        let size = CGSize(width: image.size.width+9, height: image.size.height+9)
        return size
    }

}

