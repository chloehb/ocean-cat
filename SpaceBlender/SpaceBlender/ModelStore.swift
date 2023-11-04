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
    
    // if errors like "Fail to store." occurs, set it to true and rebuild the app, then set back to false and everything should be ok
    let clearAllWhenInit = false
    
    private init() {
        let context = PersistenceController.shared.container.viewContext
        let fetchRequest: NSFetchRequest<RoomModelData> = RoomModelData.fetchRequest()
        
        if clearAllWhenInit {
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
            do {
                try context.execute(deleteRequest)
            } catch {
                // Handle the error
            }
        }

        do {
            let roomModels = try context.fetch(fetchRequest)
            if !roomModels.isEmpty {
                for eachModel in roomModels {
                    let name = eachModel.name
                    let fetchedModel = RoomModel(identifier: eachModel.identifier, name: eachModel.name, model: getPacketFromData(data: eachModel.model!), date: eachModel.date, image: eachModel.image)
                    models.append(fetchedModel)
                }
            }
            // Convert roomModels to your RoomModel struct as needed
        } catch {
            print("error when fetching stored models: \(error)")
        }
    }
    @Published var models = [RoomModel]()
    func addNewModel(_ model: RoomModel) {
        // first append the newly added model
        self.models.append(model)
        let context = PersistenceController.shared.container.viewContext
        // check the number of current models = context models + 1
        let fetchRequest: NSFetchRequest<RoomModelData> = RoomModelData.fetchRequest()
        var isLegalCount = false
        do {
            let roomModels = try context.fetch(fetchRequest)
            print(roomModels.count)
            print(models.count)
            if roomModels.count + 1 == models.count {
                isLegalCount = true
            } else {
                
            }
        } catch {
            print("error when fetching stored models: \(error)")
        }
        // sync with core data
        if isLegalCount {
            let model = models.last!
            let newModelData = RoomModelData(context: context)
            newModelData.identifier = model.identifier
            newModelData.name = model.name
            newModelData.date = model.date
            newModelData.image = model.image
            newModelData.model = getDataFromPacket(packet: model.model!)
            do {
                try context.save()
            } catch {
                print("error when try to store newly added model: \(error)")
            }
        } else {
            print("The number of stored model mismatch. Fail to store.")
        }
    }
}
