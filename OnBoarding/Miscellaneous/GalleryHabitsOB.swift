//
//  NPhotosOB.swift
//  OnBoarding
//
//  Created by Simone De Angelis on 07/03/25.
//


import SwiftUI


enum GalleryPriority: Int, CaseIterable, Hashable {
    case bestPhotos = 0
    case freeSpace = 1
    case organizePhotos = 2
    case unk = 3
    
    // Properties for each priority
    var title: String {
        switch self {
        case .bestPhotos:
            return "Keeping only my best photos"
        case .freeSpace:
            return "Freeing up space on my phone"
        case .organizePhotos:
            return "Organizing my photos so they’re easy to find"
        case .unk:
            return ""
        }
    }
    
    var subtitle: String {
        switch self {
        case .bestPhotos:
            return "Let AI help you find your best shots!"
        case .freeSpace:
            return "Remove similar and unwanted photos."
        case .organizePhotos:
            return "Swipe to organize and create albums."
        case .unk:
            return ""
        }
    }
    
    var iconName: String {
        switch self {
        case .bestPhotos:
            return "star.fill"
        case .freeSpace:
            return "trash.fill"
        case .organizePhotos:
            return "folder.fill"
        case .unk:
            return ""
        }
    }
}
struct GalleryPriorityOptionCell: View {
    let priority: GalleryPriority
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: priority.iconName)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(priority.title)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(isSelected ? .primary : .secondary)
                
                if isSelected {
                    Text(priority.subtitle)
                        .foregroundStyle(.secondary)
                        .font(.footnote)
                }
            }
            
            Spacer()
            
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .font(.title2)
        }
        .padding(.all, 24)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? .black : .black.opacity(0.2))
            )
        .scaleOnPress {
            action()
        }
    }
}

struct GalleryHabitsOB: View {
    @State private var selectedOptions: Set<GalleryPriority> = []
    
    var body: some View {
        VStack{
            ForEach(Array(GalleryPriority.allCases.enumerated()), id: \.element.rawValue) { index, priority in
                if priority != .unk {
                    GalleryPriorityOptionCell(
                        priority: priority,
                        isSelected: selectedOptions.contains(priority)
                    ) {
                        withAnimation {
                            if selectedOptions.contains(priority) {
                                selectedOptions.remove(priority)
                            } else {
                                selectedOptions.insert(priority)
                            }
                        }
                    }
                    .delayedAppear(index: index)
                    .padding(.vertical, 6)
                }
            }
        }
        
    }
}






