import Flutter
import UIKit
import PrinterSDK

public class SwiftFlutterLabelPrinterPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "com.gogovan/flutter_label_printer", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterLabelPrinterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
      
        let bluetoothScanChannel = FlutterEventChannel(name: "com.gogovan/bluetoothScan", binaryMessenger: registrar.messenger())
        bluetoothScanChannel.setStreamHandler(instance)
        
        PTDispatcher.share().initBleCentral()
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        result("iOS " + UIDevice.current.systemVersion)
    }
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        PTDispatcher.share().scanBluetooth()
        PTDispatcher.share()?.whenFindAllBluetooth({ (array) in
            // TODO filter for our model of device, not arbitrary BT devices.
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
