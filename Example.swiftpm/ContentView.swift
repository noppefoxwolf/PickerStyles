import SwiftUI
import PickerStyles

struct ContentView: View {
    private enum Category: String, CaseIterable, Hashable {
        case all = "All"
        case favorites = "Favorites"
        case recent = "Recent"
        case shared = "Shared"
        case archived = "Archived"
        
        var symbolName: String {
            switch self {
            case .all:
                return "sparkles"
            case .favorites:
                return "star.fill"
            case .recent:
                return "clock.fill"
            case .shared:
                return "person.2.fill"
            case .archived:
                return "archivebox.fill"
            }
        }
    }
    
    private enum Mode: String, CaseIterable, Hashable {
        case grid = "Grid"
        case list = "List"
        case focus = "Focus"
        case stats = "Stats"
        
        var symbolName: String {
            switch self {
            case .grid:
                return "square.grid.2x2.fill"
            case .list:
                return "list.bullet"
            case .focus:
                return "viewfinder"
            case .stats:
                return "chart.bar.fill"
            }
        }
    }
    
    private struct Item: Identifiable {
        let id = UUID()
        let title: String
        let subtitle: String
        let symbolName: String
        let category: Category
    }
    
    @State
    private var selectedCategory: Category = .all
    
    @State
    private var selectedMode: Mode = .grid

    @State
    private var exposure: Double = 0.2

    @State
    private var temperature: Double = 5200
    
    private let items: [Item] = [
        Item(title: "Morning Light", subtitle: "Lagoon", symbolName: "sunrise.fill", category: .favorites),
        Item(title: "City Loop", subtitle: "Commute", symbolName: "tram.fill", category: .recent),
        Item(title: "Studio Mix", subtitle: "Shared", symbolName: "slider.horizontal.3", category: .shared),
        Item(title: "Retro Film", subtitle: "Archive", symbolName: "camera.filters", category: .archived),
        Item(title: "Focus Zone", subtitle: "Deep work", symbolName: "circle.dotted", category: .favorites),
        Item(title: "Night Walk", subtitle: "Shared", symbolName: "moon.stars.fill", category: .shared),
        Item(title: "Scan Kit", subtitle: "Recent", symbolName: "doc.text.viewfinder", category: .recent),
        Item(title: "Portfolio", subtitle: "Archive", symbolName: "briefcase.fill", category: .archived)
    ]
    
    private var filteredItems: [Item] {
        guard selectedCategory != .all else {
            return items
        }
        return items.filter { $0.category == selectedCategory }
    }
    
    private var gridColumns: [GridItem] {
        [GridItem(.adaptive(minimum: 140), spacing: 16)]
    }
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 12) {
                Text("PickerStyles")
                    .font(.title.bold())
                Text("HorizontalScrollPicker と ToolbarPicker のサンプルです。")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            
            HorizontalScrollPicker(selection: $selectedCategory) {
                ForEach(Category.allCases, id: \.self) { category in
                    Label(category.rawValue, systemImage: category.symbolName)
                        .tag(category)
                }
            }
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Mode")
                        .font(.headline)
                    Spacer()
                    Text(selectedMode.rawValue)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 24)
                
                ScrollView {
                    LazyVGrid(columns: gridColumns, spacing: 16) {
                        ForEach(filteredItems) { item in
                            VStack(alignment: .leading, spacing: 8) {
                                Image(systemName: item.symbolName)
                                    .font(.title2)
                                    .foregroundStyle(Color.accentColor)
                                Text(item.title)
                                    .font(.headline)
                                Text(item.subtitle)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.black.opacity(0.05))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
            }
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Adjustment")
                    .font(.headline)
                    .padding(.horizontal, 24)

                VStack(spacing: 12) {
                    HStack {
                        Label("Exposure", systemImage: "sun.max.fill")
                            .font(.subheadline)
                        Spacer()
                        Text(exposure, format: .number.precision(.fractionLength(2)))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    AdjustmentSlider(
                        value: $exposure,
                        in: -1.0...1.0,
                        step: 0.05
                    )

                    HStack {
                        Label("Temperature", systemImage: "thermometer.sun.fill")
                            .font(.subheadline)
                        Spacer()
                        Text(temperature, format: .number.precision(.fractionLength(0)))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    AdjustmentSlider(
                        value: $temperature,
                        in: 3200...7200,
                        step: 50
                    )
                }
                .padding(.horizontal, 24)
            }

            Spacer(minLength: 0)
            
            ToolbarPicker(selection: $selectedMode) {
                ForEach(Mode.allCases, id: \.self) { mode in
                    Label(mode.rawValue, systemImage: mode.symbolName)
                        .tag(mode)
                }
            }
            .padding(.bottom, 12)
        }
    }
}
