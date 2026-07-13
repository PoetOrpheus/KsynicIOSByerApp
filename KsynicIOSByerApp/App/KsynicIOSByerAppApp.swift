import SwiftUI
import UserNotifications

@main
struct KsynicIOSByerAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            SellerApp()
                .accentColor(.sellerInk)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
        return true
    }
}

struct SellerApp: View {
    @StateObject private var viewModel = SellerViewModel()
    
    var body: some View {
        Group {
            switch viewModel.serverState {
            case .checking:
                ServerCheckingScreen(message: viewModel.serverStatusMessage)
            case .unavailable:
                ServerUnavailableScreen(
                    message: viewModel.serverStatusMessage,
                    isBusy: viewModel.isBusy,
                    retry: {
                        Task { await viewModel.retryServerCheck() }
                    }
                )
            case .available:
                if viewModel.session.isLoggedIn {
                    SellerShell(viewModel: viewModel)
                } else {
                    AuthScreen(viewModel: viewModel)
                }
            }
        }
    }
}

struct ServerCheckingScreen: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text(message)
                .foregroundColor(.sellerMuted)
        }
    }
}

struct ServerUnavailableScreen: View {
    let message: String
    let isBusy: Bool
    let retry: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 64))
                .foregroundColor(.sellerOrange)
            Text(message)
                .multilineTextAlignment(.center)
                .foregroundColor(.sellerInk)
                .padding(.horizontal, 32)
            Button(action: retry) {
                if isBusy {
                    ProgressView()
                } else {
                    Text("Проверить снова")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.sellerBlack)
                        .cornerRadius(26)
                }
            }
            .disabled(isBusy)
        }
    }
}
