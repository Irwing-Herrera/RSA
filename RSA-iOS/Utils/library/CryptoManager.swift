//
//  CryptoManager.swift
//  RSA-iOS
//
//  Created by MacBook on 05/08/21.
//

import Foundation

class CryptoManager {
    
    private let core: CryptoCore
    
    init(aliasKey: String?, publicKey: String?) {
        core = CryptoCore(aliasKey: aliasKey, publicKey: publicKey)
    }
    
    /**
     * Obtain public key to Crypto
     *
     *  @return Public key data
     */
    public func getPublicKey() -> String {
        return ""
    }
}
