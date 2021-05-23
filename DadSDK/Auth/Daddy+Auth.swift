//
//  Daddy+Auth.swift
//  DadSDK
//
//  Created by FOLY on 5/22/21.
//

import Boardy
import DadFoundation
import Foundation

enum SomeID {
    case some1
    case some2
}

protocol SomeExProducer {
    func produce(identifier: SomeID) -> ActivatableBoard
}

struct SomeModuleLoader: ModuleLoader {
    var identifier: String { id.rawValue }

    let id: BoardID
    var exProducer: SomeExProducer
    var exDepsFac: () -> Any

    func load(in container: ModuleContainer) {
        container.registerBoard({ (identifier) -> ActivatableBoard in
            NoBoard(identifier: identifier) { _ in
                print("Activate Board => \(identifier)")
            }
        }, with: id)
    }
}

struct AuthPlugin: ModulePlugin {
    func apply(for main: MainComponent) {
        struct ExProducer: SomeExProducer {
            let producer: ActivableBoardProducer

            func produce(identifier: SomeID) -> ActivatableBoard {
                var result: ActivatableBoard?
                switch identifier {
                case .some1:
                    result = producer.produceBoard(identifier: "pub-some-1")
                case .some2:
                    result = producer.produceBoard(identifier: "pub-some-2")
                }
                return result ?? NoBoard()
            }
        }

        func apply(for main: MainComponent) {
            let module = SomeModuleLoader(id: "some", exProducer: ExProducer(producer: main.producer)) {
                print("An external factory come here")
            }
            main.append(module: module)
        }
    }
}

extension DaddyComponent {
    public func enableAuth() -> Self {
        append(plugin: AuthPlugin())
        return self
    }
}
