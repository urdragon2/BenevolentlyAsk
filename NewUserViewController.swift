//
//  NewUserViewController.swift
//  BenevolentlyAsk
//
//  Created by Dwayne Kurfirst on 3/31/17.
//  Copyright © 2017 kurfirstcorp. All rights reserved.
//

import UIKit

class NewUserViewController: UIViewController {

    @IBOutlet weak var usernametext: UITextField!
    
    @IBOutlet weak var passwordtext: UITextField!
    
    @IBOutlet weak var emailtext: UITextField!
    
    var message: String = ""
    var emailbool: Bool = false
    var mytoken : String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        let prefs = UserDefaults.standard
        if let token = prefs.string(forKey: "token")
        {
            mytoken = token
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

    @IBAction func Save(_ sender: UIBarButtonItem) {
        message = ""
        let enteredEmail = emailtext.text
        var request = URLRequest(url: URL(string: SERVER + "/checkuseremail.php")!)
        request.httpMethod = "POST"
        var postString = "auth_user="+ADMINILOGIN
        postString += "&auth_password="+ADMINIPASSWORD
        postString += "&email="+enteredEmail!
        request.httpBody = postString.data(using: .utf8)
        //print(postString)
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
                        self.emailbool = true
                        self.myvalidate()
                        
                    }
                    
                }
                else
                {
                    OperationQueue.main.addOperation {
                        self.emailbool = false
                        self.emailtext.layer.borderWidth = 3
                        self.emailtext.layer.borderColor = UIColor.red.cgColor
                        self.message += "\"Email already in use. Please choose another.\" "
                        self.myvalidate()
                    }
                }
                
            }
        }
        
        task.resume()
    }
    
    func myvalidate()
    {
        let  enteredUsername = usernametext.text
        let enteredEmail = emailtext.text
        let enteredPassword = passwordtext.text
        let hexDigest = sha512Hex(enteredPassword!)
        let shaHex =  hexDigest.map { String(format: "%02hhx", $0) }.joined()
        if  emailbool && validateEmail(enteredEmail!) && validatePassword(enteredPassword!) && validateUsername(enteredUsername!)
        {
            var request = URLRequest(url: URL(string: SERVER + "/newuser.php")!)
            request.httpMethod = "POST"
            var postString = "auth_user="+ADMINILOGIN
            postString += "&auth_password="+ADMINIPASSWORD
            postString += "&username="+enteredUsername!
            postString += "&email="+enteredEmail!
            postString += "&mytoken="+mytoken
            postString += "&password="+shaHex
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
                            self.dialogOKCancel("Error", newmessage: "Please try again")
                        }
                    }
                    else
                    {
                        do {
                            
                            if let convertedJsonIntoDict = try JSONSerialization.jsonObject(with: data, options: []) as? NSArray {
                                
                                // Print out dictionary
                                //print(convertedJsonIntoDict)
                                
                                // Get value by key
                                let prefs = UserDefaults.standard
                                let id = (convertedJsonIntoDict[0] as! NSDictionary)["id"] as? String
                                let username = (convertedJsonIntoDict[0] as! NSDictionary)["username"] as? String
                                let email = (convertedJsonIntoDict[0] as! NSDictionary)["email"] as? String
                                prefs.setValue(id, forKey: "id")
                                prefs.setValue(username, forKey: "username")
                                prefs.setValue(email, forKey: "email")
                                prefs.setValue("0", forKey: "EULA")
                                prefs.setValue(self.passwordtext.text!, forKey: "password")
                                //print("here = \(username!)")
                                DispatchQueue.main.async() { () -> Void in
                                    self.performSegue(withIdentifier: "newuserlogin", sender: self)
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
            if !validateUsername(enteredUsername!)
            {
                usernametext.layer.borderWidth = 3
                usernametext.layer.borderColor = UIColor.red.cgColor
                message += "\"Username is only alphabetic dashes and spaces\" "
            }
            
            
            if !validateEmail(enteredEmail!)
            {
                emailtext.layer.borderWidth = 3
                emailtext.layer.borderColor = UIColor.red.cgColor
                message += "\"Please put in a proper Email\" "
            }
            if !validatePassword(enteredPassword!)
            {
                passwordtext.layer.borderWidth = 3
                passwordtext.layer.borderColor = UIColor.red.cgColor
                message += "\"Password must be alphabetic, one number, contain one special char !@#$%,and be over 6 characters long\" "
            }
            self.dialogOKCancel("Sign up Issues", newmessage: message)
        }
        
    }
    
    @IBAction func usernamechange(_ sender: UITextField) {
        usernametext.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
        usernametext.layer.borderWidth = 1.0
        usernametext.layer.cornerRadius = 5
    }
    
    @IBAction func passwordchange(_ sender: UITextField) {
        passwordtext.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
        passwordtext.layer.borderWidth = 1.0
        passwordtext.layer.cornerRadius = 5
    }
    
    @IBAction func emailchange(_ sender: UITextField) {
        emailtext.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
        emailtext.layer.borderWidth = 1.0
        emailtext.layer.cornerRadius = 5
    }
    
    
    
    
    func validateUsername(_ enteredUsername:String) -> Bool {
        
        let UsernameFormat = "[a-zA-Z0-9- ]{1,}"
        let UsernamePredicate = NSPredicate(format:"SELF MATCHES %@", UsernameFormat)
        return UsernamePredicate.evaluate(with: enteredUsername)
        
    }
    func validateEmail(_ enteredEmail:String) -> Bool {
        
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: enteredEmail)
        
    }
    
    func validatePassword(_ enteredPassword:String) -> Bool {
        
        let passwordFormat = "(?=(.*\\d){1})(?=.*[a-zA-Z])(?=.*[!@#$%])[0-9a-zA-Z!@#$%]{6,}"
        let passwordPredicate = NSPredicate(format:"SELF MATCHES %@", passwordFormat)
        return passwordPredicate.evaluate(with: enteredPassword)
        
    }
    
    
    func dialogOKCancel(_ newtitle: String, newmessage: String){
        let alert = UIAlertController(title: newtitle, message: newmessage, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
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
