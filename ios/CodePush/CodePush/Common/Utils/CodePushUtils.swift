//
//  CodePushUtils.swift
//  CodePush
//
//  Copyright © 2018 MSFT. All rights reserved.
//

import Foundation

class CodePushUtils {
    
    static let sharedInstance = CodePushUtils()
    
    var fileUtils: FileUtils
    
    private init() {
        self.fileUtils = FileUtils.sharedInstance
    }
    
    /**
     * Parses {@link JSONObject} from file.
     *
     * Parameter filePath path to file.
     * Returns: parsed {@link JSONObject} instance.
     * Throws: CodePushMalformedDataException error thrown when actual data is broken (i .e. different from the expected).
     */
    func getJsonObjectFromFile(atPath filePath: URL) throws -> Data {
        let contents = try fileUtils.readFileToString(atPath: filePath)
        return contents.data(using: .utf8)!
    }
    
    /**
     * Converts {@link Object} instance to json string.
     *
     * Parameter object {@link JSONObject} instance.
     * Returns: the json string.
     */
    func convertObjectToJsonString<T>(withObject object: T) throws -> String where T: Codable  {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(object)
        return String(data: data, encoding: .utf8)!
    }
    
    /**
     * Gets information from json file and converts it to an object of specified type.
     *
     * Parameter filePath path to file with json contents.
     * Parameter <T>      the type of the desired object.
     * Returns: object of type T.
     * Throws: CodePushMalformedDataException exception during parsing data.
     */
    func getObjectFromJsonFile<T>(_ filePath: URL) throws -> T where T: Codable {
        let json = try getJsonObjectFromFile(atPath: filePath)
        let decoder = JSONDecoder()
        let object = try decoder.decode(T.self, from: json)
        return object
    }
    
    /**
     * Saves object of specified type to a file as json string.
     *
     * Parameter object   object to be saved.
     * Parameter filePath path to file.
     * Parameter <T>      the type of the desired object.
     * Throws: IOException read/write error occurred while accessing the system.
     */
    func writeObjectToJsonFile<T>(withObject object: T, atPath filePath: URL) throws where T: Codable {
        let jsonString = try convertObjectToJsonString(withObject: object)
        try fileUtils.writeToFile(withContent: jsonString, atPath: filePath)
    }
    
    /**
     * Writes {@link JSONObject} to file.
     *
     * Parameter json     {@link JSONObject} instance.
     * Parameter filePath path to file.
     * Throws: IOException read/write error occurred while accessing the file system.
     */
    func writeJsonToFile(withJson json: Data, atPath filePath: URL) throws {
        let jsonString = String(data: json, encoding: .utf8)
        try fileUtils.writeToFile(withContent: jsonString!, atPath: filePath)
    }
    
    /**
     * Converts {@link Object} instance to {@link JSONObject}.
     *
     * Parameter object {@link JSONObject} instance.
     * Returns: {@link JSONObject} instance.
     * Throws: JSONException error occurred during parsing a json object.
     */
    func convertObjectToJsonObject<T>(withObject object: T) throws -> Data where T: Codable {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(object)
        return data
    }
    
    /**
     * Converts json string to specified class.
     *
     * Parameter stringObject json string.
     * Parameter classOfT     the class of T.
     * Parameter <T>          the type of the desired object.
     * Returns: instance of T.
     */
    func convertStringToObject<T>(withString json: String) throws -> T where T: Codable {
        let data = json.data(using: .utf8)
        let decoder = JSONDecoder()
        let object = try decoder.decode(T.self, from: data!)
        return object
    }
    
    /**
     * Converts object to query string using the following scheme: <br/>
     * <ul>
     * <li>object converts to JSON</li>
     * <li>JSON instance converts to {@link Map}&lt;String, Object&gt;
     * using field names as keys for Map and its values as values for Map;</li>
     * <li>iterates through {@link Map}&lt;String, Object&gt; instance and builds query string.</li>
     * </ul>
     *
     * Parameter object      object.
     * Returns: an array of query items
     * Throws: CodePushMalformedDataException error thrown when actual data is broken (i .e. different from the expected).
     */
    func getQueryItems(fromObject object: CodePushUpdateRequest) -> [URLQueryItem] {
        
        //        let mirror = Mirror(reflecting: object)
        //        var items = [URLQueryItem]()
        //
        //        for (_, attr) in mirror.children.enumerated() {
        //            if (attr.value != nil) {
        //                items.append(URLQueryItem(name: attr.label!, value: attr.value as? String))
        //            }
        //        }
        
        var items = [URLQueryItem]()
        
        items.append(URLQueryItem(name: "appVersion", value: object.appVersion))
        items.append(URLQueryItem(name: "clientUniqueId", value: object.clientUniqueId))
        items.append(URLQueryItem(name: "deploymentKey", value: object.deploymentKey))
        items.append(URLQueryItem(name: "packageHash", value: object.packageHash))
        items.append(URLQueryItem(name: "label", value: object.label))
        
        return items
    }
}
