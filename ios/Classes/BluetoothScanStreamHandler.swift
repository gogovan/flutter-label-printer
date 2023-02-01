//
//  BluetoothScanStreamHandler.swift
//  flutter_label_printer
//
//  Created by Peter Wong (Engineering) on 27/1/2023.
//
import PrinterSDK

class BluetoothScanStreamHandler: NSObject, FlutterStreamHandler {
    var foundPrinters: Array<PTPrinter> = []
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        PTDispatcher.share().scanBluetooth()
        PTDispatcher.share()?.whenFindAllBluetooth({ (array) in
            var hasError = false
            
            guard let array2 = array else {
                events(FlutterError(code: "1000", message: "Unexpected item received.", details: nil))
                hasError = true
                return
            }
            
            self.foundPrinters = array2.compactMap({ item in
                switch item {
                case let item as PTPrinter:
                    return item
                default:
                    events(FlutterError(code: "1000", message: "Unexpected item received.", details: nil))
                    hasError = true
                    return nil
                }
            })
            
            let result = array2.map({ item in
                switch item {
                case let item as PTPrinter:
                    return item.uuid
                default:
                    events(FlutterError(code: "1000", message: "Unexpected item received.", details: nil))
                    hasError = true
                    return nil
                }
            })
            
            if (!hasError) {
                events(result)
            }

        })
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        return nil
    }
}
