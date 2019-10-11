//
//  JSONParser.swift
//  OnMap
//
//  Created by Varosyan, Anna on 04.09.19.
//  Copyright © 2019 Varosyan, Anna. All rights reserved.
//

import Foundation

class JSONParser {
    static func encode<T: Encodable>(_ codable: T) -> String {
        do {
            let jsonData = try JSONEncoder().encode(codable)
            return String(data: jsonData, encoding: .utf8)!
        }
        catch {
            print(ErrorType.json_encoding + ": \(error.localizedDescription)")
            return ""
        }
    }
    
    static func decode<T : Decodable>(_ data: Data) -> T? {
        do {
            return try JSONDecoder().decode(T.self, from: data)
        }
        catch {
            print(ErrorType.json_decoding + " \(T.self): \(error.localizedDescription)")
            return nil
        }
    }
    
    static func deserialize(_ data: Data) -> AnyObject? {
        var deserializationResult: AnyObject! = nil
        do {
            deserializationResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            print(ErrorType.json_deserializing + ": \(error.localizedDescription)")
        }
        return deserializationResult
    }
}
