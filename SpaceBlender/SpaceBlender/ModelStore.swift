//
//  ModelStore.swift
//  SpaceBlender
//
//  Created by akai on 10/7/23.
//

import Foundation
import RoomPlan

struct RoomModel {
    var identifier: UUID?
    var name: String?
    var model: CapturedRoom?
    var date: String?
    var image: String?
}

final class ModelStore: ObservableObject {
    static let shared = ModelStore() // create one instance of the class to be shared
    private init() {}
    @Published var models = [RoomModel]()
    func addNewModel(_ model: RoomModel) {
        self.models.append(model)
    }
}
