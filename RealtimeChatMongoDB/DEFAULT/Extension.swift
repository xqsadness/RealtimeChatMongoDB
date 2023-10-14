import Foundation
import SwiftUI

extension Font{
    static var custom = "AvenirLTStd"
    static var custom1 = "BubblegumSans"
    
    public static func heavy(size: CGFloat) -> Font{
        //let font = custom(custom+"-Bold", size: size)
        return .system(size: size, weight: .heavy)
    }
    public static func regularTitle(size: CGFloat) -> Font{
        //let font = custom(custom+"-Bold", size: size)
        return .custom(custom1+"-Regular", size: size)
    }
    public static func light(size: CGFloat) -> Font{
        return .custom(custom+"-Regular", size: size)
    }
    public static func black(size: CGFloat) -> Font{
        return .custom(custom+"-Black", size: size)
    }
}
extension UIFont{
    public static func honeyFlorist(size: CGFloat)->UIFont{
        return UIFont.init(name: "HoneyFloristPersonalUse", size: size) ?? .systemFont(ofSize: size)
    }
}

extension String {
    func verifyUrl() -> Bool {
        let regex = "((http|https|ftp)://)?((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: self)
        
    }
    
    func slice(from: String, to: String) -> String? {
        guard let fromRange = from.isEmpty ? startIndex..<startIndex : range(of: from) else { return nil }
        guard let toRange = to.isEmpty ? endIndex..<endIndex : range(of: to, range: fromRange.upperBound..<endIndex) else { return nil }
        
        return String(self[fromRange.upperBound..<toRange.lowerBound])
    }
    
