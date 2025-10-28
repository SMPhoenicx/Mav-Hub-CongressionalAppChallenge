//
//  IntroPageView.swift
//  NewMavApp
//
//  Created by Jack Vu on 8/21/24.
// Pretty colors fr

import SwiftUI

struct IntroPageView: View {
    @State private var progress1: Double = 0.0
    @State private var progress2: Double = 0.0
    @State private var scheduleIndex: Int = -1
    var body: some View {
        NavigationView { // Wrapping content in NavigationView\
            ZStack{
                VStack() {
                    Image(.image)
                        .resizable()
                        .cornerRadius(60)
                        .frame(width: 205, height: 205)
                    Text("Welcome to The Mav Hub")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color(.white))
                        .padding(.top, 10.0)
                        .fontDesign(.rounded)
                    NavigationLink(destination: ScheduleCreationView(scheduleIndex: $scheduleIndex)){
                        ZStack{
                            RoundedRectangle(cornerRadius: 20)
                                .foregroundStyle( LinearGradient(
                                    gradient: Gradient(colors: [.blue, .purple, .red]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .frame(width: 160, height: 40)
                            Text("Get Started")
                                .font(.body)
                                .fontWeight(.semibold)
                                .fontDesign(.rounded)
                                .foregroundStyle(Color(.black))
                                .padding(.all, 3.0)
                        }
                    }
                    .cornerRadius(100)
                    .padding(10.0)
                    .overlay(ZStack {
                        ProgressView(progress: progress1)
                        ProgressView(progress: progress2)
                            .rotationEffect(.degrees(180.0))
                    }
                        .onAppear() {
                            withAnimation(
                                .linear(duration: 3.5)
                                .repeatForever(autoreverses: false)
                            ) {
                                progress1 = 1.0
                            }
                            withAnimation(
                                .linear(duration: 3.5)
                                .repeatForever(autoreverses: false)
                            ) {
                                progress2 = 1.0
                            }
                        })
                }
                .padding()
            }
            .ignoresSafeArea()
        }
            .preferredColorScheme(.dark)
    }
}
extension View where Self: Shape {
  func glow(
    fill: some ShapeStyle,
    lineWidth: Double,
    blurRadius: Double = 8.0,
    lineCap: CGLineCap = .round
  ) -> some View {
    self
      .stroke(style: StrokeStyle(lineWidth: lineWidth / 2, lineCap: lineCap))
      .fill(fill)
      .overlay {
        self
          .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: lineCap))
          .fill(fill)
          .blur(radius: blurRadius)
      }
      .overlay {
        self
          .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: lineCap))
          .fill(fill)
          .blur(radius: blurRadius / 2)
      }
  }
}

extension ShapeStyle where Self == AngularGradient {
  static var palette: some ShapeStyle {
    .angularGradient(
      stops: [
        .init(color: .blue, location: 0.0),
        .init(color: .purple, location: 0.2),
        .init(color: .red, location: 0.4),
        .init(color: .mint, location: 0.5),
        .init(color: .indigo, location: 0.7),
        .init(color: .pink, location: 0.8),
        .init(color: .blue, location: 1.0),
      ],
      center: .center,
      startAngle: Angle(radians: .zero),
      endAngle: Angle(radians: .pi * 2)
    )
  }
}

struct ProgressView: View, Animatable {
  var progress: Double // Accept fill as a parameter
  private let delay = 0.2

  var animatableData: Double {
    get { progress }
    set { progress = newValue }
  }

  var body: some View {
    Capsule()
          .trim(
            from: {
              if progress > delay {
                progress - delay
              } else {
                .zero
              }
            }(),
            to: {
                if progress > 0.5 {
                    0.5
              } else {
                progress
              }
            }()
          )
      .glow(
        fill: .palette,
        lineWidth: 4.0
      )
      .frame(width: 170, height: 50)
  }
}
#Preview {
    IntroPageView()
}
