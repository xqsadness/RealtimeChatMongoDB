//
//  ChatRoomBubblesView.swift
//  RealtimeChatMongoDB
//
//  Created by darktech4 on 01/06/2023.
//

import SwiftUI
import RealmSwift
import MapKit

struct ChatRoomBubblesView: View {
    @ObservedRealmObject var chatMessage: ChatMessage
    @StateRealmObject var chatster :Chatster
    @State var isClick = false
    @State var showImg = false
    let authorName: String?
    @State var showAddress: String = ""
    @State var showCity: String = ""
    var isMyMessage: Bool { authorName == nil }
    
    private enum Dimensions {
        static let padding: CGFloat = 4
        static let horizontalOffset: CGFloat = 100
        static let cornerRadius: CGFloat = 15
    }
    
    var body: some View {
        VStack{
            if isClick{
                TextDate(date: chatMessage.timestamp)
                    .font(.caption)
                    .foregroundColor(Color.black)
                    .frame(maxWidth: .infinity)
                    .padding(.top)
            }
            
            HStack{
                if isMyMessage {
                    Spacer()
                        .frame(width: Dimensions.horizontalOffset)
                }
                AuthorView(author: chatster, isMyMessage: isMyMessage)
                    .frame(width: 40,height: 40)
                    .frame(maxHeight: .infinity, alignment: .top)
                
                VStack {
                    //                HStack {
                    //                    AuthorView(author: chatster, isMyMessage: isMyMessage)
                    //
                    //                    Spacer()
                    //
                    //                    TextDate(date: chatMessage.timestamp)
                    //                        .font(.caption)
                    //                        .foregroundColor(isMyMessage ? Color.text2 : Color.text)
                    //                }
                    HStack {
                        if let photo = chatMessage.image {
                            ThumbNailView(photo: photo)
                            //                                .frame(width: 70, height: 70, alignment: .center)
                            //                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .cornerRadius(10)
                                .padding(Dimensions.padding)
                                .onAppear{
                                    showImg = true
                                }
                        }
                        let location = chatMessage.location
                        if location.count == 2 {
                            VStack {
                                MapThumbnailWithExpand(location: location.map { $0 })
                                    .onAppear{
                                        reverseGeocodeLocation(latitude: location[1], longitude: location[0]) { address, city  in
                                            if let address = address, let city = city {
                                                // Hiển thị tên đường
                                                showAddress = address
                                                showCity = city
                                            } else {
                                                // Không tìm thấy tên đường
                                                print(location[0])
                                                print(location[1])
                                            }
                                        }
                                    }
                                
                                Text("\(showAddress) \(showCity)")
                                    .font(Font.light(size: 16))
                                    .foregroundColor(.background)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(5)
                        }
                        if chatMessage.text != "" {
                            Text(safeAttributedString(chatMessage.text))
                                .padding(Dimensions.padding)
                                .foregroundColor(isMyMessage ? Color.text2 : Color.text)
                        }
                        Spacer()
                    }
                }
                .padding(Dimensions.padding)
                .padding(.vertical,8)
                .background(!showImg ? (isMyMessage ? LinearGradient(gradient: Gradient(colors: [Color(hex: "F90095"), Color(hex: "FF4848")]), startPoint: .bottomLeading, endPoint: .bottomTrailing) : LinearGradient(gradient: Gradient(colors: [Color.text2, Color.text2]), startPoint: .bottomLeading, endPoint: .bottomTrailing)) : nil )
                
                .cornerRadius(10, corners: isMyMessage ? [.topLeft, .topRight, .bottomLeft] : [.topRight, .bottomLeft, .bottomRight])
                if !isMyMessage { Spacer().frame(width: Dimensions.horizontalOffset) }
            }
            .onTapGesture {
                withAnimation {
                    isClick.toggle()
                }
            }
        }
        .padding(.horizontal)
    }
    
    private func safeAttributedString(_ sourceString: String) -> AttributedString {
        do {
            return try AttributedString(markdown: sourceString)
        } catch {
            print("Failed to convert Markdown to AttributedString: \(error.localizedDescription)")
            return try! AttributedString(markdown: "Text could not be rendered")
        }
    }
    
    func reverseGeocodeLocation(latitude: Double, longitude: Double, completion: @escaping (String?, String?) -> Void) {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: latitude, longitude: longitude)
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print("Error reverse geocoding location: \(error.localizedDescription)")
                completion(nil, nil)
                return
            }
            
