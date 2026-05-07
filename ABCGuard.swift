import UIKit
import WebKit

@objc public class ABCGuardManager: NSObject, WKScriptMessageHandler {
    @objc public static let shared = ABCGuardManager()
    private var overlayWindow: UIWindow?
    private var webView: WKWebView?

    @objc public func showGate() {
        guard overlayWindow == nil else { return }
        DispatchQueue.main.async {
            let window = UIWindow(frame: UIScreen.main.bounds)
            window.windowLevel = .alert + 1
            window.backgroundColor = .white
            window.isHidden = false

            let webView = WKWebView(frame: window.bounds)
            webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            webView.loadHTMLString(self.fullHTMLString, baseURL: nil)

            window.addSubview(webView)
            self.overlayWindow = window
            self.webView = webView
            self.setupWebViewHandler()
        }
    }

    private func setupWebViewHandler() {
        webView?.configuration.userContentController.add(self, name: "unlockApp")
        let js = """
            (function() {
                let inputField = document.querySelector('textarea') || document.querySelector('input');
                if (!inputField) return;
                function check() {
                    let val = inputField.value.trim().toUpperCase();
                    if (val === 'ABC')
                        webkit.messageHandlers.unlockApp.postMessage('unlock');
                }
                inputField.addEventListener('keypress', function(e) {
                    if (e.key === 'Enter') check();
                });
                let btn = document.querySelector('.btn-send') || document.querySelector('button');
                if (btn) btn.addEventListener('click', check);
            })();
        """
        let script = WKUserScript(source: js, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        webView?.configuration.userContentController.addUserScript(script)
    }

    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "unlockApp" { dismissGate() }
    }

    @objc public func dismissGate() {
        webView?.configuration.userContentController.removeScriptMessageHandler(forName: "unlockApp")
        webView?.removeFromSuperview()
        webView = nil
        overlayWindow?.isHidden = true
        overlayWindow = nil
    }

    private var fullHTMLString: String {
import UIKit
import WebKit

@objc public class ABCGuardManager: NSObject, WKScriptMessageHandler {
    @objc public static let shared = ABCGuardManager()
    private var overlayWindow: UIWindow?
    private var webView: WKWebView?

    @objc public func showGate() {
        guard overlayWindow == nil else { return }
        DispatchQueue.main.async {
            let window = UIWindow(frame: UIScreen.main.bounds)
            window.windowLevel = .alert + 1
            window.backgroundColor = .white
            window.isHidden = false

            let webView = WKWebView(frame: window.bounds)
            webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            webView.loadHTMLString(self.fullHTMLString, baseURL: nil)

            window.addSubview(webView)
            self.overlayWindow = window
            self.webView = webView
            self.setupWebViewHandler()
        }
    }

    private func setupWebViewHandler() {
        webView?.configuration.userContentController.add(self, name: "unlockApp")
        let js = """
            (function() {
                let inputField = document.querySelector('textarea') || document.querySelector('input');
                if (!inputField) return;
                function check() {
                    let val = inputField.value.trim().toUpperCase();
                    if (val === 'ABC')
                        webkit.messageHandlers.unlockApp.postMessage('unlock');
                }
                inputField.addEventListener('keypress', function(e) {
                    if (e.key === 'Enter') check();
                });
                let btn = document.querySelector('.btn-send') || document.querySelector('button');
                if (btn) btn.addEventListener('click', check);
            })();
        """
        let script = WKUserScript(source: js, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        webView?.configuration.userContentController.addUserScript(script)
    }

    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "unlockApp" { dismissGate() }
    }

    @objc public func dismissGate() {
        webView?.configuration.userContentController.removeScriptMessageHandler(forName: "unlockApp")
        webView?.removeFromSuperview()
        webView = nil
        overlayWindow?.isHidden = true
        overlayWindow = nil
    }

    private var fullHTMLString: String {
        return """
        <!DOCTYPE html>
        <html lang="zh-CN">
        <head>
            <meta charset="UTF-8">
            <title>青语 AI · 口令解锁</title>
            <style>/* 你的完整样式 */</style>
        </head>
        <body>
            <!-- 你的完整 HTML 内容 -->
            <textarea placeholder="输入 ABC 解锁"></textarea>
            <button>解锁</button>
        </body>
        </html>
        """
    }
}

@_cdecl("init_ABCGuard")
public func init_ABCGuard() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        ABCGuardManager.shared.showGate()
    }
}
        return """
        <!DOCTYPE html>
        <html lang="zh-CN">
        <head>
            <meta charset="UTF-8">
            <title>青语 AI · 口令解锁</title>
            <style>/* 你的完整样式 */</style>
        </head>
        <body>
            <!-- 你的完整 HTML 内容 -->
            <textarea placeholder="输入 ABC 解锁"></textarea>
            <button>解锁</button>
        </body>
        </html>
        """
    }
}

@_cdecl("init_ABCGuard")
public func init_ABCGuard() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        ABCGuardManager.shared.showGate()
    }
}
