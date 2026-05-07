import Foundation
import UIKit

@_cdecl("initialize")
public func initialize() {
    print("ABCGuard loaded")
}

@_cdecl("startGuard")
public func startGuard() {
    print("startGuard called")
}

private let _init: Void = {
    print("Static init")
}()

public class Manager {
    public static let shared = Manager()
    private init() {}
    public func run() { print("run") }
}
