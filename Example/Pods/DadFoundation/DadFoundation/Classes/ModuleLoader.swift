//
//  CoreModuleInterface.swift
//  DadFoundation
//
//  Created by NGUYEN CHI CONG on 5/14/21.
//

import Boardy
import Foundation

/// For container module which loads and activates feature modules.
public protocol ModuleContainer {
    func registerBoard(_ identifier: BoardID, producer: @escaping (BoardID) -> ActivatableBoard)
}

extension ModuleContainer {
    public func registerBoard(_ identifier: BoardID, producedBy producer: ActivableBoardProducer) {
        self.registerBoard(identifier) { id in
            producer.produceBoard(identifier: id) ?? NoBoard()
        }
    }
}

/// For feature module which will be loaded in container.
public protocol ModuleLoader {
    var identifier: BoardID { get }

    func load(in container: ModuleContainer)
}
