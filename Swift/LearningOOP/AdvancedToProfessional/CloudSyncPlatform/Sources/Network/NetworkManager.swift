import Foundation
import Alamofire
import RxSwift
import Logging

/// Network Manager - Handles all network requests
class NetworkManager {
    // MARK: - Singleton
    
    static let shared = NetworkManager()
    
    // MARK: - Properties
    
    private let logger = Logger(label: "com.cloudsync.network")
    private let session: Session
    private let baseURL: URL
    
    // MARK: - Initialization
    
    private init() {
        // Create custom Alamofire configuration
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30.0
        configuration.timeoutIntervalForResource = 300.0
        configuration.httpAdditionalHeaders = HTTPHeaders.default.dictionary
        
        // Create custom session
        self.session = Session(configuration: configuration)
        
        // Set base URL (in a real app, this would come from configuration)
        self.baseURL = URL(string: "https://api.cloudsync.example.com/v1")!
        
        logger.info("NetworkManager initialized")
    }
    
    // MARK: - Request Methods
    
    /// Make a GET request
    /// - Parameters:
    ///   - endpoint: API endpoint
    ///   - parameters: Query parameters
    ///   - headers: Additional headers
    /// - Returns: Observable with response data
    func get<T: Decodable>(
        _ endpoint: String,
        parameters: [String: Any]? = nil,
        headers: HTTPHeaders? = nil
    ) -> Observable<T> {
        return request(.get, endpoint: endpoint, parameters: parameters, headers: headers)
    }
    
    /// Make a POST request
    /// - Parameters:
    ///   - endpoint: API endpoint
    ///   - parameters: Body parameters
    ///   - headers: Additional headers
    /// - Returns: Observable with response data
    func post<T: Decodable>(
        _ endpoint: String,
        parameters: [String: Any]? = nil,
        headers: HTTPHeaders? = nil
    ) -> Observable<T> {
        return request(.post, endpoint: endpoint, parameters: parameters, headers: headers)
    }
    
    /// Make a PUT request
    /// - Parameters:
    ///   - endpoint: API endpoint
    ///   - parameters: Body parameters
    ///   - headers: Additional headers
    /// - Returns: Observable with response data
    func put<T: Decodable>(
        _ endpoint: String,
        parameters: [String: Any]? = nil,
        headers: HTTPHeaders? = nil
    ) -> Observable<T> {
        return request(.put, endpoint: endpoint, parameters: parameters, headers: headers)
    }
    
    /// Make a DELETE request
    /// - Parameters:
    ///   - endpoint: API endpoint
    ///   - parameters: Query parameters
    ///   - headers: Additional headers
    /// - Returns: Observable with response data
    func delete<T: Decodable>(
        _ endpoint: String,
        parameters: [String: Any]? = nil,
        headers: HTTPHeaders? = nil
    ) -> Observable<T> {
        return request(.delete, endpoint: endpoint, parameters: parameters, headers: headers)
    }
    
    /// Upload a file
    /// - Parameters:
    ///   - endpoint: API endpoint
    ///   - fileURL: URL to the file
    ///   - parameters: Additional parameters
    ///   - headers: Additional headers
    /// - Returns: Observable with upload progress and response
    func upload<T: Decodable>(
        _ endpoint: String,
        fileURL: URL,
        parameters: [String: String]? = nil,
        headers: HTTPHeaders? = nil
    ) -> Observable<(Double, T?)> {
        return Observable.create { observer in
            let url = self.baseURL.appendingPathComponent(endpoint)
            
            let upload = self.session.upload(
                multipartFormData: { multipartFormData in
                    // Add file
                    multipartFormData.append(
                        fileURL,
                        withName: "file",
                        fileName: fileURL.lastPathComponent,
                        mimeType: self.mimeType(for: fileURL)
                    )
                    
                    // Add parameters
                    if let parameters = parameters {
                        for (key, value) in parameters {
                            if let data = value.data(using: .utf8) {
                                multipartFormData.append(data, withName: key)
                            }
                        }
                    }
                },
                to: url,
                headers: headers
            )
            
            // Track upload progress
            upload.uploadProgress { progress in
                observer.onNext((progress.fractionCompleted, nil))
            }
            
            // Handle response
            upload.responseDecodable(of: T.self) { response in
                switch response.result {
                case .success(let value):
                    observer.onNext((1.0, value))
                    observer.onCompleted()
                case .failure(let error):
                    self.logger.error("Upload failed: \(error.localizedDescription)")
                    observer.onError(error)
                }
            }
            
            return Disposables.create {
                upload.cancel()
            }
        }
    }
    
