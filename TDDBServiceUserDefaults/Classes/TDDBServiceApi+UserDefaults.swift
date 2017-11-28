//
//  DBServiceApi+UserDefaults.swift
//  TDDBService
//
//  Created by Yapapp on 16/11/17.
//

import Foundation
import TDResult
import TDDBService

extension String: TDDBEntity{}

extension Dictionary: TDDBData{}
extension NSDictionary: TDDBData{}
extension Array: TDDBData{}
extension NSArray: TDDBData{}
extension String: TDDBData{}
extension NSString: TDDBData{}
extension Date: TDDBData{}
extension NSDate: TDDBData{}
extension NSNumber: TDDBData{}

public class TDDBServiceApiUserDefaults: TDDBServiceApi{
    
    public init(){}
    
    public var request: TDDBServiceRequest?
    var data: TDDBData?
    var entityValue: String?
    var completionHandler: TDDBFetchCompletionClosure?
    
    public func call(_ request: TDDBServiceRequest, completionHandler: @escaping TDDBFetchCompletionClosure){
        //1.
        self.request = request
        self.completionHandler = completionHandler
        
        //2.
        setupEntityValue()
        if !isEntityValid(){
            DispatchQueue.main.async {[weak self] in
                self?.completionHandler?(TDResult.Error(TDError.init(TDDBServiceError.invalidEntityType, code: nil, description: "Entity Type must be String for TDDBServiceApiUserDefaults")))
                return
            }
            
        }
        //3.
        setupDBData()
        if !isDataValid(){
            DispatchQueue.main.async {[weak self] in
                self?.completionHandler?(TDResult.Error(TDError.init(TDDBServiceError.invalidEntityType, code: nil, description: "Data is not valid for TDDBServiceApiUserDefaults - Please pass the data in Data format for custom type objects")))
                return
            }
        }
        
        let methodType = request.methodType
        switch methodType{
        case .insert:
            insert()
        case .fetch:
            fetch()
        case .delete:
            delete()
        case .update:
            update()
        }
        
    }
    
    func isEntityValid()->Bool{
        if entityValue == nil{
            return false
        }
        if entityValue?.characters.count == 0{
            return false
        }
        return true
    }
    
    func setupEntityValue(){
        let entity = self.request?.entity
        entityValue = entity as? String
    }
    
    func setupDBData(){
        data = request?.data
    }
    
    func isDataValid()->Bool{
        var isValid = false
        if let _ = data as? Dictionary<String, Any>{
            isValid = true
        }
        if let _ = data as? NSDictionary{
            isValid = true
        }
        if let _ = data as? Array<Any>{
            isValid = true
        }
        if let _ = data as? NSArray{
            isValid = true
        }
        if let _ = data as? String{
            isValid = true
        }
        if let _ = data as? NSString{
            isValid = true
        }
        if let _ = data as? Date{
            isValid = true
        }
        if let _ = data as? NSDate{
            isValid = true
        }
        if let _ = data as? NSNumber{
            isValid = true
        }
        return isValid
    }
    
    
    func insert(){
        let storeData = NSKeyedArchiver.archivedData(withRootObject: self.data as Any)
        UserDefaults.standard.setValue(storeData, forKey: entityValue!)
        DispatchQueue.main.async {[weak self] in
            self?.completionHandler?(TDResult.Success(TDDBResponse.init(request: self?.request, data: self?.data)))
        }
    }
    func fetch(){
        let storedData = UserDefaults.standard.value(forKey: entityValue!)
        if storedData == nil{
            DispatchQueue.main.async {[weak self] in
                self?.completionHandler?(TDResult.Error(TDError.init(TDDBServiceError.noRecordFound)))
            }
            return
        }
        let object = NSKeyedUnarchiver.unarchiveObject(with: storedData as! Data) as? TDDBData
        DispatchQueue.main.async {[weak self] in
            self?.completionHandler?(TDResult.Success(TDDBResponse.init(request: self?.request, data: object)))
        }
    }
    
    func delete(){
        UserDefaults.standard.removeObject(forKey: entityValue!)
        DispatchQueue.main.async {[weak self] in
            self?.completionHandler?(TDResult.Success(TDDBResponse.init(request: self?.request, data: nil)))
        }
    }
    
    func update(){
        insert()
    }
}
