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
    
    @State private var isPresentingRoomGallery = false
    @Environment(\.dismiss) private var dismiss
    @StateObject var captureController = RoomCaptureController.instance
    @ObservedObject var store = ModelStore.shared
    @State private var message = "Insert Model Name"
    
    var body: some View {
        ZStack(alignment: .bottom) {
                
                RoomCaptureViewRep()
                .toolbar {
                  ToolbarItem(placement: .principal) {
                    TextField("Model Name", text: $message)
                  }
                }
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
            VStack {
                NavigationLink(destination: RoomGalleryView(isPresented: $isPresentingRoomGallery), label: {Text("Save to Room Gallery")} ).simultaneousGesture(TapGesture().onEnded{
                    isPresentingRoomGallery.toggle()
                   captureController.done(message: message)
                   print("After call done: there are \(store.models.count) models")
               }).buttonStyle(.borderedProminent).cornerRadius(40).font(.title2).opacity(captureController.showExportButton ? 1 : 0).padding()
           }
        }
        .onTapGesture {
            // dismiss virtual keyboard from class lab
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}
