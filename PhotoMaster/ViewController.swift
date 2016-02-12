//
//  ViewController.swift
//  PhotoMaster
//
//  Created by 森泉亮介 on 2016/02/12.
//  Copyright © 2016年 森泉亮介. All rights reserved.
//

import UIKit
import Social

//UINavigationControllerDelegate, UIImagePickerControllerDelegate　カメラとアルバムから写真を取得するときに使われる
class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    
    //写真表示用ImageView
    @IBOutlet var photoImageView :UIImageView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    //カメラ、アルバムの呼び出しメソッド（カメラorアルバムのソースタイプが引数）
    func precentPikerController(sourceType: UIImagePickerControllerSourceType){
        
        //ライブラリが使用できるかどうか判定
        if UIImagePickerController.isSourceTypeAvailable(sourceType){
            
            //UIImagePickerControllerをインスタンス化
            let picker = UIImagePickerController()
            
            //ソースタイプを設定
            picker.sourceType = sourceType
            
            //デリゲートを設定
            picker.delegate = self
            
            self.presentViewController(picker, animated: true, completion: nil)
        }
    }
    
    
    //写真が選択された時に呼び出されるメソッド
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo:NSDictionary!) {
        self.dismissViewControllerAnimated(true, completion:nil)
        
        //画像を出力
        photoImageView.image = image
    }
    
    
    //画像を取得ボタンを押した時に呼ばれるメソッド
    @IBAction func selectButtonTapped(sender:UIButton){
        
        //選択肢の上に表示するタイトル、メッセージ、アラートタイプの設定
        let alertController = UIAlertController(title: "画像の取得先を選択", message: nil, preferredStyle: .ActionSheet)
        
        //選択肢の名前と処理を1つずつ設定
        let firstAction = UIAlertAction(title: "カメラ", style: .Default){
            action in
            self.precentPikerController(.Camera)
        }
        let secondAction = UIAlertAction(title: "アルバム", style: .Default){
            action in
            self.precentPikerController(.PhotoLibrary)
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .Cancel, handler: nil)
        
        //設定した選択肢をアラートに登録
        alertController.addAction(firstAction)
        alertController.addAction(secondAction)
        alertController.addAction(cancelAction)
        
        //アラートを表示
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    //元の画像にテキストとスタンプを合成するメソッド
    func drawText(image: UIImage) -> UIImage {
        
        //テキストの内容の設定
        let text = "LifeicTech!\nXmasCamp2015💖"
        
        //グラフィックスコンテキスト生成・編集を開始
        UIGraphicsBeginImageContext(image.size)
        
        //読み込んだ写真を書き出す
        image.drawInRect(CGRectMake(0, 0, image.size.width, image.size.height))
        
        //描き出す位置と大きさの設定 CGRectMake([左からのx座標]px, [上からのy座標]px, [縦の長さ]px, [横の長さ]px)
        let textRect = CGRectMake(5, 5, image.size.width - 5, image.size.height - 5)
        
        //textFontAtributes: 文字の特性（フォント、カラー、スタイル）の設定
        let textFontAttributes = [
            NSFontAttributeName: UIFont.boldSystemFontOfSize(120),
            NSForegroundColorAttributeName: UIColor.redColor(),
            NSParagraphStyleAttributeName: NSMutableParagraphStyle.defaultParagraphStyle()
        ]
        
        //textRectで指定した範囲にtextRectAttributesにしたがってtextを描き出す
        text.drawInRect(textRect, withAttributes: textFontAttributes)
        
        //グラフィックスコンテキストの画像を取得
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        //グラフィックスコンテキストの編集を終了
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    
    //元の画像にマスク画像を合成するメソッド
    func drawMaskImage(image: UIImage) -> UIImage{
        
        //グラフィックスコンテキスト生成、編集を開始
        UIGraphicsBeginImageContext(image.size)
        
        //読み込んだ写真を書き出す
        image.drawInRect(CGRectMake(0, 0, image.size.width, image.size.height))
        
        //マスク画像（保存場所：PhotoMaster > Assets.xcassets）
        let maskImage = UIImage(named: "ユニコーン")
        
        //書き出す位置と大きさの設定 CGRectMake([左からのx座標]px, [上からのy座標]px, [縦の長さ]px, [横の長さ]px)
        let offset: CGFloat = 100.0
        let maskRect = CGRectMake(
            image.size.width - maskImage!.size.width - offset,
            image.size.height - maskImage!.size.height - offset,
            maskImage!.size.width,
            maskImage!.size.height
        )
        
        //maskRectで指定した範囲にmaskImageを書き出す
        maskImage!.drawInRect(maskRect)
        
        //グラフィックスコンテキストの画像を取得
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        //グラフィックスコンテキストの編集を終了
        UIGraphicsEndImageContext()
        
        return newImage
    }

    
    //写真が選択されていない時に合成ボタンを押された時の処理
    //任意のメッセージとOKボタンを持つアラートのメソッド
    func simpleAlert(titleString: String){
        
        let alertController = UIAlertController(title: titleString, message: nil, preferredStyle: .Alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(defaultAction)
        
        presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    
    //合成ボタンを押した時に呼ばれるメソッド
    @IBAction func processButtonTapped(sender: UIButton){
        
        //photoImageView.imageがnilでなければselectedPhotoに値が入る
        guard let selectedPhoto = photoImageView.image else{
            
            //nilならアラートを表示してメソッドを抜ける
            simpleAlert("画像がありません")
            return
        }
        
        let alertController = UIAlertController(title: "合成するパーツを選択", message: nil, preferredStyle: .ActionSheet)
        let firstAction = UIAlertAction(title: "テキスト", style: .Default){
            action in
            
            //selectedPhotoにテキストを合成して画面に書き出す
            self.photoImageView.image = self.drawText(selectedPhoto)
        }
        let secondAction = UIAlertAction(title: "ユニコーン", style: .Default){
            action in
            
            //selectePhotoに画像を合成して画面に書き出す
            self.photoImageView.image = self.drawMaskImage(selectedPhoto)
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .Cancel, handler: nil)
        
        alertController.addAction(firstAction)
        alertController.addAction(secondAction)
        alertController.addAction(cancelAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    //SNSに投稿するメソッド（FacebookかTwitterのソースタイプが引数）
    func postToSNS(serviceType: String){
        
        //SLComposeViewControllerのインスタンス化し、ServiceTypeを指定
        let myComposeView = SLComposeViewController(forServiceType: serviceType)
        
        //投稿するテキストを指定
        myComposeView.setInitialText("photoMasterからの投稿")
        
        //投稿する画像を指定
        myComposeView.addImage(photoImageView.image)
        
        //myComposeViewの画面遷移
        self.presentViewController(myComposeView, animated: true, completion: nil)
    }
    
    
    //アップロードボタンを押した時に呼ばれるメソッド
    @IBAction func uploadButtonTrapped(sender: UIButton) {
        
        guard let selectedPhoto = photoImageView.image else{
             simpleAlert("画像がありません")
            return
        }
        
        let alertController = UIAlertController(title: "アップロード先を選択", message: nil, preferredStyle: .ActionSheet)
        let firstAction = UIAlertAction(title: "Facebookに投稿", style: .Default){
            action in
            self.postToSNS(SLServiceTypeFacebook)
        }
        let secondAction = UIAlertAction(title: "Twitterに投稿", style: .Default){
            action in
            self.postToSNS(SLServiceTypeTwitter)
        }
        let thirdAction = UIAlertAction(title: "カメラロールに保存", style: .Default){
            action in
            UIImageWriteToSavedPhotosAlbum(selectedPhoto, self, nil, nil)
            self.simpleAlert("アルバムに保存されました")
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .Cancel, handler: nil)
        
        alertController.addAction(firstAction)
        alertController.addAction(secondAction)
        alertController.addAction(thirdAction)
        alertController.addAction(cancelAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

