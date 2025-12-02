enum Env {
    static func pickEnvValue<T>(production: T, develop: T) -> T {
        #if DEBUG
            return develop
        #else
            return production
        #endif
    }
}
