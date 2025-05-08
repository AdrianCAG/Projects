import Foundation
import RxSwift

/// Cloud Repository Protocol
protocol CloudRepository {
    /// Upload a file
    /// - Parameters:
    ///   - file: File metadata
    ///   - data: File data
    ///   - isDelta: Whether data is a delta
    /// - Returns: Observable with upload result
    func uploadFile(file: SyncFile, data: Data, isDelta: Bool) -> Observable<Void>
    
    /// Download a file
    /// - Parameter file: File metadata
    /// - Returns: Observable with file data
    func downloadFile(file: SyncFile) -> Observable<Data>
    
    /// Get file metadata
    /// - Parameter file: Local file metadata
    /// - Returns: Observable with remote file metadata
    func getFileMetadata(file: SyncFile) -> Observable<SyncFile>
    
    /// Get file content
    /// - Parameter file: File metadata
    /// - Returns: Observable with file data
    func getFileContent(file: SyncFile) -> Observable<Data>
    
    /// Delete a file
    /// - Parameter file: File to delete
    /// - Returns: Observable with completion or error
    func deleteFile(file: SyncFile) -> Observable<Void>
    
    /// List files in a path
    /// - Parameter path: Directory path
    /// - Returns: Observable sequence of files
    func listFiles(path: String) -> Observable<[SyncFile]>
}
