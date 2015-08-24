//
//  File.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 2/20/15.
//
//

import Foundation
import SwiftTask

protocol ComicNetworkDataSource {
    func downloadComicOfKind(kind: ComicKind) -> Task<NormalizedProgressValue, Comic, ErrorType>
}