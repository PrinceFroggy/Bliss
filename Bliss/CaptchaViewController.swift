//
//  ViewController.swift
//  Bliss
//
//  Created by Andrew Solesa on 6/2/20.
//  Copyright © 2020 KSG. All rights reserved.
//

import UIKit
import WebKit

class CaptchaViewController: UIViewController {
    
    @IBOutlet weak var webview: WKWebView!
    
    var sitekey: String = "6LeWwRkUAAAAAOBsau7KpuC9AV-6J8mhw4AjC3Xz"
    var baseURL: String = "https://www.supremenewyork.com/"
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.webview.displayCaptcha(sitekey: self.sitekey, baseUrl: self.baseURL, googleLogin: true)
        // Do any additional setup after loading the view.
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

public extension WKWebView {
    
    public func displayCaptcha(sitekey: String, baseUrl: String, googleLogin: Bool) {
        if googleLogin {
            let googleUrl = URL(string: "https://accounts.google.com/signin/v2/identifier?hl=EN&flowName=GlifWebSignIn&flowEntry=ServiceLogin")
            let request = URLRequest(url: googleUrl!)
            self.load(request)
            
            
            self.checkGoogleTitle(sitekey: sitekey, baseUrl: baseUrl)
        } else {
            self.loadCaptcha(sitekey: sitekey, baseUrl: baseUrl)
            self.getToken(sitekey: sitekey, baseUrl: baseUrl)
        }
    }
    
    private func checkGoogleTitle(sitekey: String, baseUrl: String) {
        //document.title
        //sign in -> google account
        
        self.evaluateJavaScript("document.title") { (response, error) in
            if let error = error {
                print(error)
            }
            
            let responseString = response as! String
            print(responseString)
            
            
            if responseString.lowercased().range(of: "sign in") != nil || responseString.lowercased() == "" || responseString.lowercased().range(of: "google accounts") != nil {
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.checkGoogleTitle(sitekey: sitekey, baseUrl: baseUrl)
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                    self.loadCaptcha(sitekey: sitekey, baseUrl: baseUrl)
                    self.getToken(sitekey: sitekey, baseUrl: baseUrl)
                })
                
            }
            
        }
        
    }
    
    private func getToken(sitekey: String, baseUrl: String) {
        self.evaluateJavaScript("document.getElementById('g-recaptcha-response').value") { (response, error) in
            guard let response = response else {
                self.getToken(sitekey: sitekey, baseUrl: baseUrl)
                return
            }
            
            if let error = error {
                print(error)
            }
            
            
            
            if response as? String == "" || response as? String == nil{
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    self.getToken(sitekey: sitekey, baseUrl: baseUrl)
                }
            } else {
                if Tokens.tokens.contains(response as! String) {
                    
                } else {
                    Tokens.tokens.append(response as! String)
                    print(response as! String)
                }
                
                self.loadCaptcha(sitekey: sitekey, baseUrl: baseUrl)
                self.getToken(sitekey: sitekey, baseUrl: baseUrl)
            }
        }
        
    }
    
    private func loadCaptcha(sitekey: String, baseUrl: String) {
        self.loadHTMLString("<html><meta name=\"viewport\" content=\"width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no\" />\r\n<head>\r\n<style>\r\nform {\r\n  text-align: center;\r\n}\r\nbody {\r\n  text-align: center;\r\n\r\n  \r\n}\r\n\r\nh1 {\r\n  text-align: center;\r\n}\r\nh3 {\r\n  text-align: center;\r\n}\r\ndiv-captcha {\r\n      text-align: center;\r\n}\r\n    .g-recaptcha {\r\n        display: inline-block;\r\n    }\r\n</style>\r\n\r\n<meta name=\"referrer\" content=\"never\"> <script type='text/javascript' src='https://www.google.com/recaptcha/api.js'></script><script>function sub() { window.webkit.messageHandlers.captchaReceived.postMessage(document.getElementById('g-recaptcha-response').value); }</script></head> <body bgcolor=\"#ffffff\"oncontextmenu=\"return false\"><div id=\"div-captcha\"><br><img width=\"50%\"/><br><br><div style=\"opacity: 0.9\" class=\"g-recaptcha\" data-sitekey=\"\(sitekey)\" data-callback=\"sub\"></div></div><br>\r\n\r\n</body></html>", baseURL: URL(string: baseUrl))
        
    }
    
    
    
}

public struct Tokens {
    static public var tokens : [String] = []
}
