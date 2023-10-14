
import Foundation
import SystemConfiguration
import Firebase
import SwiftUI
import UserNotifications
import MessageUI
import FirebaseDatabase
import StoreKit

class Network {
    class func connectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }
}

class GiftCode{
    static var shared = GiftCode()
    @AppStorage("ACTIVE_TOOL") var ACTIVE_TOOL = false
    /// Hướng dẫn mã code
    //Type: 0 -> Dùng 1 lần
    //      1 -> Dùng vô số lần
    //      2 -> Active Download
    
    //timeExpired:  Đơn vị: timestamp. lấy ở đây https://www.epochconverter.com
    //              0 -> Giới hạn Premium
    //              1 -> Hạn sử dụng của code
    //timeDuration: Chỉ có ở loại 1 => Đơn vị là ngày
    //isPublic: Chỉ có ở loại code 2: Active Downlaod. nếu là công khai thì bất cứ ai cũng có thể dùng
    
    func check(_ code: String, completion: @escaping ((Bool, String) -> Void)){
        let database = Database.database().reference().child(CONSTANT.SHARED.URL.PATH_GIFTCODE).child(code)
        database.getData { error, data in
            guard let data = data else {return}
            if data.exists() {
                if let object = data.value as? Dictionary<String,Any>{
                    let typeCode = object["type"] as? Int
                    if typeCode == 0{
                        if (object["isActive"] as? Bool) == false{
                            let time = (object["timeExpired"] as? Int) ?? 0
                            UserDefaults.standard.setValue(time, forKey: CONSTANT.EXPIRED_PREMIUM)
                            database.setValue(
                                [
                                    "isActive": true,
                                    "timeExpired": time,
                                    "type": 0
                                ]
                            )
                            let date = Date(timeIntervalSince1970: TimeInterval(time)).toString(format: "MMM dd, YYYY (hh:mm a)")
                            completion(true, "Successfull!\nTime: \(date)")
                        }
                        else{
                            completion(false, "Code is used!")
                        }
                    }else if typeCode == 1{
                        let timeExpired = (object["timeExpired"] as? Int) ?? 0
                        let timeDuration = (object["timeDuration"] as? Int) ?? 0
                        
                        if TimeInterval(timeExpired) < Date().timeIntervalSince1970{
                            completion(false, "The code has expired!")
                        }else{
                            let time = Int(Date().timeIntervalSince1970) + timeDuration * 86400
                            UserDefaults.standard.setValue(time, forKey: CONSTANT.EXPIRED_PREMIUM)
                            let date = Date(timeIntervalSince1970: TimeInterval(time)).toString(format: "MMM dd, YYYY (hh:mm a)")
                            completion(true, "Successfull!\nTime: \(date)")
                        }
                    }else if typeCode == 2{
                        if let isActiveTool = object["isActive"] as? Bool, isActiveTool == false{
                            GiftCode.shared.ACTIVE_TOOL = true
                            if let isPublicCode = object["isPublic"] as? Bool, isPublicCode == false{
                                database.setValue(
                                    [
                                        "isActive": true,
                                        "isPublic": false,
                                        "type": 2
                                    ]
                                )
                            }
                            completion(true, "ACTIVE DOWNLOAD SUCCESSFULL!")
                        }
                        else{
                            completion(false, "Code is used!")
                        }
                    }
                }
            }
            else{
                completion(false, "Code not found!")
            }
        }
       
    }
    func show(){
        let alert = MyAlert(title: "Input your GiftCode", message: nil, preferredStyle: .alert)
        alert.addTextField() { textField in
            textField.placeholder = "Code"
        }
        let ok = UIAlertAction(title: "OK", style: .cancel) { _ in
            guard let code = alert.textFields?.first?.text else {return}
            if code == "" {
                return
            }
            GiftCode.shared.check(code) { bool, status in
                LocalNotification.shared.message(status)
                Users.shared.getUser()
            }
        }
        alert.addAction(ok)
        ok.setValue(UIColor(Color.accentColor), forKey: "titleTextColor")
        MyAlert().showAlert(alert: alert)
    }
}

//Toast Message
class LocalNotification: ObservableObject {
    static var shared = LocalNotification()
    
    func setLocalNotification(title: String, subtitle: String, body: String, when: Double, id: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.body = body
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: when, repeats: false)
        let request = UNNotificationRequest.init(identifier: id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    func message(_ str: String){
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PushMessage"), object: nil, userInfo: ["data": str])
        }
    }
    static func message(_ str: String){
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PushMessage"), object: nil, userInfo: ["data": str])
        }
    }
}

class Mail: NSObject, MFMailComposeViewControllerDelegate {
    static var shared = Mail()
    func show(){
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        composeVC.setToRecipients([CONSTANT.SHARED.INFO_APP.EMAIL_CONTRACT])
        composeVC.setSubject("Customer Care")
        composeVC.setMessageBody("Dear Deverloper,\n", isHTML: false)
        UIApplication.shared.key?.rootViewController?.present(composeVC, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

class MyAlert: UIAlertController{
    static var shared = MyAlert()
    func setBackgroundColor(color: Color) {
        if let bgView = self.view.subviews.first, let groupView = bgView.subviews.first, let contentView = groupView.subviews.first {
            contentView.backgroundColor = UIColor(color)
            groupView.layer.cornerRadius = 20
        }
    }
    
    func setTitle(font: UIFont?, color: Color?) {
        guard let title = self.title else { return }
        let attributeString = NSMutableAttributedString(string: title)//1
        if let titleFont = font {
            attributeString.addAttributes([NSAttributedString.Key.font : titleFont],//2
                                          range: NSMakeRange(0, attributeString.length))
        }
        if let titleColor = color {
            attributeString.addAttributes([NSAttributedString.Key.foregroundColor : UIColor(titleColor)],//3
                                          range: NSMakeRange(0, attributeString.length))
        }
        self.setValue(attributeString, forKey: "attributedTitle")
    }
    
    func setMessage(font: UIFont?, color: Color?) {
        guard let title = self.message else { return }
        let attributeString = NSMutableAttributedString(string: title)//1
        if let titleFont = font {
            attributeString.addAttributes([NSAttributedString.Key.font : titleFont],//2
                                          range: NSMakeRange(0, attributeString.length))
        }
        if let titleColor = color {
            attributeString.addAttributes([NSAttributedString.Key.foregroundColor : UIColor(titleColor)],//3
                                          range: NSMakeRange(0, attributeString.length))
        }
        self.setValue(attributeString, forKey: "attributedMessage")
    }

    func setTint(color: UIColor) {
        self.view.tintColor = color
    }
    
    func showAlert(alert: MyAlert) {
        alert.setTint(color: UIColor(Color("AccentColor")))
        if let controller = UIApplication.shared.topMostViewController() {
            if controller.presentedViewController == nil{
                controller.present(alert, animated: true)
            }else{
                controller.presentedViewController?.present(alert, animated: true)
            }
        }
    }
    func share(item: [Any]){
        let activityViewController = UIActivityViewController(activityItems: item, applicationActivities: nil)
        if let viewController = UIApplication.shared.topMostViewController(){
            if let pop = activityViewController.popoverPresentationController{
                pop.sourceView = viewController.view
                pop.sourceRect = CGRect(x: viewController.view.center.x, y: viewController.view.center.y, width: 0, height: 0)
            }
            DispatchQueue.main.async {
                viewController.present(activityViewController, animated: true, completion: nil)
            }
           
        }
    }
    
    static func showRate(){
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
}

