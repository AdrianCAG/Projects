import Foundation
import RxSwift

extension Observable {
    /// Retry with exponential backoff
    /// - Parameters:
    ///   - maxAttempts: Maximum number of retry attempts
    ///   - delay: Initial delay in seconds
    ///   - shouldRetry: Predicate to determine if retry should be attempted
    /// - Returns: Observable with retry logic
    func retryWithExponentialBackoff(
        maxAttempts: Int,
        delay: Double,
        shouldRetry: @escaping (Error) -> Bool = { _ in true }
    ) -> Observable<Element> {
        return self.retry(when: { errors -> Observable<Void> in
            return errors.enumerated().flatMap { attempt, error -> Observable<Void> in
                if attempt >= maxAttempts || !shouldRetry(error) {
                    return Observable<Void>.error(error)
                }
                
                let delaySeconds = delay * pow(2.0, Double(attempt))
                return Observable<Void>.just(())
                    .delay(.seconds(Int(delaySeconds)), scheduler: MainScheduler.instance)
            }
        })
    }
    
    /// Add timeout and retry logic
    /// - Parameters:
    ///   - timeout: Timeout in seconds
    ///   - retryCount: Number of retries
    ///   - retryDelay: Delay between retries in seconds
    /// - Returns: Observable with timeout and retry logic
    func timeoutWithRetry(
        timeout: RxTimeInterval,
        retryCount: Int,
        retryDelay: Double
    ) -> Observable<Element> {
        return self
            .timeout(timeout, scheduler: MainScheduler.instance)
            .retryWithExponentialBackoff(maxAttempts: retryCount, delay: retryDelay)
    }
    
    /// Execute on background scheduler and observe on main scheduler
    /// - Returns: Observable with scheduler configuration
    func executeOnBackgroundAndObserveOnMain() -> Observable<Element> {
        return self
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .observe(on: MainScheduler.instance)
    }
    
    /// Log events for debugging
    /// - Parameter tag: Tag for log messages
    /// - Returns: Observable with logging
    func logEvents(tag: String) -> Observable<Element> {
        return self.do(
            onNext: { element in
                print("[\(tag)] Next: \(element)")
            },
            onError: { error in
                print("[\(tag)] Error: \(error)")
            },
            onCompleted: {
                print("[\(tag)] Completed")
            },
            onSubscribe: {
                print("[\(tag)] Subscribed")
            },
            onDispose: {
                print("[\(tag)] Disposed")
            }
        )
    }
}
