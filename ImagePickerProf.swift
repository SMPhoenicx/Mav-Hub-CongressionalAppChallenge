import SwiftUI
import PhotosUI

struct ImagePickerProf: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    var onUpload: (UIImage) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true // Enable editing for cropping and zooming
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePickerProf

        init(_ parent: ImagePickerProf) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            picker.dismiss(animated: true)
            
            // Extract the edited image (if cropped/zoomed) or the original image
            if let editedImage = info[.editedImage] as? UIImage {
                DispatchQueue.main.async {
                    self.parent.image = editedImage
                    self.parent.onUpload(editedImage)
                }
            } else if let originalImage = info[.originalImage] as? UIImage {
                DispatchQueue.main.async {
                    self.parent.image = originalImage
                    self.parent.onUpload(originalImage)
                }
            }
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}
