//
//  ConfigurationKeys.swift
//  RSA-iOS
//
//  Created by MacBook on 03/08/21.
//

import UIKit

class CryptoCore {
    
    private var aliasKey: String? = nil
    
    private var publicKey: SecKey? = nil
    private var privateKey: SecKey? = nil
    
    init(aliasKey: String?, publicKey: String?) {
        self.aliasKey = aliasKey
        
        /**
         * If public key was sent through constructor generates valid public key to encrypt
         */
        if publicKey != nil {
            do {
                try _buildPublicKey(publicKey: publicKey!)
            } catch let error {
                print(error.localizedDescription)
            }
        }
        /**
         * If alias name was sent through constructor initialize a CryptoStorageHelper instance
         */
        if self.aliasKey != nil {
            do {
                try _buildCryptoKeys()
            } catch let error {
                print(error.localizedDescription)
            }
        }
        /**
         * If alias name and public key are not defined generate new RSA keys
         */
        if (aliasKey == nil && publicKey == nil) {
            _generateKeyPairs()
        }
    }
    
    /**
     * Creates an valid publicKey from an string publicKey value
     */
    private func _buildPublicKey(publicKey: String) throws -> Void {
        if publicKey.isEmpty {
            throw CryptoException.init("Public Key vacia")
        }
        
        let decodedPublicKey: Data = publicKey.data(using: .utf8)!
        let keyWithX509: SecKey = X509EncodedKeySpec(encodedKey: decodedPublicKey)
        
        self.publicKey = keyWithX509
    }
    /**
     * Creates an valid publicKey from an string publicKey value
     */
    private func X509EncodedKeySpec(encodedKey: Data) -> SecKey {
        let keyWithX509: Data = _X509PublicKey(key: encodedKey)!
        
        let attributes: [String:Any] = [
            String(kSecAttrKeyType)        : Constants.ALGORITHM_KEY_PAIR,
            String(kSecAttrKeyClass)       : kSecAttrKeyClassPublic,
            String(kSecAttrKeySizeInBits)  : Constants.KEY_PAIR_SIZE,
            String(kSecAttrApplicationTag) :  self.aliasKey! + Constants.PUBLIC_SUFFIX
        ]
        
        return SecKeyCreateWithData(keyWithX509 as CFData, attributes as CFDictionary, nil)!
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
    
    
    /// Generacion de llaves publica y privada
    private func _buildCryptoKeys() throws -> Void {
        let privateKey: String? = Keychain.shared.getSecKey(tag: (self.aliasKey! + Constants.PRIVATE_SUFFIX))
        
        if privateKey != nil {
            
        } else {
            
        }
    }
    
    
    /**
     * Generates new RSA keys
     */
    private func _generateKeyPairs() -> Void {
        let publicKeyAttr: [NSString: Any] = [
            kSecAttrIsPermanent: NSNumber(value: true),
            kSecAttrApplicationTag: self.aliasKey! + Constants.PUBLIC_SUFFIX
        ]
        let privateKeyAttr: [NSString: Any] = [
            kSecAttrIsPermanent: NSNumber(value: true),
            kSecAttrApplicationTag: self.aliasKey! + Constants.PRIVATE_SUFFIX
        ]
        
        let keyPairAttr = [
            kSecAttrKeyType: Constants.ALGORITHM_KEY_PAIR,
            kSecAttrKeySizeInBits: Constants.KEY_PAIR_SIZE as NSObject,
            kSecPublicKeyAttrs: publicKeyAttr,
            kSecPrivateKeyAttrs: privateKeyAttr
        ] as CFDictionary
        
        var publicKey: SecKey?
        var privateKey: SecKey?
        var statusCode: OSStatus
        
        // Crea un par de claves asimétricas.
        statusCode = SecKeyGeneratePair(keyPairAttr, &publicKey, &privateKey)
        
        if statusCode == noErr && publicKey != nil && privateKey != nil {
            print("Llaves creadas")
        } else {
            print("Error generating key pair: \(statusCode)")
        }
        
        self.publicKey = publicKey
        self.privateKey = privateKey
    }
    
    /**
     * Saves current RSA keys
     */
    private func _saveRSAKeys(alias: String) -> Void {
        Keychain.shared.set(tag: alias + Constants.PRIVATE_SUFFIX, value: _convertSeckeyToData(key: self.privateKey!), keyClass: kSecAttrKeyClassPrivate)
        Keychain.shared.set(tag: alias + Constants.PUBLIC_SUFFIX, value: _convertSeckeyToData(key: self.publicKey!), keyClass: kSecAttrKeyClassPublic)
    }
    
    /**
     * Cobnvierte un Seckey a Data
     */
    private func _convertSeckeyToData(key: SecKey) -> Data {
        var error:Unmanaged<CFError>?
        return SecKeyCopyExternalRepresentation(key, &error)! as Data
    }
    
    /**
     * Creates an valid privateKey from an string privateKey value
     */
    private func _buildPrivateKey(key: SecKey) {
        // agregar encabezado de PKS8
        self.privateKey = key
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
    
    
    /**
     * Obtain public key to Crypto
     *
     *  @return Public key data
     */
    public func getPublicKey() throws -> String {
        
        return ""
    }
    
    
    
    public class CryptoException: NSError {
        init(_ message: String) {
            super.init(domain: "com.iherrera.test.RSA-iOS.CryptoCore", code: 500, userInfo: [
                NSLocalizedDescriptionKey: message
            ])
        }
        
        @available(*, unavailable)
        required public init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
