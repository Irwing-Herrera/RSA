//
//  OtherFunctions.swift
//  SwiftyRSA-iOS
//
//  Created by MacBook on 29/07/21.
//
import UIKit
import Security

class OtherFunctions {
    
    /// Class method access.
    public static let shared = OtherFunctions()
    
    public class RSAUtilsError: NSError {
        init(_ message: String) {
            super.init(domain: "com.entotem.plato.RSAUtils", code: 500, userInfo: [
                NSLocalizedDescriptionKey: message
            ])
        }
        
        @available(*, unavailable)
        required public init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    //MARK: - Variables
    //MARK: Constants
    let logClassName = String(describing:OtherFunctions.self)
    
    //MARK: - Methods
    
    /// Convierte el String en Data
    private func base64Decode(_ stringBase64: String) -> Data {
        let data: Data = Data(base64Encoded: stringBase64, options: [])!
        return data
    }
    /**
     * Agrega una clave pública RSA al llavero y devuelve su referencia SecKey.
     *
     * - Parameter pubkeyBase64: clave pública X509 en base64 (datos entre "----- BEGIN PUBLIC KEY -----" y "----- END PUBLIC KEY -----")
     * - Parameter tagName: nombre de etiqueta para almacenar la clave RSA en el llavero
     *
     * - Throws: `RSAUtilsError` si la clave de entrada no es una clave pública X509
     *
     * - Returns: referencia de SecKey a la clave pública RSA.
     */
    public func addRSAKey(_ keyBase64: String, keyType: String) throws -> SecKey? {
        
        let tag: String = (keyType == "public_Key") ? keyType : "private_Key"
        
        let regExp: NSRegularExpression = try! NSRegularExpression(pattern: "(-----BEGIN.*?-----)|(-----END.*?-----)|\\s+", options: [])
        let fullRange = NSRange(location: 0, length: keyBase64.count)
        
        let cleanKeyInBase64: String = regExp.stringByReplacingMatches(in: keyBase64, options: [], range: fullRange, withTemplate: "")
        
        if tag == "public_Key" {
            return try addRSAPublicKey(base64Decode(cleanKeyInBase64), tagName: tag + "_Android")
        } else {
            return try addRSAPrivateKey(base64Decode(cleanKeyInBase64), tagName: tag + "_Android")
        }
    }
    
    // MARK: - Generacion de Llave Publica
    
    /**
     * Agrega una clave privada RSA al llavero y devuelve su referencia SecKey.
     *
     * - Parameter pubkey: clave pública X509
     * - Parameter tagName: nombre de etiqueta para almacenar la clave RSA en el llavero
     *
     * - Throws: `RSAUtilsError` nombre de etiqueta para almacenar la clave RSA en el llavero
     *
     * - Returns: referencia de SecKey a la clave pública RSA.
     */
    private func addRSAPublicKey(_ pubkey: Data, tagName: String) throws -> SecKey? {
        Keychain.shared.deleteKey(tag: tagName)
        
        let pubkeyData: Data? = try stripPublicKeyHeader(pubkey)
        if (pubkeyData == nil ) {
            print("No se pudo crear la llave")
            return nil
        }
        
        let save: Bool = Keychain.shared.set(tag: tagName, value: pubkeyData!, keyClass: kSecAttrKeyClassPublic)
        
        if save {
            print("Se almaceno la llave")
        } else {
            print("Error al almacenar")
        }
        
        return Keychain.shared.getSecKey(tag: tagName)
    }
    /**
     * Verifica que la clave proporcionada es de hecho una clave pública X509 y quita su encabezado.
     *
     * En el disco, un archivo de clave pública X509 comienza con la cadena "----- BEGIN PUBLIC KEY -----" y termina con la cadena "----- END PUBLIC KEY -----".
     *
     * - Parameter pubkey: clave pública X509
     *
     * - Throws: `RSAUtilsError` si la clave de entrada no es una clave pública X509 válida
     *
     * - Returns: la clave pública RSA con el encabezado despojado.
     */
    private func stripPublicKeyHeader(_ pubkey: Data) throws -> Data? {
        if ( pubkey.count == 0 ) {
            return nil
        }
        
        var keyAsArray = [UInt8](repeating: 0, count: pubkey.count / MemoryLayout<UInt8>.size)
        (pubkey as NSData).getBytes(&keyAsArray, length: pubkey.count)
        
        var idx = 0
        if (keyAsArray[idx] != 0x30) {
            throw RSAUtilsError("La clave proporcionada no tiene una estructura ASN.1 válida (el primer byte debe ser 0x30).")
        }
        idx += 1
        
        if (keyAsArray[idx] > 0x80) {
            idx += Int(keyAsArray[idx]) - 0x80 + 1
        } else {
            idx += 1
        }
        
        ///Si el byte actual es 0x02, significa que la clave no tiene un encabezado X509 (solo contiene módulo y exponente público).
        ///En este caso, podemos simplemente devolver los datos DER proporcionados como están
        if (Int(keyAsArray[idx]) == 0x02) {
            return pubkey
        }
        
        let seqiod = [UInt8](arrayLiteral: 0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00)
        
        for i in idx..<idx+seqiod.count {
            if ( keyAsArray[i] != seqiod[i-idx] ) {
                throw RSAUtilsError("La clave proporcionada no tiene un encabezado X509 válido.")
            }
        }
        idx += seqiod.count
        
        if (keyAsArray[idx] != 0x03) {
            throw RSAUtilsError("Byte no válido en el índice \(idx) (\(keyAsArray[idx])) para encabezado de clave pública.")
        }
        idx += 1
        
        if (keyAsArray[idx] > 0x80) {
            idx += Int(keyAsArray[idx]) - 0x80 + 1;
        } else {
            idx += 1
        }
        
        if (keyAsArray[idx] != 0x00) {
            throw RSAUtilsError("Byte no válido en el índice \(idx) (\(keyAsArray[idx])) para encabezado de clave pública.")
        }
        idx += 1
        return pubkey.subdata(in: idx..<keyAsArray.count)
    }
    