    static func randomString(_ length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    func toDate(format: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.date(from: self)
    }
    
    var integer: Int {
        return Int(self) ?? 0
    }
    
    var secondFromString : Int{
        let components: Array = self.components(separatedBy: ":")
        if components.count == 1{
            let hours = 0
            let minutes = 0
            let seconds = components[0].integer
            return Int((hours * 60 * 60) + (minutes * 60) + seconds)
        }
        else if components.count == 2{
            let hours = 0
            let minutes = components[0].integer
            let seconds = components[1].integer
            return Int((hours * 60 * 60) + (minutes * 60) + seconds)
        }
        else if components.count == 3{
            let hours = components[0].integer
            let minutes = components[1].integer
            let seconds = components[2].integer
            return Int((hours * 60 * 60) + (minutes * 60) + seconds)
        }
        else{
            return 0
        }
    }
    
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options:
                                            [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}

extension Color{
    init(hex string: String) {
        var string: String = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if string.hasPrefix("#") {
            _ = string.removeFirst()
        }
        
        // Double the last value if incomplete hex
        if !string.count.isMultiple(of: 2), let last = string.last {
            string.append(last)
        }
        
        // Fix invalid values
        if string.count > 8 {
            string = String(string.prefix(8))
        }
        
        // Scanner creation
        let scanner = Scanner(string: string)
        
        var color: UInt64 = 0
        scanner.scanHexInt64(&color)
        
        if string.count == 2 {
            let mask = 0xFF
            
            let g = Int(color) & mask
            
            let gray = Double(g) / 255.0
            
            self.init(.sRGB, red: gray, green: gray, blue: gray, opacity: 1)
            
        } else if string.count == 4 {
            let mask = 0x00FF
            
            let g = Int(color >> 8) & mask
            let a = Int(color) & mask
            
            let gray = Double(g) / 255.0
            let alpha = Double(a) / 255.0
            
            self.init(.sRGB, red: gray, green: gray, blue: gray, opacity: alpha)
            
        } else if string.count == 6 {
            let mask = 0x0000FF
            let r = Int(color >> 16) & mask
            let g = Int(color >> 8) & mask
            let b = Int(color) & mask
            
            let red = Double(r) / 255.0
            let green = Double(g) / 255.0
            let blue = Double(b) / 255.0
            
            self.init(.sRGB, red: red, green: green, blue: blue, opacity: 1)
            
        } else if string.count == 8 {
            let mask = 0x000000FF
            let r = Int(color >> 24) & mask
            let g = Int(color >> 16) & mask
            let b = Int(color >> 8) & mask
            let a = Int(color) & mask
            
            let red = Double(r) / 255.0
            let green = Double(g) / 255.0
            let blue = Double(b) / 255.0
            let alpha = Double(a) / 255.0
            
            self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
            
        } else {
            self.init(.sRGB, red: 1, green: 1, blue: 1, opacity: 1)
        }
    }
    func hexValue() -> String {
        guard let values = self.cgColor?.components else {return "000000"}
        var outputR: Int = 0
        var outputG: Int = 0
        var outputB: Int = 0
        var outputA: Int = 1
        
        switch values.count {
        case 1:
            outputR = Int(values[0] * 255)
            outputG = Int(values[0] * 255)
            outputB = Int(values[0] * 255)
            outputA = 1
        case 2:
            outputR = Int(values[0] * 255)
            outputG = Int(values[0] * 255)
            outputB = Int(values[0] * 255)
            outputA = Int(values[1] * 255)
        case 3:
            outputR = Int(values[0] * 255)
            outputG = Int(values[1] * 255)
            outputB = Int(values[2] * 255)
            outputA = 1
        case 4:
            outputR = Int(values[0] * 255)
            outputG = Int(values[1] * 255)
            outputB = Int(values[2] * 255)
            outputA = Int(values[3] * 255)
        default:
            break
        }
        return String(format:"%02X", outputR) + String(format:"%02X", outputG) + String(format:"%02X", outputB) + String(format:"%02X", outputA)
    }
    public static var text: Color = Color("Text")
    public static var text2: Color = Color("Text2")
    public static var background: Color = Color("Background")
    public static var background2: Color = Color("Background2")
    static var random: Color {
        return Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }
}

extension UIColor{
    convenience init(hex string: String) {
        var string: String = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if string.hasPrefix("#") {
            _ = string.removeFirst()
        }
        
        // Double the last value if incomplete hex
        if !string.count.isMultiple(of: 2), let last = string.last {
            string.append(last)
        }
        
        // Fix invalid values
        if string.count > 8 {
            string = String(string.prefix(8))
        }
        
        // Scanner creation
        let scanner = Scanner(string: string)
        
        var color: UInt64 = 0
        scanner.scanHexInt64(&color)
        
        if string.count == 2 {
            let mask = 0xFF
            
            let g = Int(color) & mask
            
            let gray = CGFloat(g) / 255.0
            
            self.init(red: gray, green: gray, blue: gray, alpha: 1)
            
        } else if string.count == 4 {
            let mask = 0x00FF
            
            let g = Int(color >> 8) & mask
            let a = Int(color) & mask
            
            let gray = CGFloat(g) / 255.0
            let alpha = CGFloat(a) / 255.0
            
            self.init(red: gray, green: gray, blue: gray, alpha: alpha)
            
        } else if string.count == 6 {
            let mask = 0x0000FF
            let r = Int(color >> 16) & mask
            let g = Int(color >> 8) & mask
            let b = Int(color) & mask
            
            let red = CGFloat(r) / 255.0
            let green = CGFloat(g) / 255.0
            let blue = CGFloat(b) / 255.0
            
            self.init(red: red, green: green, blue: blue, alpha: 1)
            
        } else if string.count == 8 {
            let mask = 0x000000FF
            let r = Int(color >> 24) & mask
            let g = Int(color >> 16) & mask
            let b = Int(color >> 8) & mask
            let a = Int(color) & mask
            
            let red = CGFloat(r) / 255.0
            let green = CGFloat(g) / 255.0
            let blue = CGFloat(b) / 255.0
            let alpha = CGFloat(a) / 255.0
            
            self.init(red: red, green: green, blue: blue, alpha: alpha)
            
        } else {
            self.init(red: 1, green: 1, blue: 1, alpha: 1)
        }
    }
}

extension UIImage {
    var averageColor: Color? {
        guard let inputImage = CIImage(image: self) else { return nil }
        let extentVector = CIVector(x: inputImage.extent.origin.x, y: inputImage.extent.origin.y, z: inputImage.extent.size.width, w: inputImage.extent.size.height)
        
        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }
        
        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull as Any])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)
        
        return Color(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255, opacity: 1)
    }
    
    func thumbnail(size: CGFloat) -> UIImage? {
        var thumbnail: UIImage?
        guard let imageData = self.pngData() else {
            return nil
        }
        let options = [
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceThumbnailMaxPixelSize: size] as [CFString : Any] as CFDictionary
        
        imageData.withUnsafeBytes { ptr in
            if let bytes = ptr.baseAddress?.assumingMemoryBound(to: UInt8.self),
               let cfData = CFDataCreate(kCFAllocatorDefault, bytes, imageData.count),
               let source = CGImageSourceCreateWithData(cfData, nil),
               let imageReference = CGImageSourceCreateThumbnailAtIndex(source, 0, options) {
                thumbnail = UIImage(cgImage: imageReference)
            }
        }
        
        return thumbnail
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
    func linearGradient()->some View{
        LinearGradient(gradient: Gradient(colors: [Color(hex: "8D60D1"), Color(hex: "E177E4")]), startPoint: .leading, endPoint: .trailing)
    }
    func angularGradient()->some View{
        AngularGradient(gradient: Gradient(colors: [.red, .purple, .blue, .green, .yellow, .red]), center: .center)
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension Bundle {
    public var icon: UIImage? {
        if let icons = infoDictionary?["CFBundleIcons"] as? [String: Any],
           let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
           let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
           let lastIcon = iconFiles.last {
            return UIImage(named: lastIcon)
        }
        return nil
    }
}

//extension UINavigationController: UIGestureRecognizerDelegate {
//    override open func viewDidLoad() {
//        super.viewDidLoad()
//        interactivePopGestureRecognizer?.delegate = self
//    }
//
//    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//        return viewControllers.count > 1
//    }
//}

extension FileManager {
    static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    static func change(fileName: String, destination: URL = FileManager.getDocumentsDirectory()) -> String{
        let documentsDirectory = destination
        var trimmedSoundFileURL = documentsDirectory.appendingPathComponent(fileName)
        if FileManager.default.fileExists(atPath: trimmedSoundFileURL.path) {
            let filename = trimmedSoundFileURL.lastPathComponent
            var newFileName : String!
            var counter = 0
            var toPath = trimmedSoundFileURL.path
            while FileManager.default.fileExists(atPath: toPath) {
                counter += 1
                let fileExt  = trimmedSoundFileURL.pathExtension
                var fileNameWithoSuffix : String!
                if filename.hasSuffix(fileExt) {
                    fileNameWithoSuffix = String(filename.prefix(filename.count - (fileExt.count+1)))
                }
                if fileExt == "" {
                    newFileName =  "\(filename) (\(counter))"
                } else {
                    newFileName =  "\(fileNameWithoSuffix!) (\(counter)).\(fileExt)"
                }
                let newURL = URL(fileURLWithPath:trimmedSoundFileURL.path).deletingLastPathComponent().appendingPathComponent(newFileName).path
                toPath = newURL
            }
            trimmedSoundFileURL = URL(fileURLWithPath: toPath)
            return newFileName
        }
        return fileName
    }
    
    
    static func saveImage(image: UIImage, folder: String = "FolderImages", name: String, completion: ((URL)->Void)? = nil) {
        let documentsDirectory = FileManager.getDocumentsDirectory()
        let folderURL = documentsDirectory.appendingPathComponent(folder)
        guard let data = image.jpegData(compressionQuality: 0.25) else { return }
        //Check folder or created
        if !FileManager.default.fileExists(atPath: folderURL.path) {
            do {
                try FileManager.default.createDirectory(atPath: folderURL.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription)
            }
        }
        //Checks if file exists, removes it if so.
        let fileURL = folderURL.appendingPathComponent(name+".jpg")
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(atPath: fileURL.path)
                print("Removed old image")
            } catch let removeError {
                print("couldn't remove file at path", removeError)
            }
        }
        do {
            try data.write(to: fileURL)
            completion?(fileURL)
        } catch let error {
            print("error saving file with error", error)
        }
    }
    
    static func saveImage(id: String, image: UIImage) {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let fileName = id + ".jpg"
        let folderURL = documentsDirectory.appendingPathComponent("FolderImages")//.appendingPathComponent(fileName)
        guard let data = image.jpegData(compressionQuality: 1) else { return }
        //Check folder or created
        if !FileManager.default.fileExists(atPath: folderURL.path) {
            do {
                try FileManager.default.createDirectory(atPath: folderURL.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription)
            }
        }
        //Checks if file exists, removes it if so.
        let fileURL = folderURL.appendingPathComponent(fileName)
        if FileManager.default.fileExists(atPath: fileURL.path) {
            //            do {
            //                try FileManager.default.removeItem(atPath: fileURL.path)
            //                print("Removed old image")
            //            } catch let removeError {
            //                print("couldn't remove file at path", removeError)
            //            }
            return
        }
        do {
            try data.write(to: fileURL)
        } catch let error {
            print("error saving file with error", error)
        }
    }
    
    static func saveImage(image: UIImage, relativeURL: String = "", name: String) {
        let documentsDirectory = FileManager.getDocumentsDirectory()
        let folderURL = documentsDirectory.appendingPathComponent(relativeURL)
        guard let data = image.jpegData(compressionQuality: 0.25) else { return }
        //Check folder or created
        if !FileManager.default.fileExists(atPath: folderURL.path) {
            do {
                try FileManager.default.createDirectory(atPath: folderURL.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription)
            }
        }
        //Checks if file exists, removes it if so.
        let fileURL = folderURL.appendingPathComponent(name+".jpg")
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(atPath: fileURL.path)
                print("Removed old image")
            } catch let removeError {
                print("couldn't remove file at path", removeError)
            }
        }
        do {
            try data.write(to: fileURL)
            
        } catch let error {
            print("error saving file with error", error)
        }
    }
    
    static func removeImage(folder: String = "FolderImages", name: String) {
        let documentsDirectory = FileManager.getDocumentsDirectory()
        let folderURL = documentsDirectory.appendingPathComponent(folder)
        let fileURL = folderURL.appendingPathComponent(name+".jpg")
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(atPath: fileURL.path)
                print("Removed old image")
            } catch let removeError {
                print("couldn't remove file at path", removeError)
            }
        }
    }
    
    static func loadImageFromDiskWith(id: String, folder: String = "FolderImages") -> UIImage? {
        let document = FileManager.getDocumentsDirectory()
        let imageUrl = document.appendingPathComponent(folder).appendingPathComponent(id + ".jpg")
        if FileManager.default.fileExists(atPath: imageUrl.path){
            let image = UIImage(contentsOfFile: imageUrl.path)
            return image
        }else{
            return nil
        }
    }
}
extension URL {
    /// check if the URL is a directory and if it is reachable
    func isDirectoryAndReachable() throws -> Bool {
        guard try resourceValues(forKeys: [.isDirectoryKey]).isDirectory == true else {
            return false
        }
        return try checkResourceIsReachable()
    }
    
