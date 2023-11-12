import SwiftUI

struct furnitureUpload: View {
    @Binding var name: String
    @Binding var selectFurniture: String
    
     @State var fileName = "no file chosen"
     @State var openFile = false
 
    var body: some View {
        VStack(spacing: 25){
        
            Text(self.fileName)
            
            Button {
                self.openFile.toggle()
            } label: {
                Text("Open Document Picker")
            }
            
        }
        
        .fileImporter( isPresented: $openFile, allowedContentTypes: [.audio,.image,.pdf,.usdz], allowsMultipleSelection: false, onCompletion: {
            (Result) in
            
            do{
                let fileURL = try Result.get()
                print(fileURL)
                self.fileName = fileURL.first?.lastPathComponent ?? "file not available"
                
            }
            catch{
               print("error reading file \(error.localizedDescription)")
            }
            
        })
       
    }
    

}