    // MARK: - Generacion de Llave Privada
    
    /**
     * Agrega una clave privada RSA al llavero y devuelve su referencia SecKey.
     *
     * - Parameter privkey: clave privada RSA (PKCS # 1 o PKCS # 8)
     * - Parameter tagName: nombre de etiqueta para almacenar la clave RSA en el llavero
     *
     * - Throws: `RSAUtilsError` si la clave de entrada no es una clave privada PKCS # 8 válida
     *
     * - Returns: referencia de SecKey a la clave privada RSA.
     */
    private func addRSAPrivateKey(_ privkey: Data, tagName: String) throws -> SecKey? {
        /// Elimine cualquier clave persistente antigua con la misma etiqueta
        Keychain.shared.deleteKey(tag: tagName)
        
        let privkeyData = try stripPrivateKeyHeader(privkey)
        if ( privkeyData == nil ) {
            return nil
        }
        
        /// Almacenar en Keychain
        let save: Bool = Keychain.shared.set(tag: tagName, value: privkey, keyClass: kSecAttrKeyClassPrivate)
        
        if save {
            print("Se almaceno la llave")
        } else {
            print("Error al almacenar")
        }
        return Keychain.shared.getSecKey(tag: tagName)
    }
    /**
     * Verifica que la clave proporcionada es de hecho una clave privada PEM RSA y elimina su encabezado.
     *
     * Si la clave proporcionada es PKCS # 8, su encabezado ASN.1 debe eliminarse. De lo contrario (PKCS # 1), todos los datos clave se dejan intactos.
     *
     * En el disco, un archivo de clave privada PEM RSA PKCS # 8 comienza con la cadena "----- BEGIN PRIVATE KEY -----" y termina con la cadena "----- END PRIVATE KEY ----- "; El archivo de clave privada PKCS # 1 comienza con la cadena "----- BEGIN RSA PRIVATE KEY -----" y termina con la cadena "----- END RSA PRIVATE KEY -----".
     *
     * - Parameter privkey: clave privada RSA (PKCS # 1 o PKCS # 8)
     *
     * - Throws: `RSAUtilsError` si la clave de entrada no es una clave privada RSA PKCS # 8 válida
     *
     * - Returns: la clave privada RSA con el encabezado despojado.
     */
    private func stripPrivateKeyHeader(_ privkey: Data) throws -> Data? {
        if ( privkey.count == 0 ) {
            return nil
        }
        
        var keyAsArray = [UInt8](repeating: 0, count: privkey.count / MemoryLayout<UInt8>.size)
        (privkey as NSData).getBytes(&keyAsArray, length: privkey.count)
        
        // PKCS # 8: byte mágico en el desplazamiento 22, verifique si realmente es ASN.1
        var idx = 22
        if ( keyAsArray[idx] != 0x04 ) {
            return privkey
        }
        idx += 1
        
        // ahora necesitamos averiguar cuánto tiempo tiene la clave, para que podamos extraer el trozo correcto
        // de bytes del búfer.
        var len = Int(keyAsArray[idx])
        idx += 1
        let det = len & 0x80 //compruebe si el bit alto está configurado
        if (det == 0) {
            //¿No? entonces la longitud de la clave es un número que cabe en un byte, (<128)
            len = len & 0x7f
        } else {
            //de lo contrario, la longitud de la clave es un número que no cabe en un byte (> 127)
            var byteCount = Int(len & 0x7f)
            if (byteCount + idx > privkey.count) {
                return nil
            }
            //por lo que necesitamos recortar bytes de byteCount desde el frente e invertir su orden
            var accum: UInt = 0
            var idx2 = idx
            idx += byteCount
            while (byteCount > 0) {
                //después de cada byte, lo empujamos, acumulando el valor en acum
                accum = (accum << 8) + UInt(keyAsArray[idx2])
                idx2 += 1
                byteCount -= 1
            }
            // ahora hemos leído todos los bytes de la longitud de la clave y los hemos convertido en un número,
            // que es el número de bytes en la clave real. usamos esto a continuación para extraer el
            // codificar bytes y operar sobre ellos
            len = Int(accum)
        }
        return privkey.subdata(in: idx..<idx+len)
        //return privkey.subdata(in: NSMakeRange(idx, len).toRange()!)
    }
}