    /// returns total allocated size of a the directory including its subFolders or not
    func directoryTotalAllocatedSize(includingSubfolders: Bool = false) throws -> Int? {
        guard try isDirectoryAndReachable() else { return nil }
        if includingSubfolders {
            guard
                let urls = FileManager.default.enumerator(at: self, includingPropertiesForKeys: nil)?.allObjects as? [URL] else { return nil }
            return try urls.lazy.reduce(0) {
                (try $1.resourceValues(forKeys: [.totalFileAllocatedSizeKey]).totalFileAllocatedSize ?? 0) + $0
            }
        }
        return try FileManager.default.contentsOfDirectory(at: self, includingPropertiesForKeys: nil).lazy.reduce(0) {
            (try $1.resourceValues(forKeys: [.totalFileAllocatedSizeKey])
                .totalFileAllocatedSize ?? 0) + $0
        }
    }
    
    /// returns the directory total size on disk
    func sizeOnDisk() throws -> String? {
        guard let size = try directoryTotalAllocatedSize(includingSubfolders: true) else { return nil }
        URL.byteCountFormatter.countStyle = .file
        guard let byteCount = URL.byteCountFormatter.string(for: size) else { return nil}
        return byteCount
    }
    
    
    static let byteCountFormatter = ByteCountFormatter()
}

