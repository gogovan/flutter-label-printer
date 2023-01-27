import Flutter
import UIKit
import PrinterSDK

public class SwiftFlutterLabelPrinterPlugin: NSObject, FlutterPlugin {
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "com.gogovan/flutter_label_printer", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterLabelPrinterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
      
        let bluetoothScanChannel = FlutterEventChannel(name: "com.gogovan/bluetoothScan", binaryMessenger: registrar.messenger())
        let handler = BluetoothScanStreamHandler()
        bluetoothScanChannel.setStreamHandler(handler)
        
        PTDispatcher.share().initBleCentral()
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        result("iOS " + UIDevice.current.systemVersion)
    }    
   
}
