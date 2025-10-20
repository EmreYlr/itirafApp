import Foundation
import UIKit
import OpenTelemetryApi
import OpenTelemetrySdk
import ResourceExtension
import OpenTelemetryProtocolExporterHttp
import URLSessionInstrumentation
import NetworkStatus

final class OpenTelemetryManager {
    static let shared = OpenTelemetryManager()
    
    private var tracerProvider: TracerProviderSdk?
    
    // Collector configuration
    private let collectorHost = "otel.oguzhanduymaz.com"
    private let collectorPort = 4318 // OTLP HTTP port
    private let serviceName = "itirafApp"
    private let serviceVersion = "1.0.0"
    private let useTLS = false // true olursa HTTPS kullan
    
    private init() {}
    
    func initialize() {
        setupTracing()
        setupInstrumentations()
        
        print("✅ OpenTelemetry initialized successfully")
        print("📡 HTTP Collector: \(collectorHost):\(collectorPort)")
    }
    
    private func setupTracing() {
        let scheme = useTLS ? "https" : "https"
        let endpoint = "\(scheme)://\(collectorHost)/v1/traces"
        
        guard let endpointURL = URL(string: endpoint) else {
            print("❌ Invalid collector endpoint URL")
            return
        }
        
        // OTLP HTTP exporter
        let spanExporter = OtlpHttpTraceExporter(endpoint: endpointURL)
        let loggingExporter = LoggingSpanExporter(wrapping: spanExporter)
        
        let batchProcessor = BatchSpanProcessor(
            spanExporter: loggingExporter,
            scheduleDelay: 2.0,
            exportTimeout: 30.0,
            maxQueueSize: 2048,
            maxExportBatchSize: 512
        )
        
        // Resource attributes
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
        
        let builder = TracerProviderBuilder()
        
        tracerProvider = builder
            .add(spanProcessor: batchProcessor)
            .with(resource: resource)
            .build()
        
        OpenTelemetry.registerTracerProvider(tracerProvider: tracerProvider!)
        
        OpenTelemetry.registerPropagators(
            textPropagators: [W3CTraceContextPropagator()],
            baggagePropagator: W3CBaggagePropagator()
        )
        
        print("✅ Tracing configured with OTLP HTTP exporter")
        sendTestSpan()
    }
    
    private func setupInstrumentations() {
        setupURLSessionInstrumentation()
        print("✅ URLSession instrumentation enabled")
    }
    
    private func setupURLSessionInstrumentation() {
        let configuration = URLSessionInstrumentationConfiguration(
            shouldRecordPayload: { _ in false },
            shouldInstrument: { request in
                guard let url = request.url?.absoluteString else { return true }
                return !url.contains(self.collectorHost)
            },
            nameSpan: { request in
                if let url = request.url {
                    let path = url.path.isEmpty ? "/" : url.path
                    return "\(request.httpMethod ?? "GET") \(path)"
                }
                return "HTTP Request"
            },
            shouldInjectTracingHeaders: { _ in true },
            createdRequest: { request, span in
                if let url = request.url {
                    span.setAttribute(key: "http.url", value: url.absoluteString)
                    span.setAttribute(key: "http.host", value: url.host ?? "unknown")
                    span.setAttribute(key: "http.scheme", value: url.scheme ?? "https")
                }
            },
            receivedResponse: { response, dataOrFile, span in
                if let httpResponse = response as? HTTPURLResponse {
                    span.setAttribute(key: "http.status_code", value: httpResponse.statusCode)
                    span.status = httpResponse.statusCode >= 400
                        ? .error(description: "HTTP \(httpResponse.statusCode)")
                        : .ok
                    if let data = dataOrFile as? Data {
                        span.setAttribute(key: "http.response_content_length", value: data.count)
                    }
                }
            },
            receivedError: { error, _, statusCode, span in
                span.status = .error(description: error.localizedDescription)
                span.setAttribute(key: "error", value: true)
                span.setAttribute(key: "error.type", value: String(describing: type(of: error)))
                span.setAttribute(key: "error.message", value: error.localizedDescription)
                span.setAttribute(key: "http.status_code", value: statusCode)
            }
        )
        
        _ = URLSessionInstrumentation(configuration: configuration)
    }
    
    private func sendTestSpan() {
        print("🧪 Sending test span…")
        
        let tracer = getTracer(instrumentationName: "test", version: "1.0.0")
        let span = tracer.spanBuilder(spanName: "test.connection").startSpan()
        
        span.setAttribute(key: "test.type", value: "connection_verification")
        span.setAttribute(key: "collector.host", value: collectorHost)
        span.setAttribute(key: "collector.port", value: collectorPort)
        span.addEvent(name: "Connection test started")
        Thread.sleep(forTimeInterval: 0.1)
        span.addEvent(name: "Connection test completed")
        span.status = .ok
        span.end()
        
        print("✅ Test span created and ended")
        forceFlush()
    }
    
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
    
    func getTracer(instrumentationName: String = "itirafApp", version: String = "1.0.0") -> Tracer {
        return OpenTelemetry.instance.tracerProvider.get(
            instrumentationName: instrumentationName,
            instrumentationVersion: version
        )
    }
    
    func getCurrentSpan() -> Span? {
        return OpenTelemetry.instance.contextProvider.activeSpan
    }
    
    func sendManualTestSpan() {
        sendTestSpan()
    }
    
    func forceFlush() {
        print("🔄 Force flushing spans…")
        if let provider = tracerProvider {
            _ = provider.forceFlush(timeout: 5.0)
            print("✅ Flush completed")
        }
    }
    
    func printDebugInfo() {
        print("\n=== OpenTelemetry Debug Info ===")
        let scheme = useTLS ? "https" : "http"
        print("Collector: \(scheme)://\(collectorHost):\(collectorPort)")
        print("Service: \(serviceName) v\(serviceVersion)")
        print("Environment: \(getEnvironment())")
        print("Device: \(getDeviceModel())")
        print("Protocol: OTLP HTTP")
        print("Tracer Provider: \(tracerProvider != nil ? "✅" : "❌")")
        print("================================\n")
    }
    
    func shutdown() {
        print("🔄 Shutting down OpenTelemetry…")
        _ = tracerProvider?.shutdown()
        print("✅ OpenTelemetry shutdown complete")
    }
}

private class LoggingSpanExporter: SpanExporter {
    private let wrappedExporter: SpanExporter
    
    init(wrapping exporter: SpanExporter) {
        self.wrappedExporter = exporter
    }
    
    func export(spans: [SpanData], explicitTimeout: TimeInterval?) -> SpanExporterResultCode {
        print("📤 Exporting \(spans.count) span(s)…")
        for (index, span) in spans.enumerated() {
            print("   [\(index + 1)] \(span.name) - TraceID: \(span.traceId.hexString)")
        }
        let result = wrappedExporter.export(spans: spans, explicitTimeout: explicitTimeout)
        if result == .success {
            print("✅ Export SUCCESS")
        } else {
            print("❌ Export FAILED")
        }
        return result
    }
    
    func flush(explicitTimeout: TimeInterval?) -> SpanExporterResultCode {
        let result = wrappedExporter.flush(explicitTimeout: explicitTimeout)
        print(result == .success ? "✅ Flush SUCCESS" : "❌ Flush FAILED")
        return result
    }
    
    func shutdown(explicitTimeout: TimeInterval?) {
        wrappedExporter.shutdown(explicitTimeout: explicitTimeout)
    }
}

