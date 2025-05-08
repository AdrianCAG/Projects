import Foundation
import Crypto

extension Data {
    /// Calculate MD5 hash of data
    var md5Hash: String {
        let hash = Insecure.MD5.hash(data: self)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    /// Calculate SHA256 hash of data
    var sha256Hash: String {
        let hash = SHA256.hash(data: self)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    /// Convert data to hexadecimal string
    var hexString: String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
    
    /// Initialize data from hexadecimal string
    init?(hexString: String) {
        let len = hexString.count / 2
        var data = Data(capacity: len)
        
        for i in 0..<len {
            let j = hexString.index(hexString.startIndex, offsetBy: i * 2)
            let k = hexString.index(j, offsetBy: 2)
            let bytes = hexString[j..<k]
            
            if var num = UInt8(bytes, radix: 16) {
                data.append(&num, count: 1)
            } else {
                return nil
            }
        }
        
        self = data
    }
    
    /// Compress data
    func compressed() -> Data? {
        // In a real implementation, we would use a compression library
        // For this demo, we'll just return the original data
        // In a production app, you would implement proper compression using zlib or another library
        return self
    }
    
    /// Decompress data
    func decompressed() -> Data? {
        // In a real implementation, we would use a compression library
        // For this demo, we'll just return the original data
        // In a production app, you would implement proper decompression using zlib or another library
        return self
    }
}
