//
//  CFCityPickerVC.swift
//  CFCityPickerVC
//
//  Created by 冯成林 on 15/7/29.
//  Copyright (c) 2015年 冯成林. All rights reserved.
//

import UIKit

protocol CFCityPickerVCDelegate{
    
    func selectedCityModel(cityPicker: CFCityPickerVC, cityModel:CityModel)
}


class CFCityPickerVC: UIViewController {

    internal var delegate: CFCityPickerVCDelegate!
    
    internal var cityModels: [CityModel]!
    
    static let cityPVCTintColor = UIColor.greenColor()
    
    internal var searchBar: CitySearchBar!
    
    internal var searchRVC: CitySearchResultVC!
    
    /** 可设置：当前城市 */
    internal var currentCity: String!{didSet{getedCurrentCityWithName(currentCity)}}
    
    /** 可设置：热门城市 */
    internal var hotCities: [String]!
    
    
    lazy var indexTitleLabel: UILabel = {UILabel()}()

    internal var showTime: CGFloat = 1.0
    
    internal var indexTitleIndexArray: [Int] = []
    
    internal var selectedCityModel: ((cityModel: CityModel) -> Void)!
    
    lazy var dismissBtn: UIButton = { UIButton(frame: CGRectMake(0, 0, 24, 24)) }()
    
    lazy var selectedCityArray: [String] = {NSUserDefaults.standardUserDefaults().objectForKey(SelectedCityKey) as? [String] ?? []}()
    
    var currentCityItemView: HeaderItemView!

    deinit{
        print("控制器安全释放")
    }
    
    var tableView: UITableView!
}




