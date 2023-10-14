//
//  HelperView.swift
//  DEFAULT_SOURCE
//
//  Created by CycTrung on 02/03/2023.
//

import SwiftUI
import WebKit

struct TextShimmer: View {
    var text: String
    var textColor: Color
    var font: Font
    @State var animation = true
    
    var body: some View{
        ZStack{
            Text(text)
                .font(font)
                .foregroundColor(textColor)
            
            HStack(spacing: 0){
                ForEach(0..<text.count,id: \.self){index in
                    Text(String(text[text.index(text.startIndex, offsetBy: index)]))
                        .font(font)
                        .foregroundColor(randomColor())
                }
            }
            .mask(
                Rectangle()
                // For Some More Nice Effect Were Going to use Gradient...
                    .fill(
                        // You can use any Color Here...
                        LinearGradient(gradient: .init(colors: [Color.white.opacity(0.5),Color.white,Color.white.opacity(0.5)]), startPoint: .top, endPoint: .bottom)
                    )
                    .rotationEffect(.init(degrees: 70))
                    .padding(0)
                // Moving View Continously...
                // so it will create Shimmer Effect...
                    .offset(x: -150)
                    .offset(x: animation ? 300 : 0)
            )
            .onAppear(perform: {
                DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                    withAnimation(Animation.linear(duration: 2).repeatForever(autoreverses: true)){
                        animation.toggle()
                    }
                }
            })
            
        }
        
    }
    
    func randomColor()->Color{
        let color = Color(red: 1, green: .random(in: 0...1), blue: .random(in: 0...1))
        return color
    }
}