            if let placemark = placemarks?.first {
                var addressString = ""
                
                if let street = placemark.thoroughfare {
                    addressString += street + ", "
                }
                
                if let city = placemark.locality {
                    addressString += city
                }
                
                if !addressString.isEmpty || placemark.locality != nil {
                    // Trả về tên đường và tên thành phố
                    completion(addressString, placemark.locality)
                    return
                }
            }
            // Không tìm thấy thông tin địa chỉ
            completion(nil, nil)
        }
    }
}

struct TextDate: View {
    let date: Date
    
    private var isLessThanOneMinute: Bool { date.timeIntervalSinceNow > -60 }
    private var isLessThanOneDay: Bool { date.timeIntervalSinceNow > -60 * 60 * 24 }
    private var isLessThanOneWeek: Bool { date.timeIntervalSinceNow > -60 * 60 * 24 * 7}
    private var isLessThanOneYear: Bool { date.timeIntervalSinceNow > -60 * 60 * 24 * 365}
    
    var body: some View {
        if isLessThanOneMinute {
            Text(date.formatted(.dateTime.hour().minute().second()))
        } else {
            if isLessThanOneDay {
                Text(date.formatted(.dateTime.hour().minute()))
            } else {
                if isLessThanOneWeek {
                    Text(date.formatted(.dateTime.weekday(.wide).hour().minute()))
                } else {
                    if isLessThanOneYear {
                        Text(date.formatted(.dateTime.month().day()))
                    } else {
                        Text(date.formatted(.dateTime.year().month().day()))
                    }
                }
            }
        }
    }
}

struct UnsendView: View {
    @ObservedRealmObject var chatMessage: ChatMessage
    @StateRealmObject var chatster :Chatster
    @State var isClick = false
    let authorName: String?
    var isMyMessage: Bool { authorName == nil }
    
    private enum Dimensions {
        static let padding: CGFloat = 4
        static let horizontalOffset: CGFloat = 100
        static let cornerRadius: CGFloat = 15
    }
    
    var body: some View {
        VStack{
            if isClick{
                TextDate(date: chatMessage.timestamp)
                    .font(.caption)
                    .foregroundColor(Color.black)
                    .frame(maxWidth: .infinity)
                    .padding(.top)
            }
            
            HStack{
                if isMyMessage {
                    Spacer()
                        .frame(width: Dimensions.horizontalOffset)
                }
                AuthorView(author: chatster, isMyMessage: isMyMessage)
                    .frame(width: 40,height: 40)
                    .frame(maxHeight: .infinity, alignment: .top)
                
                VStack {
                    HStack {
                        if let _ = chatMessage.image {
                            Text("\(isMyMessage ? "You" : "Your friend") unsent a message")
                                .padding(Dimensions.padding)
                                .italic()
                                .foregroundColor(Color.gray)
                        }
                        
                        let location = chatMessage.location
                        if location.count == 2 {
                            Text("\(isMyMessage ? "You" : "Your friend") unsent a message")
                                .padding(Dimensions.padding)
                                .italic()
                                .foregroundColor(Color.gray)
                        }
                        
                        if chatMessage.text != "" {
                            Text("\(isMyMessage ? "You" : "Your friend") unsent a message")
                                .padding(Dimensions.padding)
                                .italic()
                                .foregroundColor(Color.gray)
                        }
                        Spacer()
                    }
                }
                .padding(.vertical,8)
                .background(LinearGradient(gradient: Gradient(colors: [Color.background, Color.background]), startPoint: .bottomLeading, endPoint: .bottomTrailing) )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.black.opacity(0.6), lineWidth: 0.3)
                        .cornerRadius(10)
                )
                
                if !isMyMessage { Spacer().frame(width: Dimensions.horizontalOffset) }
            }
            .onTapGesture {
                withAnimation {
                    isClick.toggle()
                }
            }
        }
        .padding(.horizontal)
    }
    
    private func safeAttributedString(_ sourceString: String) -> AttributedString {
        do {
            return try AttributedString(markdown: sourceString)
        } catch {
            print("Failed to convert Markdown to AttributedString: \(error.localizedDescription)")
            return try! AttributedString(markdown: "Text could not be rendered")
        }
    }
}
