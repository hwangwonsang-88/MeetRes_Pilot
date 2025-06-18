//
//  WGoogleLoginService.swift
//  Meet_pilot
//
//  Created by 인스웨이브 on 6/16/25.
//

import Foundation
import GoogleSignInSwift
import GoogleAPIClientForREST_Calendar
import GTMAppAuth
import RxSwift
import GoogleSignIn

final class WGoogleLoginService {
    static let shared = WGoogleLoginService()
    
    private init () {}
    
    func singIn() -> Single<Void> {
        return Single.create { single in
            GIDSignIn.sharedInstance.signIn(withPresenting: UIApplication.shared.windows.first!.rootViewController!,
                                            hint: nil,
                                            additionalScopes: [kGTLRAuthScopeCalendarReadonly]) { result, error in
                if error != nil {
                    return single(.failure(error!))
                }
                
                guard let result = result else {
                    return single(.failure(NSError(domain: "WgoogleNoresult", code: 54949)))
                }
                
                let user = result.user
                let auth = user.accessToken
                
                WGoogleCalendarService.shared.setAuth(by: user)
                print("sign in done")
                return single(.success(()))
                
            }
            return Disposables.create()
        }
    }
    
    func signOut() {
        
    }
    
    func hasSignedIn() -> Observable<Bool> {
        return Observable.create { emitter in
            if GIDSignIn.sharedInstance.currentUser != nil {
                emitter.onNext(true)
                emitter.onCompleted()
            } else {
                emitter.onNext(false)
            }
            return Disposables.create()
        }
    }
}
