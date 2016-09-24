//
//  ViewController.swift
//  PlayCGIVideo
//
//  Created by Чингиз Б on 24.09.16.
//  Copyright © 2016 Chingiz Bayshurin. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class ViewController: UIViewController {

   
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var videoType: UISegmentedControl!
    
    var l: CALayer {
        return videoView.layer
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        videoType.selectedSegmentIndex = 1
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


   
    
    
    //==========================   VIDEO CONVERTATION  ==================================================================================
    //код был вязт отсюда http://stackoverflow.com/questions/20282672/record-save-and-or-convert-video-in-mp4-format
    //
    
    //videoURL     - передался path NSURL ================================================================
    func encodeVideo(videoURL: NSURL, videoFileName: String!)  {
        let avAsset = AVURLAsset(url: videoURL as URL, options: nil)
        var startDate = NSDate()
        
        //Create Export session
        let exportSession = AVAssetExportSession(asset: avAsset, presetName: AVAssetExportPresetPassthrough)
        
        // exportSession = AVAssetExportSession(asset: composition, presetName: mp4Quality)
        //Creating temp path to save the converted video
        
        //++++ documentsDirectory1+++
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let myDocumentPath = NSURL(fileURLWithPath: documentsDirectory).appendingPathComponent(videoFileName)?.absoluteString   //++
        let url = NSURL(fileURLWithPath: myDocumentPath!)
        
        //++++ documentsDirectory2+++
        let documentsDirectory2 = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as NSURL
        
        let filePath = documentsDirectory2.appendingPathComponent(GlobalVars.renderedFileFullName)                               //++
        deleteFile(filePath: filePath! as NSURL)
        
        //Check if the file already exists then remove the previous file
        if FileManager.default.fileExists(atPath: myDocumentPath!) {
            do {
                try FileManager.default.removeItem(atPath: myDocumentPath!)
            }
            catch let error {
                print(error)
            }
        }

        exportSession!.outputURL = filePath
        exportSession!.outputFileType = AVFileTypeMPEG4
        exportSession!.shouldOptimizeForNetworkUse = true
        var start = CMTimeMakeWithSeconds(0.0, 0)
        var range = CMTimeRangeMake(start, avAsset.duration)
        exportSession?.timeRange = range
        
        exportSession!.exportAsynchronously(completionHandler: {() -> Void in
            switch exportSession!.status {
            case .failed:
                print("%@", exportSession?.error)
            case .cancelled:
                print("Export canceled")
            case .completed:
                //Video conversion finished
                var endDate = NSDate()
                
                var time = endDate.timeIntervalSince(startDate as Date)
                print(time)
                print("Successful!")
                print(exportSession?.outputURL)
                GlobalVars.renderedFileURL = exportSession?.outputURL
                
            default:
                break
            }
            
        })
    }//========================================================================================
    
    
    //функция удаления файла===================================================================
    func deleteFile(filePath:NSURL) {
        guard FileManager.default.fileExists(atPath: filePath.path!) else {
            return
        }
        
        do {
            try FileManager.default.removeItem(atPath: filePath.path!)
        }catch{
            fatalError("Unable to delete file: \(error) : \(#function).")
        }
    }//=========================================================================================
    //=======================================END OF VIDEO CONVERTATION ======================================================================================
    
    
    
    
    
 
    
    ///=============================== ТРИ КНОПКИ =========================================================================================================
    @IBAction func convertButtonTapped(_ sender: AnyObject) {
        print("Try to convert initial video!...")
        if (videoType.selectedSegmentIndex == 0)
        {
            //***    А это тот файл, который и нужно перекодировать - VIDEO.CGI -
            //***    Так как AVKit'у нельзя скормить тип ресурса CGI я поставил расширения файла MP4
            let path = Bundle.main.path(forResource: GlobalVars.videoFileName[0], ofType: GlobalVars.videoFileExtension[0])!
            let pathURL = NSURL(fileURLWithPath: path)
            let videoFileFullName = "/(GlobalVars.videoFileName[0])./(GlobalVars.videoFileExtension[0])"
            encodeVideo(videoURL: pathURL, videoFileName: videoFileFullName)        //******  ВОТ НАШ ВЫЗОВ ФУНЦИИ ПЕРЕКОДИРОВКИ ВИДЕО
            print("videoURL = \t \(pathURL)")
            print("Rendered File  == \(GlobalVars.renderedFileURL)")
        }
        else
        {
            //***     для пример, я загрузил еще заведомо нормальный MP4 файл, который разумеется спокойно проигрывается
            //***    в исходном состоянии, перекодируется и успешно пригрывается при перекодировке
            let path = Bundle.main.path(forResource: GlobalVars.videoFileName[1], ofType: GlobalVars.videoFileExtension[1])!
            let pathURL = NSURL(fileURLWithPath: path)
            let videoFileFullName = "/(GlobalVars.videoFileName[1])./(GlobalVars.videoFileExtension[1])"
            encodeVideo(videoURL: pathURL, videoFileName: videoFileFullName)
            encodeVideo(videoURL: pathURL, videoFileName: videoFileFullName)        //******  ВОТ НАШ ВЫЗОВ ФУНЦИИ ПЕРЕКОДИРОВКИ ВИДЕО
            print("videoURL = \t \(pathURL)")
            print("Rendered File  == \(GlobalVars.renderedFileURL)")
        }
    }
    
    //ПРОИГРЫВАНИЕ ОТКОНВЕРТИРОВАННОГО ВИДЕО - "rendered-file.mp4"  КОТОРОЕ БЫЛО СОХАРНЕНО, ЕСЛИ НЕ NIL (операция конвератции прошла успешно)
    @IBAction func playRenderedFileButtonTapped(_ sender: AnyObject) {
        if GlobalVars.renderedFileURL != nil {
            print("Now play rendered video")
            playVideoView(videoFileURL: GlobalVars.renderedFileURL! as NSURL)
        } else {
            print ("There is no yet rendered file!")
        }
    }
    
    //ПРОИГРЫВАНИЕ ОРИГИНАЛЬНОГО ВИДЕО - ТО ЕСТЬ ТЕХ 2 ФАЙЛОВ ЧТО БЫЛИ СОХРАНЕНЫ В ПРОЕКТЕ  badVideo.mp4 + justForExampleVideo.mp4
    @IBAction func playButtonTapped(_ sender: AnyObject) {
        if (videoType.selectedSegmentIndex == 0)
        {
            //***    А это тот файл, который и нужно перекодировать - VIDEO.CGI -
            //***    Так как AVKit'у нельзя скормить тип ресурса CGI я поставил расширения файла MP4
            let path = Bundle.main.path(forResource: GlobalVars.videoFileName[0], ofType: GlobalVars.videoFileExtension[0])!
            print("Try to play original file \(path)")
            let pathURL = NSURL(fileURLWithPath: path)   //TODO: NSURL(fileURLWithPath: path)    not     NSURL(string: path)
            playVideoView(videoFileURL: pathURL)
        }
        else
        {
            //***     для пример, я загрузил еще заведомо нормальный MP4 файл, который разумеется спокойно проигрывается
            //***    в исходном состоянии, перекодируется и успешно пригрывается при перекодировке
            let path = Bundle.main.path(forResource: GlobalVars.videoFileName[1], ofType: GlobalVars.videoFileExtension[1])!
            print("Try to play original file \(path)")
            let pathURL = NSURL(fileURLWithPath: path)   //TODO: NSURL(fileURLWithPath: path)    not     NSURL(string: path)
            playVideoView(videoFileURL: pathURL)
        }
    }
    //======================================================================================================================================================
    
    
    
    
    
    
    
    
    
    
    //============================= БЛОК ПРОИГРЫВАНИЯ ВИДЕО ==================================================================================================
    func playVideoView(videoFileURL: NSURL!) {
        //===показать вью=====
       setUpLayer2()
        
        let player = AVPlayer(url: videoFileURL as URL)
        let newLayer = AVPlayerLayer(player: player)
        newLayer.frame = self.videoView.frame
        self.videoView.layer.addSublayer(newLayer)
        newLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        player.play()
        //    selector: "videoDidPlayToEnd"
        //функция вызова по достижению конца ролика                                 //    action: #selector(videoDidPlayToEnd)
        player.actionAtItemEnd = AVPlayerActionAtItemEnd.none
        // НОВЫЙ СИНТАКСИС РАБОТЫ С Notification servioce
        // http://stackoverflow.com/questions/38204703/notificationcenter-issue-on-swift-3
        NotificationCenter.default.addObserver(self, selector: #selector(videoDidPlayToEnd), name: NSNotification.Name(rawValue: "AVPlayerItemDidPlayToEndTimeNotification"), object: player.currentItem)
    }
    
    
    
    func videoDidPlayToEnd (notification: NSNotification) {
        var player: AVPlayerItem = notification.object as! AVPlayerItem
        
        //закольцованность видео
        //player.seek(to: kCMTimeZero)
        
        print("Достигнут конец видео")
        
         //для того, чтобы скрыть слой, где осталось изображения остановившегося видео
         setUpLayer1()
    }
    //====================================================================================================================================================================
    
    
    
    
    
    
   
 
  
    //для того, чтобы скрыть слой, где осталось изображения остановившегося видео
    func setUpLayer1() {
        l.backgroundColor = UIColor(colorLiteralRed:  128/255.0, green: 165/255.0, blue: 255/255.0, alpha: 1.0).cgColor
        
        l.borderWidth = 400.0
        l.borderColor = UIColor(colorLiteralRed:  128/255.0, green: 165/255.0, blue: 255/255.0, alpha: 1.0).cgColor
    }
    
    //для того, чтобы скрыть слой, где осталось изображения остановившегося видео
    func setUpLayer2() {
        l.backgroundColor = UIColor(colorLiteralRed:  128/255.0, green: 165/255.0, blue: 255/255.0, alpha: 1.0).cgColor
        
        l.borderWidth = 1.0
        l.borderColor = UIColor(colorLiteralRed:  128/255.0, green: 165/255.0, blue: 255/255.0, alpha: 1.0).cgColor
    }
    
}//------ end of class declaration ----------------------------

































