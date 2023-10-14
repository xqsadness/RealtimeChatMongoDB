//
//  ProfileView.swift
//  RealtimeChatMongoDB
//
//  Created by Darktech on 5/30/23.
//

import SwiftUI
import RealmSwift
import CoreLocation

struct ProfileView: View {
    @AppStorage("shouldShareLocation") var shareLocation = false
    @AppStorage("activeStatus") var activeStatus = true
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var state: AppState
    @EnvironmentObject var showPopup: ShowHideHelper
    @ObservedRealmObject var user: User
    @State var isRename = false
    @State var txtName = ""
    @Binding var userID: String?
    @Binding var isLogout: Bool
    
    @State private var displayName = ""
    @State private var photo: Photo?
    @State private var photoAdded = false
    
    let userPreferences = UserPreferences()
    
    var body: some View {
        ScrollView {
            VStack {
                HStack{
                    Image("back")
                        .resizable()
                        .frame(width: 34,height: 34)
                        .onTapGesture {
                            dismiss()
                        }
                        .padding(.leading)
                    
                    Spacer()
                    
                    Button{
                        isLogout = true
                        dismiss()
                        withAnimation {
                            logout()
                        }
                    }label: {
                        Text("Logout")
                            .font(.regularTitle(size: 17))
                            .foregroundColor(Color.red)
                    }
                    .padding(.trailing)
                }
                
                ZStack(alignment: .bottomTrailing) {
                    if photo != nil{
                        if let photo = photo {
                            Image(uiImage: UIImage(data: photo.thumbNail ?? Data()) ?? UIImage())
                                .resizable()
                                .frame(width: 130, height: 130)
                                .aspectRatio(contentMode: .fit)
                                .cornerRadius(50)
                        }
                    }else{
                        Image("default")
                            .resizable()
                            .frame(width: 150, height: 150)
                            .cornerRadius(50)
                    }
                    
                    Button {
                        showPhotoTaker()
                    } label: {
                        Image(systemName: "plus")
                            .imageScale(.large)
                            .foregroundColor(.background)
                            .frame(width: 40, height: 40)
                            .clipShape(Rectangle())
                            .background(Color.text)
                            .cornerRadius(15)
                            .padding(.trailing, -6)
                    }
                }
                .frame(width: 200)
                .padding(.bottom)
                
                HStack {
                    if displayName == "" {
                        Text("\(user.userName)")
                            .font(.black(size: 22))
                            .foregroundColor(.text)
                    }
                    else {
                        Text("\(displayName)")
                            .font(.black(size: 22))
                            .foregroundColor(.text)
                    }
                    
                    Divider()
                        .foregroundColor(.text)
                    
                    Button {
                        isRename = true
                    } label: {
                        Image(systemName: "pencil")
                            .imageScale(.large)
                            .foregroundColor(.text)
                    }
                    
                }
                .padding(.bottom, 40)
                
                .alert("Rename", isPresented: $isRename ){
                    Button(role : .none) {
                        saveProfile()
                    } label: {
                        Text("OK")
                    }
                    
                    TextField("Rename", text: $displayName)
                        .foregroundColor(Color.black)
                        .textFieldStyle(.automatic)
                        .frame(height: 40)
                }
                 
                HStack{
                    Toggle(isOn: $shareLocation, label: {
                        Text("Share Location")
                    })
                    .onChange(of: shareLocation) { value in
                        if value {
                            _ = LocationHelper.shared.currentLocation
                            checkLocationPermission()
                        }
                     
                    }
                }
                .padding(.horizontal, 24)
                .frame(maxWidth: .infinity)
                .frame(height: 72)
                .background(
                    RoundedRectangle(
                        cornerRadius: 10
                    )
                    .foregroundColor(Color.background)
                    .shadow(color: Color.text.opacity(0.2),radius: 4)
                )
                .padding(.horizontal, 24)
                .padding(5)
                
                HStack{
                    Toggle(isOn: $activeStatus, label: {
                        Text("Change active status")
                    })
                    .onChange(of: activeStatus) { value in
                        if value {
                            $user.presenceState.wrappedValue = .onLine
                            print("tren : \($user.presenceState.wrappedValue)")
                        }
                        else {
                            $user.presenceState.wrappedValue = .offLine
                            print("duoi : \($user.presenceState.wrappedValue)")
                        }
                     
                    }
                }
                .padding(.horizontal, 24)
                .frame(maxWidth: .infinity)
                .frame(height: 72)
                .background(
                    RoundedRectangle(
                        cornerRadius: 10
                    )
                    .foregroundColor(Color.background)
                    .shadow(color: Color.text.opacity(0.2),radius: 4)
                )
                .padding(.horizontal, 24)
                .padding(5)
            }
            .onAppear{
                initData()
                activeStatus = $user.presenceState.wrappedValue == .onLine
                print("status : \(activeStatus)")
            }
        }
    }

    func logout(){
        DispatchQueue.main.async {
            state.shouldIndicateActivity = true
            app.currentUser?.logOut { error in
                if let error = error {
                    print("\(error.localizedDescription)")
                } else {
                    state.shouldIndicateActivity = false
                    withAnimation {
                        userID = nil
                    }
                    LocalNotification.message("Logout success!")
                }
            }
        }
    }
    
    private func initData() {
        displayName = user.userPreferences?.displayName ?? "Unknown"
        photo = user.userPreferences?.avatarImage
    }
    
    private func saveProfile() {
        let userPreferences = UserPreferences()
        userPreferences.displayName = displayName
        
        if let newPhoto = photo {
            userPreferences.avatarImage = Photo(value: newPhoto)
        } else {
            userPreferences.avatarImage = nil
        }
        
        $user.userPreferences.wrappedValue = userPreferences
        $user.presenceState.wrappedValue = .onLine
    }

    
    private func showPhotoTaker() {
        PhotoCaptureController.show(source: .camera) { controller, photo in
            self.photo = photo
            saveProfile()
            controller.hide()
        }
    }
    
    
    func checkLocationPermission() {
        let locationManager = CLLocationManager()
        
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse, .authorizedAlways:
            print("Location permission granted")
        case .denied, .restricted:
            let alert = MyAlert(title: "You have not granted access, You need to go to settings to get access", message: "", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { action in
                shareLocation = false
            }
            okAction.setValue(UIColor.blue, forKey: "titleTextColor")
            alert.addAction(okAction)
            MyAlert.shared.showAlert(alert: alert)
        @unknown default:
            print("Unknown location permission status")
        }
    }
}
