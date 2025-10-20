//
//  OpenTelemetryManager.swift
//  itirafApp
//
//  Created by Emre on 20.10.2025.
//

import Foundation
import UIKit
import OpenTelemetryApi
import OpenTelemetrySdk
import ResourceExtension
import OTLPHTTPExporter

final class OpenTelemetryManager {
    static let shared = OpenTelemetryManager()
    
    private var tracerProvider: TracerProviderSdk?
    
    
    // Collector configuration
    private let collectorEndpoint = "https://otel.oguzhanduymaz.com"
    private let serviceName = "itirafApp"
    private let serviceVersion = "1.0.0"
    
    private init() {}
    
    // MARK: - Initialization
    
    func initialize() {
        setupTracing()
        print("✅ OpenTelemetry initialized successfully")
        print("📡 Target endpoint: \(collectorEndpoint)")
    }
    
    // MARK: - Tracing Setup
    
    private func setupTracing() {
        // Create OTLP HTTP exporter
        guard let tracesURL = URL(string: "\(collectorEndpoint)/v1/traces") else {
            print("❌ Invalid traces endpoint URL")
            return
        }
        
        // Try different possible class names for OTLP HTTP exporter
        let spanExporter: SpanExporter
        
        // Use NoopSpanExporter as fallback and also log spans
        spanExporter = ConsoleSpanExporter(collectorURL: tracesURL)
        
        // Create span processor
        let spanProcessor = SimpleSpanProcessor(spanExporter: spanExporter)
        
        // Create resource with service information
        let resourceAttributes: [String: AttributeValue] = [
            "service.name": .string(serviceName),
            "service.version": .string(serviceVersion),
            "deployment.environment": .string(getEnvironment()),
            "device.model": .string(getDeviceModel()),
            "os.type": .string("iOS"),
            "os.version": .string(UIDevice.current.systemVersion),
            "telemetry.sdk.name": .string("opentelemetry"),
            "telemetry.sdk.language": .string("swift"),
            "telemetry.sdk.version": .string("2.2.0")
        ]
        
        let resource = Resource(attributes: resourceAttributes)
        
        // Build tracer provider
        tracerProvider = TracerProviderBuilder()
            .add(spanProcessor: spanProcessor)
            .with(resource: resource)
            .build()
        
        OpenTelemetry.registerTracerProvider(tracerProvider: tracerProvider!)
        
        print("✅ Tracing configured")
        print("📡 Collector URL: \(tracesURL)")
        print("💡 Spans will be logged to console and sent to collector")
    }
    
    // MARK: - Helper Methods
    
    private func getEnvironment() -> String {
        #if DEBUG
        return "development"
        #else
        return "production"
        #endif
    }
    
    private func getDeviceModel() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let modelCode = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                ptr in String(validatingUTF8: ptr)
            }
        }
        return modelCode ?? "unknown"
    }
    
    // MARK: - Public API
    
    func getTracer(instrumentationName: String = "itirafApp", version: String = "1.0.0") -> Tracer {
        return OpenTelemetry.instance.tracerProvider.get(
            instrumentationName: instrumentationName,
            instrumentationVersion: version
        )
    }
    
    // MARK: - Shutdown
    
    func shutdown() {
        _ = tracerProvider?.shutdown()
        
        print("✅ OpenTelemetry shutdown complete")
    }
}

// MARK: - Console Span Exporter (logs and sends to collector)
class ConsoleSpanExporter: SpanExporter {
    private let collectorURL: URL
    private let session: URLSession
    
    init(collectorURL: URL) {
        self.collectorURL = collectorURL
        self.session = URLSession.shared
    }
    
    func export(spans: [SpanData], explicitTimeout: TimeInterval?) -> SpanExporterResultCode {
        // Log spans to console for debugging
        print("📊 Exporting \(spans.count) span(s) to \(collectorURL):")
        for span in spans {
            print("  └─ [\(span.name)] status: \(span.status)")
            
            // Send to collector via HTTP POST
            sendSpanToCollector(span)
        }
        return .success
    }
    
    private func sendSpanToCollector(_ span: SpanData) {
        var request = URLRequest(url: collectorURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Create a simple JSON representation
        let spanJSON: [String: Any] = [
            "name": span.name,
            "traceId": span.traceId.hexString,
            "spanId": span.spanId.hexString,
            "startTime": span.startTime.timeIntervalSince1970,
            "endTime": span.endTime.timeIntervalSince1970,
            "status": "\(span.status)"
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: spanJSON) {
            request.httpBody = jsonData
            
            let task = session.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("  ⚠️  Failed to send span: \(error.localizedDescription)")
                } else if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        print("  ✅ Span sent successfully")
                    } else {
                        print("  ⚠️  Collector returned status: \(httpResponse.statusCode)")
                    }
                }
            }
            task.resume()
        }
    }
    
    func flush(explicitTimeout: TimeInterval?) -> SpanExporterResultCode {
        return .success
    }
    
    func shutdown(explicitTimeout: TimeInterval?) {
        print("🔄 ConsoleSpanExporter shutdown")
    }
}
