//
//  ModelStore.swift
//  SpaceBlender
//
//  Created by akai on 10/7/23.
//

import Foundation
import RoomPlan

final class ModelStore: ObservableObject {
    static let shared = ModelStore() // create one instance of the class to be shared
    private init() {}
    var models = [CapturedRoom]()
}
