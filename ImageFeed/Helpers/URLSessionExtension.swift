import Foundation

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
}

extension URLSession {
    
    func data(for request: URLRequest, completion: @escaping (Result<Data, Error>) -> Void) -> URLSessionTask {
        
        let completeInMain: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = dataTask(with: request) { data, response, error in
            if let data = data,
               let response = response,
               let code = (response as? HTTPURLResponse)?.statusCode
            {
                if (200...299).contains(code) {
                    completeInMain(.success(data))
                } else {
                    completeInMain(.failure(NetworkError.httpStatusCode(code)))
                }
            } else if let error = error {
                completeInMain(.failure(NetworkError.urlRequestError(error)))
            } else {
                completeInMain(.failure(NetworkError.urlSessionError))
            }
        }
        task.resume()
        return task
    }
}
