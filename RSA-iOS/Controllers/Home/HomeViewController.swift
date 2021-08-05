//
//  HomeViewController.swift
//  RSA-iOS
//
//  Created by MacBook on 03/08/21.
//

import UIKit

class HomeViewController: UIViewController {
    
    // MARK: - Properties
    private let _publicKeyAndroid: String = "-----BEGIN RSA PUBLIC KEY-----\n" + "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAtTp3zBdRUx0cNZYZYybuc+uL+2Tjb/mhiwKPaMGK9t9k3n8iWvixWLhYjxZWKuqh9Te01/CV8Cj/7trV4UzgkwAOIYbVkLO/F6X4HSfLbXLJk9K1gHYcxhLL15teahkMe2rBR7LBUeO/nKQ9SNaFLWUDKFd+tilHUGx8jo2CTmZOwRnbSnrhaCuyYDjVwkfn32eVO3pI4+K4lDZawWK/dXSydOK3PaILMm9EoU3EgQiSHIw97DIYuOnC1XaQwHPq9AgE88xakWCSGNN1J4Jttfmp7UQ1WbpCA4Xf8d5gE4Teo0ygx2Pima1c7SmyklCFBPFJmlWuazXGfm9o2FrfRQIDAQAB" + "\n-----END RSA PUBLIC KEY-----"
    
