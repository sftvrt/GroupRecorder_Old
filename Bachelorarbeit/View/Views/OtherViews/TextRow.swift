//
//  TextRow.swift
//  Bachelorarbeit
//
//  Created by JT X on 05.08.22.
//

import Foundation

import SwiftUI

struct TextRow: View {
    
    @State var isLeftNav = false
    @State var show = false
    @State var showingProfile = false
    @EnvironmentObject var userData: UserData
    @EnvironmentObject var selectedLanguage : LanguageSettings
    @State private var isShowingSettings: Bool = false
    
    @EnvironmentObject var selectedLang : LanguageSettings
    
    let texts : [String]
    
    // MARK: - BODY
    var body: some View {
        List{
            let firstText = texts[0]
                Text((firstText.localizedStr(language: (selectedLang.lang == .zh) ? "zh-Hans" : selectedLang.lang.rawValue)))
            let secondText = texts[1]

                Text((secondText.localizedStr(language: (selectedLang.lang == .zh) ? "zh-Hans" : selectedLang.lang.rawValue)))
    }
}
}

struct TextRow_Previews: PreviewProvider {
    
    static var previews: some View {
        TextRow(texts: texts)
            .previewLayout(.sizeThatFits)
            .environmentObject(LanguageSettings())
    }
}

