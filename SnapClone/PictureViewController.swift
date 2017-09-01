//
//  PictureViewController.swift
//  SnapClone
//
//  Created by Jack Howard on 7/3/17.
//  Copyright © 2017 JackHowa. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

// need specific firebase storage
// via https://stackoverflow.com/questions/38561257/swift-use-of-unresolved-identifier-firstorage

import FirebaseStorage

class PictureViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
//    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var descriptionTextField: UITextField!
    
    // need to make a new ib outlet for displayable to be timefield
    
    @IBOutlet weak var datePickerText: UITextField!
    
    // new for adding the email address
    @IBOutlet weak var toTextField: UITextField!
    
    
    
    let datePicker = UIDatePicker()
    
    var getAtTime = ""
    
    var rawTime = ""
    
    // need to persist this unique photo id across scenes to delete from db
    var uuid = NSUUID().uuidString
    
    var imagePicker = UIImagePickerController()
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        sendButton.isEnabled = false
        createDatePicker()
        
        // don't show toolbar
        self.navigationController?.setToolbarHidden(true, animated: true)

    }
    
    // view will or did appear may account for ui changes 
    //
    
    func textFieldDidEndEditing() {
        if datePickerText.hasText && toTextField.hasText && descriptionTextField.hasText {
            sendButton.isEnabled = true
        }
    }
    
    
    
    @IBAction func tappedGestureAnywhere(_ sender: Any) {
        descriptionTextField.resignFirstResponder()
        datePickerText.resignFirstResponder()
        
        // update so that to responds as well to tap outside
        toTextField.resignFirstResponder()
    }
    
    func createDatePicker() {
        
        // format picker 
        // for only date
//        datePicker.datePickerMode = .date
        
        // toolbar
        let toolbar = UIToolbar()
        
        // fit to screen
        toolbar.sizeToFit()
        
        // create done button icon
        // action is the function that will be called
        // selector ends the assignment to the textfield
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        
        toolbar.setItems([doneButton], animated: true)
        
        datePickerText.inputAccessoryView = toolbar
        
        // assign the datepicker to text field
        datePickerText.inputView = datePicker
        
    }
    
    func donePressed() {
        
        // format 
        // dateformatter object
        var dateFormatter = DateFormatter()
        
        // shortened date show
//        dateFormatter.dateStyle = .short
//        dateFormatter.timeStyle = .none
        
        
        print("this is output of datepicker")
        print(datePicker.date)
        // 2017-08-03 20:57:21 +0000
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
    
        
        
        
        rawTime = dateFormatter.string(from: datePicker.date)
        print("this is output of rawtime")
        print(rawTime)
        
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        // datePicker date is a certain style
        
        
        getAtTime = dateFormatter.string(from: datePicker.date)
        
        print(getAtTime)
        
        // assign input text of the returned datePicker var
        datePickerText.text = getAtTime
        
        // check whether able to send
        textFieldDidEndEditing()

        // close picker view
        self.view.endEditing(true)
    }
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // can also use edited image
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        // setting the image to the view
        imageView.image = image
        
        imageView.backgroundColor = UIColor.clear
        
        // can now click next button 
        // testing and debugging
        // authorization
        
        // send button is enabled to early here
        // sendButton.isEnabled = true
        
        // check whether able to send
        textFieldDidEndEditing()
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tappedCamera(_ sender: Any) {
        // for testing we're going to pick one
//        imagePicker.sourceType = .savedPhotosAlbum
        // should be camera
        
        imagePicker.sourceType = .camera
        
        
        // would muck up the ui if allowed editing
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func tappedLibraryPlus(_ sender: Any) {
        // for testing we're going to pick one
        imagePicker.sourceType = .savedPhotosAlbum
        // should be camera
        
        //        imagePicker.sourceType = .camera
        
        
        // would muck up the ui if allowed editing
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    func displayAlertMessage(userMessage:String)
    {
        let myAlert = UIAlertController(title:"Alert", message: userMessage, preferredStyle: UIAlertControllerStyle.alert);
        
        let okAction = UIAlertAction(title:"OK", style: UIAlertActionStyle.default, handler:nil);
        
        myAlert.addAction(okAction);
        self.present(myAlert, animated:true, completion:nil);
    }
    
    
    
    @IBAction func tappedSend(_ sender: Any) {
        sendButton.isEnabled = false
        
        let imagesFolder = Storage.storage().reference().child("images")
        
        // turns image into data
        // bang to know that image exists
        // higher compression of 0.1 vs a png
        let imageData = UIImageJPEGRepresentation(imageView.image!, 0.1)!
        
        // upload to firebase
        
        // uu id unique
        imagesFolder.child("\(uuid).jpg").putData(imageData, metadata: nil, completion: { (metadata, error) in
//            print("we're trying to upload")
            if error != nil {
//                print("We had an error: \(String(describing: error))")
            } else {
                // perform segue upon no error next tap upload
                // absolute designates the value as a string
                
                // loading the message for upload into db
                let message = ["from": Auth.auth().currentUser!.email!, "description": self.descriptionTextField.text!, "image_url": metadata?.downloadURL()?.absoluteString, "uuid": self.uuid, "getAt": self.rawTime]
                
                
                
                // ok need to find the user based on the email
                let userEmail = self.toTextField.text!
                
                let ref = Database.database().reference().child("users").queryOrdered(byChild: "email").queryEqual(toValue: userEmail)
                ref.observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    for snap in snapshot.children {
                        let userSnap = snap as! DataSnapshot
                        let uid = userSnap.key //the uid of each user
//                        print("key = \(uid)")
                        
                        Database.database().reference().child("users").child(uid).child("messages").childByAutoId().setValue(message)
                    
                    }
                    
                    
                    guard snapshot.value is NSNull else {
                        //yes we got the user
                        let user = snapshot
//                        print("\(user)  exists" )
                        
                        // after selecting a row, go back to the root to see any remaining messages
                        // need this pop back after viewing
                        self.navigationController!.popToRootViewController(animated: true)

                        return
                    }
                    
                    
                    //no there is no user with desired email
//                    print("\(userEmail) isn't a user")
                    self.displayAlertMessage(userMessage: "User doesn't exist")
                    
                    
                    
                })
                { (error) in
//                    print("Failed to get snapshot", error.localizedDescription)

                }
                


            }
        })
    }
   
}
