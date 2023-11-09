//
//  ModelStore.swift
//  SpaceBlender
//
//  Created by akai on 10/7/23.
//

import Foundation
import RoomPlan
import CoreData

struct RoomModel: Codable {
    var identifier: UUID?
    var name: String?
    var model: CapturedRoom?
    var date: String?
    var image: String?
}

func getDataFromPacket(packet: CapturedRoom) -> Data?{
  do{
      let data = try PropertyListEncoder.init().encode(packet)
      
    return data
  }catch let error as NSError{
    print(error.localizedDescription)
  }
    return nil
}

func getPacketFromData(data: Data) -> CapturedRoom?{
    do{
      let packet = try PropertyListDecoder.init().decode(CapturedRoom.self, from: data)
      return packet
    }catch let error as NSError{
      print(error.localizedDescription)
    }
    
    return nil
}

final class ModelStore: ObservableObject {
    static let shared = ModelStore() // create one instance of the class to be shared
    private init() {
        let context = PersistenceController.shared.container.viewContext
        let fetchRequest: NSFetchRequest<RoomModelData> = RoomModelData.fetchRequest()

        do {
            let roomModels = try context.fetch(fetchRequest)
            // todo: add all stored models
            if !roomModels.isEmpty {
                let fetchedModel = RoomModel(identifier: roomModels[0].identifier, name: roomModels[0].name, model: getPacketFromData(data: roomModels[0].model!), date: roomModels[0].date, image: roomModels[0].image)
                models.append(fetchedModel)
            }
            // Convert roomModels to your RoomModel struct as needed
        } catch {
            // Handle the error
        }
    }
    @Published var models = [RoomModel]()
    func addNewModel(_ model: RoomModel) {
        self.models.append(model)
    }
    
    func storeModels() {
        let context = PersistenceController.shared.container.viewContext
        let modelData = RoomModelData(context: context)
        // currently, only store the first model to AllData todo: add all
        modelData.identifier = models[0].identifier
        modelData.name = models[0].name
        modelData.date = models[0].date
        modelData.image = models[0].image
        modelData.model = getDataFromPacket(packet: models[0].model!)
        
        do {
            try context.save()
        } catch {
            // Handle the error
        }
    }
}
