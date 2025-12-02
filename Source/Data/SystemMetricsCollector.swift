import Foundation
import SentrySwift

/// Orchestrates CPU and RAM metrics collection and prints them to stdout
class SystemMetricsCollector {
    private var timer: Timer?
    private let collectionInterval: TimeInterval
    private let cpuCollector = CPUMetricsCollector()
    private let ramCollector = RAMMetricsCollector()

    init(collectionInterval: TimeInterval = 5.0) {
        self.collectionInterval = collectionInterval
    }

    /// Start collecting metrics at regular intervals
    func start() {
        // Initialize CPU collector (sets up initial state for delta calculation)
        cpuCollector.initialize()

        // Collect immediately on start
        collectAndPrint()

        // Set up timer for periodic collection
        timer = Timer.scheduledTimer(withTimeInterval: collectionInterval, repeats: true) { [weak self] _ in
            self?.collectAndPrint()
        }

        // Add timer to run loop so it works in menu bar app context
        RunLoop.current.add(timer!, forMode: .common)
    }

    /// Stop collecting metrics
    func stop() {
        timer?.invalidate()
        timer = nil

        // Clean up CPU collector resources
        cpuCollector.cleanup()
    }

    /// Collect CPU and RAM metrics and print to stdout
    private func collectAndPrint() {
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let cpuInfo = cpuCollector.getCPUInfo()
        let memoryInfo = ramCollector.getMemoryUsage()

        // Build per-core CPU usage string
        var cpuUsageString = "CPU Usage (Average: \(String(format: "%.2f", cpuInfo.averageUsage))%):\n"
        for (index, usage) in cpuInfo.perCoreUsage.enumerated() {
            cpuUsageString += "            Core \(index): \(String(format: "%.2f", usage))%\n"
        }

        // Print stats to the debug console
        print(
            """
            [\(timestamp)] System Metrics:
              \(cpuUsageString)
              Memory:
                Physical Memory: \(String(format: "%.2f", memoryInfo.physicalMemory / 1024 / 1024 / 1024)) GB
                Memory Used: \(String(format: "%.2f", memoryInfo.memoryUsed / 1024 / 1024 / 1024)) GB
                  - App Memory: \(String(format: "%.2f", memoryInfo.appMemory / 1024 / 1024 / 1024)) GB
                  - Wired Memory: \(String(format: "%.2f", memoryInfo.wiredMemory / 1024 / 1024 / 1024)) GB
                  - Compressed: \(String(format: "%.2f", memoryInfo.compressedMemory / 1024 / 1024 / 1024)) GB
                Cached Files: \(String(format: "%.2f", memoryInfo.cachedFiles / 1024 / 1024 / 1024)) GB
                Swap Used: \(String(format: "%.2f", memoryInfo.swapUsed / 1024 / 1024 / 1024)) GB
            """)

        sendCPUMetricsToSentry(cpuInfo)
        sendMemoryMetricsToSentry(memoryInfo)
    }

    fileprivate func sendCPUMetricsToSentry(_ cpuInfo: CPUInfo) {
        // Send CPU metrics to Sentry
        SentrySDK.metrics.gauge(key: "system.cpu.average", value: cpuInfo.averageUsage)
        for (index, usage) in cpuInfo.perCoreUsage.enumerated() {
            SentrySDK.metrics.gauge(
                key: "system.cpu.core-\(index)", value: usage,
                attributes: [
                    "unit": "percent"
                ])
        }
    }

    fileprivate func sendMemoryMetricsToSentry(_ memoryInfo: MemoryInfo) {
        // Send memory metrics to Sentry
        SentrySDK.metrics.gauge(
            key: "system.memory.physical", value: memoryInfo.physicalMemory,
            attributes: [
                "unit": "byte"
            ])
        SentrySDK.metrics.gauge(
            key: "system.memory.used", value: memoryInfo.memoryUsed,
            attributes: [
                "unit": "byte"
            ])
        SentrySDK.metrics.gauge(
            key: "system.memory.used.app", value: memoryInfo.appMemory,
            attributes: [
                "unit": "byte"
            ])
        SentrySDK.metrics.gauge(
            key: "system.memory.used.wired", value: memoryInfo.wiredMemory,
            attributes: [
                "unit": "byte"
            ])
        SentrySDK.metrics.gauge(
            key: "system.memory.used.compressed", value: memoryInfo.compressedMemory,
            attributes: [
                "unit": "byte"
            ])
        SentrySDK.metrics.gauge(
            key: "system.memory.used.cached-files", value: memoryInfo.cachedFiles,
            attributes: [
                "unit": "byte"
            ])
        SentrySDK.metrics.gauge(
            key: "system.memory.used.swap", value: memoryInfo.swapUsed,
            attributes: [
                "unit": "byte"
            ])
    }
}
