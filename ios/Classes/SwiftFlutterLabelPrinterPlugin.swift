import Flutter
import UIKit
import PrinterSDK

public class SwiftFlutterLabelPrinterPlugin: NSObject, FlutterPlugin {
    
    let handler = BluetoothScanStreamHandler()
    var currentCommand: PTCommandCPCL? = nil
    
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
                    p.mac == address
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
        } else if (call.method == "com.gogovan/printTestPageHMA300L") {
            let cmd = PTCommandCPCL()
            cmd.printSelfInspectionPage()
            PTDispatcher.share().send(cmd.cmdData as Data)
            result(true)
        } else if (call.method == "com.gogovan/setPrintAreaSizeHMA300L") {
            if (currentCommand == nil) {
                currentCommand = PTCommandCPCL()
            }
            if let args = call.arguments as? [String:Any],
               let offset = args["offset"] as? Int,
               let horizontalRes = args["horizontalRes"] as? Int,
               let verticalRes = args["verticalRes"] as? Int,
               let height = args["height"] as? Int,
               let quantity = args["quantity"] as? Int {
                
                let hRes: PTCPCLLabelResolution
                if (horizontalRes == 100) {
                    hRes = PTCPCLLabelResolution.resolution100
                } else {
                    hRes = PTCPCLLabelResolution.resolution200
                }
                
                let vRes: PTCPCLLabelResolution
                if (verticalRes == 100) {
                    vRes = PTCPCLLabelResolution.resolution100
                } else {
                    vRes = PTCPCLLabelResolution.resolution200
                }
                
                currentCommand?.cpclLabel(withOffset: offset, hRes: hRes, vRes: vRes, height: height, quantity: quantity)
                result(true)
            } else {
                result(false)
            }
        } else {
            result(FlutterError(code: "1000", message: "Unknown call method received: \(call.method)", details: Thread.callStackSymbols.joined(separator: "\n")))
        }
    }
    
}
