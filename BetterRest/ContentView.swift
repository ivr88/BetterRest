import CoreML
import SwiftUI

struct ContentView: View {
    @State private var sleepAmount = 8.0
    @State private var wakeUp = defaultWakeUpTime
    @State private var coffeeAmount = 0
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    var calculateBedTime: String {
        let config = MLModelConfiguration()
        let model = try? SleepCalculator (configuration: config)
        let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
        let hour = (components.hour ?? 0) * 360
        let minute = (components.minute ?? 0) * 60
        let prediction = try? model?.prediction(wake: Int64(hour + minute), estimatedSleep: sleepAmount, coffee: Int64(coffeeAmount))
        let sleepTime = wakeUp - (prediction?.actualSleep ?? 0.0)
        return sleepTime.formatted(date: .omitted, time: .shortened)
    }
    
    static var defaultWakeUpTime: Date {
        var components = DateComponents()
        components.hour = 6
        components.minute = 15
        return Calendar.current.date(from: components) ?? .now
    }
    var body: some View {
        NavigationStack {
            Form {
                Section ("When do you want to wake up?") {
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .padding()
                        .position(CGPoint(x: 150.0, y: 40.0))
                }
                    
                Section ("Desired amount to sleep") {
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                        .padding()
                }
                
                Section("Daily coffee intake") {
                    Picker("Cups of coffee", selection: $coffeeAmount) {
                        ForEach(1..<21) {
                            Text("^[\($0) cup](inflect: true)")
                        }
                    }
                    .padding()
                }
                
                Section ("Time to go sleep") {
                    Text("\(calculateBedTime)")
                    
                }
            }
            .navigationTitle("BetterRest")
        }
    }
}

#Preview {
    ContentView()
}