extension URL {
    var isDirectory: Bool {
        (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
    }
    func subDirectories() throws -> [URL] {
        // @available(macOS 10.11, iOS 9.0, *)
        guard hasDirectoryPath else { return [] }
        return try FileManager.default.contentsOfDirectory(at: self, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]).filter(\.hasDirectoryPath)
    }
}

extension UIDevice {
    func MBFormatter(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = ByteCountFormatter.Units.useMB
        formatter.countStyle = ByteCountFormatter.CountStyle.decimal
        formatter.includesUnit = false
        return formatter.string(fromByteCount: bytes) as String
    }
    //MARK: Get String Value
    var totalDiskSpaceInGB:String {
        return ByteCountFormatter.string(fromByteCount: totalDiskSpaceInBytes, countStyle: ByteCountFormatter.CountStyle.decimal)
    }
    var freeDiskSpaceInGB:String {
        return ByteCountFormatter.string(fromByteCount: freeDiskSpaceInBytes, countStyle: ByteCountFormatter.CountStyle.decimal)
    }
    var usedDiskSpaceInGB:String {
        return ByteCountFormatter.string(fromByteCount: usedDiskSpaceInBytes, countStyle: ByteCountFormatter.CountStyle.decimal)
    }
    var totalDiskSpaceInMB:String {
        return MBFormatter(totalDiskSpaceInBytes)
    }
    var freeDiskSpaceInMB:String {
        return MBFormatter(freeDiskSpaceInBytes)
    }
    var usedDiskSpaceInMB:String {
        return MBFormatter(usedDiskSpaceInBytes)
    }
    //MARK: Get raw value
    var totalDiskSpaceInBytes:Int64 {
        guard let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String),
              let space = (systemAttributes[FileAttributeKey.systemSize] as? NSNumber)?.int64Value else { return 0 }
        return space
    }
    /*
     Total available capacity in bytes for "Important" resources, including space expected to be cleared by purging non-essential and cached resources. "Important" means something that the user or application clearly expects to be present on the local system, but is ultimately replaceable. This would include items that the user has explicitly requested via the UI, and resources that an application requires in order to provide functionality.
     Examples: A video that the user has explicitly requested to watch but has not yet finished watching or an audio file that the user has requested to download.
     This value should not be used in determining if there is room for an irreplaceable resource. In the case of irreplaceable resources, always attempt to save the resource regardless of available capacity and handle failure as gracefully as possible.
     */
    var freeDiskSpaceInBytes:Int64 {
        if #available(iOS 11.0, *) {
            if let space = try? URL(fileURLWithPath: NSHomeDirectory() as String).resourceValues(forKeys: [URLResourceKey.volumeAvailableCapacityForImportantUsageKey]).volumeAvailableCapacityForImportantUsage {
                return space
            } else {
                return 0
            }
        } else {
            if let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String),
               let freeSpace = (systemAttributes[FileAttributeKey.systemFreeSize] as? NSNumber)?.int64Value {
                return freeSpace
            } else {
                return 0
            }
        }
    }
    var usedDiskSpaceInBytes:Int64 {
        return totalDiskSpaceInBytes - freeDiskSpaceInBytes
    }
}

