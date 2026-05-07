import Foundation
import UIKit
import WebKit

// 动态库加载时自动执行（通过构造函数属性）
@_cdecl("initialize")
public func initialize() {
    print("ABCGuard: Dynamic library loaded.")
    // 在这里添加你的初始化逻辑（如 hook、防护等）
}

// 导出一个可供外部调用的函数
@_cdecl("startGuard")
public func startGuard() {
    print("ABCGuard: startGuard() called.")
}

// Swift 静态初始化块（比 @_cdecl 更早执行）
private let _init: Void = {
    print("ABCGuard: Static initializer executed.")
}()

// 封装一个管理类（按需使用）
public class ABCGuardManager {
    public static let shared = ABCGuardManager()
    private init() {
        print("ABCGuardManager initialized")
    }
    
    public func run() {
        print("ABCGuardManager run")
    }
}
