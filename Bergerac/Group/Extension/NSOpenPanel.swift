//
//  NSOpenPanel.swift
//  Bergerac
//
//  Created by thierryH24 on 16/08/2020.
//  Copyright © 2020 thierry hentic. All rights reserved.
//

import AppKit
import Quartz


extension NSOpenPanel {
    var selectUrl: URL? {
        title = "Select file"
        allowsMultipleSelection = false
        canChooseDirectories = false
        canChooseFiles = true
        canCreateDirectories = false
        
        allowedContentTypes = [.commaSeparatedText, .text]

        return runModal() == .OK ? urls.first : nil
    }
    //    var selectUrls: [URL]? {
    //        title = "Select files"
    //        allowsMultipleSelection = true
    //        canChooseDirectories = false
    //        canChooseFiles = true
    //        canCreateDirectories = false
    //        allowedFileTypes = ["csv", "txt"]
    //        return runModal() == .OK ? urls : nil
    //    }
}
