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
//            Button(action: {
//                captureController.export()
//                dismiss()
//            }, label: {
//                Text("Export").font(.title2)
//            }).buttonStyle(.borderedProminent).cornerRadius(40).opacity(captureController.showExportButton ? 1 : 0).padding().sheet(isPresented: $captureController.showShareSheet, content:{
//                ActivityViewControllerRep(items: [captureController.exportUrl!])
//            })
            Button(action: {
                captureController.done()
                dismiss()
            }, label: {
                Text("Done").font(.title2)
            }).buttonStyle(.borderedProminent).cornerRadius(40).opacity(captureController.showExportButton ? 1 : 0).padding()
        }
    }
}
