//
//  HomeViewController.swift
//  RSA-iOS
//
//  Created by MacBook on 03/08/21.
//

import UIKit

class HomeViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var aliastTextField: UITextField!
    @IBOutlet weak var publickKeyTextField: UITextField!
    @IBOutlet weak var textToEncryptTextField: UITextField!
    @IBOutlet weak var textToDecryptTextField: UITextField!
    
    // MARK: - IBActions
    @IBAction func encryptAction(_ sender: Any) {
        _initCryptoManager()
    }
    @IBAction func decryptAction(_ sender: Any) {
    }
    
    // MARK: Properties
    private var _alias: String
    private var _publickKey: String?
    
    private var cryptoManager: CryptoManager
    
    // MARK: - Life Cicle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Private Methods
    private func _initCryptoManager() {
        if let alias = aliastTextField.text, !alias.isEmpty {
            self._alias = alias
        } else {
            self._alias = "aliasTest"
        }
        
        if let publicKey = publickKeyTextField.text, !publicKey.isEmpty {
            self._publickKey = publicKey
        } else {
            self._publickKey = nil
        }

        cryptoManager = CryptoManager(aliasKey: self._alias, publicKey: self._publickKey)

        let currentPublicKey = cryptoManager.getPublicKey()
    }
}
