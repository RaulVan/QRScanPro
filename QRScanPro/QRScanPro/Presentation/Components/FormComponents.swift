import SwiftUI

struct FormField: View {
    let title: String
    @Binding var value: String
    var placeholder: String
    var isMultiline: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title).fontWeight(.medium)
            
            if isMultiline {
                TextEditor(text: $value)
                    .frame(height: 100)
                    .padding(4)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
            } else {
                TextField(placeholder, text: $value)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
        }
    }
} 