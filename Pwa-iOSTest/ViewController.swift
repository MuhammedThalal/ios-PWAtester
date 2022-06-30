//
//  ViewController.swift
//  Pwa-iOSTest
//
//  Created by muhammed thalal on 28/06/22.
//

import UIKit
import WebKit

class ViewController: UIViewController{
    
    @IBOutlet weak var leftButton: UIBarButtonItem!
    @IBOutlet weak var rightButton: UIBarButtonItem!
    @IBOutlet weak var OfflineButton: UIButton!
    @IBOutlet weak var OfflineIcon: UIImageView!
    @IBOutlet weak var OfflineView: UIView!
    @IBOutlet weak var WebV: UIView!
//    @IBOutlet weak var Prograssview: UIProgressView!
    @IBOutlet weak var ActivityIndicatorView: UIView!
    @IBOutlet weak var ActivityIndicator: UIActivityIndicatorView!
    
    
    
    var webView : WKWebView!
    var tempView: WKWebView!
    var progressBar : UIProgressView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = appTitle
        setupApp()
        
//        let progressView = UIProgressView(progressViewStyle: .bar)
//               progressView.center = self.view.center
//               progressView.translatesAutoresizingMaskIntoConstraints = false
//               progressView.setProgress(0.5, animated: false)
//               self.view.addSubview(progressView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    @IBAction func OnofflineButtonclick(_ sender: Any) {
        
        OfflineView.isHidden = true
        WebV.isHidden = false
        loadAppUrl()
        
        
    }
    @IBAction func OnRightButton(_ sender: Any) {
        if (changeMenuButtonOnWideScreens && iswidescreen()) {
            webView.evaluateJavaScript(alternateRightButtonJavascript, completionHandler: nil)
        } else {
            webView.evaluateJavaScript(menuButtonJavascript, completionHandler: nil)
        }
        
        
    }
    @IBAction func OnleftButton(_ sender: Any) {
        if(webView.canGoBack){
            webView.goBack()
            ActivityIndicatorView.isHidden = true
            ActivityIndicator.stopAnimating()
        } else {
            UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
          }
        }
    
    
    
    
        
    override class func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == #keyPath(WKWebView.isLoading)){
            
        }
        if(keyPath == #keyPath(WKWebView.estimatedProgress)){
//            progressBar.progress = Float(we.estimatedProgress)
//            rightButton.isEnabled = (webView.estimatedProgress == 1)
        }
    }
    
    
    
    
    
   
    func setupWebView() {
  
        webView = WKWebView(frame: CGRect(x: 0, y: 0, width: WebV.frame.width, height: WebV.frame.height))
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        WebV.addSubview(webView)
        

        webView.allowsBackForwardNavigationGestures = true
        webView.configuration.preferences.javaScriptEnabled = true

        if #available(iOS 14.0, *) {
            webView.configuration.ignoresViewportScaleLimits = false
        }

        if #available(iOS 13.0, *) {
            if (useCustomUserAgent) {
                webView.customUserAgent = customUserAgent
            }
            if (useUserAgentPostfix) {
                if (useCustomUserAgent) {
                    webView.customUserAgent = customUserAgent + " " + userAgentPostfix
                } else {
                    tempView = WKWebView(frame: .zero)
                    tempView.evaluateJavaScript("navigator.userAgent", completionHandler: { (result, error) in
                        if let resultObject = result {
                            self.webView.customUserAgent = (String(describing: resultObject) + " " + userAgentPostfix)
                            self.tempView = nil
                        }
                    })
                }
            }
            webView.configuration.applicationNameForUserAgent = ""
        }
        
        webView.scrollView.bounces = enableBounceWhenScrolling

        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.isLoading), options: NSKeyValueObservingOptions.new, context: nil)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    func setupUI(){
        
        progressBar = UIProgressView(frame: CGRect(x: 0, y: 0, width: WebV.frame.width, height: 40))
        progressBar.autoresizingMask = [.flexibleWidth]
        progressBar.progress = 0.0
        progressBar.tintColor = progressBarColor
        webView.addSubview(progressBar)
        
        ActivityIndicator.color = activityIndicatorColor
        ActivityIndicator.startAnimating()
            OfflineIcon.tintColor = offlineIconColor
        OfflineButton.tintColor = buttonColor
        OfflineView.isHidden = true
        
        
        if(forceLargeTitle){
            if #available(iOS 14.0, *){
                navigationItem.largeTitleDisplayMode = UINavigationItem.LargeTitleDisplayMode.always
            }
            if (useLightStatusBarStyle) {
                self.navigationController?.navigationBar.barStyle = UIBarStyle.black
            }
        }
    }
    func loadAppUrl(){
        let urlRequest = URLRequest(url: webAppUrl!)
        webView.load(urlRequest)
    }
    
    func setupApp(){
        setupWebView()
        setupUI()
        setupApp()
    }
    
    func iswidescreen() -> Bool {
        if (UIScreen.main.bounds.width >= wideScreenMinWidth){
            return true
        }else{
            return false
        }
    }
    
    deinit {
       webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.isLoading))
       webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
    }
    
    func updateRightbuttonTitle(invert: Bool){
        if(changeMenuButtonOnWideScreens){
            if(UIScreen.main.fixedCoordinateSpace.bounds.height < wideScreenMinWidth){
                return
            }
            if (UIScreen.main.fixedCoordinateSpace.bounds.height >= wideScreenMinWidth
                && UIScreen.main.fixedCoordinateSpace.bounds.width >= wideScreenMinWidth) {
                // both orientations are considered "wide"
                rightButton.title = alternateRightButtonTitle
                return
            }
            
            
            let changeToAlternateTitle = invert
                ? !iswidescreen()
                : iswidescreen()
            if (changeToAlternateTitle) {
                rightButton.title = alternateRightButtonTitle
            } else {
                rightButton.title = menuButtonTitle
            }
         }
    }
}

extension ViewController : WKNavigationDelegate{
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if(changeAppTitleToPageTitle){
            navigationItem.title = webView.title
        }
        progressBar.isHidden = true
        ActivityIndicatorView.isHidden = true
        ActivityIndicator.stopAnimating()
    }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        OfflineView.isHidden = false
        WebV.isHidden = true
    }
    
}

extension ViewController: WKUIDelegate{
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if(navigationAction.targetFrame == nil){
            webView.load(navigationAction.request)
        }
        return nil
    }
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let requestUrl = navigationAction.request.url{
            if let requestHost = requestUrl.host{
                if(requestHost.range(of: allowedOrigin) != nil ){
                    decisionHandler(.allow)
                }else{
                    decisionHandler(.cancel)
                    if (UIApplication.shared.canOpenURL(requestUrl)) {
                        if #available(iOS 14.0, *) {
                            UIApplication.shared.open(requestUrl)
                        } else {
                            UIApplication.shared.canOpenURL(requestUrl)
                        }
                    }
               }
            }else{
                decisionHandler(.cancel)
            }
        }
    }
}

