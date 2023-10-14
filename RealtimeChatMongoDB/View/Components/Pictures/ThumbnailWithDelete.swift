//
//  ThumbnailWithDelete.swift
//  RealtimeChatMongoDB
//
//  Created by darktech4 on 05/06/2023.
//

import SwiftUI

struct ThumbnailWithDelete: View {
    let photo: Photo?
    var action: (() -> Void)?
    
    private enum Dimensions {
        static let frameSize: CGFloat = 100
        static let imageSize: CGFloat = 70
        static let buttonSize: CGFloat = 30
        static let radius: CGFloat = 8
        static let buttonPadding: CGFloat = 4
    }
    
    var body: some View {
        ZStack {
            ThumbNailView(photo: photo)
                .frame(width: Dimensions.imageSize, height: Dimensions.imageSize, alignment: .center)
                .clipShape(RoundedRectangle(cornerRadius: Dimensions.radius))
            if let action = action {
                VStack {
                    HStack {
                        Spacer()
                        CameraButton(action: action, active: true ,activeImage: "minus.square.fill", inactiveImage: "minus.square", padding: CGFloat(8))
                            .frame(width: Dimensions.buttonSize, height: Dimensions.buttonSize, alignment: .center)
                    }
                    Spacer()
                }
                .frame(width: Dimensions.frameSize, height: Dimensions.frameSize)
            }
        }
    }
}
