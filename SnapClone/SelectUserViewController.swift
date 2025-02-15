//
//  SelectUserViewController.swift
//  SnapClone
//
//  Created by Jack Howard on 7/4/17.
//  Copyright © 2017 JackHowa. All rights reserved.
//
import Alamofire
import UIKit
import FirebaseDatabase
import FirebaseAuth

class SelectUserViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var users : [User] = []
    
    // prep for segue getting those variable values
    var imageURL = ""
    
    // description can mess with swift
    var descrip = ""
    
    
    // need to keep on knowing the uuid of the photo url so that it will be associated with the message
    var uuid = ""
    
    var displayable = ""
    
    // show date
    // and time 
    var getAt = ""

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // using delegate to reference the table view outlet
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.title = "Contacts"
        
        // call the database of firebase
        // listen for db changes at a particular place or index
        // tell us about any childadded
        // want to know all of the new users that are added
        
        // child users is the header in the storage
        Database.database().reference().child("users").observe(DataEventType.childAdded, with: {(snapshot) in
            // returns object of each user 
            // called for each user
//            print(snapshot)
            
            // like calling new
            let user = User()
            
            // setting the values
            // forcing the value as well as the upcast to a string
            
            // need to cast snapshot.value as a NSDictionary.
            let value = snapshot.value as? NSDictionary
            
            user.email = value?["email"] as! String
            
            // snapshot dictionary doesn't have a key so can keep this
            user.uid = snapshot.key // assigns the uid
            
            // kind of like shovelling back into users
            self.users.append(user)
            
            self.tableView.reloadData()
        })
    }

    // add firebase users 
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // how many rows
        return users.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        // calling the cell at the index
        let user = users[indexPath.row]
        
        // assign the label of text
        cell.textLabel?.text = user.email
        
        // make cell a different color 
        // if date is too soon, then make a different color
        
        return cell
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // find user that was selected
        let user = users[indexPath.row]
        
        // need to make a dictionary 
        // gets descrip and image url from sender user input in the picture view 
        // sender should always be current user
        
        // update the get At time 
        // get at = d/M/yy 
        // via http://nsdateformatter.com/
        
        let message = ["from": Auth.auth().currentUser!.email!, "description": descrip, "image_url": imageURL, "uuid": uuid, "getAt": getAt]
        
        
//        let inputFormatter = DateFormatter()
//        inputFormatter.dateFormat = "MM/dd/yy"
//        let showDate = inputFormatter.date(from: getAt)
//        inputFormatter.dateFormat = "yyyy-MM-dd"
//        let deliver_at = inputFormatter.string(from: showDate!)
//        
//        
//        let parameters: Parameters = [
//            "caption": descrip,
//            "image_url": imageURL,
//            "sender_id": "9",
//            "receiver_id": "9",
//            "deliver_at": deliver_at,
////           "deliver_at": "07-09-2017",
////            "deliverable": displayable
//        ]
//        
//        
//        let headers: HTTPHeaders = ["Accept": "application/json", "Content-Type" :"application/json"]
//        
//        Alamofire.request("https://aqueous-waters-34203.herokuapp.com/messages", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
//            
//            // original URL request
//            print("Request :", response.request!)
//            
//            // HTTP URL response --> header and status code
//            print("Response received is :", response.response as Any)
//            
//            // server data : example 267 bytes
//            print("Response data is :", response.data!)
//            
//            // result of response serialization : SUCCESS / FAILURE
//            print("Response result is :", response.result)
//            
//            debugPrint("Debug Print :", response)
//        }
        
        
        // child by auto id is a firebase function that prevents reuse of id and makes unique
        // add the message to the set value
        Database.database().reference().child("users").child(user.uid).child("messages").childByAutoId().setValue(message)
        
        // after selecting a row, go back to the root to see any remaining messages
        // need this pop back after viewing
        navigationController!.popToRootViewController(animated: true)

    }
}
