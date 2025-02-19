import SwiftUI

struct GenerateView: View {
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    let categories: [(icon: String, title: String, color: Color)] = [
        ("envelope.fill", "Email", .pink),
        ("person.crop.circle.fill", "Contacts", .orange),
        ("phone.fill", "Phone Number", .green),
        ("globe", "Website URL", .blue),
        ("message.fill", "Message", .purple),
        ("wifi", "WiFi", .red),
        ("doc.on.clipboard", "Clipboard URL", .cyan),
        ("location.fill", "Location", .yellow)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(categories, id: \.title) { category in
                        CategoryButton(
                            icon: category.icon,
                            title: category.title,
                            color: category.color
                        )
                    }
                }
                .padding()
            }
            .navigationTitle("Generate")
        }
    }
}

struct CategoryButton: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        Button(action: {}) {
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
} 