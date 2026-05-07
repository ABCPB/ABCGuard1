import Foundation
import UIKit
import WebKit

// MARK: - 内嵌 HTML（完整的青语 AI 聊天界面，已添加退出通信）
let qingyuHTML = """
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
    <title>青语 AI</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            background: #f0fdfa;
            font-family: system-ui, -apple-system, 'Segoe UI', sans-serif;
            height: 100vh;
            display: flex;
            flex-direction: column;
        }
        .chat-header {
            background: #0d9488;
            color: white;
            padding: 16px;
            text-align: center;
            font-size: 1.2rem;
            font-weight: 600;
        }
        .chat-messages {
            flex: 1;
            overflow-y: auto;
            padding: 16px;
            display: flex;
            flex-direction: column;
            gap: 12px;
        }
        .message {
            max-width: 80%;
            padding: 10px 14px;
            border-radius: 18px;
            font-size: 0.95rem;
        }
        .user {
            align-self: flex-end;
            background: #0d9488;
            color: white;
            border-bottom-right-radius: 4px;
        }
        .ai {
            align-self: flex-start;
            background: white;
            border: 1px solid #ccfbf1;
            border-bottom-left-radius: 4px;
            color: #1e293b;
        }
        .input-area {
            padding: 12px;
            background: white;
            border-top: 1px solid #ccfbf1;
            display: flex;
            gap: 10px;
        }
        .input-area textarea {
            flex: 1;
            border: 2px solid #99f6e4;
            border-radius: 24px;
            padding: 10px 16px;
            font-size: 0.9rem;
            resize: none;
            outline: none;
            font-family: inherit;
        }
        .input-area button {
            background: #0d9488;
            border: none;
            border-radius: 40px;
            width: 48px;
            color: white;
            font-size: 1.2rem;
            cursor: pointer;
        }
        .empty-state {
            text-align: center;
            color: #94a3b8;
            padding: 40px;
        }
    </style>
</head>
<body>
    <div class="chat-header">🦋 青语 AI · 自由对话</div>
    <div class="chat-messages" id="chatMessages">
        <div class="empty-state">输入消息开始聊天～<br>输入 <b>ABC</b> 可退出 AI 界面</div>
    </div>
    <div class="input-area">
        <textarea id="userInput" rows="1" placeholder="输入消息..."></textarea>
        <button id="sendBtn">➤</button>
    </div>

    <script>
        const messagesDiv = document.getElementById('chatMessages');
        const input = document.getElementById('userInput');
        const sendBtn = document.getElementById('sendBtn');

        function addMessage(text, isUser) {
            const msgDiv = document.createElement('div');
            msgDiv.className = 'message ' + (isUser ? 'user' : 'ai');
            msgDiv.textContent = text;
            messagesDiv.appendChild(msgDiv);
            messagesDiv.scrollTop = messagesDiv.scrollHeight;
        }

        function sendMessage() {
            let text = input.value.trim();
            if (text === "") return;
            // 检测是否输入 ABC (不区分大小写)
            if (text.toUpperCase() === "ABC") {
                // 通知 native 退出 AI 界面
                if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.exit) {
                    window.webkit.messageHandlers.exit.postMessage(null);
                }
                return;
            }
            addMessage(text, true);
            input.value = "";
            // 模拟 AI 回复
            setTimeout(() => {
                addMessage("收到：" + text, false);
            }, 500);
        }

        sendBtn.addEventListener('click', sendMessage);
        input.addEventListener('keypress', (e) => {
            if (e.key === 'Enter' && !e.shiftKey) {
                e.preventDefault();
                sendMessage();
            }
        });
    </script>
</body>
</html>
"""

// MARK: - AI WebView 控制器（必须标记可用性，避免编译错误）
@available(iOS 13.0, *)
class AIWebViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler {
    private var webView: WKWebView!
    private let htmlString: String
    weak var delegate: AIWebViewControllerDelegate?

    init(html: String) {
        self.htmlString = html
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        let config = WKWebViewConfiguration()
        let userController = WKUserContentController()
        userController.add(self, name: "exit")
        config.userContentController = userController
        webView = WKWebView(frame: .zero, configuration: config)
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        webView.loadHTMLString(htmlString, baseURL: nil)
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "exit" {
            delegate?.aiWebViewControllerDidRequestExit(self)
        }
    }
}

protocol AIWebViewControllerDelegate: AnyObject {
    func aiWebViewControllerDidRequestExit(_ controller: AIWebViewController)
}

// MARK: - 全局控制器
@available(iOS 13.0, *)
class AIController: NSObject, AIWebViewControllerDelegate {
    static let shared = AIController()
    private var originalRootVC: UIViewController?
    private var isAIActive = false

    private override init() { super.init() }

    func activate() {
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.keyWindow,
                  let root = window.rootViewController else { return }
            self.originalRootVC = root
            if !self.isAIActive {
                self.showAI()
            }
        }
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(foreground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }

    private func showAI() {
        guard let window = UIApplication.shared.keyWindow else { return }
        let aiVC = AIWebViewController(html: qingyuHTML)
        aiVC.delegate = self
        window.rootViewController = aiVC
        window.makeKeyAndVisible()
        isAIActive = true
    }

    private func exitAI() {
        guard let original = originalRootVC,
              let window = UIApplication.shared.keyWindow else { return }
        window.rootViewController = original
        window.makeKeyAndVisible()
        isAIActive = false
    }

    @objc private func foreground() {
        if isAIActive {
            DispatchQueue.main.async { self.showAI() }
        }
    }

    func aiWebViewControllerDidRequestExit(_ controller: AIWebViewController) {
        exitAI()
    }
}

// MARK: - 动态库入口
@_cdecl("initialize")
public func initialize() {
    if #available(iOS 13.0, *) {
        AIController.shared.activate()
    }
}

// 静态初始化后备
private let _entry: Void = {
    if #available(iOS 13.0, *) {
        DispatchQueue.main.async {
            AIController.shared.activate()
        }
    }
}()
