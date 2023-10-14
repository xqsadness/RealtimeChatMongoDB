//
//  USER.swift
//  DEFAULT_SOURCE
//
//  Created by CycTrung on 02/03/2023.
//

import Foundation
import SwiftUI

class Users: ObservableObject{
    static var shared = Users()
    @Published var timeExpired: Int = 0
    @Published var isPremium: Bool = false
    @AppStorage(CONSTANT.COUNT_DOWNLOAD) var countDownload = 0
    @AppStorage(CONSTANT.TIME_ADS_OPEN) var timeAdsOpen = 0
    @AppStorage(CONSTANT.COUNT_SHOW_RATE) var countShowRate = 0
    
    func getUser(){
        Users.shared.timeExpired = UserDefaults.standard.integer(forKey: CONSTANT.EXPIRED_PREMIUM)
        if TimeInterval(Users.shared.timeExpired) > Date().timeIntervalSince1970{
            Users.shared.isPremium = true
        }
        else{
            if timeExpired != 0 && UserDefaults.standard.bool(forKey: CONSTANT.IS_AUTO_RENEWS) == true{
                IAPHandler.shared.restorePurchase()
            }
            else{
                Users.shared.isPremium = false
            }
        }
    }
    
    static func activeNewDesign()->Bool{ return CONSTANT.SHARED.DESIGN.ACTIVE_NEW_DESIGN }
    
    static func activeMoreApp()->Bool{ return CONSTANT.SHARED.DESIGN.ACTIVE_MORE_APP }
    
    static func activeHidden()->Bool { return CONSTANT.SHARED.DESIGN.ACTIVE_HIDDEN }
    
    static func allowDownload()-> Bool {
        if Users.shared.isPremium{
            return true
        }
        return Users.shared.countDownload < CONSTANT.SHARED.ADS.LIMIT_FREE_WITH_REWARDED
    }
    
    static func isShowAdsOpen() -> Bool{
        if Users.shared.isPremium || !CONSTANT.SHARED.ADS.ENABLE_OPEN_APP{
            return false
        }else{
            if Users.shared.timeAdsOpen == 0{
                Users.shared.timeAdsOpen = Int(TimeInterval(Date().timeIntervalSince1970))
                return false
            }
            else{
                if Int(TimeInterval(Date().timeIntervalSince1970)) - Users.shared.timeAdsOpen > 0 {
                    Users.shared.timeAdsOpen = Int(TimeInterval(Date().timeIntervalSince1970))
                    return true
                }
                else{
                    return false
                }
            }
        }
    }
    
    static func isShowInterstitial()->Bool{
        if Users.shared.isPremium || !CONSTANT.SHARED.ADS.ENABLE_INTERSTITIAL{
            return false
        }
        return true
    }
    
    static func isShowBanner()->Bool{
        if Users.shared.isPremium || !CONSTANT.SHARED.ADS.ENABLE_BANNER{
            return false
        }
        return true
    }
    
    static func isShowRewarded()->Bool{
        if Users.shared.isPremium || !CONSTANT.SHARED.ADS.ENABLE_REWARDED{
            return false
        }
        return true
    }
    
    static func isShowNative()->Bool{
        if Users.shared.isPremium || !CONSTANT.SHARED.ADS.ENABLE_NATIVE{
            return false
        }
        return true
    }
    
    static func isShowRate()->Bool{
        if CONSTANT.SHARED.DESIGN.ACTIVE_SHOW_RATE_WHEN_OPEN_APP == false{
            return false
        }
       
        if Users.shared.countShowRate >= 16{
            return false
        }
        if ((Users.shared.countShowRate + 1) % 5 == 0){
            Users.shared.countShowRate += 1
            return true
        }
        else{
            Users.shared.countShowRate += 1
            return false
        }
    }
}

