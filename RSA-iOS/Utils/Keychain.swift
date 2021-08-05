//
//  Keychain.swift
//  RSA-iOS
//
//  Created by MacBook on 03/08/21.
//

import UIKit

public class Keychain {
    
    /// Class method access.
    public static let shared = Keychain()
    
    /// Almacenar llave en Keychain
    public func set(tag: String, value: Data, keyClass: CFString) -> Void
    {
        let query = [
            String(kSecClass)              : kSecClassKey,
            String(kSecAttrKeyType)        : kSecAttrKeyTypeRSA,
            String(kSecAttrApplicationTag) : tag,
            String(kSecValueData)          : value,
            String(kSecAttrKeyClass)       : keyClass,
            String(kSecReturnPersistentRef): true
        ] as CFDictionary
        
        SecItemDelete(query)
        
        let result = SecItemAdd(query, nil)
        
        if (result != noErr) {
            print("Error al guardar en KeyChain")
        }
        
        print("Llave almacenada \(tag)")
    }
    
    /// Retorna una SecKey si esta se encuentra en el Keychain
    public func getSecKey(tag: String) -> SecKey?
    {
        let query = [
            String(kSecClass)               : kSecClassKey,
            String(kSecAttrKeyType)         : kSecAttrKeyTypeRSA,
            String(kSecAttrApplicationTag)  : tag as AnyObject,
            String(kSecReturnRef)           : true as AnyObject
        ] as CFDictionary
        
        var dataTypeRef: AnyObject?
        let result = SecItemCopyMatching(query, &dataTypeRef)
        
        if ( result != noErr || dataTypeRef == nil ) {
            return nil
        }
        
        return dataTypeRef as! SecKey?
    }
    /// Elimnar una llave criptográfica
    public func deleteKey(tag: String) -> Void {
        let query = [
            String(kSecClass)             : kSecClassKey,
            String(kSecAttrKeyType)       : kSecAttrKeyTypeRSA,
            String(kSecAttrApplicationTag): tag as AnyObject
        ] as CFDictionary
        
        let result = SecItemDelete(query)
        
        if (result != noErr) {
            print("No existia la llave buscada")
        } else {
            print("Llave encontrada y eliminada")
        }
    }
}
