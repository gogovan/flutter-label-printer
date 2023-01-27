//
//  BluetoothScanStreamHandler.swift
//  flutter_label_printer
//
//  Created by Peter Wong (Engineering) on 27/1/2023.
//
import PrinterSDK

class BluetoothScanStreamHandler: NSObject, FlutterStreamHandler {
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        PTDispatcher.share().scanBluetooth()
        PTDispatcher.share()?.whenFindAllBluetooth({ (array) in
            var hasError = false
            let result = array?.map({ item in
                switch item {
                case let item as PTPrinter:
                    return item.mac
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
