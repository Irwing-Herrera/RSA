//
//  OtherFunctionsTest.swift
//  RSA-iOSTests
//
//  Created by MacBook on 04/08/21.
//

import Foundation
import XCTest

@testable import RSA_iOS

class OtherFunctionsTest: XCTestCase {
    
    var sut: OtherFunctions = OtherFunctions()
    
    private let _publicKeyAndroid: String = "-----BEGIN RSA PUBLIC KEY-----\n" + "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAvxCa21Z3bqPakaB4OY1rpS+zA1F3+1Rmr9EgGOrNT2vl/5Fg/3hWL7JZ5SEbbulWV5gKi5lQjpPUGYZhnvb26eKx/EpNnk5oz95473jgof1QrxfWiSgztg1i2fFe+FX0hq4B/ZYEyM27JwBJ2Fc2joZYGpkNQWSMgkwPQMVfZje71Tn5JSyB53v74n7LlpTTYnlkcO2odHuI9M05yIPwy4dZblECkN7O6fqDzNEw86ZaZZUyJTloP764DXcw6/VZjVvBBbF2lC+86mDKccs69HvHOmVeFzy21MHMA0Abd3PswZIaTS7douagRCLEvYqkkD+W/Tvt+cIN8uHdeJ2QpwIDAQAB" + "\n-----END RSA PUBLIC KEY-----"
    
    private let _privateKeyAndroid: String = "-----BEGIN RSA PRIVATE KEY-----\n" + "MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCZ2/c8O5SKQAfrbqjN7cXahlTL6XsioEtg2usmIHG1WBNln/Yo4RLuzZ/iLYgcl1dM02cL7LO/4vwlHooMI2QQ1pPLB/2LlOI6Q3+R7KUvXwIKpb5i8y8s9zHqEugnPcivRKyvSUYYZHkop8heZ3h9dYTP7hm8nHoq+GWCj2X0xc2HscA2daZYSElFgkVkxffDMojn6ZWykIIIyehAKz9XWkkebzorLQqQ+SO4EJjxv0dmZFWHbcYEcnUmHpTVy8wiS5efJATcdU58Frjlix/Adxm07LdK8Xihh5aUHzEeHtb073PixaR31QDBCR3NCtqipk+9OPLkIWqvdR6G0daBAgMBAAECggEAQRjs37qzq9TQpP+Sg2KNWlqIqSf1td5NVkL5yA1lHt2Pg2ltPLmSCaDNe2RZWQN9Z99wE38IRHFUzp2/ucgFkAxBxt7wGy0YlJ83a/XMpCDWG8wpo/MRbDyAjXGHcQb2kJWFXLqrYimsi5OFts+fjrF4yoMKt58bH3AuftGOSUP5iuy4gEAOodVSgJ1D41oLTLeUqF5OrRs+GLMOjconxiLLoybdOA3oiHOAfBM90Jn9HEDJ37A+WsFbmfmMFKase8SZUGCd5LWUTOIDXQ0jfIPzRX9jN7X1u7LlnEQc0NO+ZyE1GIvu7jg9iAS+a4INe3MWrpCNweYm+jaYwIFl4wKBgQDPQo+A8Acx/+L4LmWtzTjTj3jrFncP0Hk13DryDxRJa/7xEOLORyku/JPQLg3w0t3vZdEJd0tgH3f1RRFG8ctYrzTW3wHdqgq6bqVMW0EdjftD3z6fGS0yxqi229CIt+pZugQU1z/6mC9G2RbGdW9kQoaBAschpJXE6AQz4WcBFwKBgQC+CpRg5lOUgd43XWZhxVEdnx8u2sujWo0cLOrGfU4/hZVCwRq7A06aLcXiPRflli2hAnk7olw9DOgWPToGf9sWF6Cn/U/5u9Og/MfEfLs4Y8yPgL7NmbnrVatU0A0GKfCs3HUTISKFmlHieIEy7pgF/7uikFVjTgzm6iwvvFg0JwKBgAtP7bcy4qGm/sNe/Ou8jMJ3TTk/k6YIUeVPrOPzUL8lJtgPfOGXXrcS0BqHuPkQ+U4Mt5kVqsaHUSvQ5j2CCwA/J9omd9qaYlWEnn8JaAdt7W3p7GgQnrfrwd+hJcOgjijxjzF4AiTyU3pBdQ3F8Rt+ygqWlTnP2uDRbRFL1yxnAoGBAKXfMhdJshXjLIQCf8RCp0RFiMAqtKdF9/hptBm/cTa8b8UuKxikEE0+OoP3cw4vAHCSaiKE2iFnTINsuWLG4gDsaot17AI70MGpIOv9OqRDZ16xrthhnwcrZTnHxjZlEO6wFXe26hzWzzXunEZKPmKuDaYceIsOqvA54Ithx1LtAoGBAJnCKd3SZUdxUjsLUAixsvBAwc0wh3rh8j0rzv2yMqPEQ85Z6AcABeQpnAKFDUNySx4q1dDc8I6cIc0gCPL40wRlhmPDqkD2AtgZvPar17iScWota99Z5357je/APuyY49AprIS1CUmLklKyMTByLTilvKaSYmJCItD3p1C+TSmB" + "\n-----END RSA PRIVATE KEY-----"
    
    func testCreateKeysWithAndroid() {
        let publicKeyWithX509: SecKey = try! sut.addRSAKey(_publicKeyAndroid, keyType: "public_Key")!
        let privateKeyWithX509: SecKey = try! sut.addRSAKey(_privateKeyAndroid, keyType: "private_Key")!
        
        XCTAssertNotNil(publicKeyWithX509)
        XCTAssertNotNil(privateKeyWithX509)
    }
    
}
