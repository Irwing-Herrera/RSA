//
//  NSInteger.swift
//  RSA-iOS
//
//  Created by MacBook on 03/08/21.
//

import UIKit

extension NSInteger{
    
    init?(octetBytes: [CUnsignedChar], startIdx: inout NSInteger) {
        if octetBytes[startIdx] < 128 {
            // Forma corta
            self.init(octetBytes[startIdx])
            startIdx += 1
        } else {
            // Forma larga
            let octets = NSInteger(octetBytes[startIdx] as UInt8 - 128)
            
            if octets > octetBytes.count - startIdx {
                self.init(0)
                return nil
            }
            
            var result = UInt64(0)
            
            for j in 1...octets {
                result = (result << 8)
                result = result + UInt64(octetBytes[startIdx + j])
            }
            
            startIdx += 1 + octets
            self.init(result)
        }
    }
    
    /// Codificación / decodificación de longitudes como octetos
    func encodedOctets() -> [CUnsignedChar] {
        // Forma corta
        if self < 128 {
            return [CUnsignedChar(self)];
        }
        
        // Forma larga
        let i = Int(log2(Double(self)) / 8 + 1)
        var len = self
        var result: [CUnsignedChar] = [CUnsignedChar(i + 0x80)]
        
        for _ in 0..<i {
            result.insert(CUnsignedChar(len & 0xFF), at: 1)
            len = len >> 8
        }
        
        return result
    }
}
