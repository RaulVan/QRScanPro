import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var selectedTab = 1
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                TabView(selection: $selectedTab) {
                    HistoryView()
                        .tag(0)
                    
                    ScannerView()
                        .tag(1)
                    
                    GenerateView()
                        .tag(2)
                }
                
                // 自定义底部标签栏
                HStack(spacing: 0) {
                    // History Tab
                    Button(action: { selectedTab = 0 }) {
                        VStack(spacing: 4) {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 24))
                            Text("History")
                                .font(.system(size: 12))
                        }
                        .foregroundColor(selectedTab == 0 ? .purple : .gray)
                    }
                    .frame(width: geometry.size.width / 3)
                    
                    // Scan Tab (中间占位)
                    Color.clear
                        .frame(width: geometry.size.width / 3)
                    
                    // Generate Tab
                    Button(action: { selectedTab = 2 }) {
                        VStack(spacing: 4) {
                            Image(systemName: "qrcode")
                                .font(.system(size: 24))
                            Text("Generate")
                                .font(.system(size: 12))
                        }
                        .foregroundColor(selectedTab == 2 ? .purple : .gray)
                    }
                    .frame(width: geometry.size.width / 3)
                }
                .frame(height: 49)
                .background(Color.clear)
                .overlay(
                    Rectangle()
                        .fill(Color.gray.opacity(0))
                        .frame(height: 1),
                    alignment: .top
                )
                
                // 自定义扫描按钮
                VStack(spacing: 0) {
                    ZStack {
                        Circle()
                            .fill(Color.yellow)
                            .frame(width: 60, height: 60)
                            .shadow(radius: 4)
                        
                        Image(systemName: "qrcode.viewfinder")
                            .font(.system(size: 30))
                            .foregroundColor(.black)
                    }
                    .offset(y: -20)
                    .onTapGesture {
                        selectedTab = 1
                    }
                    
                    Text("Scan")
                        .font(.system(size: 12))
                        .foregroundColor(selectedTab == 1 ? .yellow : .gray)
                        .offset(y: -10)
                }
                .padding(.bottom, 0)
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppViewModel())
} 
