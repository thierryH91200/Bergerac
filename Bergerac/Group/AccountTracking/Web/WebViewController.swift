import AppKit
import WebKit

final class WebViewController: NSViewController, WKUIDelegate {
    
    @IBOutlet var myWebView: WKWebView!
    @IBOutlet weak var activityIndicator: NSProgressIndicator!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        let configuration = WKWebViewConfiguration()

//        configuration.preferences.javaEnabled = true
        
        myWebView = WKWebView(frame: .zero, configuration: configuration)
        myWebView.translatesAutoresizingMaskIntoConstraints = false
        
        myWebView.navigationDelegate = self
        myWebView.uiDelegate = self
        view.addSubview(myWebView)
        
        [myWebView.topAnchor.constraint(equalTo: view.topAnchor),
         myWebView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
         myWebView.leftAnchor.constraint(equalTo: view.leftAnchor),
         myWebView.rightAnchor.constraint(equalTo: view.rightAnchor)].forEach { anchor in
            anchor.isActive = true
        }
        
        if let url = URL(string: "https://google.com/") {
            myWebView.load(URLRequest(url: url))
        }
    }
    
    @IBAction func load(_ sender: Any) {
        loadReallyURL()
    }
    
    public func loadReallyURL()
    {
//        _ = myWebView.configuration.preferences.javaEnabled
        let urlString = "https://www.apple.com"
        guard let url = URL(string: urlString) else { return }
        let request = URLRequest(url: url as URL)
        self.myWebView.load(request )
//        self.view.addSubview(myWebView)
        
    }
    
//    func loadHTML()
//    {
//        myWebView.loadHTMLString("<html><body>"
//            + "<p><a href=\"http://samwize.com\">http://samwize.com</a></p>"
//            + "</body></html>", baseURL: nil)
//    }
    
}
// MARK: - WKNavigationDelegate
extension WebViewController: WKNavigationDelegate
{

    public func webView( _ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error)
    {
        print(error.localizedDescription)
    }
    public func webView( _ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator.startAnimation(self)
    }
    
    public func webView( _ webView: WKWebView, didFinish navigation: WKNavigation!)
    {
        activityIndicator.stopAnimation(self)
    }
}
