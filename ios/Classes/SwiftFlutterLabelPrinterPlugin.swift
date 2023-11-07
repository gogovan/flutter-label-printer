import Flutter
import UIKit
import PrinterSDK

public class SwiftFlutterLabelPrinterPlugin: NSObject, FlutterPlugin {
    
    static let SHARED_PREF_PAPER_TYPE = "paper_type"
    
    let handler = BluetoothScanStreamHandler()
    var currentCPCLCommand: PTCommandCPCL? = nil
    var currentTSPLCommand: PTCommandTSPL? = nil
    
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
        
        if (call.method == "hk.gogovan.label_printer.stopSearchBluetooth") {
            PTDispatcher.share().stopScanBluetooth()
            result(true)
        } else if (call.method == "hk.gogovan.label_printer.hanin.cpcl.connect" || call.method == "hk.gogovan.label_printer.hanin.tspl.connect") {
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
        } else if (call.method == "hk.gogovan.label_printer.hanin.cpcl.disconnect" || call.method == "hk.gogovan.label_printer.hanin.tspl.disconnect") {
            PTDispatcher.share().disconnect()
            result(true)
        } else if (call.method == "hk.gogovan.label_printer.hanin.cpcl.printTestPage") {
            if (PTDispatcher.share().printerConnected == nil) {
                result(FlutterError(code: "1005", message: "Printer not connected.", details: Thread.callStackSymbols.joined(separator: "\n")))
            } else {
                let cmd = PTCommandCPCL()
                cmd.printSelfInspectionPage()
                PTDispatcher.share().send(cmd.cmdData as Data)
                result(true)
            }
        } else if (call.method == "hk.gogovan.label_printer.hanin.tspl.printTestPage") {
            if (PTDispatcher.share().printerConnected == nil) {
                result(FlutterError(code: "1005", message: "Printer not connected.", details: Thread.callStackSymbols.joined(separator: "\n")))
            } else {
                let cmd = PTCommandTSPL()
                cmd.selfTest()
                PTDispatcher.share().send(cmd.cmdData as Data)
                result(true)
            }
        } else if (call.method == "hk.gogovan.label_printer.hanin.cpcl.setPrintAreaSize") {
            if (PTDispatcher.share().printerConnected == nil) {
                result(FlutterError(code: "1005", message: "Printer not connected.", details: Thread.callStackSymbols.joined(separator: "\n")))
            } else {
                if (currentCPCLCommand == nil) {
                    currentCPCLCommand = PTCommandCPCL()
                }
                if let args = call.arguments as? [String:Any],
                   let offset = args["offset"] as? Int,
                   let horizontalRes = args["horizontalRes"] as? Int,
                   let verticalRes = args["verticalRes"] as? Int,
                   let height = args["height"] as? Int,
                   let quantity = args["quantity"] as? Int,
                   let hRes = PTCPCLLabelResolution(rawValue: UInt(horizontalRes)),
                   let vRes = PTCPCLLabelResolution(rawValue: UInt(verticalRes)),
                   let cmd = currentCPCLCommand {
                    cmd.cpclLabel(withOffset: offset, hRes: hRes, vRes: vRes, height: height, quantity: quantity)
                    areaSizeSet = true
                    result(true)
                } else {
                    result(FlutterError(code: "1009", message: "Unable to extract arguments", details: Thread.callStackSymbols.joined(separator: "\n")))
                }
            }
        } else if (call.method == "hk.gogovan.label_printer.hanin.tspl.setPrintAreaSize") {
            if (PTDispatcher.share().printerConnected == nil) {
                result(FlutterError(code: "1005", message: "Printer not connected.", details: Thread.callStackSymbols.joined(separator: "\n")))
            } else {
                if (currentTSPLCommand == nil) {
                    currentTSPLCommand = PTCommandTSPL()
                }
                if let args = call.arguments as? [String:Any],
                   let width = args["width"] as? Int,
                   let height = args["height"] as? Int,
                   let cmd = currentTSPLCommand {
                    cmd.setPrintAreaSizeWithWidth(width, height: height)
                    areaSizeSet = true
                    result(true)
                } else {
                    result(FlutterError(code: "1009", message: "Unable to extract arguments", details: Thread.callStackSymbols.joined(separator: "\n")))
                }
            }
        } else if (call.method == "hk.gogovan.label_printer.hanin.cpcl.addText") {
            if (PTDispatcher.share().printerConnected == nil) {
                result(FlutterError(code: "1005", message: "Printer not connected.", details: Thread.callStackSymbols.joined(separator: "\n")))
            } else {
                if (currentCPCLCommand == nil) {
                    currentCPCLCommand = PTCommandCPCL()
                }
                if let args = call.arguments as? [String:Any],
                   let rotateValue = args["rotate"] as? Int,
                   let fontValue = args["font"] as? Int,
                   let x = args["x"] as? Int,
                   let y = args["y"] as? Int,
                   let text = args["text"] as? String,
                   let rotate = PTCPCLStyleRotation(rawValue: UInt(rotateValue)),
                   let font = PTCPCLTextFontName(rawValue: UInt(fontValue)),
                   let cmd = currentCPCLCommand {
                    cmd.cpclText(withRotate: rotate, font: font, fontSize: PTCPCLTextFontSize.size0, x: x, y: y, text: text)
                    result(true)
                } else {
                    result(FlutterError(code: "1009", message: "Unable to extract arguments", details: Thread.callStackSymbols.joined(separator: "\n")))
                }
            }
        } else if (call.method == "hk.gogovan.label_printer.hanin.tspl.addText") {
            if (PTDispatcher.share().printerConnected == nil) {
                result(FlutterError(code: "1005", message: "Printer not connected.", details: Thread.callStackSymbols.joined(separator: "\n")))
            } else {
                if (currentTSPLCommand == nil) {
                    currentTSPLCommand = PTCommandTSPL()
                }
                if let args = call.arguments as? [String:Any],
                   let rotateValue = args["rotate"] as? Int,
                   let fontValue = args["font"] as? Int,
                   let x = args["x"] as? Int,
                   let y = args["y"] as? Int,
                   let text = args["text"] as? String,
                   let charWidth = args["characterWidth"] as? Int,
                   let charHeight = args["characterHeight"] as? Int,
                   let rotate = PTTSCStyleRotation(rawValue: UInt(rotateValue)),
                   let font = PTTSCTextVectorFontStyle(rawValue: UInt(fontValue)),
                   let cmd = currentTSPLCommand {
                    cmd.appendTextForVector(withXpos: x, yPos: y, font: font, rotation: rotate, xMultiplication: charWidth, yMultiplication: charHeight, text: text)
                    result(true)
                } else {
                    result(FlutterError(code: "1009", message: "Unable to extract arguments", details: Thread.callStackSymbols.joined(separator: "\n")))
                }
            }
        } else if (call.method == "hk.gogovan.label_printer.hanin.cpcl.print") {
            if (PTDispatcher.share().printerConnected == nil) {
                result(FlutterError(code: "1005", message: "Printer not connected.", details: Thread.callStackSymbols.joined(separator: "\n")))
            } else {
                if (currentCPCLCommand == nil) {
                    currentCPCLCommand = PTCommandCPCL()
                }
                if let cmd = currentCPCLCommand {
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
                    
                    currentCPCLCommand = PTCommandCPCL() // After printing, throw away the old data.
                    areaSizeSet = false
                    
                    result(true)
                }
            }
        } else if (call.method == "hk.gogovan.label_printer.hanin.tspl.print") {
            if (PTDispatcher.share().printerConnected == nil) {
                result(FlutterError(code: "1005", message: "Printer not connected.", details: Thread.callStackSymbols.joined(separator: "\n")))
            } else {
                if (currentTSPLCommand == nil) {
                    currentTSPLCommand = PTCommandTSPL()
                }
                if let cmd = currentTSPLCommand {
                    let args = call.arguments as? [String:Any]
                    let count = args?["count"] as? Int ?? 1
                    
                    if (!areaSizeSet) {
                        log.w(msg: "Print Area Size is not set. This may result in unexpected behavior in printing.")
                    }
                    
                    cmd.print(withSets: 1, copies: count)
                    PTDispatcher.share().send(Data(cmd.cmdData))
                    
                    currentTSPLCommand = PTCommandTSPL()
                    areaSizeSet = false
                    
                    result(true)
                } else {
                    result(FlutterError(code: "1009", message: "Unable to extract arguments", details: Thread.callStackSymbols.joined(separator: "\n")))
                }
            }
        } else if (call.method == "hk.gogovan.label_printer.hanin.cpcl.setPaperType") {
            if (PTDispatcher.share().printerConnected == nil) {
                result(FlutterError(code: "1005", message: "Printer not connected.", details: Thread.callStackSymbols.joined(separator: "\n")))
            } else {
                if (currentCPCLCommand == nil) {
                    currentCPCLCommand = PTCommandCPCL()
                }
                if let args = call.arguments as? [String:Any],
                   let typeId = args["paperType"] as? Int,
                   let type = PTCPCLNewPaperType(rawValue: UInt(typeId)),
                   let cmd = currentCPCLCommand {
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
        } else if (call.method == "hk.gogovan.label_printer.hanin.cpcl.setBold") {
            if (PTDispatcher.share().printerConnected == nil) {
                result(FlutterError(code: "1005", message: "Printer not connected.", details: Thread.callStackSymbols.joined(separator: "\n")))
            } else {
                if (currentCPCLCommand == nil) {
                    currentCPCLCommand = PTCommandCPCL()
                }
                if let args = call.arguments as? [String:Any],
                   let sizeId = args["size"] as? Int,
                   let cmd = currentCPCLCommand {
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
        } else if (call.method == "hk.gogovan.label_printer.hanin.cpcl.setTextSize") {
            if (PTDispatcher.share().printerConnected == nil) {
                result(FlutterError(code: "1005", message: "Printer not connected.", details: Thread.callStackSymbols.joined(separator: "\n")))
            } else {
                if (currentCPCLCommand == nil) {
                    currentCPCLCommand = PTCommandCPCL()
                }
                if let args = call.arguments as? [String:Any],
                   let widthId = args["width"] as? Int,
                   let heightId = args["height"] as? Int,
                   let cmd = currentCPCLCommand {
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
        } else if (call.method == "hk.gogovan.label_printer.hanin.cpcl.getStatus") {
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
        } else if (call.method == "hk.gogovan.label_printer.hanin.tspl.getStatus") {
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
                
                let cmd = PTCommandTSPL()
                cmd.getPrinterStatus()
                PTDispatcher.share().send(cmd.cmdData as Data)
            }
        } else if (call.method == "hk.gogovan.label_printer.hanin.cpcl.space") {
            if (PTDispatcher.share().printerConnected == nil) {
                result(FlutterError(code: "1005", message: "Printer not connected.", details: Thread.callStackSymbols.joined(separator: "\n")))
            } else {
                if (currentCPCLCommand == nil) {
                    currentCPCLCommand = PTCommandCPCL()
                }
                if let args = call.arguments as? [String:Any],
                   let dot = args["dot"] as? Int,
                   let cmd = currentCPCLCommand {
                    cmd.cpclFeed(dot)
                    result(true)
                } else {
                    result(FlutterError(code: "1009", message: "Unable to extract arguments", details: Thread.callStackSymbols.joined(separator: "\n")))
                }
            }
        } else if (call.method == "hk.gogovan.label_printer.hanin.tspl.space") {
            if (PTDispatcher.share().printerConnected == nil) {
                result(FlutterError(code: "1005", message: "Printer not connected.", details: Thread.callStackSymbols.joined(separator: "\n")))
            } else {
                if (currentTSPLCommand == nil) {
                    currentTSPLCommand = PTCommandTSPL()
                }
                if let args = call.arguments as? [String:Any],
                   let mm = args["mm"] as? Int,
                   let cmd = currentTSPLCommand {
                    cmd.setFeedLength(mm)
                    result(true)
                } else {
                    result(FlutterError(code: "1009", message: "Unable to extract arguments", details: Thread.callStackSymbols.joined(separator: "\n")))
                }
            }
        } else if (call.method == "hk.gogovan.label_printer.hanin.cpcl.setPageWidth") {
            if (PTDispatcher.share().printerConnected == nil) {
                result(FlutterError(code: "1005", message: "Printer not connected.", details: Thread.callStackSymbols.joined(separator: "\n")))
            } else {
                if (currentCPCLCommand == nil) {
                    currentCPCLCommand = PTCommandCPCL()
                }
                if let args = call.arguments as? [String:Any],
                   let width = args["width"] as? Int,
                   let cmd = currentCPCLCommand {
                    cmd.cpclPageWidth(width)
                    result(true)
                } else {
                    result(FlutterError(code: "1009", message: "Unable to extract arguments", details: Thread.callStackSymbols.joined(separator: "\n")))
                }
            }
        } else if (call.method == "hk.gogovan.label_printer.hanin.cpcl.setAlign") {
            if (PTDispatcher.share().printerConnected == nil) {
                result(FlutterError(code: "1005", message: "Printer not connected.", details: Thread.callStackSymbols.joined(separator: "\n")))
            } else {
                if (currentCPCLCommand == nil) {
                    currentCPCLCommand = PTCommandCPCL()
                }
                if let args = call.arguments as? [String:Any],
                   let align = args["align"] as? Int,
                   let cmd = currentCPCLCommand {
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
        } else if (call.method == "hk.gogovan.label_printer.hanin.cpcl.addBarcode") {
            if (PTDispatcher.share().printerConnected == nil) {
                result(FlutterError(code: "1005", message: "Printer not connected.", details: Thread.callStackSymbols.joined(separator: "\n")))
            } else {
                if (currentCPCLCommand == nil) {
                    currentCPCLCommand = PTCommandCPCL()
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
                   let cmd = currentCPCLCommand {
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
        } else if (call.method == "hk.gogovan.label_printer.hanin.tspl.addBarcode") {
            if (PTDispatcher.share().printerConnected == nil) {
                result(FlutterError(code: "1005", message: "Printer not connected.", details: Thread.callStackSymbols.joined(separator: "\n")))
            } else {
                if (currentTSPLCommand == nil) {
                    currentTSPLCommand = PTCommandTSPL()
                }
                
                if let args = call.arguments as? [String:Any],
                   let x = args["x"] as? Int,
                   let y = args["y"] as? Int,
                   let type = args["type"] as? String,
                   let height = args["height"] as? Int,
                   let showData = args["showData"] as? UInt,
                   let rotate = args["rotate"] as? UInt,
                   let data = args["data"] as? String,
                   let readableN = PTTSCBarcodeReadbleStyle(rawValue: showData),
                   let rotateN = PTTSCStyleRotation(rawValue: rotate),
                   let ratioN = PTTSCBarcodeRatio(rawValue: 1),
                   let cmd = currentTSPLCommand {
                    let typeN: PTTSCBarcodeStyle?
                    switch (type) {
                    case "128": typeN = PTTSCBarcodeStyle.style128;
                        break;
                    case "128M": typeN = PTTSCBarcodeStyle.style128M;
                        break;
                    case "EAN128": typeN = PTTSCBarcodeStyle.styleEAN128;
                        break;
                    case "39": typeN = PTTSCBarcodeStyle.style39;
                        break;
                    case "93": typeN = PTTSCBarcodeStyle.style93;
                        break;
                    case "UPCA": typeN = PTTSCBarcodeStyle.styleUPCA;
                        break;
                    case "MSI": typeN = PTTSCBarcodeStyle.styleMSI;
                        break;
                    case "ITF14": typeN = PTTSCBarcodeStyle.styleITF14;
                        break;
                    case "EAN13": typeN = PTTSCBarcodeStyle.styleEAN13;
                        break;
                    default:
                        typeN = nil;
                    }
                    
                    if let typeR = typeN {
                        cmd.printBarcode(withXPos: x, yPos: y, type: typeR, height: height, readable: readableN, rotation: rotateN, ratio: ratioN, context: data)
                        result(true)
                    } else {
                        result(FlutterError(code: "1009", message: "Unsupported barcode type \(type)", details: Thread.callStackSymbols.joined(separator: "\n")))
                    }
                } else {
                    result(FlutterError(code: "1009", message: "Unable to extract arguments", details: Thread.callStackSymbols.joined(separator: "\n")))
                }
            }
        } else if (call.method == "hk.gogovan.label_printer.hanin.cpcl.addQRCode") {
            if (PTDispatcher.share().printerConnected == nil) {
                result(FlutterError(code: "1005", message: "Printer not connected.", details: Thread.callStackSymbols.joined(separator: "\n")))
            } else {
                if (currentCPCLCommand == nil) {
                    currentCPCLCommand = PTCommandCPCL()
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
                   let cmd = currentCPCLCommand {
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
        } else if (call.method == "hk.gogovan.label_printer.hanin.tspl.addQRCode") {
            if (PTDispatcher.share().printerConnected == nil) {
                result(FlutterError(code: "1005", message: "Printer not connected.", details: Thread.callStackSymbols.joined(separator: "\n")))
            } else {
                if (currentTSPLCommand == nil) {
                    currentTSPLCommand = PTCommandTSPL()
                }
                
                if let args = call.arguments as? [String:Any],
                   let x = args["x"] as? Int,
                   let y = args["y"] as? Int,
                   let eccLevel = args["eccLevel"] as? String,
                   let unitSize = args["unitSize"] as? UInt,
                   let mode = args["mode"] as? UInt8,
                   let rotate = args["rotate"] as? UInt,
                   let data = args["data"] as? String,
                   let cellWidth = PTTSCQRcodeWidth(rawValue: unitSize),
                   let rotateN = PTTSCStyleRotation(rawValue: rotate),
                   let modelN = PTTSCQRCodeModel(rawValue: 0),
                   let codeMaskN = PTTSCQRcodeMask(rawValue: 1),
                   let cmd = currentTSPLCommand {
                    let modeN = mode == 0 ? PTTSCQRCodeMode.auto : PTTSCQRCodeMode.manual
                    let eccLevelN: PTTSCQRcodeEcclevel?
                    switch (eccLevel) {
                    case "L": eccLevelN = PTTSCQRcodeEcclevel.L;
                        break;
                    case "M": eccLevelN = PTTSCQRcodeEcclevel.M;
                        break;
                    case "H": eccLevelN = PTTSCQRcodeEcclevel.H;
                        break;
                    case "Q": eccLevelN = PTTSCQRcodeEcclevel.Q;
                        break;
                    default:
                        eccLevelN = nil
                    }
                    
                    if let eccLevelR = eccLevelN {
                        cmd.printQRcode(withXPos: x, yPos: y, eccLevel: eccLevelR, cellWidth: cellWidth, mode: modeN, rotation: rotateN, model: modelN, mask: codeMaskN, context: data)
                        result(true)
                    } else {
                        result(FlutterError(code: "1009", message: "Unsupported ECCLevel type \(eccLevel)", details: Thread.callStackSymbols.joined(separator: "\n")))
                    }
                } else {
                    result(FlutterError(code: "1009", message: "Unable to extract arguments", details: Thread.callStackSymbols.joined(separator: "\n")))
                }
            }
        } else if (call.method == "hk.gogovan.label_printer.hanin.cpcl.addRectangle") {
            if (PTDispatcher.share().printerConnected == nil) {
                result(FlutterError(code: "1005", message: "Printer not connected.", details: Thread.callStackSymbols.joined(separator: "\n")))
            } else {
                if (currentCPCLCommand == nil) {
                    currentCPCLCommand = PTCommandCPCL()
                }
                
                if let args = call.arguments as? [String:Any],
                   let x0 = args["x0"] as? Int,
                   let y0 = args["y0"] as? Int,
                   let x1 = args["x1"] as? Int,
                   let y1 = args["y1"] as? Int,
                   let width = args["width"] as? Int,
                   let cmd = currentCPCLCommand {
                    cmd.cpclBox(withXPos: x0, yPos: y0, xEnd: x1, yEnd: y1, thickness: width)
                    
                    result(true)
                } else {
                    result(FlutterError(code: "1009", message: "Unable to extract arguments", details: Thread.callStackSymbols.joined(separator: "\n")))
                }
            }
        } else if (call.method == "hk.gogovan.label_printer.hanin.tspl.addRectangle") {
            if (PTDispatcher.share().printerConnected == nil) {
                result(FlutterError(code: "1005", message: "Printer not connected.", details: Thread.callStackSymbols.joined(separator: "\n")))
            } else {
                if (currentTSPLCommand == nil) {
                    currentTSPLCommand = PTCommandTSPL()
                }
                
                if let args = call.arguments as? [String:Any],
                   let x0 = args["x0"] as? Int,
                   let y0 = args["y0"] as? Int,
                   let x1 = args["x1"] as? Int,
                   let y1 = args["y1"] as? Int,
                   let width = args["width"] as? Int,
                   let cmd = currentTSPLCommand {
                    cmd.setBoxWithXStart(x0, yStart: y0, xEnd: x1, yEnd: y1, thickness: width)
                    result(true)
                } else {
                    result(FlutterError(code: "1009", message: "Unable to extract arguments", details: Thread.callStackSymbols.joined(separator: "\n")))
                }
            }
        } else if (call.method == "hk.gogovan.label_printer.hanin.cpcl.addLine") {
            if (PTDispatcher.share().printerConnected == nil) {
                result(FlutterError(code: "1005", message: "Printer not connected.", details: Thread.callStackSymbols.joined(separator: "\n")))
            } else {
                if (currentCPCLCommand == nil) {
                    currentCPCLCommand = PTCommandCPCL()
                }
                
                if let args = call.arguments as? [String:Any],
                   let x0 = args["x0"] as? Int,
                   let y0 = args["y0"] as? Int,
                   let x1 = args["x1"] as? Int,
                   let y1 = args["y1"] as? Int,
                   let width = args["width"] as? Int,
                   let cmd = currentCPCLCommand {
                    cmd.cpclLine(withXPos: x0, yPos: y0, xEnd: x1, yEnd: y1, thickness: width)
                    
                    result(true)
                } else {
                    result(FlutterError(code: "1009", message: "Unable to extract arguments", details: Thread.callStackSymbols.joined(separator: "\n")))
                }
            }
        } else if (call.method == "hk.gogovan.label_printer.hanin.tspl.addLine") {
            if (PTDispatcher.share().printerConnected == nil) {
                result(FlutterError(code: "1005", message: "Printer not connected.", details: Thread.callStackSymbols.joined(separator: "\n")))
            } else {
                if (currentTSPLCommand == nil) {
                    currentTSPLCommand = PTCommandTSPL()
                }
                
                if let args = call.arguments as? [String:Any],
                   let x0 = args["x"] as? Int,
                   let y0 = args["y"] as? Int,
                   let width = args["width"] as? Int,
                   let height = args["height"] as? Int,
                   let cmd = currentTSPLCommand {
                    cmd.drawBar(withXPos: x0, yPos: y0, width: width, height: height)
                    result(true)
                } else {
                    result(FlutterError(code: "1009", message: "Unable to extract arguments", details: Thread.callStackSymbols.joined(separator: "\n")))
                }
            }
        } else if (call.method == "hk.gogovan.label_printer.hanin.cpcl.addImage") {
            if (PTDispatcher.share().printerConnected == nil) {
                result(FlutterError(code: "1005", message: "Printer not connected.", details: Thread.callStackSymbols.joined(separator: "\n")))
            } else {
                if (currentCPCLCommand == nil) {
                    currentCPCLCommand = PTCommandCPCL()
                }
                
                if let args = call.arguments as? [String:Any],
                   let imagePath = args["imagePath"] as? String,
                   let x = args["x"] as? Int,
                   let y = args["y"] as? Int,
                   let mode = args["mode"] as? Int,
                   let modeEnum = PTBitmapMode(rawValue: mode),
                   let cmd = currentCPCLCommand {
                    let url = URL(fileURLWithPath: imagePath)
                    guard let imageData = NSData(contentsOf: url) else {
                        result(FlutterError(code: "1010", message: "Unable to load the file \(imagePath).", details: Thread.callStackSymbols.joined(separator: "\n")))
                        return
                    }
                    let image = UIImage(data: imageData as Data)
                    
                    if let loadedImage = image?.cgImage {
                        // Compress does not work and crashes the printer if compressed.
                        cmd.cpclPrintBitmap(withXPos: x, yPos: y, image: loadedImage, bitmapMode: modeEnum, compress: PTBitmapCompressMode.none, isPackage: false)
                        result(true)
                    } else {
                        result(FlutterError(code: "1010", message: "Unable to load the file \(imagePath).", details: Thread.callStackSymbols.joined(separator: "\n")))
                    }
                } else {
                    result(FlutterError(code: "1009", message: "Unable to extract arguments", details: Thread.callStackSymbols.joined(separator: "\n")))
                }
            }
        } else if (call.method == "hk.gogovan.label_printer.hanin.tspl.addImage") {
            if (PTDispatcher.share().printerConnected == nil) {
                result(FlutterError(code: "1005", message: "Printer not connected.", details: Thread.callStackSymbols.joined(separator: "\n")))
            } else {
                if (currentTSPLCommand == nil) {
                    currentTSPLCommand = PTCommandTSPL()
                }
                
                if let args = call.arguments as? [String:Any],
                   let imagePath = args["imagePath"] as? String,
                   let x = args["x"] as? Int,
                   let y = args["y"] as? Int,
                   let type = args["type"] as? Int,
                   let modeN = PTBitmapMode(rawValue: type),
                   let cmd = currentTSPLCommand {
                    let url = URL(fileURLWithPath: imagePath)
                    guard let imageData = NSData(contentsOf: url) else {
                        result(FlutterError(code: "1010", message: "Unable to load the file \(imagePath).", details: Thread.callStackSymbols.joined(separator: "\n")))
                        return
                    }
                    
                    let image = UIImage(data: imageData as Data)
                    
                    if let loadedImage = image?.cgImage {
                        // Compress does not work and crashes the printer if compressed.
                        cmd.addBitmap(withXPos: x, yPos: y, mode: PTTSCBitmapMode(rawValue: 0)!, image: loadedImage, bitmapMode: modeN, compress: PTBitmapCompressMode(rawValue: 0)!)
                        result(true)
                    } else {
                        result(FlutterError(code: "1010", message: "Unable to load the file \(imagePath).", details: Thread.callStackSymbols.joined(separator: "\n")))
                    }
                } else {
                    result(FlutterError(code: "1009", message: "Unable to extract arguments", details: Thread.callStackSymbols.joined(separator: "\n")))
                }
            }
        } else {
            result(FlutterError(code: "1000", message: "Unknown call method received: \(call.method)", details: Thread.callStackSymbols.joined(separator: "\n")))
        }
    }

}
