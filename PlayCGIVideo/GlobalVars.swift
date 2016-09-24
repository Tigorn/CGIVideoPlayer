//
//  GlobalVars.swift
//  PlayCGIVideo
//
//  Created by Чингиз Б on 24.09.16.
//  Copyright © 2016 Chingiz Bayshurin. All rights reserved.
//

import Foundation


class GlobalVars {
    
    static var renderedFileURL : URL?
    static var renderedFileFullName = "rendered-file.mp4"   // имя получаемого нами видеофайла после конвертации
    
    // первый элемент - наще "плохое" видео, которое нужно каким-то образом перекодировать (вернуть заголовки MP4)
    // второй элнемент - нормальный видеоролик, включенный для примера (он отлично перекодируется и проигрывается)
    
    static var videoFileName : [String]      = ["badVideo", "justForExampleVideo"]
    static var videoFileExtension : [String] = ["mp4", "mp4"]
    
    
    
    

}
