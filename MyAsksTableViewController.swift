//
//  MyAsksTableViewController.swift
//  BenevolentlyAsk
//
//  Created by Dwayne Kurfirst on 3/31/17.
//  Copyright © 2017 kurfirstcorp. All rights reserved.
//

import UIKit

class MyAsksTableViewController: UITableViewController {
    var MyAsk = [MyAsks]()
    var id = ""
    let prefs = UserDefaults.standard
    var limit = "100"
    var offset = "0"
    override func viewDidLoad() {
        super.viewDidLoad()
        id = prefs.string(forKey: "id")!
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        loadMyAsks()
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl?.addTarget(self, action: #selector(loadMyAsks), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl!)
    }
    func dialogOK(_ newtitle: String, newmessage: String){
        let alert = UIAlertController(title: newtitle, message: newmessage, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return MyAsk.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "MyAsksTableViewCell"
        let cell = self.tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! MyAsksTableViewCell
        let ask = MyAsk[indexPath.row]
        cell.username.text = ask.username
        cell.date.text = ask.date
        cell.ask.self.textContainer.lineFragmentPadding = 0;
        cell.ask.textContainerInset = UIEdgeInsets.zero;
        cell.ask.text = ask.ask
        cell.believes.text = ask.counts + " Believes"
        if ask.received == "1"
        {
            cell.received.setTitleColor(UIColor.black, for: .normal)
        }
        else
        {
            cell.received.setTitleColor(self.view.tintColor, for: .normal)
        }
        cell.received.addTarget(self, action: #selector(receiveaction(sender:)), for: .touchDown)
        cell.received.tag = Int(ask.askid)!
        return cell
    }
    
    func receiveaction(sender: UIButton) {
        var believechoice : String
        if sender.currentTitleColor == UIColor.black
        {
            sender.setTitleColor(self.view.tintColor, for: .normal)
            believechoice = "0"
        }else
        {
            sender.setTitleColor(UIColor.black, for: .normal)
            believechoice = "1"
        }
        var myaskid : String
        myaskid = String(sender.tag)
        
        var request = URLRequest(url: URL(string: SERVER + "/receivedaction.php")!)
        request.httpMethod = "POST"
        var postString = "auth_user="+ADMINILOGIN
        postString += "&auth_password="+ADMINIPASSWORD
        postString += "&id="+id
        postString += "&myaskid="+myaskid
        postString += "&believechoice="+believechoice
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                //print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                //print("statusCode should be 200, but is \(httpStatus.statusCode)")
                //print("response = \(response)")
            }else{
                
                let responseString = String(data: data, encoding: .utf8)
                //print("responseString = " + responseString!)
                if responseString == "null"
                {
                    OperationQueue.main.addOperation {
                        self.dialogOK("Error", newmessage: "Please try again")
                    }
                }
                else
                {
                    do {
                        
                    } catch let error as NSError {
                        print(error)
                    }
                }
            }
        }
        
        task.resume()
    }
    
    func loadMyAsks() {
        MyAsk.removeAll()
        self.tableView.reloadData()
        var request = URLRequest(url: URL(string: SERVER + "/myasks.php")!)
        request.httpMethod = "POST"
        var postString = "auth_user="+ADMINILOGIN
        postString += "&auth_password="+ADMINIPASSWORD
        postString += "&limit="+limit
        postString += "&id="+id
        postString += "&offset="+offset
        print(postString)
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                //print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                //print("statusCode should be 200, but is \(httpStatus.statusCode)")
                //print("response = \(response)")
            }else{
                
                let responseString = String(data: data, encoding: .utf8)
                if responseString == "null"
                {
                    OperationQueue.main.addOperation {
                        self.dialogOK("No Results", newmessage: "TPlease my some Benevolently asks.")
                    }
                }
                else
                {
                    
                    do {
                        
                        if let convertedJson = try JSONSerialization.jsonObject(with: data, options: []) as? [[String:Any]] {
                            //print(convertedJson)
                            for item in convertedJson {
                                let userid = item["userid"] as? String
                                let askid = item["askid"] as? String
                                let username = item["username"] as? String
                                let ask = item["ask"] as? String
                                let date = item["date"] as? String
                                let counts = item["counts"] as? String
                                let received = item["received"] as? String
                                
                                let MyAsk = MyAsks(userid: userid!,  askid: askid!, username: username!, ask:ask!, date:date!, counts: counts!, received:received!)!
                                self.MyAsk.append(MyAsk)
                            }
                            OperationQueue.main.addOperation {
                                self.tableView.reloadData()
                                self.refreshControl?.endRefreshing()
                            }
                        }
                        else{
                            //print("here")
                        }
                        
                    } catch let error as NSError {
                        print(error)
                    }
                }
            }
        }
        
        task.resume()
    }
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