public struct ActivityIndicatorView: View {
    public var body: some View {
        GeometryReader { geometry in
            ForEach(0..<3, id: \.self) { index in
                ArcsIndicatorItemView(lineWidth: 2, index: index, count: 3, size: geometry.size)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

struct ArcsIndicatorItemView: View {
    let lineWidth: CGFloat
    let index: Int
    let count: Int
    let size: CGSize

    @State private var rotation: Double = 0

    var body: some View {
        let animation = Animation.default
            .speed(Double.random(in: 0.2...0.5))
            .repeatForever(autoreverses: false)

        return Group { () -> Path in
            var p = Path()
            p.addArc(center: CGPoint(x: size.width / 2, y: size.height / 2),
                     radius: size.width / 2 - CGFloat(index) * CGFloat(count),
                     startAngle: .degrees(0),
                     endAngle: .degrees(Double(Int.random(in: 120...300))),
                     clockwise: true)
            return p.strokedPath(.init(lineWidth: lineWidth))
        }
        .frame(width: size.width, height: size.height)
        .rotationEffect(.degrees(rotation))
        .onAppear {
            rotation = 0
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                withAnimation(animation) {
                    rotation = 360
                }
            }
        }
    }
}

struct CustomActivity: View {
    var hasBackground: Bool = false
    var colorBackground: Color = .black
    var opacityBackground: Double = 0.4
    var foregroundColor: Color = .accentColor
    var size: CGSize = CGSize(width: 50, height: 50)
    @State var show = true
    var body: some View {
        ZStack{
            if hasBackground{
                colorBackground
                    .ignoresSafeArea()
                    .opacity(opacityBackground)
            }
            ActivityIndicatorView()
                .frame(width: size.width, height: size.height , alignment: .center)
                .foregroundColor(.accentColor)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct SkeletonView<Content>: View where Content: View {
    @State var alpha = 0.5
    var views: Content
    
    init(@ViewBuilder content: () -> Content) {
           self.views = content()
       }
    var body: some View {
        ZStack{
            views
        }
        .opacity(alpha)
        .onAppear(perform: {
            withAnimation(.easeInOut(duration: 3).repeatForever()){
                if alpha == 0.5{
                    alpha = 1
                }else{
                    alpha = 0.5
                }
            }
        })
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct WebView: UIViewRepresentable {
 
    var url: URL
 
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
 
    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}

struct TextView: UIViewRepresentable {
    @Binding var text: String
    @Binding var font: UIFont
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.font = font
        textView.autocapitalizationType = .sentences
        textView.isSelectable = true
        textView.isUserInteractionEnabled = true
        textView.backgroundColor = UIColor(Color("Background"))
        textView.textColor = UIColor(Color("Text"))
        textView.textAlignment = .left
        textView.allowsEditingTextAttributes = false
        textView.isEditable = false
        textView.linkTextAttributes = [
            .foregroundColor: UIColor.blue,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
        uiView.font = font
    }
}


struct MarqueeText: View{
    @State var text: String
    var font: UIFont
    var color: Color
    var speed = 0.015
    var delay: Double = 1
    @State var storedSize: CGSize = .zero
    @State var offset: CGFloat = 0
    
    var body: some View{
        ScrollView(.horizontal, showsIndicators: false){
            Text(text)
                .font(Font(font))
                .foregroundColor(color)
                .offset(x: offset)
        }
        .disabled(true)
        .onAppear(perform: {
            let baseText = text
            (1...15).forEach { _ in
                text.append(" ")
            }
            storedSize = textSize()
            text.append(baseText)
            
            let time: Double = speed * storedSize.width
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.linear(duration: time)){
                    offset = -storedSize.width
                }
            }
        })
        .onReceive(Timer.publish(every: (speed * storedSize.width)+delay, on: .main, in: .default).autoconnect()) { _ in
            offset = 0
            withAnimation(.linear(duration: (speed * storedSize.width))){
                offset = -storedSize.width
            }
        }
        
    }
    
    func textSize()->CGSize{
        let fontAttributes = [NSAttributedString.Key.font: font]
        return text.size(withAttributes: fontAttributes)
    }
}

extension View{
    func customSheet<SheetView: View>(height: CGFloat, detents: [UISheetPresentationController.Detent]? = nil, showSheet: Binding<Bool>, @ViewBuilder sheetView: @escaping ()->SheetView)->some View{
        return self.background(
            SheetHepler(sheetView: sheetView(), height: height, detents: detents, showSheet: showSheet)
        )
    }
}
struct RemoveBackground: UIViewRepresentable{
    func makeUIView(context: Context) -> some UIView {
        return UIView()
    }
    func updateUIView(_ uiView: UIViewType, context: Context) {
        DispatchQueue.main.async {
            uiView.superview?.superview?.backgroundColor = .clear
        }
    }
}
struct SheetHepler<SheetView: View>: UIViewControllerRepresentable{
    var sheetView: SheetView
    var height: CGFloat
    var detents: [UISheetPresentationController.Detent]? = nil
    @Binding var showSheet: Bool
    let controller = UIViewController()
    
    func makeUIViewController(context: Context) ->  UIViewController {
        controller.view.backgroundColor = .clear
        return controller
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if showSheet{
            let sheetController = CustomHostingController(rootView: sheetView)
            sheetController.height = height
            uiViewController.present(sheetController, animated: true)
        }else{
            uiViewController.dismiss(animated: true)
        }
    }
}

class CustomHostingController<Content: View>: UIHostingController<Content>{
    var height: CGFloat = 0.0
    var detents: [UISheetPresentationController.Detent]? = nil
    override func  viewDidLoad() {
        if let presentationController = presentationController as? UISheetPresentationController{
            //preferredContentSize.height = height
            if let dentent = detents{
                if #available(iOS 16.0, *) {
                    presentationController.detents = dentent +  [.custom(resolver: { context in
                        return self.height
                    })]
                } else {
                    presentationController.detents = dentent
                }
            }else{
                if #available(iOS 16.0, *) {
                    presentationController.detents = [.custom(resolver: { context in
                        return self.height
                    })]
                } else {
                    if height <= UIScreen.main.bounds.height / 2 - 60 {
                        presentationController.detents = [.medium()]
                    }
                    else{
                        presentationController.detents = [.large()]
                    }
                }
            }
        }
    }
}

struct HalvedCircularBar: View {
    
    @Binding var progress: CGFloat
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .trim(from: 0.0, to: 1)
                    .stroke(Color.background, style: StrokeStyle(lineWidth: 5))
                    .rotationEffect(Angle(degrees: -90))
                Circle()
                    .trim(from: 0.0, to: progress > 0 ? progress : 0)
                    .stroke(LinearGradient(colors: [.accentColor, Color(hex: "E177E4")], startPoint: .leading, endPoint: .trailing), lineWidth:  5)
                    .rotationEffect(Angle(degrees: -90))

            }
        }
    }
}
