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
        // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        // 这里请替换成你自己的完整 AI 聊天 HTML 代码
        // 把你之前发给我的那一大段 HTML 粘贴到这里
        // 注意使用三个双引号保持原格式
        // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        return """
        <!DOCTYPE html>
        <html lang="zh-CN">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
            <title>青语 AI · 解锁</title>
            <style>
                * { margin: 0; padding: 0; box-sizing: border-box; }
                body { font-family: system-ui; background: #f0fdfa; display: flex; justify-content: center; align-items: center; height: 100vh; padding: 20px; }
                .card { background: white; border-radius: 32px; padding: 30px; max-width: 500px; width: 100%; box-shadow: 0 20px 40px rgba(0,0,0,0.05); text-align: center; }
                h2 { color: #0d9488; margin-bottom: 20px; }
                textarea { width: 100%; padding: 14px; border-radius: 28px; border: 2px solid #99f6e4; font-size: 16px; }
                button { background: #0d9488; color: white; border: none; padding: 12px 28px; border-radius: 40px; margin-top: 20px; }
            </style>
        </head>
        <body>
            <div class="card">
                <h2>🔐 请输入启动口令</h2>
                <textarea rows="1" placeholder="输入 ABC 后按回车"></textarea>
                <button onclick="check()">解锁进入</button>
                <div style="margin-top: 20px; font-size: 12px; color: #94a3b8;">口令：ABC</div>
            </div>
            <script>
                function check() {
                    let val = document.querySelector('textarea').value.trim().toUpperCase();
                    if (val === 'ABC') {
                        window.webkit.messageHandlers.unlockApp.postMessage('unlock');
                    } else {
                        alert('口令错误');
                    }
                }
                document.querySelector('textarea').addEventListener('keypress', function(e) {
                    if (e.key === 'Enter') check();
                });
            </script>
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
