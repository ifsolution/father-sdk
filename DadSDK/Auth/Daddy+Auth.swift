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
    var identifier: BoardID
    var exProducer: SomeExProducer
    var exDepsFac: () -> Any

    func load(in container: ModuleContainer) {
        container.registerBoard(identifier) { identifier in
            NoBoard(identifier: identifier) { _ in
                print("Activate Board => \(identifier)")
            }
        }
    }
}

public struct AuthPlugin: ModulePlugin {
    public let identifier: BoardID

    let some1: BoardID
    let some2: BoardID

    public init(identifier: BoardID, some1Destination: BoardID, some2Destination: BoardID) {
        self.identifier = identifier
        some1 = some1Destination
        some2 = some2Destination
    }

    public func apply(for main: MainComponent) {
        struct ExProducer: SomeExProducer {
            let producer: ActivableBoardProducer
            let some1: BoardID
            let some2: BoardID

            func produce(identifier: SomeID) -> ActivatableBoard {
                var result: ActivatableBoard?
                switch identifier {
                case .some1:
                    result = producer.produceBoard(identifier: some1)
                case .some2:
                    result = producer.produceBoard(identifier: some2)
                }
                return result ?? NoBoard()
            }
        }

        let module = SomeModuleLoader(identifier: identifier, exProducer: ExProducer(producer: main.producer, some1: some1, some2: some2)) {
            print("An external factory come here")
        }
        module.load(in: main)
    }
}
