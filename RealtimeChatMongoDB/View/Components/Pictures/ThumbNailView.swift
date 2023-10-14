//
//  ThumbNailView.swift
//  RealtimeChatMongoDB
//
//  Created by darktech4 on 02/06/2023.
//

import SwiftUI

struct ThumbNailView: View {
    let photo: Photo?
    private let compressionQuality: CGFloat = 0.8
    
    var body: some View {
        NavigationLink{
            VStack {
                if let picture = photo?.picture {
                    if let image = UIImage(data: picture) {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                }
            }
        }label: {
            VStack {
                if let photo = photo {
                    if photo.thumbNail != nil || photo.picture != nil {
                        if let photo = photo.thumbNail {
                            Thumbnail(imageData: photo)
                        } else {
                            if let photo = photo.picture {
                                Thumbnail(imageData: photo)
                            } else {
                                Thumbnail(imageData: UIImage().jpegData(compressionQuality: compressionQuality)!)
                            }
                        }
                    }
                }
            }
        }
    }
}

struct Thumbnail: View {
    let imageData: Data
    
    var body: some View {
        Image(uiImage: (UIImage(data: imageData) ?? UIImage()))
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}
