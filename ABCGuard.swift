import Foundation
import UIKit

// 原生聊天悬浮窗（轻量、安全）
class NativeChatView: UIView, UITextFieldDelegate {
    private let textView = UITextView()
    private let textField = UITextField()
    private let sendButton = UIButton(type: .system)
    private var messages: [String] = []
    private var onExit: (() -> Void)?

    init(frame: CGRect, onExit: @escaping () -> Void) {
        self.onExit = onExit
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        backgroundColor = UIColor(red: 0.94, green: 0.98, blue: 0.96, alpha: 1.0)
        
        // 头部
        let header = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width, height: 60))
        header.text = "🦋 青语 AI 自由对话"
        header.textAlignment = .center
        header.backgroundColor = UIColor(red: 0.05, green: 0.52, blue: 0.53, alpha: 1.0)
        header.textColor = .white
        header.font = UIFont.boldSystemFont(ofSize: 18)
        addSubview(header)
        
        // 消息显示区
        textView.frame = CGRect(x: 10, y: 70, width: frame.width - 20, height: frame.height - 140)
        textView.isEditable = false
        textView.backgroundColor = .white
        textView.layer.cornerRadius = 12
        textView.font = UIFont.systemFont(ofSize: 14)
        addSubview(textView)
        
        // 输入框
        textField.frame = CGRect(x: 10, y: frame.height - 60, width: frame.width - 90, height: 44)
        textField.borderStyle = .roundedRect
        textField.placeholder = "输入消息... (输入 ABC 退出)"
        textField.returnKeyType = .send
        textField.delegate = self
        addSubview(textField)
        
        // 发送按钮
        sendButton.frame = CGRect(x: frame.width - 70, y: frame.height - 60, width: 60, height: 44)
        sendButton.setTitle("发送", for: .normal)
        sendButton.backgroundColor = UIColor(red: 0.05, green: 0.52, blue: 0.53, alpha: 1.0)
        sendButton.setTitleColor(.white, for: .normal)
        sendButton.layer.cornerRadius = 8
        sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)
        addSubview(sendButton)
        
        addMessage("输入 ABC 可退出插件", isUser: false)
    }
    
    @objc private func sendTapped() {
        guard let text = textField.text, !text.isEmpty else { return }
        textField.text = ""
        addMessage(text, isUser: true)
        if text.uppercased() == "ABC" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.onExit?()
            }
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.addMessage("收到: \(text)", isUser: false)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendTapped()
        return true
    }
    
    private func addMessage(_ text: String, isUser: Bool) {
        let prefix = isUser ? "👤 我: " : "🦋 青语: "
        let newText = prefix + text + "\n\n"
        textView.text = (textView.text ?? "") + newText
        let bottom = NSRange(location: textView.text.count - 1, length: 1)
        textView.scrollRangeToVisible(bottom)
    }
}

// 管理悬浮窗
class FloatingChatManager {
    static let shared = FloatingChatManager()
    private var chatWindow: UIWindow?
    private var chatView: NativeChatView?
    
    func show() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            // 获取当前活动的场景或主屏幕
            let bounds = UIScreen.main.bounds
            let window: UIWindow
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                window = UIWindow(windowScene: scene)
            } else {
                window = UIWindow(frame: bounds)
            }
            window.windowLevel = .alert + 1
            window.backgroundColor = .clear
            window.isHidden = false
            
            let chatView = NativeChatView(frame: bounds) {
                window.isHidden = true
                window.removeFromSuperview()
                // 恢复原来的 keyWindow（系统自动处理）
            }
            window.addSubview(chatView)
            window.makeKeyAndVisible()
            self.chatWindow = window
            self.chatView = chatView
        }
    }
}

// 动态库入口
private let _entry: Void = {
    FloatingChatManager.shared.show()
}()
