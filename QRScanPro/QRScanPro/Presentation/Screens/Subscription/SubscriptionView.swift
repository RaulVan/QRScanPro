import SwiftUI

struct SubscriptionView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @Environment(\.dismiss) var dismiss
    @State private var selectedPlan: SubscriptionPlan?
    @State private var showMainView = false
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
            }
            .background(Color(.systemBackground))
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Illustration
            ZStack {
                Circle()
                    .fill(Color.purple.opacity(0.2))
                    .frame(width: 200, height: 200)
                
                Image(systemName: "qrcode.viewfinder")
                    .font(.system(size: 80))
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
            )
            
            // 3个月套餐（推荐）
            SubscriptionPlanRow(
                plan: .quarterly,
                isSelected: selectedPlan == .quarterly,
                action: { selectedPlan = .quarterly }
            )
            .overlay(
                selectedPlan == nil ? 
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.purple, lineWidth: 2) : nil
            )
            
            // 1个月套餐
            SubscriptionPlanRow(
                plan: .monthly,
                isSelected: selectedPlan == .monthly,
                action: { selectedPlan = .monthly }
            )
        }
    }
    
    private var termsSection: some View {
        VStack(spacing: 8) {
            Button(action: {
                if let plan = selectedPlan {
                    viewModel.subscribe(to: plan)
                    dismiss()
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
            .disabled(selectedPlan == nil)
            
            Button(action: {
                viewModel.restorePurchases()
            }) {
                Text("Restore Purchases")
                    .font(.subheadline)
                    .foregroundColor(.purple)
            }
            .padding(.top, 8)
            
            Text("By continuing, you agree to our Terms & Conditions")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.top, 4)
        }
        .padding(.top)
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