    /// Download a file
    /// - Parameters:
    ///   - endpoint: API endpoint
    ///   - destination: Destination URL
    ///   - parameters: Query parameters
    ///   - headers: Additional headers
    /// - Returns: Observable with download progress and destination URL
    func download(
        _ endpoint: String,
        destination: URL,
        parameters: [String: Any]? = nil,
        headers: HTTPHeaders? = nil
    ) -> Observable<(Double, URL?)> {
        return Observable.create { observer in
            let url = self.baseURL.appendingPathComponent(endpoint)
            
            let download = self.session.download(
                url,
                method: .get,
                parameters: parameters,
                headers: headers,
                to: { _, _ in
                    return (destination, [.removePreviousFile, .createIntermediateDirectories])
                }
            )
            
            // Track download progress
            download.downloadProgress { progress in
                observer.onNext((progress.fractionCompleted, nil))
            }
            
            // Handle response
            download.response { response in
                if let error = response.error {
                    self.logger.error("Download failed: \(error.localizedDescription)")
                    observer.onError(error)
                } else if let fileURL = response.fileURL {
                    observer.onNext((1.0, fileURL))
                    observer.onCompleted()
                } else {
                    let error = AFError.responseValidationFailed(reason: .dataFileNil)
                    self.logger.error("Download failed: File URL is nil")
                    observer.onError(error)
                }
            }
            
            return Disposables.create {
                download.cancel()
            }
        }
    }
    
    // MARK: - Helper Methods
    
    /// Make a request
    /// - Parameters:
    ///   - method: HTTP method
    ///   - endpoint: API endpoint
    ///   - parameters: Request parameters
    ///   - headers: Additional headers
    /// - Returns: Observable with response data
    private func request<T: Decodable>(
        _ method: HTTPMethod,
        endpoint: String,
        parameters: [String: Any]? = nil,
        headers: HTTPHeaders? = nil
    ) -> Observable<T> {
        return Observable.create { observer in
            let url = self.baseURL.appendingPathComponent(endpoint)
            
            let encoding: ParameterEncoding = method == .get ? URLEncoding.default : JSONEncoding.default
            
            let request = self.session.request(
                url,
                method: method,
                parameters: parameters,
                encoding: encoding,
                headers: headers
            )
            
            request.responseDecodable(of: T.self) { response in
                switch response.result {
                case .success(let value):
                    observer.onNext(value)
                    observer.onCompleted()
                case .failure(let error):
                    self.logger.error("Request failed: \(error.localizedDescription)")
                    observer.onError(error)
                }
            }
            
            return Disposables.create {
                request.cancel()
            }
        }
    }
    
    /// Get MIME type for a file URL
    /// - Parameter url: File URL
    /// - Returns: MIME type string
    private func mimeType(for url: URL) -> String {
        let pathExtension = url.pathExtension
        
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as CFString, nil)?.takeRetainedValue(),
           let mimeType = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
            return mimeType as String
        }
        
        // Default to binary data if type cannot be determined
        return "application/octet-stream"
    }
}

/// API Error Response
struct APIError: Codable, Error {
    let code: String
    let message: String
    let details: String?
}
