//
//  Daddy.swift
//  DadSDK
//
//  Created by FOLY on 5/22/21.
//

import Boardy
import DadFoundation
import Foundation

public final class DaddyComponent {
    public let options: MainOptions

    private var container = BoardProducer(registrations: [])

    private var plugins: [ModulePlugin] = []
    private var flowRegistrations: [(FlowMotherboard) -> Void] = []

    init(options: MainOptions) {
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

    public func install(plugins: [ModulePlugin]) -> Self {
        for plugin in plugins {
            _ = append(plugin: plugin)
        }
        return self
    }

    public func install(plugin: ModulePlugin,
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
    public var producer: BoardDynamicProducer { container }
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

    public static func with(options: MainOptions) -> DaddyComponent {
        DaddyComponent(options: options)
    }

    public func launch<Input>(on rootObject: AnyObject, input: BoardInput<Input>) {
        launch(on: rootObject) { mainboard in
            mainboard.activateBoard(input)
        }
    }

    public func launch(on rootObject: AnyObject, action: (_ mainboard: FlowMotherboard) -> Void) {
        #if DEBUG
        if mainboard.root != nil, mainboard.root !== rootObject {
            print("⚠️ Motherboard \(mainboard) will change root from \(mainboard.root) to \(rootObject)")
        }
        #endif

        mainboard.installIntoRoot(rootObject)
        action(mainboard)
    }

    public func activateNow(_ action: (_ mainboard: FlowMotherboard) -> Void) {
        guard mainboard.root != nil else {
            assertionFailure("🚧 Motherboard \(mainboard) was not installed. DadSDK must be launched before activating modules.")
            return
        }
        action(mainboard)
    }
}
