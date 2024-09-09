//
//  ImageSelectViewController.swift
//  Instagram
//

import UIKit
import ZLImageEditor

class ImageSelectViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    @IBAction func handleLibraryButton(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let pickerController = UIImagePickerController()
            pickerController.delegate = self
            pickerController.sourceType = .photoLibrary
            self.present(pickerController, animated: true, completion: nil)
        }
    }
    
    @IBAction func handleCameraButton(_ sender: Any) {
            // カメラを指定してピッカーを開く
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let pickerController = UIImagePickerController()
                pickerController.delegate = self
                pickerController.sourceType = .camera
                self.present(pickerController, animated: true, completion: nil)
            }
        }
    
    @IBAction func handleCancelButton(_ sender: Any) {
        // 画面を閉じる
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if info[.originalImage] != nil {
            let image = info[.originalImage] as!  UIImage
            print("DEBUG_PRINT: image = \(image)")
            ZLImageEditorConfiguration.default()
                 .editImageTools([.draw, .clip, .textSticker, .mosaic, .filter, .adjust])
                 .adjustTools([.brightness, .contrast, .saturation])
             // ZLImageEditorの画像加工画面に遷移する
             ZLEditImageViewController.showEditImageVC(parentVC: self, image: image) { image, _ in
                 // ZLImageEditorで加工された画像を投稿画面に渡して画面遷移する
                let postViewController = self.storyboard?.instantiateViewController(withIdentifier: "Post") as! PostViewController
                postViewController.image = image
                self.present(postViewController, animated: true, completion: nil)
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

}
