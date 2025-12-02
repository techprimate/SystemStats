import Darwin
import Foundation

/// Memory information structure matching Activity Monitor
struct MemoryInfo {
    let physicalMemory: Double
    let memoryUsed: Double
    let appMemory: Double
    let wiredMemory: Double
    let compressedMemory: Double
    let cachedFiles: Double
    let swapUsed: Double
}

/// Collects RAM usage metrics
class RAMMetricsCollector {
    /// Get current memory usage with all Activity Monitor categories
    func getMemoryUsage() -> MemoryInfo {
        var stats = vm_statistics64()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64>.size) / 4

        let result = withUnsafeMutablePointer(to: &stats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                host_statistics64(
                    mach_host_self(),
                    HOST_VM_INFO64,
                    $0,
                    &count)
            }
        }

        guard result == KERN_SUCCESS else {
            return MemoryInfo(
                physicalMemory: 0,
                memoryUsed: 0,
                appMemory: 0,
                wiredMemory: 0,
                compressedMemory: 0,
                cachedFiles: 0,
                swapUsed: 0
            )
        }

        // Get page size
        var pageSize: vm_size_t = 0
        host_page_size(mach_host_self(), &pageSize)

        let physicalMemory = Double(ProcessInfo.processInfo.physicalMemory)

        // Calculate memory categories (all in bytes)
        let activeMemory = Double(stats.active_count) * Double(pageSize)
        let inactiveMemory = Double(stats.inactive_count) * Double(pageSize)
        let wiredMemory = Double(stats.wire_count) * Double(pageSize)
        let compressedMemory = Double(stats.compressor_page_count) * Double(pageSize)
        let externalPageCount = Double(stats.external_page_count) * Double(pageSize)

        // Cached Files = File-backed pages (external_page_count)
        // This represents pages backed by files on disk
        let cachedFiles = externalPageCount

        // App Memory = Active + Inactive memory used by applications
        // Activity Monitor calculates this as active+inactive excluding file-backed
        // We approximate by subtracting file-backed from active+inactive, but ensure non-negative
        let appMemoryRaw = activeMemory + inactiveMemory - cachedFiles
        let appMemory = max(0, appMemoryRaw)

        // Memory Used = App Memory + Wired + Compressed
        // This matches Activity Monitor's "Memory Used" calculation
        let memoryUsed = appMemory + wiredMemory + compressedMemory

        // Get swap usage from sysctl
        let swapUsed = getSwapUsed()

        return MemoryInfo(
            physicalMemory: physicalMemory,
            memoryUsed: memoryUsed,
            appMemory: appMemory,
            wiredMemory: wiredMemory,
            compressedMemory: compressedMemory,
            cachedFiles: cachedFiles,
            swapUsed: swapUsed
        )
    }

    /// Get swap usage from sysctl
    private func getSwapUsed() -> Double {
        var swapInfo = xsw_usage()
        var size = MemoryLayout<xsw_usage>.size

        let result = sysctlbyname("vm.swapusage", &swapInfo, &size, nil, 0)

        guard result == 0 else {
            return 0.0
        }

        // xsw_usage.xsu_used is in bytes
        return Double(swapInfo.xsu_used)
    }
}
