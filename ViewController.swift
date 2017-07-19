//
//  ViewController.swift
//  BenevolentlyAsk
//
//  Created by Dwayne Kurfirst on 3/25/17.
//  Copyright © 2017 kurfirstcorp. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var emailtext: UITextField!
    
    @IBOutlet weak var passwordtext: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.applicationIconBadgeNumber = 0
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let prefs = UserDefaults.standard
        if let email = prefs.string(forKey: "email")
        {
            emailtext.text = email
        }
        if let password = prefs.string(forKey: "password")
        {
            passwordtext.text = password
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func loginbutton(_ sender: UIButton) {
        if emailtext.text != "" && passwordtext.text != ""
        {
            let hexDigest = sha512Hex(passwordtext.text!)
            let shaHex =  hexDigest.map { String(format: "%02hhx", $0) }.joined()
            var request = URLRequest(url: URL(string: SERVER + "/auth.php")!)
            request.httpMethod = "POST"
            var postString = "auth_user="+ADMINILOGIN
            postString += "&auth_password="+ADMINIPASSWORD
            postString += "&login="+emailtext.text!
            postString += "&password="+shaHex
            let prefs = UserDefaults.standard
            let token = prefs.string(forKey: "token")
            postString += "&mytoken="+token!
            postString += "&device=IOS"
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
                            self.dialogOKCancel("Login Incorrect", newmessage: "Your username and/or password do not match our records. Please try again.")
                        }
                    }
                    else
                    {
                        do {
                            
                            if let convertedJsonIntoDict = try JSONSerialization.jsonObject(with: data, options: []) as? NSArray {
                                
                                // Print out dictionary
                                //print(convertedJsonIntoDict)
                                
                                // Get value by key
                                let id = (convertedJsonIntoDict[0] as! NSDictionary)["id"] as? String
                                let username = (convertedJsonIntoDict[0] as! NSDictionary)["username"] as? String
                                let email = (convertedJsonIntoDict[0] as! NSDictionary)["email"] as? String
                                let EULA = (convertedJsonIntoDict[0] as! NSDictionary)["EULA"] as? String
                                let prefs = UserDefaults.standard
                                prefs.setValue(id, forKey: "id")
                                prefs.setValue(EULA, forKey: "EULA")
                                prefs.setValue(username, forKey: "username")
                                prefs.setValue(email, forKey: "email")
                                prefs.setValue(self.passwordtext.text!, forKey: "password")
                                DispatchQueue.main.async() { () -> Void in
                                    self.performSegue(withIdentifier: "loginsegue", sender: self)
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
        else
        {
            self.dialogOKCancel("Credentials needed", newmessage: "Please put your login and password in the proper fields.")
        }
    }

    @IBAction func forgotpasswordbutton(_ sender: UIButton) {
        if emailtext.text != ""
        {
            var passwordmash = ""
            var chars: [String] = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"]
            var nums: [String] = ["0","1","2","3","4","5","6","7","8","9"]
            var specials: [String] = ["1","@","#","$","%"]
            passwordmash = chars[Int(arc4random_uniform(24))]
            passwordmash += chars[Int(arc4random_uniform(24))]
            passwordmash += chars[Int(arc4random_uniform(24))]
            passwordmash += chars[Int(arc4random_uniform(24))]
            passwordmash += chars[Int(arc4random_uniform(24))]
            passwordmash += nums[Int(arc4random_uniform(9))]
            passwordmash += specials[Int(arc4random_uniform(5))]
            //print(passwordmash)
            let hexDigest = sha512Hex(passwordmash)
            let shaHex =  hexDigest.map { String(format: "%02hhx", $0) }.joined()
            print("hexDigest:\n\(shaHex)")
            var request = URLRequest(url: URL(string: SERVER + "/forgotemail.php")!)
            request.httpMethod = "POST"
            var postString = "auth_user="+ADMINILOGIN
            postString += "&auth_password="+ADMINIPASSWORD
            postString += "&login="+emailtext.text!
            postString += "&password="+shaHex
            postString += "&clearpassword="+passwordmash
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
                            self.dialogOKCancel("Error", newmessage: "That email does not exist on our system")
                        }
                    }
                    else
                    {
                        do {
                            
                            if (try JSONSerialization.jsonObject(with: data, options: []) as? NSArray) != nil {
                                
                                // Print out dictionary
                                //print(convertedJsonIntoDict)
                                
                                // Get value by key
                                let prefs = UserDefaults.standard
                                prefs.setValue(passwordmash, forKey: "password")
                                //print("here = \(username!)")
                                OperationQueue.main.addOperation {
                                    self.dialogOKCancel("Your new password", newmessage: "Please check your email. Your new password has been sent to you.")
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
            
        }else
        {
            self.dialogOKCancel("Email needed", newmessage: "Please put the email you regististered with in the login field.")
            
        }

    }

func dialogOKCancel(_ newtitle: String, newmessage: String){
    let alert = UIAlertController(title: newtitle, message: newmessage, preferredStyle: UIAlertControllerStyle.alert)
    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
    self.present(alert, animated: true, completion: nil)
}

func sendtolanding() {
    //print("here")
    performSegue(withIdentifier: "loginsegue", sender: self)
}


func sha512Hex(_ string: String) -> Data {
    var hash = Data(count: Int(CC_SHA512_DIGEST_LENGTH))
    if let newData: Data = string.data(using: .utf8) {
        _ = hash.withUnsafeMutableBytes {mutableBytes in
            newData.withUnsafeBytes {bytes in
                CC_SHA512(bytes, CC_LONG(newData.count), mutableBytes)
            }
        }
    }
    
    return hash
    

}

}
