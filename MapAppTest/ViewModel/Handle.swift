//
//  Handle.swift
//  MapAppTest
//
//  Created by Nadhif Rahman Alfan on 20/05/24.
//

import SwiftUI

struct Handle : View {
    private let handleThickness = CGFloat(5.0)
    var body: some View {
        RoundedRectangle(cornerRadius: handleThickness / 2.0)
            .frame(width: 40, height: handleThickness)
            .foregroundColor(Color.secondary)
            .padding(.vertical,-10)
            .padding(.bottom, -10)
    }
}
