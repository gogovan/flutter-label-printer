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
            guard let tArray = array as? Array<AnyObject> else {
                events(FlutterError(code: "1000", message: "Unexpected item received.", details: nil))
                return
            }
            
            let filtered = tArray.filter({ element in
                element is PTPrinter && element.mac != "Unknown"
            }).map({ element in
                element as! PTPrinter
            })
            
            self.foundPrinters = filtered
            
            let result = filtered.map({ item in
                return "\(item.mac ?? "");\(item.name ?? "")"
            })

            events(result)
        })
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        return nil
    }
}