extension Date {
    var zeroSeconds: Date? {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: self)
        return calendar.date(from: dateComponents)
    }
    func toString(format: String = "yyyy-MM-dd") -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    func dateAndTimetoString(format: String = "yyyy-MM-dd HH:mm") -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    func timeIn24HourFormat() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }
    
    func startOfMonth() -> Date {
        var components = Calendar.current.dateComponents([.year,.month], from: self)
        components.day = 1
        let firstDateOfMonth: Date = Calendar.current.date(from: components)!
        return firstDateOfMonth
    }
    
    func endOfMonth() -> Date {
        return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth())!
    }
    
    func nextDate() -> Date {
        let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: self)
        return nextDate ?? Date()
    }
    
    func previousDate() -> Date {
        let previousDate = Calendar.current.date(byAdding: .day, value: -1, to: self)
        return previousDate ?? Date()
    }
    
    func addMonths(numberOfMonths: Int) -> Date {
        let endDate = Calendar.current.date(byAdding: .month, value: numberOfMonths, to: self)
        return endDate ?? Date()
    }
    
    func removeMonths(numberOfMonths: Int) -> Date {
        let endDate = Calendar.current.date(byAdding: .month, value: -numberOfMonths, to: self)
        return endDate ?? Date()
    }
    
    func removeYears(numberOfYears: Int) -> Date {
        let endDate = Calendar.current.date(byAdding: .year, value: -numberOfYears, to: self)
        return endDate ?? Date()
    }
    
    func getHumanReadableDayString() -> String {
        let weekdays = [
            "Sunday",
            "Monday",
            "Tuesday",
            "Wednesday",
            "Thursday",
            "Friday",
            "Saturday"
        ]
        
        let calendar = Calendar.current.component(.weekday, from: self)
        return weekdays[calendar - 1]
    }
    
    func timeSinceDate(fromDate: Date) -> String {
        let earliest = self < fromDate ? self  : fromDate
        let latest = (earliest == self) ? fromDate : self
        
        let components:DateComponents = Calendar.current.dateComponents([.minute,.hour,.day,.weekOfYear,.month,.year,.second], from: earliest, to: latest)
        let year = components.year  ?? 0
        let month = components.month  ?? 0
        let week = components.weekOfYear  ?? 0
        let day = components.day ?? 0
        let hours = components.hour ?? 0
        let minutes = components.minute ?? 0
        let seconds = components.second ?? 0
        
        if year >= 2{
            return "\(year) years ago"
        }else if (year >= 1){
            return "1 year ago"
        }else if (month >= 2) {
            return "\(month) months ago"
        }else if (month >= 1) {
            return "1 month ago"
        }else  if (week >= 2) {
            return "\(week) weeks ago"
        } else if (week >= 1){
            return "1 week ago"
        } else if (day >= 2) {
            return "\(day) days ago"
        } else if (day >= 1){
            return "1 day ago"
        } else if (hours >= 2) {
            return "\(hours) hours ago"
        } else if (hours >= 1){
            return "1 hour ago"
        } else if (minutes >= 2) {
            return "\(minutes) minutes ago"
        } else if (minutes >= 1){
            return "1 minute ago"
        } else if (seconds >= 3) {
            return "\(seconds) seconds ago"
        } else {
            return "Just now"
        }
    }
    
    func sessionOnDay()->String{
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 6..<12 : return "Morning"
        case 12 : return "Noon"
        case 13..<17 : return "Afternoon"
        case 17..<22 : return "Evening"
        default: return "Night"
        }
    }
}

