//
//  shareListTableViewController.swift
//  MyGraphics
//
//  Created by Linsw on 16/1/22.
//  Copyright © 2016年 Linsw. All rights reserved.
//

import UIKit

class ShareListTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

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
        return 1
        
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 2
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("shareListCell", forIndexPath: indexPath) as! ShareListTableViewCell
        switch indexPath.row {
        case 0: cell.cellLabel.text = "分享给朋友"
        case 1: cell.cellLabel.text = "分享到朋友圈"
        default: break
        }
        // Configure the cell...
        return cell
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.row {
        case 0: share(0)
        case 1: share(1)
        default: break
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func share(kind:Int32){
        
        //创建分享内容对象
        let urlMessage = WXMediaMessage.init()
        urlMessage.title = "fenxiang"//分享标题
        urlMessage.description = "MIAOSHU"//分享描述
        urlMessage.setThumbImage(UIImage(named: "shareRed"))//分享图片,使用SDK的setThumbImage方法可压缩图片大小
        //创建图片对象
        let imageObject = WXImageObject.init()
//        let imagePath:String
//        imageObject.imageData = NSData(contentsOfFile: imagePath)
        //完成发送对象实例
        urlMessage.mediaObject = imageObject;
        
        //创建发送对象实例
        let sendReq=SendMessageToWXReq()
        sendReq.bText = false;//不使用文本信息
        sendReq.scene = kind;//0 = 好友列表 1 = 朋友圈 2 = 收藏
        sendReq.message = urlMessage;
        
        //发送分享信息
        WXApi.sendReq(sendReq)
    }
}
