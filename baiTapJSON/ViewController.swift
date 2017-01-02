//
//  ViewController.swift
//  baiTapJSON
//
//  Created by Dung Duong on 1/2/17.
//  Copyright © 2017 Tai Duong. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var result: Array<CategoryStruct> = []
    var cellArr: Array<CategoryStruct> = []
    var cellArrNextLevel: Array<CategoryStruct> = []
    var currentCategory = CategoryStruct()
    var currentLevel = 2
    
    static let cellId = "cellId"
    
    lazy var tableView: UITableView = {
        let temp = UITableView()
        temp.register(UITableViewCell.self, forCellReuseIdentifier: ViewController.cellId)
        temp.delegate = self
        temp.dataSource = self
        
        return temp
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.init(white: 0.9, alpha: 1)
        
        loadDataWebService(urlString: "http://hidaacademy.com/baitap.json", completion: {dic in
            let temp = dic as! Dictionary<String, Any>
            if let arr = temp["result"] as? Array<Any>
            {
                for i in arr
                {
                    let strA = CategoryStruct(object: i)
                    self.result.append(strA)
                }
                for i in self.result
                {
                    if i.categoryLevel == self.currentLevel
                    {
                        self.cellArr.append(i)
                    }
                    else if i.categoryLevel == self.currentLevel + 1
                    {
                        self.cellArrNextLevel.append(i)
                    }
                }
                print(self.cellArrNextLevel.count)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        })
        
        self.view.addSubview(tableView)
        self.view.addConstraintsWithFormat(format: "V:|[v0]|", views: tableView)
        self.view.addConstraintsWithFormat(format: "H:|[v0]|", views: tableView)
        let butComeBack = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(comeBack))
        butComeBack.title = "Back"
        navigationItem.rightBarButtonItem = butComeBack
        
    }
    
    func comeBack()
    {
        if currentLevel > 2
        {
            currentLevel -= 1
            cellArrNextLevel.removeAll()
            cellArr = []
            var tempCurrent = CategoryStruct()
            for i in result
            {
                if currentCategory.categoryParentId == i.categoryParentId
                {
                    cellArr.append(i)
                }
                else if i.categoryLevel == currentLevel + 1
                {
                    cellArrNextLevel.append(i)
                }
                else if i.categoryID == currentCategory.categoryParentId
                {
                    tempCurrent = i
                }
            }
            currentCategory = tempCurrent
            tableView.reloadData()
        }
        
    }
    
    }

extension ViewController: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ViewController.cellId, for: indexPath)
        cell.textLabel?.text = cellArr[indexPath.row].categoryName
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellArr.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tempObject = cellArr[indexPath.row]
        currentCategory = tempObject
        var tempNextARR: Array<CategoryStruct> = []
        cellArr.removeAll()
        for i in cellArrNextLevel
        {
            if i.categoryParentId == tempObject.categoryID
            {
                cellArr.append(i)
            }
            else if i.categoryLevel == currentLevel + 1
            {
                tempNextARR.append(i)
            }
        }
        currentLevel += 1
        cellArrNextLevel = tempNextARR
        tableView.reloadData()
    }

}

struct CategoryStruct
{
    var categoryID: Int
    var categoryLevel: Int
    var categoryName: String
    var categoryParentId: Int
    
    init() {
        categoryID = 0
        categoryLevel = 0
        categoryName = ""
        categoryParentId = 0
    }
    init(object: Any) {
        if let dic = object as? Dictionary<String, Any>
        {
            if let id = dic["categoryId"] as? Int, let level = dic["categoryLevel"] as? Int, let name = dic["categoryName"] as? String, let parentId = dic["categoryParentId"] as? Int
            {
                categoryID = id
                categoryLevel = level
                let arrName = name.components(separatedBy: " | ")
                //if level == 1... else do
                categoryName = arrName[categoryLevel - 2]
                categoryParentId = parentId
                print(categoryName)
                
            }
            else
            {
                categoryID = 0
                categoryLevel = 0
                categoryName = ""
                categoryParentId = 0
            }
        }
        else
        {
            categoryID = 0
            categoryLevel = 0
            categoryName = ""
            categoryParentId = 0
        }
    }
    
}
