# SystemMetrics

#### A minimal macOS menu bar app to monitor CPU and RAM usage with Sentry integration.

SystemMetrics collects CPU and RAM usage metrics over time and sends them to [Sentry](https://sentry.io) using Sentry's metrics product.

## Features

- 📊 **CPU & RAM Monitoring** - Continuously tracks system resource usage
- 📈 **Sentry Integration** - Automatically sends metrics to Sentry for monitoring and alerting
- 🖥️ **Menu Bar App** - Lives in your menu bar, always accessible but never intrusive
- ⚙️ **Customizable** - Configure your Sentry DSN and device name in settings
- 🔒 **Privacy Focused** - Metrics collected locally before being sent to Sentry
- ⚡ **Lightweight** - Minimal resource footprint, built with SwiftUI

## Development

### Prerequisites

- macOS 14.0 or later
- Xcode 15.0 or later
- Swift 5.9 or later

### Setup

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/techprimate/SystemMetrics.git
   cd SystemMetrics
   ```

2. **Install Dependencies**:
   ```bash
   make setup
   ```
   This will install Homebrew dependencies and set up pre-commit hooks.

3. **Build the Application**:
   ```bash
   make build
   ```
   Or open the project in Xcode:
   ```bash
   open SystemMetrics.xcodeproj
   ```

### Configuration

1. **Get Your Sentry DSN**:
   - Create a project in [Sentry](https://sentry.io)
   - Copy your DSN from the project settings

2. **Configure the App**:
   - Launch SystemMetrics
   - Open Settings (⌘,)
   - Enter your Sentry DSN
   - Optionally set a custom device name

3. **Monitor Metrics**:
   - Metrics will start collecting automatically
   - View them in your Sentry dashboard under Metrics

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for development setup, guidelines, and detailed documentation.

## Get help

- 📧 **Email Support** - Direct help for any questions
- 🐛 **Report Issues** - Bug reports and feature requests on [GitHub Issues](https://github.com/techprimate/SystemMetrics/issues)
- 📖 **Documentation** - Detailed guides and technical docs

## License

This project is open source under the MIT License. See [LICENSE](LICENSE) for details.

## Acknowledgments

SystemMetrics is inspired by [iStat Menus](https://bjango.com/mac/istatmenus/), a comprehensive system monitoring tool for macOS.

---

_SystemMetrics is a personal project crafted with care by Philip Niedertscheider._
