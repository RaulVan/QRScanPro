import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var selectedTab = 1
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HistoryView()
                .tabItem {
                    Image(systemName: "clock.fill")
                    Text("History")
                }
                .tag(0)
            
            ScannerView()
                .tabItem {
//                    ZStack {
//                        Circle()
//                            .fill(Color.yellow)
//                            .frame(width: 60, height: 60)
//                        Image(systemName: "qrcode.viewfinder")
//                            .font(.system(size: 30))
//                            .foregroundColor(.black)
//                    }
//                    Text("Scan")
                }
                .tag(1)
            
            GenerateView()
                .tabItem {
                    Image(systemName: "qrcode")
                    Text("Generate")
                }
                .tag(2)
        }
        .tint(.purple)
        .overlay(
            // Custom scan button overlay
            VStack {
                Spacer()
                ZStack {
                    Circle()
                        .fill(Color.yellow)
                        .frame(width: 60, height: 60)
                        .shadow(radius: 4)
                    
                    Image(systemName: "qrcode.viewfinder")
                        .font(.system(size: 30))
                        .foregroundColor(.black)
                   
                    
                }
                .offset(y: 0) // 调整按钮位置，使其部分覆盖在 TabBar 上
                .onTapGesture {
                    selectedTab = 1
                }
                Text("Scan")
                .font(.system(size: 12))
                .foregroundColor(selectedTab == 1 ? .yellow : .gray)
            }
        )
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppViewModel())
} 
