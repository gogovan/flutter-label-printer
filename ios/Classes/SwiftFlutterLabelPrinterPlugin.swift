import Flutter
import UIKit
import PrinterSDK

public class SwiftFlutterLabelPrinterPlugin: NSObject, FlutterPlugin {
    
    static let SHARED_PREF_PAPER_TYPE = "paper_type"
    
    let handler = BluetoothScanStreamHandler()
    var currentCommand: PTCommandCPCL? = nil
    
    var currentPaperType: PTCPCLNewPaperType? = nil
    
    var paperTypeSet = false
    var areaSizeSet = false
    
    let log = Log()
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "hk.gogovan.label_printer.flutter_label_printer", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterLabelPrinterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        let bluetoothScanChannel = FlutterEventChannel(name: "hk.gogovan.label_printer.bluetoothScan", binaryMessenger: registrar.messenger())
        
        bluetoothScanChannel.setStreamHandler(instance.handler)
        PTDispatcher.share().initBleCentral()
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if (currentPaperType == nil) {
            let def = UserDefaults()
            let value = def.integer(forKey: SwiftFlutterLabelPrinterPlugin.SHARED_PREF_PAPER_TYPE)
            currentPaperType = PTCPCLNewPaperType(rawValue: UInt(value))
        }
        
        if (call.method == "hk.gogovan.label_printer.stopSearchHMA300L") {
            PTDispatcher.share().stopScanBluetooth()
            result(true)
        } else if (call.method == "hk.gogovan.label_printer.connectHMA300L") {
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
        } else if (call.method == "hk.gogovan.label_printer.disconnectHMA300L") {
            PTDispatcher.share().disconnect()
            result(true)
        } else if (call.method == "hk.gogovan.label_printer.printTestPageHMA300L") {
            if (PTDispatcher.share().printerConnected == nil) {
                result(FlutterError(code: "1005", message: "Printer not connected.", details: Thread.callStackSymbols.joined(separator: "\n")))
            } else {
                let cmd = PTCommandCPCL()
                cmd.printSelfInspectionPage()
                PTDispatcher.share().send(cmd.cmdData as Data)
                result(true)
            }
        } else if (call.method == "hk.gogovan.label_printer.setPrintAreaSizeHMA300L") {
            if (PTDispatcher.share().printerConnected == nil) {
                result(FlutterError(code: "1005", message: "Printer not connected.", details: Thread.callStackSymbols.joined(separator: "\n")))
            } else {
                if (currentCommand == nil) {
                    currentCommand = PTCommandCPCL()
                }
                if let args = call.arguments as? [String:Any],
                   let offset = args["offset"] as? Int,
                   let horizontalRes = args["horizontalRes"] as? Int,
                   let verticalRes = args["verticalRes"] as? Int,
                   let height = args["height"] as? Int,
                   let quantity = args["quantity"] as? Int,
                   let hRes = PTCPCLLabelResolution(rawValue: UInt(horizontalRes)),
                   let vRes = PTCPCLLabelResolution(rawValue: UInt(verticalRes)),
                   let cmd = currentCommand {
                    cmd.cpclLabel(withOffset: offset, hRes: hRes, vRes: vRes, height: height, quantity: quantity)
                    
                    areaSizeSet = true
                    
                    result(true)
                } else {
                    result(FlutterError(code: "1009", message: "Unable to extract arguments", details: Thread.callStackSymbols.joined(separator: "\n")))
                }
            }
        } else if (call.method == "hk.gogovan.label_printer.addTextHMA300L") {
            if (PTDispatcher.share().printerConnected == nil) {
                result(FlutterError(code: "1005", message: "Printer not connected.", details: Thread.callStackSymbols.joined(separator: "\n")))
            } else {
                if (currentCommand == nil) {
                    currentCommand = PTCommandCPCL()
                }
                if let args = call.arguments as? [String:Any],
                   let rotateValue = args["rotate"] as? Int,
                   let fontValue = args["font"] as? Int,
                   let x = args["x"] as? Int,
                   let y = args["y"] as? Int,
                   let text = args["text"] as? String,
                   let rotate = PTCPCLStyleRotation(rawValue: UInt(rotateValue)),
                   let font = PTCPCLTextFontName(rawValue: UInt(fontValue)),
                   let cmd = currentCommand {
                    cmd.cpclText(withRotate: rotate, font: font, fontSize: PTCPCLTextFontSize.size0, x: x, y: y, text: text)
                    result(true)
                } else {
                    result(FlutterError(code: "1009", message: "Unable to extract arguments", details: Thread.callStackSymbols.joined(separator: "\n")))
                }
            }
        } else if (call.method == "hk.gogovan.label_printer.printHMA300L") {
            if (PTDispatcher.share().printerConnected == nil) {
                result(FlutterError(code: "1005", message: "Printer not connected.", details: Thread.callStackSymbols.joined(separator: "\n")))
            } else {
                if (currentCommand == nil) {
                    currentCommand = PTCommandCPCL()
                }
                if let cmd = currentCommand {
                    if (!paperTypeSet) {
                        log.w(msg: "Paper Type is not set. This may result in unexpected behavior in printing.")
                    }
                    if (!areaSizeSet) {
                        log.w(msg: "Print Area Size is not set. This may result in unexpected behavior in printing.")
                    }
                    
                    cmd.encoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding.init(CFStringEncodings.GB_18030_2000.rawValue))
                    if (currentPaperType == PTCPCLNewPaperType.paperLabel) {
                        cmd.cpclForm()
                    }
                    cmd.cpclPrint();
                    PTDispatcher.share().send(cmd.cmdData as Data)
                    
                    currentCommand = PTCommandCPCL() // After printing, throw away the old data.
                    areaSizeSet = false
                    
                    result(true)
                }
            }
        } else if (call.method == "hk.gogovan.label_printer.setPaperTypeHMA300L") {
            if (PTDispatcher.share().printerConnected == nil) {
                result(FlutterError(code: "1005", message: "Printer not connected.", details: Thread.callStackSymbols.joined(separator: "\n")))
            } else {
                if (currentCommand == nil) {
                    currentCommand = PTCommandCPCL()
                }
                if let args = call.arguments as? [String:Any],
                   let typeId = args["paperType"] as? Int,
                   let type = PTCPCLNewPaperType(rawValue: UInt(typeId)),
                   let cmd = currentCommand {
                    cmd.setPrinterPaperTypeFor4Inch(type)
                    
                    currentPaperType = type
                    let def = UserDefaults()
                    def.set(currentPaperType?.rawValue, forKey: SwiftFlutterLabelPrinterPlugin.SHARED_PREF_PAPER_TYPE)
                    paperTypeSet = true
                    
                    result(true)
                } else {
                    result(FlutterError(code: "1009", message: "Unable to extract arguments", details: Thread.callStackSymbols.joined(separator: "\n")))
                }
            }
        } else if (call.method == "hk.gogovan.label_printer.setBoldHMA300L") {
            if (PTDispatcher.share().printerConnected == nil) {
                result(FlutterError(code: "1005", message: "Printer not connected.", details: Thread.callStackSymbols.joined(separator: "\n")))
            } else {
                if (currentCommand == nil) {
                    currentCommand = PTCommandCPCL()
                }
                if let args = call.arguments as? [String:Any],
                   let sizeId = args["size"] as? Int,
                   let cmd = currentCommand {
                    let sizeCapped = max(0, min(5, sizeId))
                    let size = PTCPCLTextBold(rawValue: UInt(sizeCapped))
                    
                    if let fSize = size {
                        cmd.cpclSetBold(fSize)
                        result(true)
                    } else {
                        result(FlutterError(code: "1009", message: "Unable to extract arguments", details: Thread.callStackSymbols.joined(separator: "\n")))
                    }
                } else {
                    result(FlutterError(code: "1009", message: "Unable to extract arguments", details: Thread.callStackSymbols.joined(separator: "\n")))
                }
            }
        } else if (call.method == "hk.gogovan.label_printer.setTextSizeHMA300L") {
            if (PTDispatcher.share().printerConnected == nil) {
                result(FlutterError(code: "1005", message: "Printer not connected.", details: Thread.callStackSymbols.joined(separator: "\n")))
            } else {
                if (currentCommand == nil) {
                    currentCommand = PTCommandCPCL()
                }
                if let args = call.arguments as? [String:Any],
                   let widthId = args["width"] as? Int,
                   let heightId = args["height"] as? Int,
                   let cmd = currentCommand {
                    let widthCapped = max(1, min(16, widthId))
                    let heightCapped = max(1, min(16, heightId))
                    let width = PTCPCLFontScale(rawValue: UInt(widthCapped))
                    let height = PTCPCLFontScale(rawValue: UInt(heightCapped))
                    
                    if let fWidth = width,
                       let fHeight = height {
                        cmd.cpclSetMag(withWidth: fWidth, height: fHeight)
                        result(true)
                    } else {
                        result(FlutterError(code: "1009", message: "Unable to extract arguments", details: Thread.callStackSymbols.joined(separator: "\n")))
                    }
                } else {
                    result(FlutterError(code: "1009", message: "Unable to extract arguments", details: Thread.callStackSymbols.joined(separator: "\n")))
                }
            }
        } else if (call.method == "hk.gogovan.label_printer.getStatusHMA300L") {
            if (PTDispatcher.share().printerConnected == nil) {
                result(FlutterError(code: "1005", message: "Printer not connected.", details: Thread.callStackSymbols.joined(separator: "\n")))
            } else {
                PTDispatcher.share().whenReceiveData({ (temp) in
                    if let data = temp {
                        if data.count == 1 {
                            result(data[0])
                        }
                    } else {
                        result(FlutterError(code: "1009", message: "Unable to receive data", details: Thread.callStackSymbols.joined(separator: "\n")))
                    }
                })
                
                let cmd = PTCommandCPCL()
                cmd.cpclGetPaperStatus()
                PTDispatcher.share().send(cmd.cmdData as Data)
            }
        } else if (call.method == "hk.gogovan.label_printer.prefeedHMA300L") {
            if (PTDispatcher.share().printerConnected == nil) {
                result(FlutterError(code: "1005", message: "Printer not connected.", details: Thread.callStackSymbols.joined(separator: "\n")))
            } else {
                if (currentCommand == nil) {
                    currentCommand = PTCommandCPCL()
                }
                if let args = call.arguments as? [String:Any],
                   let dot = args["dot"] as? Int,
                   let cmd = currentCommand {
                    cmd.cpclFeed(dot)
                    result(true)
                } else {
                    result(FlutterError(code: "1009", message: "Unable to extract arguments", details: Thread.callStackSymbols.joined(separator: "\n")))
                }
            }
        } else if (call.method == "hk.gogovan.label_printer.setPageWidthHMA300L") {
            if (PTDispatcher.share().printerConnected == nil) {
                result(FlutterError(code: "1005", message: "Printer not connected.", details: Thread.callStackSymbols.joined(separator: "\n")))
            } else {
                if (currentCommand == nil) {
                    currentCommand = PTCommandCPCL()
                }
                if let args = call.arguments as? [String:Any],
                   let width = args["width"] as? Int,
                   let cmd = currentCommand {
                    cmd.cpclPageWidth(width)
                    result(true)
                } else {
                    result(FlutterError(code: "1009", message: "Unable to extract arguments", details: Thread.callStackSymbols.joined(separator: "\n")))
                }
            }
        } else if (call.method == "hk.gogovan.label_printer.setAlignHMA300L") {
            if (PTDispatcher.share().printerConnected == nil) {
                result(FlutterError(code: "1005", message: "Printer not connected.", details: Thread.callStackSymbols.joined(separator: "\n")))
            } else {
                if (currentCommand == nil) {
                    currentCommand = PTCommandCPCL()
                }
                if let args = call.arguments as? [String:Any],
                   let width = args["width"] as? Int,
                   let cmd = currentCommand {
                    cmd.cpclPageWidth(width)
                    result(true)
                } else {
                    result(FlutterError(code: "1009", message: "Unable to extract arguments", details: Thread.callStackSymbols.joined(separator: "\n")))
                }
            }
        } else if (call.method == "hk.gogovan.label_printer.setAlignHMA300L") {
            if (PTDispatcher.share().printerConnected == nil) {
                result(FlutterError(code: "1005", message: "Printer not connected.", details: Thread.callStackSymbols.joined(separator: "\n")))
            } else {
                if (currentCommand == nil) {
                    currentCommand = PTCommandCPCL()
                }
                if let args = call.arguments as? [String:Any],
                   let align = args["align"] as? Int,
                   let cmd = currentCommand {
                    if (align == 0) {
                        cmd.cpclLeft()
                        result(true)
                    } else if (align == 1) {
                        cmd.cpclCenter()
                        result(true)
                    } else if (align == 2) {
                        cmd.cpclRight()
                        result(true)
                    } else {
                        result(FlutterError(code: "1009", message: "Invalid Align argument: \(align)", details: Thread.callStackSymbols.joined(separator: "\n")))
                    }
                } else {
                    result(FlutterError(code: "1009", message: "Unable to extract arguments", details: Thread.callStackSymbols.joined(separator: "\n")))
                }
            }
        } else if (call.method == "hk.gogovan.label_printer.addBarcode") {
            if (PTDispatcher.share().printerConnected == nil) {
                result(FlutterError(code: "1005", message: "Printer not connected.", details: Thread.callStackSymbols.joined(separator: "\n")))
            } else {
                if (currentCommand == nil) {
                    currentCommand = PTCommandCPCL()
                }
                if let args = call.arguments as? [String:Any],
                   let orientation = args["orientation"] as? Int,
                   let type = args["type"] as? Int,
                   let width = args["width"] as? Int,
                   let ratio = args["ratio"] as? Int,
                   let height = args["height"] as? Int,
                   let x = args["x"] as? Int,
                   let y = args["y"] as? Int,
                   let data = args["data"] as? String,
                   let showData = args["showData"] as? Bool,
                   let dataFont = args["dataFont"] as? Int?,
                   let dataTextSize = args["dataTextSize"] as? Int?,
                   let dataTextOffset = args["dataTextOffset"] as? Int?,
                   let typeEnum = PTCPCLBarcodeStyle(rawValue: UInt(type)),
                   let ratioEnum = PTCPCLBarcodeBarRatio(rawValue: UInt(ratio)),
                   let cmd = currentCommand {
                    guard (!(showData && (dataFont == nil || dataTextSize == nil || dataTextOffset == nil))) else {
                        result(FlutterError(code: "1009", message: "showData requested but required params are not provided", details: Thread.callStackSymbols.joined(separator: "\n")))
                        return
                    }
                    if let dataFontN = dataFont,
                       let dataTextSizeN = dataTextSize,
                       let dataTextOffsetN = dataTextOffset,
                       let dataFontEnum = PTCPCLTextFontName(rawValue: UInt(dataFontN)) {
                        if (showData) {
                            cmd.cpclBarcodeText(withFont: dataFontEnum, fontSize: dataTextSizeN, offset: dataTextOffsetN)
                        }
                        
                        if (orientation == 0) {
                            cmd.cpclBarcode(typeEnum, width: width, ratio: ratioEnum, height: height, x: x, y: y, barcode: data)
                        } else if (orientation == 1) {
                            cmd.cpclBarcodeVertical(typeEnum, width: width, ratio: ratioEnum, height: height, x: x, y: y, barcode: data)
                        } else {
                            result(FlutterError(code: "1009", message: "Invalid orientation argument: \(orientation)", details: Thread.callStackSymbols.joined(separator: "\n")))
                            return
                        }
                        
                        if (showData) {
                            cmd.cpclBarcodeTextOff()
                        }
                        
                        result(true)
                    } else {
                        result(FlutterError(code: "1009", message: "Unable to extract arguments", details: Thread.callStackSymbols.joined(separator: "\n")))
                    }
                } else {
                    result(FlutterError(code: "1009", message: "Unable to extract arguments", details: Thread.callStackSymbols.joined(separator: "\n")))
                }
            }
        } else if (call.method == "hk.gogovan.label_printer.addQRCode") {
            if (PTDispatcher.share().printerConnected == nil) {
                result(FlutterError(code: "1005", message: "Printer not connected.", details: Thread.callStackSymbols.joined(separator: "\n")))
            } else {
                if (currentCommand == nil) {
                    currentCommand = PTCommandCPCL()
                }
                
                if let args = call.arguments as? [String:Any],
                   let orientation = args["orientation"] as? Int,
                   let x = args["x"] as? Int,
                   let y = args["y"] as? Int,
                   let model = args["model"] as? Int,
                   let unitSize = args["unitSize"] as? Int,
                   let data = args["data"] as? String,
                   let modelEnum = PTCPCLQRCodeModel(rawValue: UInt(model)),
                   let unitWidthEnum = PTCPCLQRCodeUnitWidth(rawValue: UInt(unitSize)),
                   let cmd = currentCommand {
                    if (orientation == 0) {
                        cmd.cpclBarcodeQRcode(withXPos: x, yPos: y, model: modelEnum, unitWidth: unitWidthEnum)
                    } else if (orientation == 1) {
                        cmd.cpclBarcodeVerticalQRcode(withXPos: x, yPos: y, model: modelEnum, unitWidth: unitWidthEnum)
                    } else {
                        result(FlutterError(code: "1009", message: "Invalid orientation argument: \(orientation)", details: Thread.callStackSymbols.joined(separator: "\n")))
                        return
                    }
                    
                    cmd.cpclBarcodeQRCodeCorrectionLecel(PTCPCLQRCodeCorrectionLevel.M, characterMode: PTCPCLQRCodeDataInputMode.A, context: data)
                    cmd.cpclBarcodeQRcodeEnd()
                    
                    result(true)
                } else {
                    result(FlutterError(code: "1009", message: "Unable to extract arguments", details: Thread.callStackSymbols.joined(separator: "\n")))
                }
            }
        } else if (call.method == "hk.gogovan.label_printer.addRectangle") {
            if (PTDispatcher.share().printerConnected == nil) {
                result(FlutterError(code: "1005", message: "Printer not connected.", details: Thread.callStackSymbols.joined(separator: "\n")))
            } else {
                if (currentCommand == nil) {
                    currentCommand = PTCommandCPCL()
                }
                
                if let args = call.arguments as? [String:Any],
                   let x0 = args["x0"] as? Int,
                   let y0 = args["y0"] as? Int,
                   let x1 = args["x1"] as? Int,
                   let y1 = args["y1"] as? Int,
                   let width = args["width"] as? Int,
                   let cmd = currentCommand {
                    cmd.cpclBox(withXPos: x0, yPos: y0, xEnd: x1, yEnd: y1, thickness: width)
                    
                    result(true)
                } else {
                    result(FlutterError(code: "1009", message: "Unable to extract arguments", details: Thread.callStackSymbols.joined(separator: "\n")))
                }
            }
        } else if (call.method == "hk.gogovan.label_printer.addLine") {
            if (PTDispatcher.share().printerConnected == nil) {
                result(FlutterError(code: "1005", message: "Printer not connected.", details: Thread.callStackSymbols.joined(separator: "\n")))
            } else {
                if (currentCommand == nil) {
                    currentCommand = PTCommandCPCL()
                }
                
                if let args = call.arguments as? [String:Any],
                   let x0 = args["x0"] as? Int,
                   let y0 = args["y0"] as? Int,
                   let x1 = args["x1"] as? Int,
                   let y1 = args["y1"] as? Int,
                   let width = args["width"] as? Int,
                   let cmd = currentCommand {
                    cmd.cpclLine(withXPos: x0, yPos: y0, xEnd: x1, yEnd: y1, thickness: width)
                    
                    result(true)
                } else {
                    result(FlutterError(code: "1009", message: "Unable to extract arguments", details: Thread.callStackSymbols.joined(separator: "\n")))
                }
            }
        } else {
            result(FlutterError(code: "1000", message: "Unknown call method received: \(call.method)", details: Thread.callStackSymbols.joined(separator: "\n")))
        }
    }

}
