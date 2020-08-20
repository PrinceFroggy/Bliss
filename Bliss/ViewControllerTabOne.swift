//
//  ViewControllerTabOne.swift
//  Bliss
//
//  Created by Andrew Solesa on 2020-02-05.
//  Copyright © 2020 KSG. All rights reserved.
//

import UIKit
import WebKit
import Fuzi

class ViewControllerTabOne: TabViewController, WKNavigationDelegate
{
    @IBOutlet weak var yeezySupplyWebViewContainer: UIView!
    
    var yeezySupplyWebView: WKWebView?
    
    var abckPackage: [abck]?
    
    var blockRedirection: Bool?
    var stepFunction: Int?
    
    var urlReq: URLRequest?
    
    var killSwitch = 0
    
    var nsDate: Date?
    var date: String?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(activateKillSwitch), name: Notification.Name("tabOneKillSwitch"), object: nil)
        
        self.cleanCache()
        self.cleanAllCookies()
        
        self.getABCK()
    }
    
    @objc func activateKillSwitch()
    {
        self.killSwitch = 1
    }
    
    func getABCK()
    {
        let request = WebApiRequest()
        
        request.urlBase = "http://www.ysgenerator.com/abck"
        request.httpMethod = "GET"
        
        request.sendRequest(toUrlPath: "INCLUDED API KEY IN URLBASE", completion:
        { (result: abck) in
            
            self.abckPackage = [result]
            
            self.configBrowser()
        })
    }
    
    func configBrowser()
    {
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        preferences.javaScriptCanOpenWindowsAutomatically = true
           
        let js = self.getMyJavaScript()
        let script = WKUserScript(source: js, injectionTime: .atDocumentStart, forMainFrameOnly: false)
           
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        nsDate = NSDate(timeIntervalSinceNow: 3600) as Date

        date = dateFormatter.string(from: nsDate!)

        let cookie = HTTPCookie(properties:
        [
            .domain: ".yeezysupply.com",
            .path: "/",
            .name: "_abck",
            .value: self.abckPackage!.first!.val,
            .secure: "TRUE",
            .expires: date
        ])
        
        let webConfiguration = WKWebViewConfiguration()
        
        if let myCookie = cookie
        {
            webConfiguration.includeCustomCookies(cookies: [myCookie], completion:
            {
                    [weak self] in
                    
                    webConfiguration.websiteDataStore = WKWebsiteDataStore.default()
                    webConfiguration.processPool = WKProcessPool()
                    
                    self!.yeezySupplyWebView = WKWebView(frame: CGRect(x: 0, y: 0, width: self!.view.frame.size.width , height: self!.view.frame.height), configuration: webConfiguration)
                    
                    self!.yeezySupplyWebView!.configuration.websiteDataStore.httpCookieStore.setCookie(myCookie, completionHandler:
                    {
                        HTTPCookieStorage.shared.setCookie(myCookie)
                    })
                                           
                    self!.yeezySupplyWebView!.configuration.userContentController.addUserScript(script)
                    
                    self!.yeezySupplyWebView!.navigationDelegate = self
                                           
                    self!.yeezySupplyWebViewContainer.addSubview(self!.yeezySupplyWebView!)
                        
                    self!.loadYeezySupply()
            })
        }
    }
    
    func cleanCache()
    {
        let websiteDataTypes = NSSet(array: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache])
        let date = Date(timeIntervalSince1970: 0)
        WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes as! Set<String>, modifiedSince: date, completionHandler:{ })
    }
    
    func cleanAllCookies()
    {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
    }
    
    func getMyJavaScript() -> String
    {
        if let filepath = Bundle.main.path(forResource: "jquery", ofType: "js")
        {
            do
            {
                return try String(contentsOfFile: filepath)
            }
            catch
            {
                return ""
            }
        }
        else
        {
           return ""
        }
    }
    
    func cookieStore()
    {
        let wkHttpCookieStorage = WKWebsiteDataStore.default().httpCookieStore;
        wkHttpCookieStorage.getAllCookies
        { (cookies) in
            for cookie in cookies
            {
                HTTPCookieStorage.shared.setCookie(cookie)
                if cookie.name == "_abck"
                {
                    print("Cookie Name:\(cookie.name) - Cookie domain: \(cookie.domain) - Cookie secure: \(cookie.isSecure) - Cookie Value:\(cookie.value) - Cookie Expiry: \(String(describing: cookie.expiresDate)) - Cookie path: \(cookie.path)");
                }
            }
        }
    }
    
    func loadYeezySupply()
    {
        self.stepFunction = 0
        self.blockRedirection = false
        
        self.urlReq = URLRequest(url: URL(string: "https://www.yeezysupply.com/")!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10)
        self.urlReq!.httpShouldHandleCookies = true
        
        self.yeezySupplyWebView!.load(self.urlReq!)
    }
    
    func generateList()
    {
        self.cookieStore()
        
        self.yeezySupplyWebView!.evaluateJavaScript("document.documentElement.outerHTML.toString()", completionHandler:
        { (html: Any?, error: Error?) in
            
            let htmlText = html as! String
            
            if let doc = try? HTMLDocument(string: htmlText, encoding: String.Encoding.utf8)
            {
                for item in doc.css("article").filter({ $0.children.count >= 1 })
                {
                    let name = item.css("p[data-auto-id='ys-product-name']").first!.stringValue.lowercased()
                    
                    let wishListName = self.m.YSPackage!.shoeName.lowercased()
                    
                    if name.range(of: wishListName) != nil
                    {
                        if item.css("p[data-auto-id='ys-product-color']").count == 1
                        {
                            let color = item.css("p[data-auto-id='ys-product-color']").first!.stringValue.lowercased()
                        
                            let wishListColor = self.m.YSPackage!.shoeColor.lowercased()
                        
                                if color.range(of: wishListColor) != nil
                                {
                                    self.stepFunction = 1
                                    self.blockRedirection = true
                                
                                    self.yeezySupplyWebView!.evaluateJavaScript("$('\(item.children.first!.self)')[0].click()")
                                
                                    self.selectSize()
                                
                                    return
                                }
                        }
                        else
                        {
                            self.stepFunction = 1
                            self.blockRedirection = true
                        
                            self.yeezySupplyWebView!.evaluateJavaScript("$('\(item.parent!.children.first!.self)')[0].click()")
                        
                            self.selectSize()
                        
                            return
                        }
                    }
                }
            }
        })
    }
    
    func selectSize()
    {
        self.cookieStore()
        
        if killSwitch != 1
        {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute:
            {
                self.yeezySupplyWebView!.evaluateJavaScript("$('[data-auto-id=\"yeezy-size-selection-dropdown\"]').length", completionHandler:
                    { (html: Any?, error: Error?) in
            
                        let elementExists = html as! Int
            
                        if elementExists > 0
                        {
                            if self.killSwitch != 1
                            {
                                NotificationCenter.default.post(name: Notification.Name("tabTwoKillSwitch"), object: nil)
                                NotificationCenter.default.post(name: Notification.Name("tabThreeKillSwitch"), object: nil)
                                NotificationCenter.default.post(name: Notification.Name("tabFourKillSwitch"), object: nil)
                            }
                            
                            if self.killSwitch != 1
                            {
                                self.tabBarController?.selectedIndex = 0
                            
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute:
                                {
                                    let size = self.m.YSPackage!.shoeSize
                    
                                    self.yeezySupplyWebView!.evaluateJavaScript("document.documentElement.outerHTML.toString()", completionHandler:
                                    { (html: Any?, error: Error?) in
                                        
                                        let htmlText = html as! String
                                        
                                        if let doc = try? HTMLDocument(string: htmlText, encoding: String.Encoding.utf8)
                                        {
                                            let item = doc.firstChild(css: "select")
                                            
                                            let id = item!.attr("class")
                                                
                                            self.yeezySupplyWebView!.evaluateJavaScript("let selectedValue = $('select[class=\"\(id!)\"] > option:contains(\"\(size)\")').val(); let select = document.querySelectorAll('.\(id!)')[0];  select.value = selectedValue; var nativeInputValueSetter = Object.getOwnPropertyDescriptor(window.HTMLSelectElement.prototype, \"value\").set; nativeInputValueSetter.call(select, selectedValue); var ev2 = new Event('change', { bubbles: true}); select.dispatchEvent(ev2);", completionHandler:
                                                { (html: Any?, error: Error?) in
                                                    
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 10.0, execute:
                                                    {
                                                        self.yeezySupplyWebView!.evaluateJavaScript("let btn = document.querySelectorAll('[data-auto-id=\"ys-add-to-bag-btn\"]')[0]; btn.click()", completionHandler:
                                                        { (html: Any?, error: Error?) in
                                                            
                                                            self.stepFunction = 2
                                                            self.blockRedirection = true
                                                            
                                                            self.checkoutPage()
                                                        })
                                                    })
                                                })
                                        }
                                    })
                                })
                            }
                        }
                        else
                        {
                            self.blockRedirection = false
                
                            return
                        }
                    })
            })
        }
    }
    
    func checkoutPage()
    {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute:
        {
            self.yeezySupplyWebView!.evaluateJavaScript("$('[data-auto-id=\"yeezy-mini-basket\"]')[0].click()", completionHandler:
            { (html: Any?, error: Error?) in
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute:
                {
                    self.yeezySupplyWebView!.evaluateJavaScript("$('[data-auto-id=\"glass-checkout-button-bottom\"]')[0].click()", completionHandler:
                    { (html: Any?, error: Error?) in
                        
                        self.stepFunction = 3
                        self.blockRedirection = true
                        
                        self.processDelivery()
                        
                    })
                })
                
            })
        })
    }
    
    func processDelivery()
    {
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0, execute:
        {
            let firstName = self.m.YSPackage!.firstName
            let lastName = self.m.YSPackage!.lastName
            let address = self.m.YSPackage!.address
            let city = self.m.YSPackage!.city
            let state = self.m.YSPackage!.state
            let zipCode = self.m.YSPackage!.zipCode
            let phoneNumber = self.m.YSPackage!.phoneNumber
            let email = self.m.YSPackage!.email
                    
            self.yeezySupplyWebView!.evaluateJavaScript("var input = document.querySelectorAll('[data-auto-id=\"shippingAddress-firstName\"]')[0]; var nativeInputValueSetter = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, \"value\").set; nativeInputValueSetter.call(input, \"\(firstName)\"); var ev2 = new Event('change', { bubbles: true}); input.dispatchEvent(ev2); input.dispatchEvent(new Event('focus')); input.dispatchEvent(new Event('blur')); var input2 = document.querySelectorAll('[data-auto-id=\"shippingAddress-lastName\"]')[0]; var nativeInputValueSetter2 = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, \"value\").set; nativeInputValueSetter2.call(input2, \"\(lastName)\"); var ev3 = new Event('change', { bubbles: true}); input2.dispatchEvent(ev3); input2.dispatchEvent(new Event('focus')); input2.dispatchEvent(new Event('blur')); var input3 = document.querySelectorAll('[data-auto-id=\"shippingAddress-address1\"]')[0]; var nativeInputValueSetter3 = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, \"value\").set; nativeInputValueSetter3.call(input3, \"\(address)\"); var ev4 = new Event('change', { bubbles: true}); input3.dispatchEvent(ev4); input3.dispatchEvent(new Event('focus')); input3.dispatchEvent(new Event('blur')); var input4 = document.querySelectorAll('[data-auto-id=\"shippingAddress-city\"]')[0]; var nativeInputValueSetter4 = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, \"value\").set; nativeInputValueSetter4.call(input4, \"\(city)\"); var ev5 = new Event('change', { bubbles: true}); input4.dispatchEvent(ev5); input4.dispatchEvent(new Event('focus')); input4.dispatchEvent(new Event('blur')); let selectedValue2 = \"\(state)\"; let select2 = document.querySelectorAll('.gl-native-dropdown__select-element')[0]; select2.value = selectedValue2; var nativeInputValueSetter5 = Object.getOwnPropertyDescriptor(window.HTMLSelectElement.prototype, \"value\").set; nativeInputValueSetter5.call(select2, selectedValue2); var ev6 = new Event('change', { bubbles: true}); select2.dispatchEvent(ev6); select2.dispatchEvent(new Event('focus')); select2.dispatchEvent(new Event('blur')); var input5 = document.querySelectorAll('[data-auto-id=\"shippingAddress-zipcode\"]')[0]; var nativeInputValueSetter6 = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, \"value\").set; nativeInputValueSetter6.call(input5, \"\(zipCode)\"); var ev7 = new Event('change', { bubbles: true}); input5.dispatchEvent(ev7); input5.dispatchEvent(new Event('focus')); input5.dispatchEvent(new Event('blur')); var input6 = document.querySelectorAll('[data-auto-id=\"shippingAddress-phoneNumber\"]')[0]; var nativeInputValueSetter7 = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, \"value\").set; nativeInputValueSetter7.call(input6, \"\(phoneNumber)\"); var ev8 = new Event('change', { bubbles: true}); input6.dispatchEvent(ev8); input6.dispatchEvent(new Event('focus')); input6.dispatchEvent(new Event('blur')); var input7 = document.querySelectorAll('[data-auto-id=\"shippingAddress-emailAddress\"]')[0]; var nativeInputValueSetter8 = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, \"value\").set; nativeInputValueSetter8.call(input7, \"\(email)\"); var ev9 = new Event('change', { bubbles: true}); input7.dispatchEvent(ev9); input7.dispatchEvent(new Event('focus')); input7.dispatchEvent(new Event('blur'));", completionHandler:
                { (html: Any?, error: Error?) in
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 20.0, execute:
                    {
                        self.yeezySupplyWebView!.evaluateJavaScript("$('[data-auto-id=\"review-and-pay-button\"]').click();", completionHandler:
                        { (html: Any?, error: Error?) in
                                
                            self.stepFunction = 4
                            self.blockRedirection = true
                                
                            self.processReviewPay()
                                
                        })
                    })
            })
        })
    }
    
    func processReviewPay()
    {
        DispatchQueue.main.asyncAfter(deadline: .now() + 20.0, execute:
        {
            let cardNumber = self.m.YSPackage!.cardNumber
            let nameOnCard = self.m.YSPackage!.nameOnCard
            let expiryDate = self.m.YSPackage!.monthYear
            let cvv = self.m.YSPackage!.cvv
                    
            self.yeezySupplyWebView!.evaluateJavaScript("var input8 = document.querySelectorAll('[data-auto-id=\"card-number-field\"]')[0]; var nativeInputValueSetter9 = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, \"value\").set; nativeInputValueSetter9.call(input8, \"\(cardNumber)\"); var ev10 = new Event('change', { bubbles: true}); input8.dispatchEvent(ev10); input8.dispatchEvent(new Event('focus')); input8.dispatchEvent(new Event('blur')); var input9 = document.querySelectorAll('[data-auto-id=\"name-on-card-field\"]')[0]; var nativeInputValueSetter10 = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, \"value\").set; nativeInputValueSetter10.call(input9, \"\(nameOnCard)\"); var ev11 = new Event('change', { bubbles: true}); input9.dispatchEvent(ev11); input9.dispatchEvent(new Event('focus')); input9.dispatchEvent(new Event('blur')); var input10 = document.querySelectorAll('[data-auto-id=\"expiry-date-field\"]')[0]; var nativeInputValueSetter11 = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, \"value\").set; nativeInputValueSetter11.call(input10, \"\(expiryDate)\"); var ev12 = new Event('change', { bubbles: true}); input10.dispatchEvent(ev12); input10.dispatchEvent(new Event('focus')); input10.dispatchEvent(new Event('blur')); var input11 = document.querySelectorAll('[data-auto-id=\"security-number-field\"]')[0]; var nativeInputValueSetter12 = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, \"value\").set; nativeInputValueSetter12.call(input11, \"\(cvv)\"); var ev13 = new Event('change', { bubbles: true}); input11.dispatchEvent(ev13); input11.dispatchEvent(new Event('focus')); input11.dispatchEvent(new Event('blur'));", completionHandler:
                { (html: Any?, error: Error?) in
                        
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute:
                    {
                        self.yeezySupplyWebView!.evaluateJavaScript("$('[data-auto-id=\"place-order-button\"]').click();", completionHandler:
                        { (html: Any?, error: Error?) in
                                
                        })
                    })
                })
        })
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Swift.Void)
    {
        let cookies = HTTPCookieStorage.shared.cookies ?? []
        
        for cookie in cookies
        {
            if cookie.name == "_abck"
            {
                if cookie.expiresDate != nsDate
                {
                    let newCookie = HTTPCookie(properties:
                    [
                    .domain: ".yeezysupply.com",
                    .path: "/",
                    .name: "_abck",
                    .value: self.abckPackage!.first!.val,
                    .secure: "TRUE",
                    .expires: date
                    ])
                    
                    webView.configuration.websiteDataStore.httpCookieStore.setCookie(newCookie!)
                }
                else
                {
                    decisionHandler(.allow)
                }
            }
        }
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!)
    {
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!)
    {
        webView.configuration.websiteDataStore.httpCookieStore.getAllCookies(
        {cookies in
            
            for cookie in cookies
            {
                if cookie.name == "_abck"
                {
                        print("Cookie Name:\(cookie.name) - Cookie domain: \(cookie.domain) - Cookie secure: \(cookie.isSecure) - Cookie Value:\(cookie.value) - Cookie Expiry: \(String(describing: cookie.expiresDate)) - Cookie path: \(cookie.path)");
                }
            }
        })
        
        if (!self.blockRedirection!)
        {
            switch self.stepFunction
            {
            case 0:
                self.generateList()
                break
                    
            case 1:
                self.selectSize()
                break
                    
            case 2:
                self.checkoutPage()
                break
                    
            case 3:
                self.processDelivery()
                break
                    
            case 4:
                self.processReviewPay()
                break
                    
            default:
                break
            }
        }
        
        self.blockRedirection = true
        }
    }

extension String
{
    func slice(from: String, to: String) -> String?
    {
        return (range(of: from)?.upperBound).flatMap
        { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map
            { substringTo in
            substring(with: substringFrom..<substringTo)
            }
        }
    }
}

extension WKWebViewConfiguration
{
    func includeCustomCookies(cookies: [HTTPCookie], completion: @escaping  () -> Void)
    {
        let dataStore = WKWebsiteDataStore.nonPersistent()
        let waitGroup = DispatchGroup()

        for cookie in cookies
        {
            waitGroup.enter()
            dataStore.httpCookieStore.setCookie(cookie) { waitGroup.leave() }
        }

        waitGroup.notify(queue: DispatchQueue.main)
        {
            self.websiteDataStore = dataStore
            completion()
        }
    }
}
