//
//  RealtimeChatMongoDBApp.swift
//  RealtimeChatMongoDB
//
//  Created by CycTrung on 29/05/2023.
//
import SwiftUI
import Firebase
import GoogleMobileAds
import Kingfisher
import RealmSwift

let app = RealmSwift.App(id: "rchat-cbcqq")
let client = app.emailPasswordAuth

@main
struct RealtimeChatMongoDBApp: SwiftUI.App {
    @StateObject var appState = AppState()

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
        }
    }
}

struct RootView: View {
    @StateObject var appController = APPCONTROLLER.shared
    @StateObject var user = Users.shared
    @AppStorage("FIRST_LOAD_APP") var FIRST_LOAD_APP = false
    @AppStorage(CONSTANT.TIME_INSTALLED_APP) var TIME_INSTALLED_APP = 0
    @AppStorage(CONSTANT.SAVE_VERSION_APP) var SAVE_VERSION_APP = ""
    @State var load = false
    @AppStorage("LIST_APP_NAVIGATION") var listAppNavigation: [String] = []
    
    var body: some View {
        ZStack{
            if appController.SHOW_OPEN_APPP{
                ZStack{
                    Image("background")
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 10){
                        Image("iconApp")
                            .resizable()
                            .frame(width: 150, height: 150)
                        
                        ActivityIndicatorView()
                            .frame(width: 50, height: 50, alignment: .center)
                            .foregroundColor(.accentColor)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            else{
                ContentView()
                    .overlay(alignment: .center, content: {
                        appController.SHOW_APP_NAVIGATION ?
                        App_Navigation_View()
                        : nil
                    })
                if appController.SHOW_MESSAGE_ON_SCREEN{
                    Text(appController.MESSAGE_ON_SCREEN)
                        .font(.light(size: 16))
                        .foregroundColor(.text)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(.ultraThinMaterial)
                        .cornerRadius(20)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100)
                }
            }
        }
        .environmentObject(appController)
        .environmentObject(user)
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("PushMessage"))) { (output) in
            DispatchQueue.main.async {
                guard let str = output.userInfo?["data"] as? String else {return}
                appController.MESSAGE_ON_SCREEN = str
                withAnimation(.easeInOut(duration: 1)){
                    appController.SHOW_MESSAGE_ON_SCREEN  = true
                }
                appController.TIMER_MESSAGE_ON_SCREEN?.invalidate()
                appController.TIMER_MESSAGE_ON_SCREEN = Timer.scheduledTimer(withTimeInterval: 4, repeats: false, block: { _ in
                    withAnimation(.easeInOut(duration: 1)){
                        appController.SHOW_MESSAGE_ON_SCREEN  = false
                    }
                })
            }
        }
        .onAppear {
            if load == true{
                return
            }
            CONSTANT.SHARED.load {
                if appController.SHOW_OPEN_APPP{
                    openApp()
                    DispatchQueue.main.async {
                        withAnimation(.easeOut(duration: 1)) {
                            appController.SHOW_OPEN_APPP = false
                        }
                    }
                   
                }
                else{
                    DispatchQueue.main.async {
                        appController.SHOW_OPEN_APPP = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                        withAnimation(.easeOut(duration: 1)) {
                            appController.SHOW_OPEN_APPP = false
                        }
                    })
                }
                load = true
            }
        }
        .onChange(of: appController.INDEX_TABBAR, perform: { b in
            if Users.isShowInterstitial() == false{
                return
            }
            appController.COUNT_INTERSTITIAL += 1
            if appController.COUNT_INTERSTITIAL % CONSTANT.SHARED.ADS.INTERVAL_INTERSTITIAL == 0{
                InterstitialAd.shared.show()
            }
        })
    }
    
    func openApp(){
        Users.shared.getUser()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            GADMobileAds.sharedInstance().start(completionHandler: {_ in
                //GADMobileAds.sharedInstance().applicationMuted = true
            })
        })
        if !FIRST_LOAD_APP{
            TIME_INSTALLED_APP = Int(Date().timeIntervalSince1970)
            FIRST_LOAD_APP = true
        }
        appController.SHOW_APP_NAVIGATION = CONSTANT.SHARED.APP_NAVIGATION.ENABLE && !listAppNavigation.contains(where: { str in
            return str == CONSTANT.SHARED.APP_NAVIGATION.URL
        })
    }
}


struct App_Navigation_View: View{
    @State var opacity: Double = 0
    @StateObject var appController = APPCONTROLLER.shared
    @AppStorage("LIST_APP_NAVIGATION") var listAppNavigation: [String] = []
    var body: some View{
        ZStack{
            Color.black
                .opacity(0.5)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        appController.SHOW_APP_NAVIGATION = false
                    }
                    if !CONSTANT.SHARED.APP_NAVIGATION.IS_SHOW_ALWAYS{
                        listAppNavigation.append(CONSTANT.SHARED.APP_NAVIGATION.URL)
                    }
                }
            
            VStack(spacing: 20){
                KFImage(URL(string: CONSTANT.SHARED.APP_NAVIGATION.IMAGE_URL))
                    .resizable()
                    .onSuccess({ img in
                        withAnimation {
                            opacity = 1
                        }
                    })
                    .frame(width: 78, height: 78, alignment: .center)
                    .cornerRadius(12)
                    .padding(.top)
                
                VStack(spacing: 10){
                    Text(CONSTANT.SHARED.APP_NAVIGATION.TITLE)
                        .font(.light(size: 20))
                        .foregroundColor(Color(hex: CONSTANT.SHARED.APP_NAVIGATION.COLOR_TEXT))
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 10)
                        .multilineTextAlignment(.center)

                    Text(CONSTANT.SHARED.APP_NAVIGATION.MESSAGE)
                        .font(.light(size: 18))
                        .foregroundColor(Color(hex: CONSTANT.SHARED.APP_NAVIGATION.COLOR_TEXT))
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 30)
                        .multilineTextAlignment(.center)
                }
                VStack(spacing: 0){
                    Divider()
                    
                    Button {
                        if let url = URL(string: CONSTANT.SHARED.APP_NAVIGATION.URL) {
                            UIApplication.shared.open(url)
                        }
                        appController.SHOW_APP_NAVIGATION = false
                        if !CONSTANT.SHARED.APP_NAVIGATION.IS_SHOW_ALWAYS{
                            listAppNavigation.append(CONSTANT.SHARED.APP_NAVIGATION.URL)
                        }
                    } label: {
                        Text(CONSTANT.SHARED.APP_NAVIGATION.BUTTON_NAME)
                            .font(.light(size: 18))
                            .foregroundColor(Color(hex: CONSTANT.SHARED.APP_NAVIGATION.COLOR_BUTTON_TEXT))
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                    }
                }
            }
            .frame(width: 275, height: 230)
            .background(Color(hex: CONSTANT.SHARED.APP_NAVIGATION.COLOR_BACKGROUND))
            .cornerRadius(15)
            .opacity(opacity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