public struct BytesConverter {
    
    public let bytes: Int64
    
    public var kilobytes: Double {
        return Double(bytes) / 1_024
    }
    
    public var megabytes: Double {
        return kilobytes / 1_024
    }
    
    public var gigabytes: Double {
        return megabytes / 1_024
    }
    
    public init(bytes: Int64) {
        self.bytes = bytes
    }
    
    public func getReadableUnit() -> String {
        
        switch bytes {
        case 0..<1_024:
            return "\(bytes) bytes"
        case 1_024..<(1_024 * 1_024):
            return "\(String(format: "%.2f", kilobytes)) KB"
        case 1_024..<(1_024 * 1_024 * 1_024):
            return "\(String(format: "%.2f", megabytes)) MB"
        case (1_024 * 1_024 * 1_024)...Int64.max:
            return "\(String(format: "%.2f", gigabytes)) GB"
        default:
            return "\(bytes) bytes"
        }
    }
}

extension EnvironmentValues {
    var safeAreaInsets: EdgeInsets {
        self[SafeAreaInsetsKey.self]
    }
    
}

private struct SafeAreaInsetsKey: EnvironmentKey {
    static var defaultValue: EdgeInsets {
        UIApplication.shared.key?.safeAreaInsets.swiftUiInsets ?? EdgeInsets()
    }
}

