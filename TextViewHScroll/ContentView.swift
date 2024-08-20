//
//  ContentView.swift
//  TextViewHScroll
//
//  Created by Arnaldo Rozon on 8/19/24.
//

import SwiftUI

struct ScrollOffsetPreferenceKey: PreferenceKey {
  static var defaultValue: CGFloat = 0
  
  static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
    value = nextValue()
  }
}

struct ContentView: View {
  
  private var text = "38457129056724937862347562348756234875623475623478562789657892345"
  private var color = Color(uiColor: UIColor.systemBackground)
  
  @State private var scrollViewOffset: CGFloat = 0
  @State private var scrollViewWidth: CGFloat = 0
  @State private var contentWidth: CGFloat = 0
  
  private var gradientWidth: CGFloat = 35
  
  private var isOffsetMin: Bool {
    abs(scrollViewOffset) > gradientWidth - 10
  }
  
  private var isOffsetMax: Bool {
    abs(scrollViewOffset) < (contentWidth - scrollViewWidth)
  }
  
  var alphaMaskContent: some View {
    HStack(spacing: 0) {
      LinearGradient(gradient: Gradient(colors: [color.opacity(0), color]), 
                     startPoint: .leading, endPoint: .trailing).frame(width: gradientWidth)
        .overlay {
          Color.black.opacity(isOffsetMin ? 0 : 1)
        }
      
      Rectangle()
        .fill(Color.black)
      
      LinearGradient(gradient: Gradient(colors: [color, color.opacity(0)]), 
                     startPoint: .leading, endPoint: .trailing)
      .frame(width: gradientWidth)
      .overlay {
        Color.black.opacity(isOffsetMax ? 0 : 1)
      }
    }
  }
  
  var body: some View {
    ScrollViewReader { proxy in
      ScrollView(.horizontal, showsIndicators: false) {
        VStack {
          Text(text)
            .font(.system(size: 64, weight: .regular))
            .foregroundStyle(.black)
            .padding(.horizontal)
            .background(
              GeometryReader { geo -> Color in
                DispatchQueue.main.async {
                  contentWidth = geo.size.width
                  
                  print(contentWidth)
                  print(scrollViewWidth)
                }
                
                return Color.clear
              }
            )
        }
        .background(
          GeometryReader { inner in
            Color.clear.preference(key: ScrollOffsetPreferenceKey.self,
                                   value: inner.frame(in: .global).minX)
          }
        )
        .background {
          Color.yellow
        }
        .padding(.leading)
      }
      .background(
        GeometryReader { geo -> Color in
          DispatchQueue.main.async {
            // Update scroll view width from within geo reader since this returns
            scrollViewWidth = geo.size.width
          }
          
          return Color.clear
        }
      )
      .mask(alphaMaskContent)
      .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
        withAnimation(.easeOut(duration: 0.25)) { 
          // Update the current offset
          scrollViewOffset = value
        }
      }
    }
  }
}

#Preview {
  ContentView()
}
