//
//  ViewControllerSettings.swift
//  Bliss
//
//  Created by Andrew Solesa on 5/7/20.
//  Copyright © 2020 KSG. All rights reserved.
//

import UIKit
import CoreData

class ViewControllerSettings: UIViewController {
    
    @IBOutlet weak var webhookTextField: UITextField!
    
    var webhookCoreData: NSManagedObject?
    
    var webhook: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        //we will check the core data here for a webhook that exists
        //if it does we will preload it into the text box on load
        // Do any additional setup after loading the view.
        
        let webhookFetchRequest: NSFetchRequest<WebhookEntity> = WebhookEntity.fetchRequest()
        
        do {
            let webhookEntity = try? CDStack.context.fetch(webhookFetchRequest)
            if let webhookValue = webhookEntity?.last{
                webhookTextField.text = webhookValue.webhook
                webhook = webhookTextField.text
                print("Success grabbing webhook!")
            }
            else{
                print("empty webhook entity")
            }
        } catch {
            print("Error grabbing webhook")
        }
        
    }
    
    @IBAction func TestWebhook(_ sender: Any) {
        //TODO: save webhook to coreData and pass that into hook, if empty prompt the user to input a webhook, and detect changes to the webhook and update
        webhook = webhookTextField.text
        
        if webhook != ""{
            if validateWebhook(webhook: webhook!){
                let testWebhook = discordWebhook(hook: webhook!)
                testWebhook.successPostHook(email: "test@gmail.com", orderNumber: "YZ12345", productName: "Yeezy 350 v2 Sulfur", productImage: "https://imgur.com/EoVmR4c.png")
            }
            else {
               let alertController = UIAlertController(title: "Error!", message:
                    "Webhook Invalid", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))

                self.present(alertController, animated: true, completion: nil)
            }
        }
        else{
            let alertController = UIAlertController(title: "Error", message:
                "Webhook Empty", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))

            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func saveWebhook(_ sender: Any) {
        //currently it just appends the new webhook to the array. will need to add a check for an existing webhook and then update the old one if differnet or do nothing if the same
        
        print("Attempting to save webhook")
        
        if webhook != "" && webhook != nil && validateWebhook(webhook: webhook!) || webhookTextField.text != nil{
            //look up the webhook to see if it exists
            let webhookFetchRequest: NSFetchRequest<WebhookEntity> = WebhookEntity.fetchRequest()
            
            do {
                let webhookEntity = try CDStack.context.fetch(webhookFetchRequest)
                if let webhookValue = webhookEntity.last?.value(forKey: "webhook") as? String {
                    if webhookValue != nil && webhookValue != webhookTextField.text{
                        webhookEntity.last!.setValue(webhookTextField.text, forKey: "webhook")
                        webhook = webhookTextField.text
                        CDStack.save()
                        return
                    }
                    else {
                        let alertController = UIAlertController(title: "Error", message:
                            "Webhook the same", preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))

                        self.present(alertController, animated: true, completion: nil)
                        return
                    }
                }
                webhook = webhookTextField.text
                let webhookEntity2 = WebhookEntity(context: CDStack.context)
                webhookEntity2.webhook = webhook
                CDStack.save()
                
            } catch{
                print("Error grabbing webhook")
            }
           
        }
        else {
            let alertController = UIAlertController(title: "Error", message:
                "Webhook Empty", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))

            self.present(alertController, animated: true, completion: nil)
        }
        
    }
    
    
    func validateWebhook(webhook: String) -> Bool{
        let regex = try? NSRegularExpression(pattern: "https://.+/api/webhooks/")
        let range = NSRange(location: 0, length: webhook.utf16.count)
        if ((regex?.matches(in: webhook, range: range)) != nil){
            return true
        }
        return false
    }
    
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
