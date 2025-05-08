//
//  CategoryListView.swift
//  MVCPatternApp
//
//  Created by Adrian on 5/8/25.
//

import SwiftUI

struct CategoryListView: View {
    @EnvironmentObject var taskController: TaskController
    
    var body: some View {
        List {
            ForEach(TaskCategory.allCases) { category in
                Button(action: {
                    taskController.selectedCategory = category
                    taskController.selectedTab = 0 // Switch to tasks tab
                }) {
                    HStack {
                        Image(systemName: category.icon)
                            .foregroundColor(Color.blue)
                            .frame(width: 30, height: 30)
                        
                        VStack(alignment: .leading) {
                            Text(category.rawValue)
                                .font(.headline)
                            
                            Text("\(taskController.taskCount(byCategory: category)) tasks")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                            .font(.caption)
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
}

//struct CategoryListView_Previews: PreviewProvider {
//    static var previews: some View {
//        CategoryListView()
//            .environmentObject(TaskController())
//    }
//}
