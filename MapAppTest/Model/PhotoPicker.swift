import SwiftUI
import PhotosUI

struct CustomPhotoPickerView: UIViewControllerRepresentable {

    @Binding var selectedImages: [UIImage]?
    
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        config.filter = .images
        config.selectionLimit = 0
        let controller = PHPickerViewController(configuration: config)
        controller.delegate = context.coordinator
        return controller
    }
    
    func makeCoordinator() -> CustomPhotoPickerView.Coordinator {
        return Coordinator(self)
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
    }
    
    class Coordinator: PHPickerViewControllerDelegate {
        private let parent: CustomPhotoPickerView
        
        init(_ parent: CustomPhotoPickerView) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.presentationMode.wrappedValue.dismiss()
            guard !results.isEmpty else {
                return
            }
            
            var selectedImages = [UIImage]()
            let group = DispatchGroup()
            
            for imageResult in results {
                if imageResult.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    group.enter()
                    imageResult.itemProvider.loadObject(ofClass: UIImage.self) { (selectedImage, error) in
                        if let error = error {
                            print(error.localizedDescription)
                        } else if let image = selectedImage as? UIImage {
                            selectedImages.append(image)
                        }
                        group.leave()
                    }
                }
            }
            
            group.notify(queue: .main) {
                self.parent.selectedImages = selectedImages
            }
        }
    }
}

struct CustomPhotoPicker_Previews: PreviewProvider {
    static var previews: some View {
        CustomPhotoPickerView(selectedImages: Binding.constant(nil))
    }
}
