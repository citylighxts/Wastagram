import SwiftUI

enum WasteType { case anorganic, organic }
enum CompostMethod { case returnBack, donate }
enum ScheduleType { case now, scheduled, subscribe }

struct Style {
    static let dash = StrokeStyle(lineWidth: 1, dash: [5])
}
