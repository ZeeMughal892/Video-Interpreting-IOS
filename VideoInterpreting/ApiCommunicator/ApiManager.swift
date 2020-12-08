
import Foundation
import AlamofireObjectMapper
import RappleProgressHUD
import PromiseKit
import Alamofire

class ApiManager{
    static let api = ApiManager()
    private init(){
    }
    ///Get Token
    func GetToken(method:String,url:String,request:GetTokenRequest,viewController:UIViewController) -> Promise<GetTokenResponse> {
        var obj = GetTokenResponse();
        let manager = Alamofire.SessionManager.init()
                manager.delegate.sessionDidReceiveChallenge = { session, challenge in
                    var disposition: URLSession.AuthChallengeDisposition = .performDefaultHandling
                    var credential: URLCredential?
                    if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
                        disposition = URLSession.AuthChallengeDisposition.useCredential
                        credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
                    } else {
                        if challenge.previousFailureCount > 0 {
                            disposition = .cancelAuthenticationChallenge
                        } else {
                            credential = manager.session.configuration.urlCredentialStorage?.defaultCredential(for: challenge.protectionSpace)
                            if credential != nil {
                                disposition = .useCredential
                            }
                        }
                    }
                    return (disposition, credential)
                }            
        let parameter = [
            "Username": request.Username!,
            "PinCode": request.PinCode!
            ] as [String : Any]
        let header = ["Content-Type": "application/json"]
        return Promise<GetTokenResponse> {
            seal in
            manager.request(url,method: .post, parameters:parameter,encoding: JSONEncoding.default,headers: header).responseObject { (response : DataResponse<GetTokenResponse>) in
                switch(response.result) {
                case .success(_):
                    if let data = response.result.value{
                        obj = data
                        seal.fulfill(obj)
                        break
                    }
                case .failure(_):
                    if let alamoError = response.result.error{
                        RappleActivityIndicatorView.stopAnimation()
                        seal.reject(alamoError as Error)
                        break
                    }
                }
            }
        }
    }
    func EndHostMeeting(method:String,url:String,request:EndProcessRequest,viewController:UIViewController) -> Promise<EndProcessResponse> {
        var obj = EndProcessResponse();
        let manager = Alamofire.SessionManager.init()
                manager.delegate.sessionDidReceiveChallenge = { session, challenge in
                    var disposition: URLSession.AuthChallengeDisposition = .performDefaultHandling
                    var credential: URLCredential?
                    if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
                        disposition = URLSession.AuthChallengeDisposition.useCredential
                        credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
                    } else {
                        if challenge.previousFailureCount > 0 {
                            disposition = .cancelAuthenticationChallenge
                        } else {
                            credential = manager.session.configuration.urlCredentialStorage?.defaultCredential(for: challenge.protectionSpace)
                            if credential != nil {
                                disposition = .useCredential
                            }
                        }
                    }
                    return (disposition, credential)
                }
        let parameter = [
            "MeetingDetailID": request.MeetingDetailID!,
            "ParticipantSID": request.ParticipantSID!
            ] as [String : Any]
        let header = ["Content-Type": "application/json"]
        return Promise<EndProcessResponse> {
            seal in
            manager.request(url,method: .post, parameters:parameter,encoding: JSONEncoding.default,headers: header).responseObject { (response : DataResponse<EndProcessResponse>) in
                switch(response.result) {
                case .success(_):
                    if let data = response.result.value{
                        obj = data
                        seal.fulfill(obj)
                        break
                    }
                case .failure(_):
                    if let alamoError = response.result.error{
                        RappleActivityIndicatorView.stopAnimation()
                        seal.reject(alamoError as Error)
                        break
                    }
                }
            }
        }
    }
    func EndParticipantMeeting(method:String,url:String,request:EndProcessRequest,viewController:UIViewController) -> Promise<EndProcessResponse> {
        var obj = EndProcessResponse();
        let manager = Alamofire.SessionManager.init()
                manager.delegate.sessionDidReceiveChallenge = { session, challenge in
                    var disposition: URLSession.AuthChallengeDisposition = .performDefaultHandling
                    var credential: URLCredential?
                    if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
                        disposition = URLSession.AuthChallengeDisposition.useCredential
                        credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
                    } else {
                        if challenge.previousFailureCount > 0 {
                            disposition = .cancelAuthenticationChallenge
                        } else {
                            credential = manager.session.configuration.urlCredentialStorage?.defaultCredential(for: challenge.protectionSpace)
                            if credential != nil {
                                disposition = .useCredential
                            }
                        }
                    }
                    return (disposition, credential)
                }
        let parameter = [
            "MeetingDetailID": request.MeetingDetailID!,
            "ParticipantSID": request.ParticipantSID!
            ] as [String : Any]
        let header = ["Content-Type": "application/json"]
        return Promise<EndProcessResponse> {
            seal in
            manager.request(url,method: .post, parameters:parameter,encoding: JSONEncoding.default,headers: header).responseObject { (response : DataResponse<EndProcessResponse>) in
                switch(response.result) {
                case .success(_):
                    if let data = response.result.value{
                        obj = data
                        seal.fulfill(obj)
                        break
                    }
                case .failure(_):
                    if let alamoError = response.result.error{
                        RappleActivityIndicatorView.stopAnimation()
                        seal.reject(alamoError as Error)
                        break
                    }
                }
            }
        }
    }
    func UpdateRoomDetail(method:String,url:String,request:UpdateRoomDetailRequest,viewController:UIViewController) -> Promise<UpdateRoomDetailResponse> {
        var obj = UpdateRoomDetailResponse();
        let manager = Alamofire.SessionManager.init()
                manager.delegate.sessionDidReceiveChallenge = { session, challenge in
                    var disposition: URLSession.AuthChallengeDisposition = .performDefaultHandling
                    var credential: URLCredential?
                    if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
                        disposition = URLSession.AuthChallengeDisposition.useCredential
                        credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
                    } else {
                        if challenge.previousFailureCount > 0 {
                            disposition = .cancelAuthenticationChallenge
                        } else {
                            credential = manager.session.configuration.urlCredentialStorage?.defaultCredential(for: challenge.protectionSpace)
                            if credential != nil {
                                disposition = .useCredential
                            }
                        }
                    }
                    return (disposition, credential)
                }
        let parameter = [
            "MeetingID": request.MeetingID!,
            "RoomSID": request.RoomSID!
            ] as [String : Any]
        let header = ["Content-Type": "application/json"]
        return Promise<UpdateRoomDetailResponse> {
            seal in
            manager.request(url,method: .post, parameters:parameter,encoding: JSONEncoding.default,headers: header).responseObject { (response : DataResponse<UpdateRoomDetailResponse>) in
                switch(response.result) {
                case .success(_):
                    if let data = response.result.value{
                        obj = data
                        seal.fulfill(obj)
                        break
                    }
                case .failure(_):
                    if let alamoError = response.result.error{
                        RappleActivityIndicatorView.stopAnimation()
                        seal.reject(alamoError as Error)
                        break
                    }
                }
            }
        }
    }

}
