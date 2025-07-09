import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let calculatorChannel = FlutterMethodChannel(name: "com.example.calculator/operations",
                                                   binaryMessenger: controller.binaryMessenger)
        
        calculatorChannel.setMethodCallHandler({
            [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
            guard let args = call.arguments as? [String: Any] else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Argumentos inválidos", details: nil))
                return
            }
            
            let a = args["a"] as? Double ?? 0.0
            let b = args["b"] as? Double ?? 0.0
            
            switch call.method {
            case "add":
                result(self?.add(a: a, b: b))
            case "subtract":
                result(self?.subtract(a: a, b: b))
            case "multiply":
                result(self?.multiply(a: a, b: b))
            case "divide":
                if b == 0.0 {
                    result(FlutterError(code: "DIVISION_BY_ZERO", message: "No se puede dividir por cero", details: nil))
                } else {
                    result(self?.divide(a: a, b: b))
                }
            default:
                result(FlutterMethodNotImplemented)
            }
        })
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    private func add(a: Double, b: Double) -> Double {
        return a + b
    }
    
    private func subtract(a: Double, b: Double) -> Double {
        return a - b
    }
    
    private func multiply(a: Double, b: Double) -> Double {
        return a * b
    }
    
    private func divide(a: Double, b: Double) -> Double {
        return a / b
    }
}