extension UIEdgeInsets {
    var swiftUiInsets: EdgeInsets {
        EdgeInsets(top: top, leading: left, bottom: bottom, trailing: right)
    }
}

extension UIApplication {
    static func dismissKeyboard() {
        let keyWindow = shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .map({$0 as? UIWindowScene})
            .compactMap({$0})
            .first?.windows
            .filter({$0.isKeyWindow}).first
        keyWindow?.endEditing(true)
    }
    var key: UIWindow? {
        self.connectedScenes
            .map({$0 as? UIWindowScene})
            .compactMap({$0})
            .first?
            .windows
            .filter({$0.isKeyWindow})
            .first
    }
    func topMostViewController() -> UIViewController? {
        guard let rootController = keyWindow()?.rootViewController else {
            return nil
        }
        return topMostViewController(for: rootController)
    }
    private func keyWindow() -> UIWindow? {
        return UIApplication.shared.connectedScenes
            .filter {$0.activationState == .foregroundActive}
            .compactMap {$0 as? UIWindowScene}
            .first?.windows.filter {$0.isKeyWindow}.first
    }
    private func topMostViewController(for controller: UIViewController) -> UIViewController {
        if let presentedController = controller.presentedViewController {
            return topMostViewController(for: presentedController)
        } else if let navigationController = controller as? UINavigationController {
            guard let topController = navigationController.topViewController else {
                return navigationController
            }
            return topMostViewController(for: topController)
        } else if let tabController = controller as? UITabBarController {
            guard let topController = tabController.selectedViewController else {
                return tabController
            }
            return topMostViewController(for: topController)
        }
        return controller
    }
}
extension URL {
    var attributes: [FileAttributeKey : Any]? {
        do {
            return try FileManager.default.attributesOfItem(atPath: path)
        } catch let error as NSError {
            print("FileAttribute error: \(error)")
        }
        return nil
    }

    var fileSize: UInt64 {
        return attributes?[.size] as? UInt64 ?? UInt64(0)
    }

    var fileSizeString: String {
        return ByteCountFormatter.string(fromByteCount: Int64(fileSize), countStyle: .file)
    }

    var creationDate: Date? {
        return attributes?[.creationDate] as? Date
    }
}
//MARK: - TimeInterval - Lastupdate: 17/03/2022
extension TimeInterval {
    func convertToString() -> String{
        switch self{
        case 60..<3600:
            return self.hourMinuteSecond
        case 1..<60:
            return self.minuteSecondMS
        case 0..<1:
            return self.secondMS
        default:
            return self.hourMinuteSecond
        }
    }
    var hourMinuteSecond: String {
        String(format:"%d:%02d:%02d", hour, minute, second)
    }
    var minuteSecondMS: String {
        String(format:"%d:%02d:%03d", minute, second, millisecond)
    }
    var secondMS: String {
        String(format:"%02d:%03d", second, millisecond)
    }
    var hour: Int {
        Int((self/3600).truncatingRemainder(dividingBy: 3600))
    }
    var minute: Int {
        Int((self/60).truncatingRemainder(dividingBy: 60))
    }
    var second: Int {
        Int(truncatingRemainder(dividingBy: 60))
    }
    var millisecond: Int {
        Int((self*1000).truncatingRemainder(dividingBy: 1000))
    }
}

