import SwiftUI

struct LaunchScreenView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var isActive = false
    @State private var size = 0.8
    @State private var opacity = 0.5
    
    var body: some View {
        if isActive {
            if viewModel.isSubscribed {
                MainTabView()
            } else {
                SubscriptionView(showCloseButton: true)
            }
        } else {
            ZStack {
                Color.purple
                    .ignoresSafeArea()
                
                VStack {
                    Image(systemName: "qrcode.viewfinder")
                        .font(.system(size: 80))
                        .foregroundColor(.white)
                    
                    Text("QR Scan Pro")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top)
                }
                .scaleEffect(size)
                .opacity(opacity)
                .onAppear {
                    withAnimation(.easeIn(duration: 1.2)) {
                        self.size = 1.0
                        self.opacity = 1.0
                    }
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
    }
}

#Preview {
    LaunchScreenView()
        .environmentObject(AppViewModel())
} 