//
//  Daddy.swift
//  DadSDK
//
//  Created by FOLY on 5/22/21.
//

import Boardy
import DadFoundation
import Foundation

public struct Options {
    public init() {}

    public static let `default` = Options()
}

public final class DaddyComponent {
    private let options: Options

    private var container = BoardContainer()

    private var plugins: [ModulePlugin] = []
    private var flowRegistrations: [(FlowMotherboard) -> Void] = []

    private var modules: [ModuleLoader] = []

    public var producer: ActivableBoardProducer { container }

    init(options: Options) {
        self.options = options
    }

    func append(plugin: ModulePlugin) -> Bool {
        if !plugins.contains(where: { $0.identifier == plugin.identifier }) {
            plugins.append(plugin)
            return true
        } else {
            #if DEBUG
            print("⚠️ Duplicated plugin \(plugin.identifier)")
            #endif
        }
        return false
    }

    public func adopt(plugin: ModulePlugin,
                      with flowRegistration: @escaping (FlowMotherboard) -> Void = { _ in }) -> Self {
        if append(plugin: plugin) {
            flowRegistrations.append(flowRegistration)
        }
        return self
    }

    public func initialize() {
        // Load plutins
        plugins.forEach { $0.apply(for: self) }

        let mainboard = Motherboard(boardProducer: producer)
        flowRegistrations.forEach { $0(mainboard) }

        // Init shared Daddy
        Daddy.sharedInstance = Daddy(mainboard: mainboard)
    }
}

extension DaddyComponent: MainComponent {
    public func registerBoard(_ identifier: BoardID, producer: @escaping (BoardID) -> ActivatableBoard) {
        container.register({ producer(identifier) }, forId: identifier)
    }

    public func append(module: ModuleLoader) {
        if !modules.contains(where: { $0.identifier == module.identifier }) {
            modules.append(module)
        } else {
            #if DEBUG
            print("⚠️ Duplicated module \(module.identifier)")
            #endif
        }
    }
}

public final class Daddy {
    static var sharedInstance: Daddy?

    private let mainboard: Motherboard

    fileprivate init(mainboard: Motherboard) {
        self.mainboard = mainboard
    }

    public static var shared: Daddy {
        guard let instance = sharedInstance else {
            fatalError("Daddy must be initialized before using")
        }
        return instance
    }

    public static func with(options: Options) -> DaddyComponent {
        DaddyComponent(options: options)
    }

    public func launch<Input>(in window: UIWindow, input: BoardInput<Input>) {
        mainboard.installIntoWindow(window)
        mainboard.activateBoard(input)
    }
}