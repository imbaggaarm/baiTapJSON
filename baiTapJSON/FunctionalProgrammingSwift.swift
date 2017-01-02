//
//  FunctionalProgrammingSwift.swift
//  appLayoutMP3ZING
//
//  Created by Dung Duong on 12/9/16.
//  Copyright © 2016 Tai Duong. All rights reserved.
//

import Foundation
import UIKit

let widthOfScreen = UIScreen.main.bounds.size.width
let heightOfScreen = UIScreen.main.bounds.size.height

extension UIImageView
{
    public func loadImageFromURL(urlString: String)
    {
        let url: URL = URL(string: urlString)!
        do
        {
            let data: Data = try Data(contentsOf: url)
            self.image = UIImage(data: data)
        }
        catch
        {
            print("LOAD IMAGE ERROR!");
        }        
        
    }
    public func loadImageFromURLWithMultiThreading(urlString: String)
    {
        
        let indicator: UIActivityIndicatorView = {
            let temp = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
            temp.color = UIColor.init(white: 0.9, alpha: 1)
            temp.translatesAutoresizingMaskIntoConstraints = false
            return temp
        }()
        self.addSubview(indicator)
        indicator.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        indicator.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        indicator.startAnimating()
        
        let queue = DispatchQueue(label: "queue")
        queue.async {
            if let url: URL = URL(string: urlString)
            {
                do
                {
                    let data: Data = try Data(contentsOf: url)
                    DispatchQueue.main.async {
                        self.image = UIImage(data: data)
                        indicator.stopAnimating()
                        indicator.hidesWhenStopped = true
                    }
                }
                catch
                {
                    
                }
            }

        }
    }
}
//extension UIView
//{
//    func addConstraintsWithFormat(format: String, views: UIView...)
//    {
//        var dic = Dictionary<String, UIView>()
//        for view in views
//        {
//            let key = "v\(views.index(of: view))"
//            view.translatesAutoresizingMaskIntoConstraints = false
//            dic[key] = view
//        }
//        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: dic))
//    }
//}
extension UIView
{
    func addConstraintsWithFormat(format: String, views: UIView...)
    {
        var dic = Dictionary<String, UIView>()
        for (index, view) in views.enumerated()
        {
            let key = "v\(index)"
            view.translatesAutoresizingMaskIntoConstraints = false
            dic[key] = view
        }
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: dic))
    }
    
}
extension UILabel
{
    class func setLbl(backgroundColor: UIColor, cornerRadius: CGFloat, borderWidth: CGFloat, borderColor: UIColor, isClips: Bool, title: String, font: UIFont, textAlignment: NSTextAlignment, textColor: UIColor) -> UILabel
    {
        let temp = UILabel()
        temp.backgroundColor = backgroundColor
        temp.layer.cornerRadius = cornerRadius
        temp.clipsToBounds = isClips
        temp.layer.borderColor = borderColor.cgColor
        temp.layer.borderWidth = borderWidth
        temp.text = title
        temp.font = font
        temp.textColor = textColor
        temp.textAlignment = textAlignment
        return temp
    }
}
extension UIColor
{
    class func rgb(red:CGFloat, green: CGFloat, blue: CGFloat) -> UIColor
    {
        return UIColor.init(red: red/255, green: green/255, blue: blue/255, alpha: 1);
    }
    class func rgba(red:CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIColor
    {
        return UIColor.init(red: red/255, green: green/255, blue: blue/255, alpha: alpha);
    }
    
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
    
    class func colorFromHexstring (hex:String, alpha: CGFloat = 1) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.characters.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}

extension UITextField
{
    func setLeftPadding(width: CGFloat)
    {
        let leftView = UIView()
        self.addSubview(leftView)
        self.leftView = leftView
        self.leftViewMode = .always
        leftView.frame = CGRect(x: 0, y: 0, width: width, height: self.frame.size.height)
    }
    class func initWith(placeHolder: String = "", cornerRadius: CGFloat = 5, backGroundColor: UIColor = UIColor.white, txtColor: UIColor = UIColor.black, font: UIFont = UIFont.systemFont(ofSize: 20), borderWidth: CGFloat = 0, borderColor: UIColor = .white, leftPaddingWidth: CGFloat = 4, keyboardType: UIKeyboardType = UIKeyboardType.alphabet) -> UITextField
    {
        let temp = UITextField()
        temp.backgroundColor = backGroundColor
        temp.placeholder = placeHolder
        temp.setLeftPadding(width: leftPaddingWidth)
        temp.textColor = txtColor
        temp.layer.cornerRadius = cornerRadius
        temp.font = font
        temp.layer.borderColor = borderColor.cgColor
        temp.layer.borderWidth = borderWidth
        temp.keyboardType = keyboardType
        temp.clipsToBounds = true
        
        return temp
    }
}

extension UIViewController
{
    func loadDataWebService(urlString: String, method: String = "GET", keyAndValue: Dictionary<String,Any> = [:], completion:@escaping (_ result: Any) -> Void)
    {
        var tempURLString = urlString
        let param = keyAndValue.convertDicToParamType()
        if method == "GET"
        {
            if param != ""
            {
                tempURLString += "?\(param)"
            }
        }
        
        let url = URL(string: tempURLString)
        print(url!)
        var urlRequest = URLRequest(url: url!)
        
        if method == "POST"
        {
            urlRequest.httpBody = param.data(using: .utf8)!
            urlRequest.httpMethod = method
        }
        
        
        let session = URLSession.shared
        
        session.dataTask(with: urlRequest, completionHandler: {(data, response, error) in
            do
            {
                let tempResult = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                //print("checkGetData\(tempResult)")
                completion(tempResult)
                DispatchQueue.global().async {
                }
            }
            catch{
            }
        }).resume()
    }
}

extension Dictionary
{
    func convertDicToParamType() -> String
    {
        var resultString = ""
        for (index, i) in self.enumerated()
        {
            if index == 0
            {
                resultString += "\(i.key)=\(i.value)"
            }
            else
            {
                resultString += "&\(i.key)=\(i.value)"
            }
        }
        return resultString
    }
}


extension UIButton
{
    class func initWithGhostButton(title: String, titleColor: UIColor, borderWidth: CGFloat, cornerRadius: CGFloat = 0, titleFont: UIFont = .systemFont(ofSize: 20)) -> UIButton
    {
        let temp = UIButton(type: .system)
        temp.setTitle(title, for: .normal)
        temp.setTitleColor(titleColor, for: .normal)
        temp.layer.borderColor = titleColor.cgColor
        temp.layer.cornerRadius = cornerRadius
        temp.layer.borderWidth = borderWidth
        temp.titleLabel?.font = titleFont
        temp.clipsToBounds = true
        temp.backgroundColor = .clear
        return temp
    }
}

extension UIViewController
{
    
}



/// http
/*
 <key>NSAppTransportSecurity</key>
 <dict>
 <key>NSAllowsArbitraryLoads</key><true/>
 </dict>
 */
