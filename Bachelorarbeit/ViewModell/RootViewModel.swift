//
//  RootViewModel.swift
//

import SwiftUI

class RootViewModel: ObservableObject {
    /// 标签栏选中的索引
    @Published var tabSelection: Int = 0
    
    @Published var isPop: Bool = false

    /// 标签栏界面导航是否隐藏
    @Published var tabNavigationHidden: Bool = false
    
    /// 标签栏界面导航标题
    @Published var tabNavigationTitle: LocalizedStringKey = ""
    
    /// 标签栏界面导航左侧按钮
    @Published var tabNavigationBarLeadingItems: AnyView = .init(EmptyView())

    /// 标签栏界面导航右侧按钮
    @Published var tabNavigationBarTrailingItems: AnyView = .init(EmptyView())
    
}

