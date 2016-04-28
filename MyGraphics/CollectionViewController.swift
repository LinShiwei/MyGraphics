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

class CollectionViewController: UICollectionViewController{
    //MARK: 自定义变量
    enum ProviderEditState {
        case Normal
        case Choose
    }
    var currentEditState = ProviderEditState.Normal
    let appFilePath = (NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0]) + "/"
    var myImageCollection = [NSManagedObject]()
    var settingObject : NSManagedObject?
    var imagePaths = [String]()
    let isChoosing = false
    //MARK: IBOutlet
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var chooseButton: UIBarButtonItem!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    //MARK: IBAction
    @IBAction func chooseButton(sender: UIBarButtonItem) {
        if self.currentEditState == ProviderEditState.Normal{
            self.currentEditState = ProviderEditState.Choose
            chooseButton.title = "完成"
            shareButton.enabled = true
            deleteButton.enabled = true
            self.collectionView!.allowsSelection = true
            self.collectionView!.allowsMultipleSelection = true
            for cell in self.collectionView!.visibleCells() as! [CollectionViewCell]{
                cell.cellImage.userInteractionEnabled = false
            }
        }else{
            self.currentEditState = ProviderEditState.Normal
            chooseButton.title = "选择"
            shareButton.enabled = false
            deleteButton.enabled = false
            self.collectionView!.allowsMultipleSelection = false
            self.collectionView!.allowsSelection = false
            for cell in self.collectionView!.visibleCells() as! [CollectionViewCell]{
                cell.cellImage.userInteractionEnabled = true
            }
        }
    }
    
    @IBAction func chooseImageToDelete(sender: UIBarButtonItem) {
        var indexPath:[NSIndexPath] = self.collectionView!.indexPathsForSelectedItems()!
        if indexPath.count > 0 {
            if indexPath.count > 1{
                //冒泡排序
                for j in 1...indexPath.count - 1 {
                    for i in 0...indexPath.count - j - 1{
                        if indexPath[i].row < indexPath[i + 1].row {
                        let temp = indexPath[i]
                        indexPath[i] = indexPath[i + 1]
                        indexPath[i + 1] = temp
                        }
                    }
                }
            }
            let managedContext = getManagedContext()
            for path in indexPath {
                managedContext.deleteObject(myImageCollection[path.row])
                self.myImageCollection.removeAtIndex(path.row)
            }
            do {
                try managedContext.save()
            }catch let error as NSError {
                print("Could not save \(error), \(error.userInfo)")
            }
            self.collectionView!.performBatchUpdates({
                self.collectionView!.deleteItemsAtIndexPaths(indexPath)
                return
                }, completion: nil)
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
    @IBAction func addImage(sender: AnyObject) {
        let hour = settingObject!.valueForKey("updateCycle") as! Double
        let date = NSDate(timeInterval: -3600*hour, sinceDate: NSDate())
        let predicate:NSPredicate
        if hour == 0.0{
            predicate = NSPredicate(format: "creationDate < %@", date)
        }else{
            predicate = NSPredicate(format: "creationDate > %@", date)
        }
        let fetchOptions = PHFetchOptions()
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
                    let data = UIImageJPEGRepresentation(image!,1)
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
    //MARK: view
    override func viewDidLoad() {
        super.viewDidLoad()
        settingObject = initsettingObject()
        myImageCollection = fetchImageObject()
        shareButton.enabled = false
        deleteButton.enabled = false
        self.collectionView!.collectionViewLayout = getLayout()
        self.collectionView!.backgroundColor = UIColor(white: 0.95, alpha: 1)
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if settingObject!.hasChanges {
            saveToCoreData()
            self.collectionView!.collectionViewLayout = getLayout()
        }
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "share" {
            let controller = segue.destinationViewController as! ShareListTableViewController
            controller.indexPath = (self.collectionView!.indexPathsForSelectedItems())!
            controller.imageManagedObject = myImageCollection
        }
       
    }
    // MARK: UICollectionViewDataSource
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return myImageCollection.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("imageCell", forIndexPath: indexPath) as! CollectionViewCell
        // Configure the cell
        let imageURL = getImageURL(myImageCollection, indexPathRow: indexPath.row)
        
        cell.selectedBackgroundView = UIView.init()
        cell.selectedBackgroundView?.backgroundColor = UIColor(red: 0/255, green: 128/255, blue: 255/255, alpha: 1)
        
        cell.cellImage.setupForImageViewer(NSURL(string: imageURL)!, backgroundColor: UIColor.blackColor())
        cell.cellImage.image = getImage(imageURL)
        if(self.currentEditState == ProviderEditState.Normal){
            cell.cellImage.userInteractionEnabled = true
        }else{
            cell.cellImage.userInteractionEnabled = false
        }
        return cell
    }
    override func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
            cell.backgroundColor = UIColor(white: 0.95, alpha: 1)
    }

    //MARK: 自定义函数
    func cellSize(imageObj:[NSManagedObject],indexPathRow:Int)->CGSize{
        let imageURL = getImageURL(myImageCollection, indexPathRow: indexPathRow)
        let image = getImage(imageURL)
        let size = CGSize(width: image.size.width+4, height: image.size.height+4)
        return size
    }
    func getLayout()->CollectionViewWaterfallLayout{
        let layout = CollectionViewWaterfallLayout()
        layout.sectionInset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
        layout.headerInset = UIEdgeInsetsMake(20, 0, 0, 0)
        layout.headerHeight = 0
        layout.footerHeight = 0
        layout.columnCount = settingObject!.valueForKey("columnCount") as! Int
        layout.minimumColumnSpacing = 1
        layout.minimumInteritemSpacing = 1
        return layout
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
        if object.count > 0 {
            return object[0]
        }else{
            let entity = NSEntityDescription.entityForName("Setting", inManagedObjectContext:managedContext)
            let settingObject = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
            settingObject.setValue(1.0, forKey: "updateCycle")
            settingObject.setValue(3, forKey: "columnCount")
            do {
                try managedContext.save()
            }
            catch let error as NSError {
                print("Could not save \(error), \(error.userInfo)")
            }
            return settingObject
        }
        
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
    func longPressToShare(){
        shareButton.enabled = true
        let shareTableViewController = self.storyboard!.instantiateViewControllerWithIdentifier("shareTableViewController")
        shareTableViewController.popoverPresentationController?.sourceView = self.collectionView
        presentViewController(shareTableViewController,animated: true, completion:nil)
        
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
}
// MARK: WaterfallLayoutDelegate
extension CollectionViewController : CollectionViewWaterfallLayoutDelegate{
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return cellSize(myImageCollection,indexPathRow: indexPath.item)
    }
}