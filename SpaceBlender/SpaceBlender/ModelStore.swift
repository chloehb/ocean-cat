//
//  ModelStore.swift
//  SpaceBlender
//
//  Created by akai on 10/7/23.
//

import Foundation
import RoomPlan
import CoreData

struct RoomModel {
    var identifier: UUID?
    var name: String?
    var model: CapturedRoom?
    var date: String?
    var image: String?
    var adjustment: AttachedResult? = nil
}

func getDataFromAttachedResult(packet: AttachedResult) -> Data? {
    do{
        let data = try PropertyListEncoder.init().encode(packet)
        return data
    }catch let error as NSError{
        print(error.localizedDescription)
    }
    return nil
}

func getAttachedResultFromData(data: Data) -> AttachedResult?{
    do{
        let packet = try PropertyListDecoder.init().decode(AttachedResult.self, from: data)
        return packet
    }catch let error as NSError{
        print(error.localizedDescription)
    }
    return nil
}

func getDataFromCapturedRoom(packet: CapturedRoom) -> Data?{
    do{
        let data = try PropertyListEncoder.init().encode(packet)
        
        return data
    }catch let error as NSError{
        print(error.localizedDescription)
    }
    return nil
}

func getCapturedRoomFromData(data: Data) -> CapturedRoom?{
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
    let clearAllAdjustment = false
    
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
                    if let adj = eachModel.adjustment {
                        print("find stored adjustment for model")
                        if !clearAllAdjustment {
                            let fetchedModel = RoomModel(identifier: eachModel.identifier, name: eachModel.name, model: getCapturedRoomFromData(data: eachModel.model!), date: eachModel.date, image: eachModel.image, adjustment: getAttachedResultFromData(data: adj))
                            models.append(fetchedModel)
                        } else {
                            print("set to clear all adjustments")
                            let fetchedModel = RoomModel(identifier: eachModel.identifier, name: eachModel.name, model: getCapturedRoomFromData(data: eachModel.model!), date: eachModel.date, image: eachModel.image)
                            models.append(fetchedModel)
                        }
                    } else {
                        print("can't find stored adjustment for model")
                        let fetchedModel = RoomModel(identifier: eachModel.identifier, name: eachModel.name, model: getCapturedRoomFromData(data: eachModel.model!), date: eachModel.date, image: eachModel.image)
                        models.append(fetchedModel)
                    }
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
            let newModelData = RoomModelData(context: context)
            newModelData.identifier = model.identifier
            newModelData.name = model.name
            newModelData.date = model.date
            newModelData.image = model.image
            newModelData.model = getDataFromCapturedRoom(packet: model.model!)
            if let adj = model.adjustment {
                newModelData.adjustment = getDataFromAttachedResult(packet: adj)
            } else {
                newModelData.adjustment = nil
            }
            do {
                try context.save()
            } catch {
                print("error when try to store newly added model: \(error)")
            }
        } else {
            print("The number of stored model mismatch. Fail to store.")
        }
    }
    func storeAdjustment(_ index: Int) {
        let context = PersistenceController.shared.container.viewContext
        // check the number of current models = context models + 1
        let fetchRequest: NSFetchRequest<RoomModelData> = RoomModelData.fetchRequest()
        if let adjustment = models[index].adjustment {
            do {
                let roomModels = try context.fetch(fetchRequest)
                if roomModels.count > index && index >= 0 {
                    roomModels[index].adjustment = getDataFromAttachedResult(packet: adjustment)
                    try context.save()
                    print("save adjustment ok")
                } else {
                    print("invalid index \(index)")
                }
            
            } catch {
                print("error when fetching stored models: \(error)")
            }
        }
        
    }
}
