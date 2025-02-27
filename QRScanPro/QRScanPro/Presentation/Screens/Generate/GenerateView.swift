import SwiftUI

struct GenerateView: View {
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    @State private var activeSheet: QRCodeType?
    @EnvironmentObject var historyManager: HistoryManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(QRCodeType.allCases, id: \.self) { type in
                        CategoryButton(
                            icon: type.icon,
                            title: type.title,
                            color: type.color,
                            action: {
                                activeSheet = type
                            }
                        )
                    }
                }
                .padding()
            }
            .navigationTitle("Generate")
            .sheet(item: $activeSheet) { type in
                QRCodeFormView(type: type, historyManager: historyManager)
            }
        }
    }
}

struct CategoryButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: icon)
                            .font(.system(size: 24))
                            .foregroundColor(color)
                    )
                
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
        )
    }
}

#Preview {
    GenerateView()
        .environmentObject(HistoryManager())
} 