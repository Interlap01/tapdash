import SwiftUI
import WidgetKit

struct TapDashEntry: TimelineEntry {
    let date: Date
}

struct TapDashProvider: TimelineProvider {
    func placeholder(in context: Context) -> TapDashEntry {
        TapDashEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (TapDashEntry) -> Void) {
        completion(TapDashEntry(date: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TapDashEntry>) -> Void) {
        completion(Timeline(entries: [TapDashEntry(date: Date())], policy: .never))
    }
}

struct TapDashWidgetView: View {
    var entry: TapDashEntry

    var body: some View {
        ZStack {
            Color.black
            Text("TapDash")
                .font(.headline)
                .foregroundColor(.white)
        }
    }
}

@main
struct TapDashWidget: Widget {
    let kind = "TapDashWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TapDashProvider()) { entry in
            TapDashWidgetView(entry: entry)
        }
        .configurationDisplayName("TapDash")
        .description("Shows the TapDash badge.")
        .supportedFamilies([.systemSmall])
    }
}
