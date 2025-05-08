import Foundation
import RxSwift
import Logging

/// Delta Generator - Generates deltas between file versions
class DeltaGenerator {
    // MARK: - Properties
    
    private let logger = Logger(label: "com.cloudsync.delta")
    
    // MARK: - Initialization
    
    init() {
        logger.info("DeltaGenerator initialized")
    }
    
    // MARK: - Delta Methods
    
    /// Generate a delta between two versions of a file
    /// - Parameters:
    ///   - oldData: Old version data
    ///   - newData: New version data
    /// - Returns: Delta data
    func generateDelta(oldData: Data, newData: Data) -> Observable<Data> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onError(NSError(domain: "com.cloudsync.delta", code: 500, userInfo: [NSLocalizedDescriptionKey: "DeltaGenerator deallocated"]))
                return Disposables.create()
            }
            
            // In a real app, this would use a proper delta algorithm
            // For demo purposes, we'll create a simple delta format
            
            // Calculate delta size
            let deltaSize = min(newData.count, oldData.count / 10)
            
            // Create delta header
            var deltaData = Data()
            
            // Add old data hash for verification
            let oldHash = oldData.sha256Hash
            guard let oldHashData = oldHash.data(using: .utf8) else {
                let error = NSError(domain: "com.cloudsync.delta", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to encode hash"])
                self.logger.error("Failed to encode hash")
                observer.onError(error)
                return Disposables.create()
            }
            
            // Add header (hash length + hash)
            let hashLength = UInt32(oldHashData.count)
            var hashLengthBytes = hashLength.bigEndian
            deltaData.append(Data(bytes: &hashLengthBytes, count: MemoryLayout<UInt32>.size))
            deltaData.append(oldHashData)
            
            // Add new data size
            let newSize = UInt64(newData.count)
            var newSizeBytes = newSize.bigEndian
            deltaData.append(Data(bytes: &newSizeBytes, count: MemoryLayout<UInt64>.size))
            
            // In a real implementation, we would compute actual differences
            // For demo purposes, we'll just include a portion of the new data
            
            // Add operation count
            let opCount: UInt32 = 1
            var opCountBytes = opCount.bigEndian
            deltaData.append(Data(bytes: &opCountBytes, count: MemoryLayout<UInt32>.size))
            
            // Add a single "replace" operation
            let opType: UInt8 = 1 // 1 = replace
            deltaData.append(Data([opType]))
            
            // Add offset
            let offset: UInt64 = 0
            var offsetBytes = offset.bigEndian
            deltaData.append(Data(bytes: &offsetBytes, count: MemoryLayout<UInt64>.size))
            
            // Add length
            let length: UInt64 = UInt64(deltaSize)
            var lengthBytes = length.bigEndian
            deltaData.append(Data(bytes: &lengthBytes, count: MemoryLayout<UInt64>.size))
            
            // Add data
            let dataChunk = newData.prefix(deltaSize)
            deltaData.append(dataChunk)
            
            self.logger.info("Generated delta: \(deltaData.count) bytes (original: \(newData.count) bytes)")
            observer.onNext(deltaData)
            observer.onCompleted()
            
            return Disposables.create()
        }
    }
    
    /// Apply a delta to a file
    /// - Parameters:
    ///   - oldData: Old version data
    ///   - deltaData: Delta data
    /// - Returns: New version data
    func applyDelta(oldData: Data, deltaData: Data) -> Observable<Data> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onError(NSError(domain: "com.cloudsync.delta", code: 500, userInfo: [NSLocalizedDescriptionKey: "DeltaGenerator deallocated"]))
                return Disposables.create()
            }
            
            // In a real app, this would use a proper delta algorithm
            // For demo purposes, we'll parse our simple delta format
            
            var offset = 0
            
            // Read hash length
            guard offset + MemoryLayout<UInt32>.size <= deltaData.count else {
                let error = NSError(domain: "com.cloudsync.delta", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid delta format: too short for hash length"])
                self.logger.error("Invalid delta format: too short for hash length")
                observer.onError(error)
                return Disposables.create()
            }
            
            let hashLengthData = deltaData.subdata(in: offset..<offset+MemoryLayout<UInt32>.size)
            var hashLength: UInt32 = 0
            hashLengthData.withUnsafeBytes { hashLength = UInt32(bigEndian: $0.load(as: UInt32.self)) }
            offset += MemoryLayout<UInt32>.size
            
            // Read hash
            guard offset + Int(hashLength) <= deltaData.count else {
                let error = NSError(domain: "com.cloudsync.delta", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid delta format: too short for hash"])
                self.logger.error("Invalid delta format: too short for hash")
                observer.onError(error)
                return Disposables.create()
            }
            
            let hashData = deltaData.subdata(in: offset..<offset+Int(hashLength))
            guard let hash = String(data: hashData, encoding: .utf8) else {
                let error = NSError(domain: "com.cloudsync.delta", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid delta format: invalid hash encoding"])
                self.logger.error("Invalid delta format: invalid hash encoding")
                observer.onError(error)
                return Disposables.create()
            }
            offset += Int(hashLength)
            
            // Verify hash
            let oldHash = oldData.sha256Hash
            guard hash == oldHash else {
                let error = NSError(domain: "com.cloudsync.delta", code: 400, userInfo: [NSLocalizedDescriptionKey: "Hash mismatch: delta cannot be applied to this file version"])
                self.logger.error("Hash mismatch: delta cannot be applied to this file version")
                observer.onError(error)
                return Disposables.create()
            }
            
            // Read new data size
            guard offset + MemoryLayout<UInt64>.size <= deltaData.count else {
                let error = NSError(domain: "com.cloudsync.delta", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid delta format: too short for new size"])
                self.logger.error("Invalid delta format: too short for new size")
                observer.onError(error)
                return Disposables.create()
            }
            
            let newSizeData = deltaData.subdata(in: offset..<offset+MemoryLayout<UInt64>.size)
            var newSize: UInt64 = 0
            newSizeData.withUnsafeBytes { newSize = UInt64(bigEndian: $0.load(as: UInt64.self)) }
            offset += MemoryLayout<UInt64>.size
            
            // Read operation count
            guard offset + MemoryLayout<UInt32>.size <= deltaData.count else {
                let error = NSError(domain: "com.cloudsync.delta", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid delta format: too short for operation count"])
                self.logger.error("Invalid delta format: too short for operation count")
                observer.onError(error)
                return Disposables.create()
            }
            
            let opCountData = deltaData.subdata(in: offset..<offset+MemoryLayout<UInt32>.size)
            var opCount: UInt32 = 0
            opCountData.withUnsafeBytes { opCount = UInt32(bigEndian: $0.load(as: UInt32.self)) }
            offset += MemoryLayout<UInt32>.size
            
            // Create result data
            var resultData = oldData
            
            // Process operations
            for _ in 0..<opCount {
                // Read operation type
                guard offset + 1 <= deltaData.count else {
                    let error = NSError(domain: "com.cloudsync.delta", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid delta format: too short for operation type"])
                    self.logger.error("Invalid delta format: too short for operation type")
                    observer.onError(error)
                    return Disposables.create()
                }
                
                let opType = deltaData[offset]
                offset += 1
                
                // Read offset
                guard offset + MemoryLayout<UInt64>.size <= deltaData.count else {
                    let error = NSError(domain: "com.cloudsync.delta", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid delta format: too short for operation offset"])
                    self.logger.error("Invalid delta format: too short for operation offset")
                    observer.onError(error)
                    return Disposables.create()
                }
                
                let opOffsetData = deltaData.subdata(in: offset..<offset+MemoryLayout<UInt64>.size)
                var opOffset: UInt64 = 0
                opOffsetData.withUnsafeBytes { opOffset = UInt64(bigEndian: $0.load(as: UInt64.self)) }
                offset += MemoryLayout<UInt64>.size
                
                // Read length
                guard offset + MemoryLayout<UInt64>.size <= deltaData.count else {
                    let error = NSError(domain: "com.cloudsync.delta", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid delta format: too short for operation length"])
                    self.logger.error("Invalid delta format: too short for operation length")
                    observer.onError(error)
                    return Disposables.create()
                }
                
                let opLengthData = deltaData.subdata(in: offset..<offset+MemoryLayout<UInt64>.size)
                var opLength: UInt64 = 0
                opLengthData.withUnsafeBytes { opLength = UInt64(bigEndian: $0.load(as: UInt64.self)) }
                offset += MemoryLayout<UInt64>.size
                
                // Process operation
                switch opType {
                case 1: // Replace
                    // Read data
                    guard offset + Int(opLength) <= deltaData.count else {
                        let error = NSError(domain: "com.cloudsync.delta", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid delta format: too short for operation data"])
                        self.logger.error("Invalid delta format: too short for operation data")
                        observer.onError(error)
                        return Disposables.create()
                    }
                    
                    let opData = deltaData.subdata(in: offset..<offset+Int(opLength))
                    offset += Int(opLength)
                    
                    // Apply replace operation
                    let opOffsetInt = Int(opOffset)
                    let opLengthInt = Int(opLength)
                    
                    // In a real implementation, we would handle this more efficiently
                    // For demo purposes, we'll just create a new data object
                    
                    // Ensure the offset is valid
                    if opOffsetInt <= resultData.count {
                        let prefix = opOffsetInt > 0 ? resultData.prefix(opOffsetInt) : Data()
                        let suffix = opOffsetInt + opLengthInt < resultData.count ? resultData.suffix(from: opOffsetInt + opLengthInt) : Data()
                        
                        resultData = prefix + opData + suffix
                    }
                    
                default:
                    let error = NSError(domain: "com.cloudsync.delta", code: 400, userInfo: [NSLocalizedDescriptionKey: "Unknown operation type: \(opType)"])
                    self.logger.error("Unknown operation type: \(opType)")
                    observer.onError(error)
                    return Disposables.create()
                }
            }
            
            // Verify size
            if resultData.count != Int(newSize) {
                self.logger.warning("Size mismatch after applying delta: expected \(newSize), got \(resultData.count)")
                
                // In a real implementation, we would handle this more carefully
                // For demo purposes, we'll just pad or truncate
                if resultData.count < Int(newSize) {
                    // Pad with zeros
                    let padding = Data(count: Int(newSize) - resultData.count)
                    resultData.append(padding)
                } else if resultData.count > Int(newSize) {
                    // Truncate
                    resultData = resultData.prefix(Int(newSize))
                }
            }
            
            self.logger.info("Applied delta: \(deltaData.count) bytes, resulting in \(resultData.count) bytes")
            observer.onNext(resultData)
            observer.onCompleted()
            
            return Disposables.create()
        }
    }
}
