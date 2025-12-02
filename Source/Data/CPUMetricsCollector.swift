import Darwin
import Foundation

/// CPU usage information structure
struct CPUInfo {
    let perCoreUsage: [Double]
    let averageUsage: Double

    init(perCoreUsage: [Double]) {
        self.perCoreUsage = perCoreUsage
        self.averageUsage = perCoreUsage.isEmpty ? 0.0 : perCoreUsage.reduce(0, +) / Double(perCoreUsage.count)
    }
}

/// Collects CPU usage metrics per core
class CPUMetricsCollector {
    private var previousCpuInfo: processor_info_array_t?
    private var previousCpuInfoCount: mach_msg_type_number_t = 0

    /// Initialize the collector (sets up initial state for delta calculation)
    func initialize() {
        _ = getCPUInfo()  // This will set up previousCpuInfo
    }

    /// Clean up resources
    func cleanup() {
        if let prevCpuInfo = previousCpuInfo {
            vm_deallocate(
                mach_task_self_, vm_address_t(bitPattern: prevCpuInfo),
                vm_size_t(Int(previousCpuInfoCount) * MemoryLayout<integer_t>.size))
            previousCpuInfo = nil
        }
    }

    /// Get current CPU usage information by comparing with previous measurement
    func getCPUInfo() -> CPUInfo {
        var cpuInfo: processor_info_array_t?
        var numCpuInfo: mach_msg_type_number_t = 0
        var numCpus: natural_t = 0

        let result = host_processor_info(
            mach_host_self(),
            PROCESSOR_CPU_LOAD_INFO,
            &numCpus,
            &cpuInfo,
            &numCpuInfo)

        guard result == KERN_SUCCESS, let cpuInfo = cpuInfo else {
            return CPUInfo(perCoreUsage: [])
        }

        defer {
            // Store current info as previous for next call
            if let prevCpuInfo = previousCpuInfo {
                vm_deallocate(
                    mach_task_self_, vm_address_t(bitPattern: prevCpuInfo),
                    vm_size_t(Int(previousCpuInfoCount) * MemoryLayout<integer_t>.size))
            }
            previousCpuInfo = cpuInfo
            previousCpuInfoCount = numCpuInfo
        }

        // If we don't have previous data, return zeros (will be accurate on next call)
        guard let prevCpuInfo = previousCpuInfo, previousCpuInfoCount == numCpuInfo else {
            return CPUInfo(perCoreUsage: Array(repeating: 0.0, count: Int(numCpus)))
        }

        // Use UnsafeMutableRawPointer to safely access the memory
        let prevCpuInfoRaw = UnsafeMutableRawPointer(prevCpuInfo)
        let cpuInfoRaw = UnsafeMutableRawPointer(cpuInfo)

        var perCoreUsage: [Double] = []

        for idx in 0..<Int(numCpus) {
            // Calculate offset for each processor
            let offset = idx * MemoryLayout<processor_cpu_load_info>.size

            // Bind memory to processor_cpu_load_info structure
            let prevLoad = prevCpuInfoRaw.advanced(by: offset).bindMemory(to: processor_cpu_load_info.self, capacity: 1)
                .pointee
            let load = cpuInfoRaw.advanced(by: offset).bindMemory(to: processor_cpu_load_info.self, capacity: 1).pointee

            let userDiff = UInt64(load.cpu_ticks.0) - UInt64(prevLoad.cpu_ticks.0)
            let systemDiff = UInt64(load.cpu_ticks.1) - UInt64(prevLoad.cpu_ticks.1)
            let idleDiff = UInt64(load.cpu_ticks.2) - UInt64(prevLoad.cpu_ticks.2)

            let used = userDiff + systemDiff
            let total = used + idleDiff

            let coreUsage = total > 0 ? Double(used) / Double(total) * 100.0 : 0.0
            perCoreUsage.append(coreUsage)
        }

        return CPUInfo(perCoreUsage: perCoreUsage)
    }
}
