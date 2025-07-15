//
//  NetworkManager.swift
//  StickerMakerNew4.0
//
//  Created by Bcl Device 13 on 3/6/24.
//

import Foundation
import UIKit

final public class NetworkManager: NSObject {
    
    let BASEURL =  "http://iv2-api.gifmakerpro.com/v2/stickers/list/0/0"
    
    let API_KEY = "+bWQKjfK-=jfbqbc8q=jDLBc&526Crr5sdfsdf4216549xasx894JjyWpXTUxsRb5_"

    private var urlSession = URLSession(configuration: URLSessionConfiguration.default)
    private var apiTasks: [URLSessionTask] = []
    private var requestTimeoutValue: Double = 60.0
    public static let sharedInstance = NetworkManager()
    
}

//MARK: Request Methods
extension NetworkManager {

    
    func loadAsset(requestUrl: String, method: RequestMethod, params: JSON, showAlert: Bool = true,  completion: @escaping (Data?, Int) -> Void) -> Void {
        
        var request = URLRequest(baseUrl: requestUrl, path: "", method: method, params: params, addHeaders: false)
        request.timeoutInterval = requestTimeoutValue
        
        print("\nSERVICE CALLING STARTED.........\n")
        print(request.url ?? "")
        let task = NetworkManager.sharedInstance.urlSession.dataTask(with: request) { [weak self] data, response, error in
            self?.apiTaskDone()
            
            if let requestData = data {
                if let json = try? JSONSerialization.jsonObject(with: requestData, options: []) {
                    print(json)
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    completion(requestData, httpResponse.statusCode)
                } else {
                    completion(nil, 0)
                }
            } else {
                if let error = error, showAlert{
                    let alertMessagePopUpBox = UIAlertController(title: "Error!", message: error.localizedDescription, preferredStyle: .alert)
                    let okButton = UIAlertAction(title: "Okay", style: .default)
                    
                    alertMessagePopUpBox.addAction(okButton)

                    DispatchQueue.main.async {
                        UIApplication.shared.keyWindow?.visibleViewController?.present(alertMessagePopUpBox, animated: true)
                    }
                }
                completion(nil, 0)
            }
        }
        NetworkManager.sharedInstance.apiTasks.append(task)
        task.resume()
        
        return
    }
}

//MARK: Custom methods
extension NetworkManager {
    
    func apiTaskDone() {
        if apiTasks.count > 0 {
            apiTasks.removeLast()
        }
    }
    
    func cancelAllAPICalls() {
        for task in apiTasks {
            task.cancel()
        }
        apiTasks.removeAll()
    }
}

//MARK: URL
extension URL {
    init(baseUrl: String, path: String, params: JSON, method: RequestMethod) {
        var components = URLComponents(string: baseUrl)
        if !path.isEmpty {
            components?.path += path
        }
        
        switch method {
        case .get, .delete:
            if params.count > 0 {
                components?.queryItems = params.map {
                    URLQueryItem(name: $0.key, value: String(describing: $0.value))
                }
            }
        default:
            break
        }
        
        if let url = components?.url {
            self = url
        } else {
            self = URL(fileURLWithPath: "")
        }
    }
}

//MARK: URLRequest
extension URLRequest {
    init(baseUrl: String, path: String, method: RequestMethod, params: JSON, addHeaders: Bool = true) {
        let url = URL(baseUrl: baseUrl, path: path, params: params, method: method)
        
        self.init(url: url)
        httpMethod = method.rawValue
        if addHeaders {
            setValue("application/json", forHTTPHeaderField: "Accept")
            setValue("application/json", forHTTPHeaderField: "Content-Type")
            setValue(NetworkConstants.userName, forHTTPHeaderField: "UserName")
            setValue(NetworkConstants.password, forHTTPHeaderField: "Password")
        }
        
        switch method {
        case .post, .put:
            httpBody = try! JSONSerialization.data(withJSONObject: params, options: [])
        default:
            break
        }
    }
}

enum RequestError: Error {
    case error(Error), unknownResponse, decodingError,invalidURL
}

extension NetworkManager {
    
    func requestForGetStickersData(completion: ((Result<Data, RequestError>) -> Void)?) {
          let url = URL(string: BASEURL)
           guard let requestUrl = url else { fatalError() }
           
           var request = URLRequest(url: requestUrl)
           request.httpMethod = "GET"
           
           request.allHTTPHeaderFields = ["authorization": API_KEY]
           
        let task =  NetworkManager.sharedInstance.urlSession.dataTask(with: request) { (data, response, error) in
               if let error = error {
                   completion?(.failure(.error(error)))
               }
               guard let httpResponse = response as? HTTPURLResponse else {
                   return
               }
               
               if let validData = data {
                   if let JSONString = String(data: validData, encoding: String.Encoding.utf8) {
//                       print("response json > ",JSONString)
                       UserDefaults.standard.setValue(JSONString, forKey: "StickerAPIResponseKey")
                       completion?(.success(validData))
                   }
               }
           }
           task.resume()
       }
}

import Foundation
import UIKit

public extension UIWindow {
    var visibleViewController: UIViewController? {
        return UIWindow.getVisibleViewControllerFrom(self.rootViewController)
    }

    static func getVisibleViewControllerFrom(_ vc: UIViewController?) -> UIViewController? {
        if let nc = vc as? UINavigationController {
            return UIWindow.getVisibleViewControllerFrom(nc.visibleViewController)
        } else if let tc = vc as? UITabBarController {
            return UIWindow.getVisibleViewControllerFrom(tc.selectedViewController)
        } else {
            if let pvc = vc?.presentedViewController {
                return UIWindow.getVisibleViewControllerFrom(pvc)
            } else {
                return vc
            }
        }
    }
}
