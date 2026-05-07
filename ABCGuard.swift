import Foundation
import UIKit
import WebKit

// MARK: - 内嵌 HTML（青语 AI，输入 ABC 发送后通知 native 关闭）
let qingyuHTML = """
<!DOCTYPE html>
<html>
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        * { margin:0; padding:0; box-sizing:border-box; }
        body { font-family:system-ui; background:#f0fdfa; height:100vh; display:flex; flex-direction:column; }
        header { background:#0d9488; color:white; padding:16px; text-align:center; font-size:1.2rem; font-weight:bold; }
        .msgs { flex:1; overflow-y:auto; padding:12px; display:flex; flex-direction:column; gap:8px; }
        .msg { max-width:80%; padding:8px 12px; border-radius:18px; }
        .user { align-self:flex-end; background:#0d9488; color:white; }
        .ai { align-self:flex-start; background:white; border:1px solid #ccfbf1; }
        .input-area { display:flex; padding:8px; background:white; gap:8px; border-top:1px solid #ccc; }
        textarea { flex:1; border:1px solid #ccc; border-radius:20px; padding:8px; resize:none; }
        button { background:#0d9488; border:none; border-radius:30px; width:44px; color:white; font-size:1.2rem; }
    </style>
</head>
<body>
    <header>🦋 青语 AI</header>
    <div class="msgs" id="msgs"><div class="msg ai">输入 ABC 可退出插件</div></div>
    <div class="input-area">
        <textarea id="input" rows="1" placeholder="输入消息..."></textarea>
        <button id="send">➤</button>
    </div>
    <script>
        const msgsDiv = document.getElementById('msgs');
        const input = document.getElementById('input');
        const btn = document.getElementById('send');
        function addMsg(text, isUser) {
            const div = document.createElement('div');
            div.className = 'msg ' + (isUser ? 'user' : 'ai');
            div.textContent = text;
            msgsDiv.appendChild(div);
            msgsDiv.scrollTop = msgsDiv.scrollHeight;
        }
        function send() {
            let txt = input.value.trim();
            if (!txt) return;
            if (txt.toUpperCase() === "ABC") {
                if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.exit) {
                    window.webkit.messageHandlers.exit.postMessage(null);
                }
                return;
            }
            addMsg(txt, true);
            input.value = '';
            setTimeout(() => addMsg("收到：" + txt, false), 400);
        }
        btn.onclick = send;
        input.onkeypress = (e) => { if(e.key==='Enter' && !e.shiftKey) { e.preventDefault(); send(); } };
    </script>
</body>
</html>
"""

// 负责管理悬浮窗的类
class FloatingAIManager: NSObject, WKScriptMessageHandler {
    static let shared = FloatingAIManager()
    private var aiWindow: UIWindow?
    private var webView: WKWebView?

    func showAICover() {
        // 如果已经存在且可见，就不重复创建
        if let window = aiWindow, window.isKeyWindow { return }

        // 获取当前活动的场景（兼容 iOS 13+ 多窗口）
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            // 降级：使用旧方式
            createWindowOnKeyWindow()
            return
        }
        createWindow(on: scene)
    }

    private func createWindow(on scene: UIWindowScene) {
        let window = UIWindow(windowScene: scene)
        window.windowLevel = .alert + 1   // 确保在最上层
        window.backgroundColor = .white

        let config = WKWebViewConfiguration()
        config.userContentController.add(self, name: "exit")
        let wv = WKWebView(frame: window.bounds, configuration: config)
        wv.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        wv.loadHTMLString(qingyuHTML, baseURL: nil)
        window.addSubview(wv)
        self.webView = wv

        window.makeKeyAndVisible()
        self.aiWindow = window
    }

    private func createWindowOnKeyWindow() {
        // 旧版 iOS 兼容
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.windowLevel = .alert + 1
        window.backgroundColor = .white

        let config = WKWebViewConfiguration()
        config.userContentController.add(self, name: "exit")
        let wv = WKWebView(frame: window.bounds, configuration: config)
        wv.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        wv.loadHTMLString(qingyuHTML, baseURL: nil)
        window.addSubview(wv)
        self.webView = wv

        window.makeKeyAndVisible()
        self.aiWindow = window
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "exit" {
            DispatchQueue.main.async {
                self.aiWindow?.isHidden = true
                self.aiWindow = nil
                // 恢复原来的 keyWindow（系统会自动处理）
            }
        }
    }
}

// 自动执行入口（动态库加载时运行）
private let _entry: Void = {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
        FloatingAIManager.shared.showAICover()
    }
}()
