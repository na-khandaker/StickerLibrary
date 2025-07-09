//
//  GIFKBFavouritManager.swift
//  GIF Maker Pro
//
//  Created by BCL Device 22 on 15/12/24.
//

import Foundation

class GIFKBFavouritManager{
    private var userDefault : UserDefaults = .standard
    static let shared : GIFKBFavouritManager = .init()
    private init(){
        
    }
    
//    private func save(_ items : [TenorResult])-> Bool{
//        do{
//            let data = try  NSKeyedArchiver.archivedData(withRootObject: items, requiringSecureCoding: false)
//            userDefault.set(data, forKey: FAVORITES_KEY)
//            userDefault.synchronize()
//            return true
//        }catch{
//            print(error.localizedDescription)
//        }
//        return false
//        
//    }
    
//    func getAllFavourite()-> [TenorResult]{
//        let data = userDefault.data(forKey: FAVORITES_KEY)
//        if let data = data{
//            do{
//                let results = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [TenorResult] ?? []
//                return results
//            }catch{
//                debugPrint(error.localizedDescription)
//            }
//            
//            return []
//        }
//        return  []
//    }
//    func addFavourite(_ item : TenorResult)-> Bool{
//        var allFavourite = getAllFavourite()
//        if !allFavourite.contains(item){
//            allFavourite.append(item)
//        }
//        return save(allFavourite)
//    }
//    func removeFavourite(_ item : TenorResult)-> Bool{
//        var allFavourite = getAllFavourite()
//        if let indx = allFavourite.firstIndex(where: {$0.id == item.id}){
//            allFavourite.remove(at: indx)
//        }
//        return save(allFavourite)
//    }
//    func isFavourit(_ item : TenorResult)-> Bool{
//        let allFavourite = getAllFavourite()
//        return allFavourite.filter({$0.id == item.id}).count == 1
//    }
//
    private func save(_ items : [GIFModel])-> Bool{
        return true
        //return userDefault.setObject(items, forKey: "FAVORITES_KEY")
//        do{
//            let data = try  NSKeyedArchiver.archivedData(withRootObject: items, requiringSecureCoding: false)
//            userDefault.set(data, forKey: FAVORITES_KEY)
//            userDefault.synchronize()
//            return true
//        }catch{
//            print(error.localizedDescription)
//        }
//        return false
        
    }
    func getAllFavourite()-> [GIFModel]{
        return []
      //  return userDefault.getObject(forKey: FAVORITES_KEY, castTo: [GIFModel].self)?.filter({$0.height != nil && $0.width != nil}) ?? []
    }
    
    func addFavourite(_ item : GIFModel)-> Bool{
        var allFavourite = getAllFavourite()
        if !allFavourite.contains(where: {$0.id == item.id}){
            allFavourite.append(item)
        }
        return save(allFavourite)
    }
    func removeFavourite(_ item : GIFModel)-> Bool{
        var allFavourite = getAllFavourite()
        if let indx = allFavourite.firstIndex(where: {$0.id == item.id}){
            allFavourite.remove(at: indx)
        }
        return save(allFavourite)
    }
    func isFavourit(_ item : GIFModel)-> Bool{
        let allFavourite = getAllFavourite()
        return allFavourite.filter({$0.id == item.id}).count == 1
    }
}
