import Foundation
import UIKit
import WebKit

@_cdecl("initialize")
public func initialize() {
    print("ABCGuard: Dynamic library loaded.")
}

@_cdecl("startGuard")
public func startGuard() {
    print("ABCGuard: startGuard() called.")
}

private let _init: Void = {
    print("ABCGuard: Static initializer executed.")
}()

public class ABCGuardManager {
    public static let shared = ABCGuardManager()
    private init() {
        print("ABCGuardManager initialized")
    }
    public func run() {
        print("ABCGuardManager run")
    }
}
