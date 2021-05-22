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
}

public final class DaddyComponent {
    private let options: Options

    private var container = BoardContainer()

    private var plugins: [ModulePlugin] = []
    private var modules: [ModuleLoader] = []

    var producer: ActivableBoardProducer { container }

    init(options: Options) {
        self.options = options
    }

    func append(plugin: ModulePlugin) {
        plugins.append(plugin)
    }

    public func initialize() {
        plugins.forEach { $0.apply(for: self) }
    }
}

extension DaddyComponent: MainComponent {
    func append(module: ModuleLoader) {
        if !modules.contains(where: { $0.identifier == module.identifier }) {
            modules.append(module)
        } else {
            #if DEBUG
            print("⚠️ Duplicated module \(module.identifier)")
            #endif
        }
    }

    public func registerBoard(_ factory: @escaping (BoardID) -> ActivatableBoard, with identifier: BoardID) {
        container.register({ factory(identifier) }, forId: identifier)
    }
}

public final class Daddy {
    static var sharedInstance: Daddy?

    private init() {}

    public static var shared: Daddy {
        guard let instance = sharedInstance else {
            fatalError("Daddy must be initialized before using")
        }
        return instance
    }

    public static func with(options: Options = Options()) -> DaddyComponent {
        DaddyComponent(options: options)
    }
}