//27/3/2023
extension Array: RawRepresentable where Element: Codable {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode([Element].self, from: data)
        else {
            return nil
        }
        self = result
    }

    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return result
    }
}

public extension CGFloat {
    /// Map the value to a new range
    /// Return a value on [from.lowerBound,from.upperBound] to a [to.lowerBound, to.upperBound] range
    ///
    /// - Parameters:
    ///   - from source: Current range (Default: 0...1.0)
    ///   - to target: Desired range (Default: 0...1.0)
    func mapped(from source: ClosedRange<CGFloat> = 0 ... 1.0, to target: ClosedRange<CGFloat> = 0 ... 1.0) -> CGFloat {
        return ((self - source.lowerBound) / (source.upperBound - source.lowerBound)) * (target.upperBound - target.lowerBound) + target.lowerBound
    }

    /// Map the value to a new inverted range
    /// Return a value on [from.lowerBound,from.upperBound] to the inverse of a [to.lowerBound, to.upperBound] range
    ///
    /// - Parameters:
    ///   - from source: Current range (Default: 0...1.0)
    ///   - to target: Desired range (Default: 0...1.0)
    func mappedInverted(from source: ClosedRange<CGFloat> = 0 ... 1.0, to target: ClosedRange<CGFloat> = 0 ... 1.0) -> CGFloat {
        return target.upperBound - mapped(from: source, to: target) + target.lowerBound
    }

    /// Map the value to a new range at a base-10 logarithmic scaling
    /// Return a value on [from.lowerBound,from.upperBound] to a [to.lowerBound, to.upperBound] range
    ///
    /// - Parameters:
    ///   - from source: Current range (Default: 0...1.0)
    ///   - to target: Desired range (Default: 0...1.0)
    func mappedLog10(from source: ClosedRange<CGFloat> = 0 ... 1.0, to target: ClosedRange<CGFloat> = 0 ... 1.0) -> CGFloat {
        let logN = log10(self)
        let logStart1 = log10(source.lowerBound)
        let logStop1 = log10(source.upperBound)
        let result = ((logN - logStart1) / (logStop1 - logStart1)) * (target.upperBound - target.lowerBound) + target.lowerBound
        if result.isNaN {
            return 0.0
        } else {
            return ((logN - logStart1) / (logStop1 - logStart1)) * (target.upperBound - target.lowerBound) + target.lowerBound
        }
    }

    /// Map the value to a new range at a base e^log(n) scaling
    /// Return a value on [from.lowerBound,from.upperBound] to a [to.lowerBound, to.upperBound] range
    ///
    /// - Parameters:
    ///   - from source: Current range (Default: 0...1.0)
    ///   - to target: Desired range (Default: 0...1.0)
    func mappedExp(from source: ClosedRange<CGFloat> = 0 ... 1.0, to target: ClosedRange<CGFloat> = 0 ... 1.0) -> CGFloat {
        let logStart2 = log(target.lowerBound)
        let logStop2 = log(target.upperBound)
        let scale = (logStop2 - logStart2) / (source.upperBound - source.lowerBound)
        return exp(logStart2 + scale * (self - source.lowerBound))
    }
}


public extension Int {
    /// Map the value to a new range
    /// Return a value on [from.lowerBound,from.upperBound] to a [to.lowerBound, to.upperBound] range
    ///
    /// - Parameters:
    ///   - from source: Current range
    ///   - to target: Desired range (Default: 0...1.0)
    func mapped(from source: ClosedRange<Int>, to target: ClosedRange<CGFloat> = 0 ... 1.0) -> CGFloat {
        return (CGFloat(self - source.lowerBound) / CGFloat(source.upperBound - source.lowerBound)) * (target.upperBound - target.lowerBound) + target.lowerBound
    }
}
