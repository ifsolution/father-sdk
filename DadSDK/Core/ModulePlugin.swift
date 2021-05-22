//
//  ModulePlugin.swift
//  DadSDK
//
//  Created by FOLY on 5/22/21.
//

import Boardy
import DadFoundation
import Foundation

protocol MainComponent: ModuleContainer {
    /// Main producer
    var producer: ActivableBoardProducer { get }

    func append(module: ModuleLoader)
}

protocol ModulePlugin {
    func apply(for main: MainComponent)
}
