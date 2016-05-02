//
//  AppConfiguration.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 01/05/16.
//
//

/// Protocol defining access to the root wireframe instance
protocol AppConfiguration {
    var wireframe: MainWireframe { get }
}
