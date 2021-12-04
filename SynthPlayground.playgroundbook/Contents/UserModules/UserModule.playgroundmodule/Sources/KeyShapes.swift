//
//  KeyShapes.swift
//  SynthApp
//
//  Created by Pierre Juliot on 18/04/2021.
//

import Foundation
import SwiftUI

struct LeftKey : Shape{
    
    let blackKeyWidth : CGFloat;

    func path(in rect: CGRect) -> Path {
        return Path{ path in
            
            let acomp = blackKeyWidth * 1.5;
            let comp = blackKeyWidth - blackKeyWidth / 4
            path.move(to: CGPoint(x: 0, y: 0))
            
            var next = CGPoint(x: path.currentPoint!.x + comp, y: path.currentPoint!.y);
            path.addLine(to: next)
            
            next = CGPoint(x: path.currentPoint!.x, y: rect.size.height * 2/3);
            path.addLine(to: next)
           
            next = CGPoint(x: path.currentPoint!.x + acomp / 2, y: path.currentPoint!.y);
            path.addLine(to: next)
            
            next = CGPoint(x: path.currentPoint!.x, y: rect.size.height);
            path.addLine(to: next)
           
            next = CGPoint(x: 0, y: rect.size.height);
            path.addLine(to: next)
            
            next = CGPoint(x: 0, y: 0);
            path.addLine(to: next)
            
        }
    }
}


struct RightKey : Shape{
    
    var blackKeyWidth : CGFloat;
    
    func path(in rect: CGRect) -> Path {
        return Path{ path in
            
            path.move(to: CGPoint(x: blackKeyWidth * 3/4, y: 0))
            
            var next = CGPoint(x: path.currentPoint!.x + blackKeyWidth * 3/4, y: path.currentPoint!.y);
            path.addLine(to: next)

            next = CGPoint(x: path.currentPoint!.x, y: rect.size.height);
            path.addLine(to: next)
            
            next = CGPoint(x: 0, y: rect.size.height);
            path.addLine(to: next)
            
            next = CGPoint(x: 0, y: rect.size.height * 2/3);
            path.addLine(to: next)
            
            next = CGPoint(x: blackKeyWidth - ((1/4) * blackKeyWidth), y: rect.size.height * 2/3);
            path.addLine(to: next)
            
            next = CGPoint(x: path.currentPoint!.x, y: 0);
            path.addLine(to: next)
            
            path.closeSubpath();

        }
    }
}

struct MiddleKey : Shape{
    
    var blackKeyWidth : CGFloat;
    
    func path(in rect: CGRect) -> Path {
        return Path{ path in
            
            let comp = blackKeyWidth - blackKeyWidth / 4
            path.move(to: CGPoint(x: blackKeyWidth / 4, y: 0))
            
            var next = CGPoint(x: path.currentPoint!.x + comp, y: path.currentPoint!.y);
            path.addLine(to: next)
            
            next = CGPoint(x: path.currentPoint!.x, y: rect.size.height * 2/3);
            path.addLine(to: next)

            next = CGPoint(x: path.currentPoint!.x + blackKeyWidth / 2, y: rect.size.height * 2/3);
            path.addLine(to: next)
        
            next = CGPoint(x: path.currentPoint!.x, y: rect.size.height);
            path.addLine(to: next)
            
            next = CGPoint(x: path.currentPoint!.x - blackKeyWidth * 1.5, y: path.currentPoint!.y);
            path.addLine(to: next)
            
            next = CGPoint(x: path.currentPoint!.x, y: rect.size.height * 2/3);
            path.addLine(to: next)
            
            next = CGPoint(x: path.currentPoint!.x + blackKeyWidth / 4, y: path.currentPoint!.y);
            path.addLine(to: next)
            
            next = CGPoint(x: path.currentPoint!.x, y: 0);
            path.addLine(to: next)
   
            path.closeSubpath();

        }
    }
}

struct MiddleKey2 : Shape{
    
    var blackKeyWidth : CGFloat;
    
    func path(in rect: CGRect) -> Path {
        return Path{ path in
            
            path.move(to: CGPoint(x: blackKeyWidth / 2, y: 0))
            
            var next = CGPoint(x: path.currentPoint!.x + blackKeyWidth * 3 / 4, y: path.currentPoint!.y);
            path.addLine(to: next)
            
            next = CGPoint(x: path.currentPoint!.x, y: rect.size.height * 2/3);
            path.addLine(to: next)
        
            next = CGPoint(x: path.currentPoint!.x + blackKeyWidth / 4, y: rect.size.height * 2/3);
            path.addLine(to: next)
            
            next = CGPoint(x: path.currentPoint!.x, y: rect.size.height);
            path.addLine(to: next)
            
            next = CGPoint(x: path.currentPoint!.x - blackKeyWidth * 1.5, y: path.currentPoint!.y);
            path.addLine(to: next)
            
            next = CGPoint(x: path.currentPoint!.x, y: rect.size.height * 2/3);
            path.addLine(to: next)
            
            next = CGPoint(x: path.currentPoint!.x + blackKeyWidth / 2, y: path.currentPoint!.y);
            path.addLine(to: next)
            
            next = CGPoint(x: path.currentPoint!.x, y: 0);
            path.addLine(to: next)
        
            path.closeSubpath();

        }
    }
}

struct MiddleKey3 : Shape{
    
    var blackKeyWidth : CGFloat;
    
    func path(in rect: CGRect) -> Path {
        return Path{ path in
            
            path.move(to: CGPoint(x: blackKeyWidth * 1/4, y: 0))
            
            var next = CGPoint(x: path.currentPoint!.x + blackKeyWidth, y: path.currentPoint!.y);
            path.addLine(to: next)
            
            next = CGPoint(x: path.currentPoint!.x, y: rect.size.height * 2/3);
            path.addLine(to: next)
        
            next = CGPoint(x: path.currentPoint!.x + blackKeyWidth / 4, y: rect.size.height * 2/3);
            path.addLine(to: next)
            
            next = CGPoint(x: path.currentPoint!.x, y: rect.size.height);
            path.addLine(to: next)
            
            next = CGPoint(x: path.currentPoint!.x - blackKeyWidth * 1.5, y: path.currentPoint!.y);
            path.addLine(to: next)
            
            next = CGPoint(x: path.currentPoint!.x, y: rect.size.height * 2/3);
            path.addLine(to: next)
            
            next = CGPoint(x: path.currentPoint!.x + blackKeyWidth * 1 / 4, y: path.currentPoint!.y);
            path.addLine(to: next)
            
            next = CGPoint(x: path.currentPoint!.x, y: 0);
            path.addLine(to: next)

            path.closeSubpath();

        }
    }
}
