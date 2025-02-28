import SwiftUI

struct SubscriptionView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @Environment(\.dismiss) var dismiss
    @State private var selectedPlan: SubscriptionPlan = .quarterly  // 默认选中 3 个月套餐
    @State private var showMainView = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showError = false
    let showCloseButton: Bool
    
    var body: some View {
        if showMainView {
            MainTabView()
        } else {
            ScrollView {
                VStack(spacing: 24) {
                    // Close Button
                    if showCloseButton {
                        HStack {
                            Spacer()
                            Button(action: {
                                showMainView = true
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.bottom)
                    }
                    
                    // Header Image and Title
                    headerSection
                    
                    // Features List
                    featuresSection
                    
                    // Subscription Plans
                    plansSection
                    
                    // Terms and Conditions
                    termsSection
                }
                .padding()
                .overlay {
                    if isLoading {
                        ProgressView()
                            .scaleEffect(1.5)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.black.opacity(0.2))
                    }
                }
            }
            .background(Color(.systemBackground))
            .alert("Error", isPresented: $showError) {
                Button("OK") {
                    showError = false
                }
            } message: {
                Text(errorMessage ?? "An unknown error occurred")
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Illustration
            ZStack {
                Circle()
                    .fill(Color.purple.opacity(0.2))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "qrcode.viewfinder")
                    .font(.system(size: 50))
                    .foregroundColor(.purple)
            }
            
            Text("Go Pro")
                .font(.title)
                .fontWeight(.bold)
        }
    }
    
    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(SubscriptionPlan.defaultPlan.features, id: \.self) { feature in
                FeatureRow(text: feature)
            }
        }
        .padding(.vertical)
    }
    
    private var plansSection: some View {
        VStack(spacing: 12) {
            // 3天试用
            SubscriptionPlanRow(
                plan: .trial,
                isSelected: selectedPlan == .trial,
                action: { selectedPlan = .trial }
            ).overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(selectedPlan == .trial ? Color.purple : Color.clear, lineWidth: 2)
            )
            
            // 3个月套餐（推荐）
            SubscriptionPlanRow(
                plan: .quarterly,
                isSelected: selectedPlan == .quarterly,
                action: { selectedPlan = .quarterly }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(selectedPlan == .quarterly ? Color.purple : Color.clear, lineWidth: 2)
            )
            
            // 1个月套餐
            SubscriptionPlanRow(
                plan: .monthly,
                isSelected: selectedPlan == .monthly,
                action: { selectedPlan = .monthly }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(selectedPlan == .monthly ? Color.purple : Color.clear, lineWidth: 2)
            )
        }
    }
    
    private var termsSection: some View {
        VStack(spacing: 8) {
            Button(action: {
                Task {
                    await subscribe()
                }
            }) {
                Text("Buy")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.green)
                    )
            }
            .disabled(isLoading)
            
            Button(action: {
                Task {
                    await restorePurchases()
                }
            }) {
                Text("Restore Purchases")
                    .font(.subheadline)
                    .foregroundColor(.purple)
            }
            .disabled(isLoading)
            .padding(.top, 8)
            
            Text("By continuing, you agree to our Terms & Conditions")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.top, 4)
        }
        .padding(.top)
    }
    
    private func subscribe() async {
        isLoading = true
        do {
            try await viewModel.subscribe(to: selectedPlan)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        isLoading = false
    }
    
    private func restorePurchases() async {
        isLoading = true
        do {
            try await viewModel.restorePurchases()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        isLoading = false
    }
}

struct FeatureRow: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark")
                .foregroundColor(.green)
            
            Text(text)
                .font(.subheadline)
        }
    }
}

struct SubscriptionPlanRow: View {
    let plan: SubscriptionPlan
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .purple : .gray)
                    .font(.system(size: 20))
                
                VStack(alignment: .leading) {
                    Text(plan.title)
                        .font(.headline)
                    Text(plan.priceDescription)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: .gray.opacity(0.2), radius: 5)
            )
        }
    }
}

#Preview {
    SubscriptionView(showCloseButton: true)
        .environmentObject(AppViewModel())
}

#Preview {
    SubscriptionPlanRow(
        plan: .quarterly,
        isSelected: true,
        action: { }
    )
}

