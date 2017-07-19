//
//  LandingViewController.swift
//  BenevolentlyAsk
//
//  Created by Dwayne Kurfirst on 4/3/17.
//  Copyright © 2017 kurfirstcorp. All rights reserved.
//

import UIKit

class LandingViewController: UIViewController {
    var id = ""
    let prefs = UserDefaults.standard
    var currentbadge : Int = 0
    var mytoken : String = ""
    var EULA : String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        id = prefs.string(forKey: "id")!
        EULA = prefs.string(forKey: "EULA")!
        if EULA == "0"
        {
            self.dialogOKCancel(newtitle: "End User Licensing Agreement", newmessage: "By clicking OK, you agree to this End User Licensing Agreement and privacy agreement found at http://kurfirstcorp.com/BenevolentlyAsk/privacy.php. You also agree that there is no tolerance for any objectionable content or abusive harassment nature on this app at any time.")
        }
        
        if let token = prefs.string(forKey: "token")
        {
            mytoken = token
        }
        if mytoken != "0"
        {
            //_ = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.getnotifications), userInfo: nil, repeats: true);
        }
        else{
            self.dialogOK(newtitle: "Notification error", newmessage: "In order to get messages from people in real time notifications have to be turned on. Thank you")
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func buttonaction() {
        var request = URLRequest(url: URL(string: SERVER + "/updateEULA.php")!)
        request.httpMethod = "POST"
        var postString = "auth_user="+ADMINILOGIN
        postString += "&auth_password="+ADMINIPASSWORD
        postString += "&id="+id
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
                print("responseString = " + responseString!)
                if responseString == "null"
                {
                    OperationQueue.main.addOperation {
                        self.dialogOK(newtitle: "Error", newmessage: "Please try again")
                    }
                }
                else
                {
                    do {
                        
                        if (try JSONSerialization.jsonObject(with: data, options: []) as? NSArray) != nil {
                            self.dialogOK(newtitle: "Thank you!", newmessage: "You can now use Benevolently Ask.")
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
    
    func dialogOK(newtitle: String, newmessage: String){
        let alert = UIAlertController(title: newtitle, message: newmessage, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func dialogOKCancel(newtitle: String, newmessage: String){
        let alert = UIAlertController(title: newtitle, message: newmessage, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:{ action in
            self.buttonaction()
        }))
        
        
        self.present(alert, animated: true, completion: nil)
    }
}
