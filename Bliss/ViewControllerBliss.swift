//
//  ViewControllerMainScreen.swift
//  Bliss
//
//  Created by Andrew Solesa on 2020-02-05.
//  Copyright © 2020 KSG. All rights reserved.
//

import UIKit

class ViewControllerBliss: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate
{
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var zipCodeTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var stateTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var cardNumberTextField: UITextField!
    @IBOutlet weak var nameOnCardTextField: UITextField!
    @IBOutlet weak var monthYearTextField: UITextField!
    @IBOutlet weak var cvvTextField: UITextField!
    @IBOutlet weak var shoeNameTextField: UITextField!
    @IBOutlet weak var shoeColorTextField: UITextField!
    @IBOutlet weak var shoeSizeTextField: UITextField!
    
    var m: DataModelManager!
    
    var selectedState: String?
    var stateList = ["AA Military", "AE Military", "AP Military", "Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado", "Connecticut", "Delaware", "District Of Columbia", "Florida", "Georgia", "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky", "Louisiana", "Maine", "Maryland", "Massachusetts", "Michigan", "Minnesota", "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada", "New Hampshire", "New Jersey", "New Mexico", "New York", "North Carolina", "North Dakota", "Ohio", "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island", "South Carolina", "South Dakota", "Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington", "West Virginia", "Wisconsin", "Wyoming"]
    
    var selectedSize: String?
    var sizeList = ["4K", "5K", "6K", "7K", "8K", "9K", "10K", "11K", "12K", "13K", "1", "2", "3", "4", "5", "5.5", "6", "6.5", "7", "7.5", "8", "8.5", "9", "9.5", "10", "10.5", "11", "11.5", "12", "12.5", "13", "13.5", "14"]
    
    var textFieldSwitch = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil);

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil);
        
        let toolbar:UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0,  width: self.view.frame.size.width, height: 30))
        let flexSpace = UIBarButtonItem(barButtonSystemItem:    .flexibleSpace, target: nil, action: nil)
        let doneBtn: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonAction))
        toolbar.setItems([flexSpace, doneBtn], animated: false)
        toolbar.sizeToFit()
        
        stateTextField.delegate = self
        shoeSizeTextField.delegate = self
        
        self.firstNameTextField.inputAccessoryView = toolbar
        self.lastNameTextField.inputAccessoryView = toolbar
        self.addressTextField.inputAccessoryView = toolbar
        self.zipCodeTextField.inputAccessoryView = toolbar
        self.cityTextField.inputAccessoryView = toolbar
        self.phoneNumberTextField.inputAccessoryView = toolbar
        self.emailTextField.inputAccessoryView = toolbar
        self.cardNumberTextField.inputAccessoryView = toolbar
        self.nameOnCardTextField.inputAccessoryView = toolbar
        self.monthYearTextField.inputAccessoryView = toolbar
        self.cvvTextField.inputAccessoryView = toolbar
        self.shoeNameTextField.inputAccessoryView = toolbar
        self.shoeColorTextField.inputAccessoryView = toolbar
        
        createPickerView()
        
        dismissPickerView()
        
        // Do any additional setup after loading the view.
    }
    
    @objc func keyboardWillShow(sender: NSNotification) {
         self.view.frame.origin.y = -150 // Move view 150 points upward
    }

    @objc func keyboardWillHide(sender: NSNotification) {
         self.view.frame.origin.y = 0 // Move view to original position
    }
    
    @objc func doneButtonAction()
    {
       self.view.endEditing(true)
    }
    
    @IBAction func startSearch(_ sender: UIBarButtonItem)
    {
        if !self.firstNameTextField.text!.isEmpty && !self.lastNameTextField.text!.isEmpty && !self.addressTextField.text!.isEmpty && !self.zipCodeTextField.text!.isEmpty && !self.cityTextField.text!.isEmpty && !self.stateTextField.text!.isEmpty && !self.phoneNumberTextField.text!.isEmpty && !self.emailTextField.text!.isEmpty && !self.cardNumberTextField.text!.isEmpty && !self.nameOnCardTextField.text!.isEmpty && !self.monthYearTextField.text!.isEmpty && !self.cvvTextField.text!.isEmpty && !self.shoeNameTextField.text!.isEmpty && !self.shoeColorTextField.text!.isEmpty && !self.shoeSizeTextField.text!.isEmpty
        {
        
            m.YSPackage = YSPackage(withFirstName: firstNameTextField.text!, lastName: lastNameTextField.text!, address: addressTextField.text!, zipCode: zipCodeTextField.text!, city: cityTextField.text!, state: stateTextField.text!, phoneNumber: phoneNumberTextField.text!, email: emailTextField.text!, cardNumber: cardNumberTextField.text!, nameOnCard: nameOnCardTextField.text!, monthYear: monthYearTextField.text!, cvv: cvvTextField.text!, shoeName: shoeNameTextField.text!, shoeColor: shoeColorTextField.text!, shoeSize: shoeSizeTextField.text!)
            
        
            performSegue(withIdentifier: "startSearch", sender: self)
        }
    }
    
    func createPickerView()
    {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        stateTextField.inputView = pickerView
        shoeSizeTextField.inputView = pickerView
    }
    
    func dismissPickerView()
    {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let button = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.action))
        toolBar.setItems([button], animated: true)
        toolBar.isUserInteractionEnabled = true
        stateTextField.inputAccessoryView = toolBar
        shoeSizeTextField.inputAccessoryView = toolBar
    }
    
    @objc func action()
    {
        view.endEditing(true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        if textField == stateTextField
        {
            self.textFieldSwitch = true
        }
        else if textField == shoeSizeTextField
        {
            self.textFieldSwitch = false
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        if self.textFieldSwitch == true
        {
            return stateList.count
        }
        else
        {
            return sizeList.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        if self.textFieldSwitch == true
        {
            return stateList[row]
        }
        else
        {
            return sizeList[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if self.textFieldSwitch == true
        {
            selectedState = stateList[row]
            stateTextField.text = selectedState
        }
        else
        {
            selectedSize = sizeList[row]
            shoeSizeTextField.text = selectedSize
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "startSearch"
        {
           let vc = segue.destination as! BaseTabBarController
           
           vc.m = self.m
        }
    }

}
