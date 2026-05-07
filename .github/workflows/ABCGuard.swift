import Foundation
import UIKit      // 与编译命令中的 -framework UIKit 对应
import WebKit     // 与 -framework WebKit 对应

// 方式1：使用构造函数属性，加载动态库时自动执行
@_cdecl("initialize")
public func initialize() {
    print("ABCGuard1: Dynamic library loaded.")
    // 在这里添加你的防护逻辑或 hook 代码
}

// 方式2：也可以导出一个外部可调用的函数
@_cdecl("startGuard")
public func startGuard() {
    print("ABCGuard1: startGuard() called.")
}

// 如果需要更早执行，可以使用 Swift 的静态初始化块
private let _init: Void = {
    print("ABCGuard1: Static initializer executed.")
    // 这里可以执行更早的逻辑
}()

// 可选的类封装（方便组织代码）
public class ABCGuardManager {
    public static let shared = ABCGuardManager()
    private init() {
        print("ABCGuardManager initialized")
    }
    
    public func run() {
        print("ABCGuardManager run")
    }
}
