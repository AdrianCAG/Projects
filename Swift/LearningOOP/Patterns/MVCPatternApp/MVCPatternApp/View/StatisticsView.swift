//
//  StatisticsView.swift
//  MVCPatternApp
//
//  Created by Adrian on 5/8/25.
//

import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject var taskController: TaskController
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Completion rate card
                StatisticsCard(title: "Completion Rate") {
                    VStack {
                        CompletionRateRing(rate: taskController.completionRate())
                            .frame(height: 150)
                            .padding()
                        
                        HStack {
                            StatBox(
                                value: "\(taskController.taskCount(byStatus: .completed))",
                                label: "Completed",
                                color: .green
                            )
                            
                            Divider()
                                .frame(height: 40)
                            
                            StatBox(
                                value: "\(taskController.taskCount(byStatus: .pending) + taskController.taskCount(byStatus: .inProgress))",
                                label: "Pending",
                                color: .orange
                            )
                        }
                    }
                }
                
                // Tasks by status
                StatisticsCard(title: "Tasks by Status") {
                    VStack(spacing: 12) {
                        ForEach(TaskStatus.allCases) { status in
                            StatusProgressBar(
                                status: status,
                                count: taskController.taskCount(byStatus: status),
                                total: taskController.tasks.count
                            )
                        }
                    }
                }
                
                // Tasks by priority
                StatisticsCard(title: "Tasks by Priority") {
                    VStack(spacing: 12) {
                        ForEach(TaskPriority.allCases) { priority in
                            PriorityProgressBar(
                                priority: priority,
                                count: taskController.taskCount(byPriority: priority),
                                total: taskController.tasks.count
                            )
                        }
                    }
                }
                
                // Tasks by category
                StatisticsCard(title: "Tasks by Category") {
                    VStack(spacing: 12) {
                        ForEach(TaskCategory.allCases) { category in
                            CategoryProgressBar(
                                category: category,
                                count: taskController.taskCount(byCategory: category),
                                total: taskController.tasks.count
                            )
                        }
                    }
                }
                
                // Time-based statistics
                StatisticsCard(title: "Time-based Statistics") {
                    HStack {
                        StatBox(
                            value: "\(taskController.tasksDueToday().count)",
                            label: "Due Today",
                            color: .blue
                        )
                        
                        Divider()
                            .frame(height: 40)
                        
                        StatBox(
                            value: "\(taskController.tasksDueThisWeek().count)",
                            label: "Due This Week",
                            color: .purple
                        )
                        
                        Divider()
                            .frame(height: 40)
                        
                        StatBox(
                            value: "\(taskController.overdueTasks().count)",
                            label: "Overdue",
                            color: .red
                        )
                    }
                }
            }
            .padding()
        }
    }
}

// Card container for statistics
struct StatisticsCard<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(title)
                .font(.headline)
                .padding(.horizontal)
            
            content
                .padding(.horizontal)
                .padding(.bottom)
        }
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// Completion rate ring component
struct CompletionRateRing: View {
    let rate: Double
    
    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 20)
            
            // Progress ring
            Circle()
                .trim(from: 0, to: CGFloat(min(rate, 1.0)))
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [.blue, .green]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 20, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut, value: rate)
            
            // Percentage text
            VStack {
                Text("\(Int(rate * 100))%")
                    .font(.system(size: 36, weight: .bold))
                
                Text("Completed")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}

// Stat box component
struct StatBox: View {
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack {
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

// Status progress bar component
struct StatusProgressBar: View {
    let status: TaskStatus
    let count: Int
    let total: Int
    
    var body: some View {
        HStack {
            // Status label
            Text(status.rawValue)
                .font(.subheadline)
                .frame(width: 100, alignment: .leading)
            
            // Progress bar
            ZStack(alignment: .leading) {
                // Background
                Rectangle()
                    .frame(height: 10)
                    .foregroundColor(Color.gray.opacity(0.2))
                    .cornerRadius(5)
                
                // Progress
                Rectangle()
                    .frame(width: progressWidth, height: 10)
                    .foregroundColor(statusColor)
                    .cornerRadius(5)
                    .animation(.easeInOut, value: progressWidth)
            }
            
            // Count
            Text("\(count)")
                .font(.subheadline)
                .foregroundColor(.gray)
                .frame(width: 30, alignment: .trailing)
        }
    }
    
    // Calculate progress width
    private var progressWidth: CGFloat {
        if total == 0 { return 0 }
        let percentage = CGFloat(count) / CGFloat(total)
        return percentage * 200 // Assuming container width is around 200
    }
    
    // Status color
    private var statusColor: Color {
        switch status {
        case .pending:
            return .yellow
        case .inProgress:
            return .blue
        case .completed:
            return .green
        case .cancelled:
            return .gray
        }
    }
}

// Priority progress bar component
struct PriorityProgressBar: View {
    let priority: TaskPriority
    let count: Int
    let total: Int
    
    var body: some View {
        HStack {
            // Priority label
            Text(priority.rawValue)
                .font(.subheadline)
                .frame(width: 100, alignment: .leading)
            
            // Progress bar
            ZStack(alignment: .leading) {
                // Background
                Rectangle()
                    .frame(height: 10)
                    .foregroundColor(Color.gray.opacity(0.2))
                    .cornerRadius(5)
                
                // Progress
                Rectangle()
                    .frame(width: progressWidth, height: 10)
                    .foregroundColor(priorityColor)
                    .cornerRadius(5)
                    .animation(.easeInOut, value: progressWidth)
            }
            
            // Count
            Text("\(count)")
                .font(.subheadline)
                .foregroundColor(.gray)
                .frame(width: 30, alignment: .trailing)
        }
    }
    
    // Calculate progress width
    private var progressWidth: CGFloat {
        if total == 0 { return 0 }
        let percentage = CGFloat(count) / CGFloat(total)
        return percentage * 200 // Assuming container width is around 200
    }
    
    // Priority color
    private var priorityColor: Color {
        switch priority {
        case .low:
            return .green
        case .medium:
            return .blue
        case .high:
            return .orange
        case .urgent:
            return .red
        }
    }
}

// Category progress bar component
struct CategoryProgressBar: View {
    let category: TaskCategory
    let count: Int
    let total: Int
    
    var body: some View {
        HStack {
            // Category label with icon
            HStack {
                Image(systemName: category.icon)
                    .foregroundColor(.blue)
                Text(category.rawValue)
            }
            .font(.subheadline)
            .frame(width: 100, alignment: .leading)
            
            // Progress bar
            ZStack(alignment: .leading) {
                // Background
                Rectangle()
                    .frame(height: 10)
                    .foregroundColor(Color.gray.opacity(0.2))
                    .cornerRadius(5)
                
                // Progress
                Rectangle()
                    .frame(width: progressWidth, height: 10)
                    .foregroundColor(.blue)
                    .cornerRadius(5)
                    .animation(.easeInOut, value: progressWidth)
            }
            
            // Count
            Text("\(count)")
                .font(.subheadline)
                .foregroundColor(.gray)
                .frame(width: 30, alignment: .trailing)
        }
    }
    
    // Calculate progress width
    private var progressWidth: CGFloat {
        if total == 0 { return 0 }
        let percentage = CGFloat(count) / CGFloat(total)
        return percentage * 200 // Assuming container width is around 200
    }
}

struct StatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticsView()
            .environmentObject(TaskController())
    }
}