    private let _privateKeyAndroid: String = "-----BEGIN RSA PRIVATE KEY-----\n" + "MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCZ2/c8O5SKQAfrbqjN7cXahlTL6XsioEtg2usmIHG1WBNln/Yo4RLuzZ/iLYgcl1dM02cL7LO/4vwlHooMI2QQ1pPLB/2LlOI6Q3+R7KUvXwIKpb5i8y8s9zHqEugnPcivRKyvSUYYZHkop8heZ3h9dYTP7hm8nHoq+GWCj2X0xc2HscA2daZYSElFgkVkxffDMojn6ZWykIIIyehAKz9XWkkebzorLQqQ+SO4EJjxv0dmZFWHbcYEcnUmHpTVy8wiS5efJATcdU58Frjlix/Adxm07LdK8Xihh5aUHzEeHtb073PixaR31QDBCR3NCtqipk+9OPLkIWqvdR6G0daBAgMBAAECggEAQRjs37qzq9TQpP+Sg2KNWlqIqSf1td5NVkL5yA1lHt2Pg2ltPLmSCaDNe2RZWQN9Z99wE38IRHFUzp2/ucgFkAxBxt7wGy0YlJ83a/XMpCDWG8wpo/MRbDyAjXGHcQb2kJWFXLqrYimsi5OFts+fjrF4yoMKt58bH3AuftGOSUP5iuy4gEAOodVSgJ1D41oLTLeUqF5OrRs+GLMOjconxiLLoybdOA3oiHOAfBM90Jn9HEDJ37A+WsFbmfmMFKase8SZUGCd5LWUTOIDXQ0jfIPzRX9jN7X1u7LlnEQc0NO+ZyE1GIvu7jg9iAS+a4INe3MWrpCNweYm+jaYwIFl4wKBgQDPQo+A8Acx/+L4LmWtzTjTj3jrFncP0Hk13DryDxRJa/7xEOLORyku/JPQLg3w0t3vZdEJd0tgH3f1RRFG8ctYrzTW3wHdqgq6bqVMW0EdjftD3z6fGS0yxqi229CIt+pZugQU1z/6mC9G2RbGdW9kQoaBAschpJXE6AQz4WcBFwKBgQC+CpRg5lOUgd43XWZhxVEdnx8u2sujWo0cLOrGfU4/hZVCwRq7A06aLcXiPRflli2hAnk7olw9DOgWPToGf9sWF6Cn/U/5u9Og/MfEfLs4Y8yPgL7NmbnrVatU0A0GKfCs3HUTISKFmlHieIEy7pgF/7uikFVjTgzm6iwvvFg0JwKBgAtP7bcy4qGm/sNe/Ou8jMJ3TTk/k6YIUeVPrOPzUL8lJtgPfOGXXrcS0BqHuPkQ+U4Mt5kVqsaHUSvQ5j2CCwA/J9omd9qaYlWEnn8JaAdt7W3p7GgQnrfrwd+hJcOgjijxjzF4AiTyU3pBdQ3F8Rt+ygqWlTnP2uDRbRFL1yxnAoGBAKXfMhdJshXjLIQCf8RCp0RFiMAqtKdF9/hptBm/cTa8b8UuKxikEE0+OoP3cw4vAHCSaiKE2iFnTINsuWLG4gDsaot17AI70MGpIOv9OqRDZ16xrthhnwcrZTnHxjZlEO6wFXe26hzWzzXunEZKPmKuDaYceIsOqvA54Ithx1LtAoGBAJnCKd3SZUdxUjsLUAixsvBAwc0wh3rh8j0rzv2yMqPEQ85Z6AcABeQpnAKFDUNySx4q1dDc8I6cIc0gCPL40wRlhmPDqkD2AtgZvPar17iScWota99Z5357je/APuyY49AprIS1CUmLklKyMTByLTilvKaSYmJCItD3p1C+TSmB" + "\n-----END RSA PRIVATE KEY-----"
    
    
    private var _publicKeyiOS: String = ""
    private var _privateKeyiOS: String = ""
    private let _plainText: String = "this is a testing test"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //_encryptWithIOSKeys()
        _encryptWithAndroidKeys()
    }
    
    /// Cifrar mediante las llaves generadas en iOS
    private func _encryptWithIOSKeys() {
        let response = ConfigurationKeys.shared._generateKeys(alias: "llaves")
        
        let publicKey: SecKey = response.public
        let privateKey: SecKey = response.private
        
        _publicKeyiOS = ConfigurationKeys.shared.secKeyToString(key: response.public, addExtension: false)!
        _privateKeyiOS = ConfigurationKeys.shared.secKeyToString(key: response.private, addExtension: false)!
        
        print()
        print("--- Public Key iOS ---")
        print(_publicKeyiOS)
        print()

        print("--- Private Key iOS ---")
        print(_privateKeyiOS)
        print()

        let ciphertextWithAndroid: String = "nQjzs7dFwveL1xdhPuZj+dGIHGMnjmv49l9yIc9msVn/BXmswYn8nC/FCvpLT7DXnHd0ErqYfkxlXlDqHOEEYCEkLgrZUa3Z8uzWoM1qjCSR4+stn/gMm0AMsjbCLVpgyH/PnRZngYofG6DiVwTlnNdUJ6m5cy9RGbQlRLoHZCZyExxFt1wEBKbzHaS+f771fforvNXz8zoOCbvJ4IFDqP6SmxQiwKL+Q/8Z5QRLS+f1kr1+Vji3xthCeSMu1cy0t3vSRtTevogWOcEbyTIxDhZHaQsI2ylQxPeZEHOsLqF6U15AeTvki5OUZxR4m31H6hKnVM29sTLorUsfjWdx2Q=="
        
        let plainData: Data = _plainText.data(using: .utf8)!
        
        let ciphertext = cipher(message: plainData, publicKey: publicKey)!
        
        _decipherWithAndroidKeys(ciphertext: ciphertext, privateKey: privateKey)
    }
    
    /// Cifrar mediante las llaves generadas en Android
    private func _encryptWithAndroidKeys() {
        let publicKeyWithX509: SecKey = try! OtherFunctions.shared.addRSAKey(_publicKeyAndroid, keyType: "public_Key")!
        let privateKeyWithX509: SecKey = try! OtherFunctions.shared.addRSAKey(_privateKeyAndroid, keyType: "private_Key")!
        
        let plainData: Data = _plainText.data(using: .utf8)!
        
        let ciphertext = cipher(message: plainData, publicKey: publicKeyWithX509)!
        
        _decipherWithAndroidKeys(ciphertext: ciphertext, privateKey: privateKeyWithX509)
    }
    
    /// Cifrar con llave publica con encabezado x509
    private func cipher(message: Data, publicKey: SecKey) -> String? {
        let error:UnsafeMutablePointer<Unmanaged<CFError>?>? = nil
        
        if let encryptedMessageData:Data = SecKeyCreateEncryptedData(publicKey, .rsaEncryptionOAEPSHA1, message as CFData,error) as Data? {
            
            let encryptedMessageSigned: [Int8] = encryptedMessageData.map { Int8.init(bitPattern: $0) }
            
            let data: Data = Data(encryptedMessageSigned.map(UInt8.init))
            
            let ciphertext: String = data.base64EncodedString()
            
            print()
            print("Texto cifrado en base64")
            print(ciphertext)
            print()
            
            return ciphertext
        }
        else{
            print("Error cifrando texto")
            return nil
        }
    }
    
    /// Descifrar con llave privada
    private func _decipherWithAndroidKeys(ciphertext: String, privateKey: SecKey) -> Void {
        let data: Data = Data(base64Encoded: ciphertext, options: .ignoreUnknownCharacters)!
        
        let error:UnsafeMutablePointer<Unmanaged<CFError>?>? = nil
        
        if let decryptedMessage:Data = SecKeyCreateDecryptedData(privateKey, .rsaEncryptionOAEPSHA1, data as CFData,error) as Data? {
            print()
            print("Texto descifrado")
            print("Son los mismos: \((_plainText == String.init(data: decryptedMessage, encoding: .utf8)!))")
            print(String.init(data: decryptedMessage, encoding: .utf8)!)
            print()
        }
        else{
            print("Error descifrando")
        }
    }
}
