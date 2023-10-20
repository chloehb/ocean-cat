//
//  ScanningView.swift
//  SpaceBlender
//
//  Created by akai on 10/7/23.
//

import Foundation
import SwiftUI
import RoomPlan

struct RoomCaptureViewRep : UIViewRepresentable
{
    func makeUIView(context: Context) -> some UIView {
        RoomCaptureController.instance.roomCaptureView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {}
}

struct ActivityViewControllerRep: UIViewControllerRepresentable {
    var items: [Any]
    var activities: [UIActivity]? = nil
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityViewControllerRep>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: activities)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityViewControllerRep>) {}
}

struct ScanningView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var captureController = RoomCaptureController.instance
    @ObservedObject var store = ModelStore.shared
    
    var body: some View {
        ZStack(alignment: .bottom) {
            RoomCaptureViewRep()
                .navigationBarBackButtonHidden(true)
                .navigationBarItems(leading: Button("Cancel") {
                    captureController.stopSession()
                    dismiss()
                })
                .navigationBarItems(trailing: Button("Done") {
                    captureController.stopSession()
                    captureController.showExportButton = true
                }.opacity(captureController.showExportButton ? 0 : 1)).onAppear() {
                    captureController.showExportButton = false
                    captureController.startSession()
                }
            // export button
            //            Button(action: {
            //                captureController.export()
            //                dismiss()
            //            }, label: {
            //                Text("Export").font(.title2)
            //            }).buttonStyle(.borderedProminent).cornerRadius(40).opacity(captureController.showExportButton ? 1 : 0).padding().sheet(isPresented: $captureController.showShareSheet, content:{
            //                ActivityViewControllerRep(items: [captureController.exportUrl!])
            //            })
            NavigationLink(destination: TestView(), label: {Text("Go to test view")} ).simultaneousGesture(TapGesture().onEnded{
                captureController.done()
                print("After call done: there are \(store.models.count) models")
            }).buttonStyle(.borderedProminent).cornerRadius(40).font(.title2)
            
        }
    }
}
