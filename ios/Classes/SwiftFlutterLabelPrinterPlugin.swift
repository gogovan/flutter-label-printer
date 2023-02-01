import Flutter
import UIKit
import PrinterSDK

public class SwiftFlutterLabelPrinterPlugin: NSObject, FlutterPlugin {
    
    let handler = BluetoothScanStreamHandler()
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "com.gogovan/flutter_label_printer", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterLabelPrinterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
      
        let bluetoothScanChannel = FlutterEventChannel(name: "com.gogovan/bluetoothScan", binaryMessenger: registrar.messenger())
        
        bluetoothScanChannel.setStreamHandler(instance.handler)
        PTDispatcher.share().initBleCentral()
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if (call.method == "com.gogovan/stopSearchHMA300L") {
            PTDispatcher.share().stopScanBluetooth()
            result(true)
        } else if (call.method == "com.gogovan/connectHMA300L") {
            if let args = call.arguments as? [String:Any],
               let address = args["address"] as? String {
                let printer = handler.foundPrinters.filter { p in
                    p.uuid == address
                }.first
                
                PTDispatcher.share().connect(printer)
                PTDispatcher.share().whenConnectSuccess {
                    result(true)
                }
                PTDispatcher.share().whenConnectFailureWithErrorBlock { (error) in
                    var fError: FlutterError
                    switch error {
                    case .bleTimeout:
                        fError = FlutterError(code: "1008", message: "Connection timed out.", details: Thread.callStackSymbols.joined(separator: "\n"))
                    case .bleValidateTimeout:
                        fError = FlutterError(code: "1008", message: "Bluetooth validation timed out.", details: Thread.callStackSymbols.joined(separator: "\n"))
                    case .bleUnknownDevice:
                        fError = FlutterError(code: "1006", message: "Unknown device.", details: Thread.callStackSymbols.joined(separator: "\n"))
                    case .bleSystem:
                        fError = FlutterError(code: "1006", message: "System error.", details: Thread.callStackSymbols.joined(separator: "\n"))
                    case .bleValidateFail:
                        fError = FlutterError(code: "1006", message: "Verification failed.", details: Thread.callStackSymbols.joined(separator: "\n"))
                    case .bleDisvocerServiceTimeout:
                        fError = FlutterError(code: "1006", message: "Connection failed.", details: Thread.callStackSymbols.joined(separator: "\n"))
                    default:
                        fError = FlutterError(code: "1006", message: "Unexpected connection error.", details: Thread.callStackSymbols.joined(separator: "\n"))
                    }
                    result(fError)
                }
            } else {
                result(FlutterError(code: "1000", message: "Unable to extract arguments", details: Thread.callStackSymbols.joined(separator: "\n")))
            }
        } else if (call.method == "com.gogovan/disconnectHMA300L") {
            PTDispatcher.share().disconnect()
            result(true)
        } else {
            result(FlutterError(code: "1000", message: "Unknown call method received: \(call.method)", details: Thread.callStackSymbols.joined(separator: "\n")))
        }
    }    
   
}
