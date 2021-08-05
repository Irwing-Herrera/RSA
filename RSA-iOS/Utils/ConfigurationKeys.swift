//
//  ConfigurationKeys.swift
//  RSA-iOS
//
//  Created by MacBook on 03/08/21.
//

import UIKit

class ConfigurationKeys {
    
    /// Class method access.
    public static let shared = ConfigurationKeys()
    
    /// Generacion de llaves publica y privada
    public func _generateKeys(alias: String) -> (public: SecKey, private:  SecKey)  {
        let PUBLIC_SUFFIX = alias + ".pub"
        let PRIVATE_SUFFIX = alias + ".key"
        
        let publicKey: SecKey? = Keychain.shared.getSecKey(tag: PUBLIC_SUFFIX)
        let privateKey: SecKey? = Keychain.shared.getSecKey(tag: PRIVATE_SUFFIX)
        
        if publicKey == nil && privateKey == nil {
            let publicKeyAttr: [NSString: Any] = [
                kSecAttrIsPermanent: NSNumber(value: true),
                kSecAttrApplicationTag: PUBLIC_SUFFIX
            ]
            let privateKeyAttr: [NSString: Any] = [
                kSecAttrIsPermanent: NSNumber(value: true),
                kSecAttrApplicationTag: PRIVATE_SUFFIX
            ]
            
            let keyPairAttr = [
                kSecAttrKeyType: kSecAttrKeyTypeRSA,
                kSecAttrKeySizeInBits: 2048 as NSObject,
                kSecPublicKeyAttrs: publicKeyAttr,
                kSecPrivateKeyAttrs: privateKeyAttr
            ] as CFDictionary
            
            var newPublicKey: SecKey?
            var newPrivateKey: SecKey?
            var statusCode: OSStatus
            
            /// Crea un par de claves asimétricas.
            statusCode = SecKeyGeneratePair(keyPairAttr, &newPublicKey, &newPrivateKey)
            
            if statusCode == noErr && newPublicKey != nil && newPrivateKey != nil {
                print("Llaves creadas")
            } else {
                print("Error generating key pair: \(statusCode)")
            }
            
            return (newPublicKey!, newPrivateKey!)
        }
        
        return (publicKey!, privateKey!)
    }
    
    /// Convertir SecKey a Base64
    /// Agrega el header x509 para ser utilizada la llave publica en otras plataformas
    public func secKeyToString(key:SecKey, addExtension: Bool) -> String? {
        var error:Unmanaged<CFError>?
        if let cfData = SecKeyCopyExternalRepresentation(key, &error) {
            
            var llaveCompleta: Data
            var base64KeyString: String
            
            if addExtension {
                llaveCompleta = _X509PublicKey(key: cfData as Data)!
                base64KeyString = llaveCompleta.base64EncodedString()
            } else {
                base64KeyString = (cfData as Data).base64EncodedString()
            }
            return base64KeyString
        }
        
        return nil
    }
    
    
    /// Agrega un header x509 a la llave para poder ser utilizada en otars plataformas
    private func _X509PublicKey(key: Data) -> Data? {
        let result = NSMutableData()
        
        let encodingLength: Int = (key.count + 1).encodedOctets().count
        let OID: [CUnsignedChar] = [0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86,
                                    0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00]
        
        var builder: [CUnsignedChar] = []
        
        // ASN.1 SEQUENCE
        builder.append(0x30)
        
        // Tamaño total, hecho de OID + codificación de cadena de bits + clave real
        let size = OID.count + 2 + encodingLength + key.count
        let encodedSize = size.encodedOctets()
        builder.append(contentsOf: encodedSize)
        result.append(builder, length: builder.count)
        result.append(OID, length: OID.count)
        builder.removeAll(keepingCapacity: false)
        
        builder.append(0x03)
        builder.append(contentsOf: (key.count + 1).encodedOctets())
        builder.append(0x00)
        result.append(builder, length: builder.count)
        
        // Bytes de clave reales
        result.append(key as Data)
        
        let response: Data = result as Data
        
        return response
    }
}
