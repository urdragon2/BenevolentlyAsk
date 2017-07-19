//
//  AsksTableViewController.swift
//  BenevolentlyAsk
//
//  Created by Dwayne Kurfirst on 3/31/17.
//  Copyright © 2017 kurfirstcorp. All rights reserved.
//

import UIKit

class AsksTableViewController: UITableViewController, UITextViewDelegate {
    var Asks = [asks]()
    var id = ""
    let prefs = UserDefaults.standard
    var limit = "100"
    var offset = "0"
    var myreport : String = ""
    var pinfillView = UIView()
    var popuptext = UITextView()
    override func viewDidLoad() {
        super.viewDidLoad()
        id = prefs.string(forKey: "id")!
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        loadAsks()
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl?.addTarget(self, action: #selector(AsksTableViewController.loadAsks), for: UIControlEvents.valueChanged)
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
        return Asks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "AsksTableViewCell"
        let cell = self.tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! AsksTableViewCell
        let ask = Asks[indexPath.row]
        cell.username.text = ask.username
        cell.date.text = ask.date
        cell.ask.self.textContainer.lineFragmentPadding = 0;
        cell.ask.textContainerInset = UIEdgeInsets.zero;
        cell.ask.text = ask.ask
        cell.believes.text = ask.counts + " Believes"
        if ask.myid == id
        {
            cell.believe.setTitleColor(UIColor.black, for: .normal)
        }
        else
        {
            cell.believe.setTitleColor(self.view.tintColor, for: .normal)
        }
        cell.believe.addTarget(self, action: #selector(ibelieveaction(sender:)), for: .touchDown)
        cell.believe.tag = Int(ask.askid)!
        cell.delete.tag = Int(ask.askid)!
        cell.delete.accessibilityHint = String(indexPath.row)
        cell.delete.addTarget(self, action: #selector(deleteactionAlert(sender:)), for: .touchDown)
        cell.report.tag = Int(ask.userid)!
        cell.report.accessibilityHint = String(indexPath.row)
        cell.report.addTarget(self, action: #selector(reportactionAlert(sender:)), for: .touchDown)
        return cell
    }

    func reportactionAlert(sender: UIButton) {
        var userid : String
        userid = String(sender.tag)
        var rowid : Int
        rowid = Int(sender.accessibilityHint!)!
        let alert = UIAlertController(title: "Report User", message: "How would you like to Report this user?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
        alert.addAction(UIAlertAction(title: "Spam or Scam or Fake", style: UIAlertActionStyle.default, handler:{ action in
            self.myreport = "Spam or Scam or Fake"
            self.reportaction(userid: userid, rowid:rowid)
        }))
        alert.addAction(UIAlertAction(title: "Inapproprate Information", style: UIAlertActionStyle.default, handler:{ action in
            self.myreport = "Inapproprate Information"
            self.reportaction(userid: userid, rowid:rowid)
        }))
        alert.addAction(UIAlertAction(title: "Harassment", style: UIAlertActionStyle.default, handler:{ action in
            self.myreport = "Harassment, Bullying or Annoying Behavior"
            self.reportaction(userid: userid, rowid:rowid)
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func reportaction(userid : String, rowid : Int) {
        var request = URLRequest(url: URL(string: SERVER + "/reportuser.php")!)
        request.httpMethod = "POST"
        var postString = "auth_user="+ADMINILOGIN
        postString += "&auth_password="+ADMINIPASSWORD
        postString += "&myid="+id
        postString += "&userid="+userid
        postString += "&report="+myreport
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
                        //if let convertedJsonIntoDict = try JSONSerialization.jsonObject(with: data, options: []) as? NSArray {
                        if (try JSONSerialization.jsonObject(with: data, options: []) as? NSArray) != nil {
                            OperationQueue.main.addOperation {
                                self.Asks.remove(at: rowid)
                                self.tableView.reloadData()
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

    
    func deleteactionAlert(sender: UIButton) {
        var askid : String
        askid = String(sender.tag)
        var rowid : Int
        rowid = Int(sender.accessibilityHint!)!
        let alert = UIAlertController(title: "Delete", message: "Are you sure you want to delete this post?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:{ action in
            self.deleteaction(askid: askid, rowid:rowid)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func deleteaction(askid : String, rowid : Int) {
        var request = URLRequest(url: URL(string: SERVER + "/deleteuserconn.php")!)
        request.httpMethod = "POST"
        var postString = "auth_user="+ADMINILOGIN
        postString += "&auth_password="+ADMINIPASSWORD
        postString += "&id="+id
        postString += "&askid="+askid
        //print(postString)
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
                        //if let convertedJsonIntoDict = try JSONSerialization.jsonObject(with: data, options: []) as? NSArray {
                        if (try JSONSerialization.jsonObject(with: data, options: []) as? NSArray) != nil {
                            OperationQueue.main.addOperation {
                                self.dialogOK("Thank you!", newmessage: "This user has been deleted from yoru connections.")
                                OperationQueue.main.addOperation {
                                    self.Asks.remove(at: rowid)
                                    self.tableView.reloadData()
                                }
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

    
    func ibelieveaction(sender: UIButton) {
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
        
        var request = URLRequest(url: URL(string: SERVER + "/ibelieveaction.php")!)
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
    

    
    func loadAsks() {
        Asks.removeAll()
        self.tableView.reloadData()
        var request = URLRequest(url: URL(string: SERVER + "/asks.php")!)
        request.httpMethod = "POST"
        var postString = "auth_user="+ADMINILOGIN
        postString += "&auth_password="+ADMINIPASSWORD
        postString += "&limit="+limit
        postString += "&id="+id
        postString += "&offset="+offset
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
                        self.dialogOK("No Results", newmessage: "There is no user on our system with that email address.")
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
                                let myid = item["myid"] as? String
                                let MyAsk = asks(userid: userid!,  askid: askid!, username: username!, ask:ask!, date:date!, counts: counts!, myid:myid!)!
                                self.Asks.append(MyAsk)
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

    @IBAction func addaction(_ sender: UIBarButtonItem) {
        
        let pinpopupView = UIView()

        pinfillView.isUserInteractionEnabled = true
        pinfillView.frame = CGRect(x:0, y:0, width: view.frame.width, height: view.frame.height)
        pinfillView.backgroundColor = UIColor.lightGray
        pinpopupView.isUserInteractionEnabled = true
        pinpopupView.frame = CGRect(x: pinfillView.frame.width/5, y: pinfillView.frame.height/3, width: view.frame.width/1.5, height: view.frame.height/5)
        pinpopupView.layer.borderWidth = 1
        pinpopupView.backgroundColor = UIColor.white
        
        let popuplabel: UILabel = UILabel()
        popuplabel.frame = (frame: CGRect(x:10, y:0, width: pinpopupView.frame.width, height: 20))
        popuplabel.textColor = UIColor.black
        popuplabel.font = popuplabel.font.withSize(10)
        popuplabel.textAlignment = NSTextAlignment.left
        popuplabel.text = "Ask"
        pinpopupView.addSubview(popuplabel)
        
        
        popuptext.frame = (frame: CGRect(x:10, y:30, width: pinpopupView.frame.width - 20, height: 60))
        popuptext.textColor = UIColor.lightGray
        popuptext.font = popuplabel.font.withSize(10)
        popuptext.textAlignment = NSTextAlignment.left
        popuptext.text = "I Benevolently Ask..."
        popuptext.layer.cornerRadius = 5
        popuptext.layer.borderWidth = 1
        popuptext.delegate = self
        popuptext.layer.borderColor = UIColor.black.cgColor
        popuptext.tag = 1
        pinpopupView.addSubview(popuptext)
        
        let popupbuttonCancel = UIButton(type: .system)
        popupbuttonCancel.frame = (frame: CGRect(x: 10, y: 100, width: pinpopupView.frame.width/2, height: 25))
        popupbuttonCancel.setTitle("Cancel", for: .normal)
        popupbuttonCancel.addTarget(self, action: #selector(self.buttonactioncancel(sender:)), for: .touchDown)
        pinpopupView.addSubview(popupbuttonCancel)
        
        
        let popupbuttonOK = UIButton(type: .system)
        popupbuttonOK.frame = (frame: CGRect(x: pinpopupView.frame.width/2, y: 100, width: pinpopupView.frame.width/2, height: 25))
        popupbuttonOK.setTitle("OK", for: .normal)
        popupbuttonOK.addTarget(self, action: #selector(self.buttonactionOK(sender:)), for: .touchDown)
        pinpopupView.addSubview(popupbuttonOK)
        
        pinfillView.addSubview(pinpopupView)
        
        
        view.addSubview(pinfillView)
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            if textView.tag == 1
            {
                textView.text = "I Benevolently Ask..."
            }
            textView.textColor = UIColor.lightGray
        }
    }
    
    func buttonactionOK(sender: UIButton) {
        var request = URLRequest(url: URL(string: SERVER + "/insertask.php")!)
        request.httpMethod = "POST"
        var postString = "auth_user="+ADMINILOGIN
        postString += "&auth_password="+ADMINIPASSWORD
        postString += "&id="+id
        postString += "&myask="+popuptext.text
        //print("postString = " + postString)
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
                        //if let convertedJsonIntoDict = try JSONSerialization.jsonObject(with: data, options: []) as? NSArray {
                        if (try JSONSerialization.jsonObject(with: data, options: []) as? NSArray) != nil {
                            OperationQueue.main.addOperation {
                                self.loadAsks()
                                //self.tableView.reloadData()
                                //self.refreshControl?.endRefreshing()
                                self.pinfillView.removeFromSuperview()
                                self.dialogOK("You asked.", newmessage: "Believe and Receive.")
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
    
    func buttonactioncancel(sender: UIButton) {
        self.pinfillView.removeFromSuperview()
    }
}
