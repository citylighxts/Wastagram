import SwiftUI

/// Demo view untuk menunjukkan fitur Batch Suggestion
struct BatchSuggestionDemoView: View {
    @StateObject private var viewModel = BatchSuggestionViewModel()
    
    var body: some View {
        ZStack {
            VStack {
                // Header
                VStack(spacing: 8) {
                    Text("Demo Batch Suggestion")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.darkGreen)
                    
                    Text("Simulasi sistem rekomendasi rute efisien")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.top, 20)
                .padding(.bottom, 10)
                
                // Info status
                VStack(alignment: .leading, spacing: 12) {
                    InfoRow(
                        icon: "shippingbox.fill",
                        title: "Order Tersedia",
                        value: "\(viewModel.availableOrders.count)",
                        color: .blue
                    )
                    
                    InfoRow(
                        icon: "checkmark.circle.fill",
                        title: "Order Diterima",
                        value: "\(viewModel.acceptedOrders.count)",
                        color: .green
                    )
                }
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(15)
                .padding(.horizontal)
                
                // List order tersedia
                ScrollView {
                    VStack(spacing: 12) {
                        Text("Order Tersedia:")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .padding(.top)
                        
                        ForEach(viewModel.availableOrders) { order in
                            OrderCard(order: order) {
                                viewModel.simulateDriverPickupOrder(orderId: order.id)
                            }
                        }
                        
                        if viewModel.acceptedOrders.isEmpty == false {
                            Text("Order Diterima:")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                                .padding(.top)
                            
                            ForEach(viewModel.acceptedOrders) { order in
                                AcceptedOrderCard(order: order)
                            }
                        }
                    }
                }
                
                Spacer()
            }
            
            // Batch Suggestion Card overlay
            if viewModel.showBatchSuggestion, let suggestion = viewModel.currentBatchSuggestion {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        // Prevent dismiss on background tap
                    }
                
                VStack {
                    Spacer()
                    
                    BatchSuggestionCard(
                        suggestion: suggestion,
                        onAccept: {
                            withAnimation {
                                viewModel.acceptBatchSuggestion()
                            }
                        },
                        onDecline: {
                            withAnimation {
                                viewModel.declineBatchSuggestion()
                            }
                        }
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    
                    Spacer()
                        .frame(height: 50)
                }
            }
        }
        .animation(.spring(), value: viewModel.showBatchSuggestion)
    }
}

// MARK: - Supporting Views

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 30)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Spacer()
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.darkGreen)
        }
    }
}

struct OrderCard: View {
    let order: Order
    let onPickup: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(order.customerName)
                        .font(.headline)
                        .foregroundColor(.darkGreen)
                    
                    Text(order.address)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(String(format: "%.1f", order.weight)) kg")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.brandGreen)
                    
                    Text(order.id)
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
            
            Button(action: onPickup) {
                HStack {
                    Image(systemName: "car.fill")
                    Text("Ambil Order")
                }
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Color.brandGreen)
                .cornerRadius(10)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}

struct AcceptedOrderCard: View {
    let order: Order
    
    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .font(.title3)
                .foregroundColor(.green)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(order.customerName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.darkGreen)
                
                Text(order.address)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Text("\(String(format: "%.1f", order.weight)) kg")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.green)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.green.opacity(0.1))
                .cornerRadius(8)
        }
        .padding()
        .background(Color.green.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.green.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal)
    }
}

struct BatchSuggestionDemoView_Previews: PreviewProvider {
    static var previews: some View {
        BatchSuggestionDemoView()
    }
}
