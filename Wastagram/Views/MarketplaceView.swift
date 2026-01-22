import SwiftUI

struct MarketplaceView: View {
    @State private var searchText = ""
    @State private var selectedCategory = "All"
    
    let products: [ProductItem] = [
        ProductItem(name: "Bamboo Toothbrush", image: "toothbrush", points: 150),
        ProductItem(name: "Reusable Cup", image: "cup.and.saucer.fill", points: 450),
        ProductItem(name: "Metal Straw Set", image: "pencil.and.ruler.fill", points: 200),
        ProductItem(name: "Organic Tote Bag", image: "bag.fill", points: 350),
        ProductItem(name: "Recycled Notebook", image: "book.closed.fill", points: 300),
        ProductItem(name: "Natural Soap", image: "sun.max.fill", points: 120)
    ]
    
    let columns = [
        GridItem(.flexible(), spacing: 15),
        GridItem(.flexible(), spacing: 15)
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Marketplace")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Find sustainable swaps")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.top, 20)
                
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search eco products", text: $searchText)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(15)
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                .padding(.horizontal)
                .padding(.top, 20)
                .padding(.bottom, 15)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        Button(action: { selectedCategory = "All" }) {
                            HStack {
                                Image(systemName: "line.3.horizontal.decrease")
                                Text("All")
                            }
                            .padding(.vertical, 10)
                            .padding(.horizontal, 25)
                            .background(selectedCategory == "All" ? Color.brandGreen : Color.white)
                            .foregroundColor(selectedCategory == "All" ? .white : .black)
                            .cornerRadius(30)
                            .overlay(
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: selectedCategory == "All" ? 0 : 1)
                            )
                        }
                        
                        FilterChip(icon: "leaf", title: "Compost", selected: $selectedCategory)
                        FilterChip(icon: "tshirt", title: "Fashion", selected: $selectedCategory)
                        FilterChip(icon: "lightbulb", title: "Home", selected: $selectedCategory)
                        FilterChip(icon: "fork.knife", title: "Kitchen", selected: $selectedCategory)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("Eco Picks")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.bottom, 20)
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(products) { product in
                            ProductCard(product: product)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 100)
                }
            }
            .background(Color(.systemGray6))
            .navigationBarHidden(true)
        }
    }
}

struct FilterChip: View {
    let icon: String
    let title: String
    @Binding var selected: String
    
    var isSelected: Bool {
        selected == title
    }
    
    var body: some View {
        Button(action: { selected = title }) {
            HStack {
                Image(systemName: icon)
                Text(title)
            }
            .font(.subheadline)
            .fontWeight(.medium)
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            .background(isSelected ? Color.brandGreen : Color.white)
            .foregroundColor(isSelected ? .white : .black)
            .cornerRadius(30)
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(Color.gray.opacity(0.3), lineWidth: isSelected ? 0 : 1)
            )
        }
    }
}

struct ProductCard: View {
    let product: ProductItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                Color.gray.opacity(0.1)
                Image(systemName: product.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(20)
                    .foregroundColor(.darkGreen)
            }
            .aspectRatio(1, contentMode: .fit)
            .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.black)
                    .lineLimit(1)
                
                Text("\(product.points) pts")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "2DAD02"))
            }
            .padding(.horizontal, 5)
            .padding(.bottom, 10)
        }
        .padding(8)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct ProductItem: Identifiable {
    let id = UUID()
    let name: String
    let image: String
    let points: Int
}

struct MarketplaceView_Previews: PreviewProvider {
    static var previews: some View {
        MarketplaceView()
    }
}
