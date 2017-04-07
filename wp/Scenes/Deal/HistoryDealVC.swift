//
//  HistoryDealVC.swift
//  wp
//
//  Created by 木柳 on 2017/1/4.
//  Copyright © 2017年 com.yundian. All rights reserved.
//

import UIKit
import RealmSwift
import DKNightVersion
class HistoryDealCell: OEZTableViewCell{
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var winLabel: UILabel!
    @IBOutlet weak var failLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var handleLabel: UILabel!
    // 盈亏
    @IBOutlet weak var statuslb: UILabel!
    override func update(_ data: Any!) {
        if let model: PositionModel = data as! PositionModel? {
            print(model.description)
            nameLabel.text = "\(model.name)"
            timeLabel.text = Date.yt_convertDateToStr(Date.init(timeIntervalSince1970: TimeInterval(model.closeTime)), format: "yyyy.MM.dd HH:mm:ss")
           //com.yundian.trip
            priceLabel.text = "¥" + String(format: "%.2f", model.openCost)
            priceLabel.dk_textColorPicker = DKColorTable.shared().picker(withKey: AppConst.Color.main)

            statuslb.backgroundColor = model.result   ? UIColor.init(hexString: "E9573F") : UIColor.init(hexString: "0EAF56")
            statuslb.text =  model.result   ?  "盈" :   "亏"
            titleLabel.text = model.buySell == 1 ? "买入" : "卖出"
            let handleText = [" 未操作 "," 双倍返还 "," 货运 "," 退舱 "]

            if model.handle < handleText.count{
                handleLabel.text = handleText[model.handle]
            }
            
            if model.buySell == -1 && UserModel.share().currentUser?.type == 0 && model.result == false{
                handleLabel.backgroundColor = UIColor.clear
                handleLabel.text = ""
            }else if model.handle == 0{
                handleLabel.backgroundColor = UIColor.init(rgbHex: 0xc2cfd7)
            }else{
                handleLabel.dk_backgroundColorPicker = DKColorTable.shared().picker(withKey: AppConst.Color.main)
            }
        }
    }
}

class HistoryDealVC: BasePageListTableViewController {
    
    var historyModels: [PositionModel] = []
    //MARK: --LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        requestPositionHistroy()
    }
    
    func requestPositionHistroy() {
        

        
    }
    override func didRequest(_ pageIndex: Int) {
       
        if let token = UserDefaults.standard.value(forKey: SocketConst.Key.token) as? String {
            let model = RequestHistroyModel()
            model.token = token
            model.recordPos = pageIndex * 10
            model.requestPath = "/api/trade/user/flightspaces.json"
            HttpRequestManage.shared().postRequestModels(requestModel: model, responseClass: PoHistoryModel.self, reseponse: { (response) in
                
            }) { (error) in
                
            }
        }
        
        
    }
    
   
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = UIStoryboard.init(name: "Deal", bundle: nil).instantiateViewController(withIdentifier: HandlePositionVC.className()) as! HandlePositionVC
        controller.modalPresentationStyle = .custom
        controller.modalTransitionStyle = .crossDissolve
        
        present(controller, animated: true, completion: nil)
        if let model = self.dataSource?[indexPath.row] as? PositionModel{
            print(model.handle)
            if model.handle != 0{
                return
            }

        }
    }
}
