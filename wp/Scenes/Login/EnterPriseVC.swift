
//
//  RegisterVC.swift
//  wp
//
//  Created by 木柳 on 2016/12/25.
//  Copyright © 2016年 com.yundian. All rights reserved.
//

import UIKit
import SVProgressHUD
import DKNightVersion
class EnterPriseVC : BaseTableViewController {
    
    @IBOutlet weak var phoneText: UITextField!
    //验证码
    @IBOutlet weak var codeText: UITextField!
    @IBOutlet weak var codeBtn: UIButton!
    //公司名称
    @IBOutlet weak var companyNameTf: UITextField!
    //公司组织机构代码
    @IBOutlet weak var companyNubTf: UITextField!
    //详细地址
    @IBOutlet weak var detailTF: UITextField!
    //邮件地址
    @IBOutlet weak var emailTF: UITextField!
    //下一步
    @IBOutlet weak var nextBtn: UIButton!
    //密码
    @IBOutlet weak var pwdText: UITextField!
    private var timer: Timer?
    //上传营业执照扫面件
    @IBOutlet weak var uploadLicense: UIButton!
    //上传营业执照扫面件
    @IBOutlet weak var uploadCard: UIButton!
    private var codeTime = 60
    //注册btn
    @IBOutlet weak var registBtn: UIButton!
    private var voiceCodeTime = 60
    
    //MARK: --LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideTabBarWithAnimationDuration()
        translucent(clear: false)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SVProgressHUD.dismiss()
    }
    //MARK: --DATA
    
    
    //获取验证码
    @IBAction func changeCodePicture(_ sender: UIButton) {
        if checkoutText(){
            _ = UserModel.share().forgetPwd ? 1:0
            SVProgressHUD.showProgressMessage(ProgressMessage: "请稍候...")
            
            AppDataHelper.instance().getVailCode(phone: phoneText.text!, type: 0, reseponse: { [weak self](result) in
                if let strongSelf = self{
                    SVProgressHUD.dismiss()
                    SVProgressHUD.showSuccess(withStatus: "验证码已发送")
                    let dic  = result as! Dictionary<String, Any>
                    UserModel.share().codeToken = dic["codeToken"] as! String
                    strongSelf.codeBtn.isEnabled = false
                    strongSelf.timer = Timer.scheduledTimer(timeInterval: 1, target: strongSelf, selector: #selector(strongSelf.updatecodeBtnTitle), userInfo: nil, repeats: true)
                }
                
                
            })
        }

//            AppAPIHelper.commen().verifycode(verifyType: Int64(type), phone: phoneText.text!, complete: { [weak self](result) -> ()? in
//                SVProgressHUD.dismiss()
//                if let strongSelf = self{
//                    if let resultDic: [String: AnyObject] = result as? [String : AnyObject]{
//                        if let token = resultDic[SocketConst.Key.vToken]{
//                            UserModel.share().codeToken = token as! String
//                        }
//                        if let timestamp = resultDic[SocketConst.Key.timestamp]{
//                            UserModel.share().timestamp = timestamp as! Int
//                        }
//                    }
//                    strongSelf.codeBtn.isEnabled = false
//                    strongSelf.timer = Timer.scheduledTimer(timeInterval: 1, target: strongSelf, selector: #selector(strongSelf.updatecodeBtnTitle), userInfo: nil, repeats: true)
//                }
//                return nil
//                }, error: errorBlockFunc())
//        }
    }
    deinit {
        UserModel.share().companyImg = ""
        UserModel.share().identityCardBack = ""
        UserModel.share().identityCardJust = ""
        ShareModel.share().removeObserver(self, forKeyPath: "CompanyUrl")
        ShareModel.share().removeObserver(self, forKeyPath: "PersonUrl")
      
    }
    func updatecodeBtnTitle() {
        if codeTime == 0 {
            codeBtn.isEnabled = true
            codeBtn.setTitle("重新发送", for: .normal)
            codeTime = 60
            timer?.invalidate()
            codeBtn.dk_backgroundColorPicker = DKColorTable.shared().picker(withKey: AppConst.Color.main)
            return
        }
        codeBtn.isEnabled = false
        codeTime = codeTime - 1
        let title: String = "\(codeTime)秒后重新发送"
        codeBtn.setTitle(title, for: .normal)
        codeBtn.backgroundColor = UIColor.init(rgbHex: 0xCCCCCC)
    }
    //获取声音验证码
    
    @IBAction func requestVoiceCode(_ sender: UIButton) {
        if checkoutText(){
            
        }
    }
   
    
    //注册
    @IBAction func registerBtnTapped(_ sender: Any) {
        if checkoutText(){
            if checkTextFieldEmpty([phoneText,pwdText,codeText,emailTF,companyNubTf,companyNameTf]){
                UserModel.share().code = codeText.text
                UserModel.share().phone = phoneText.text
                register()
            }
        }
    }
    
    func register() {
      
        
        if !checkTextFieldEmpty([phoneText,codeText,codeText,companyNameTf,emailTF,detailTF,companyNubTf]){
        
            return
        }
        if UserModel.share().companyImg == "" {
            SVProgressHUD.showError(withStatus: "请上传企业营业执照")
            return
        }
        if UserModel.share().identityCardBack == "" {
            SVProgressHUD.showError(withStatus: "请上传身份证正面")
            return
        }
        if UserModel.share().identityCardJust ==  "" {
            SVProgressHUD.showError(withStatus: "请上传身份证反面")
            return
        }
         let model =  RegistCompanyModel()
         model.phoneNum = phoneText.text!
         model.phoneCode = codeText.text!
         model.password = pwdText.text!
         model.fullName = companyNameTf.text!
         model.email = emailTF.text!
         model.address = detailTF.text!
          model.codeToken = UserModel.share().codeToken
         model.identityCard = companyNubTf.text!
         model.requestPath = "/api/user/enterprise/register.json"
         model.businessLicense = UserModel.share().companyImg
         model.identityCardBack = UserModel.share().identityCardBack
         model.identityCardJust = UserModel.share().identityCardJust
        HttpRequestManage.shared().postRequestModelWithJson(requestModel: model, reseponse: { (result) in
            let datadic = result as? Dictionary<String,AnyObject>
            
            if let _ =  datadic?["token"]{
                
                UserDefaults.standard.setValue(datadic?["token"] as! String, forKey: SocketConst.Key.token)
                SVProgressHUD.showSuccess(withStatus: "注册成功")
                UserInfoVCModel.share().upateUserInfo(userObject: result)
                UserModel.share().companyImg = ""
                UserModel.share().identityCardBack = ""
                UserModel.share().identityCardJust = ""
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: AppConst.NotifyDefine.UpdateUserInfo), object: nil)
                
            }
        }) { (error) in
            
        }
       
        //注册
//        SVProgressHUD.showProgressMessage(ProgressMessage: "注册中...")
//        let password = ((pwdText.text! + AppConst.sha256Key).sha256()+UserModel.share().phone!).sha256()
//        AppAPIHelper.login().register(phone: UserModel.share().phone!, code: UserModel.share().code!, pwd: password, complete: { [weak self](result) -> ()? in
//            SVProgressHUD.dismiss()
//            if result != nil {
//                UserModel.share().fetchUserInfo(phone: self?.phoneText.text ?? "", pwd: self?.pwdText.text ?? "")
//            }else{
//                SVProgressHUD.showErrorMessage(ErrorMessage: "注册失败，请稍后再试", ForDuration: 1, completion: nil)
//            }
//            return nil
//            }, error: errorBlockFunc())
        
    }
  
    func registSuccess(){
        
        self.dismissController()
    }
    
    func checkoutText() -> Bool {
        if checkTextFieldEmpty([phoneText]) {
            if isTelNumber(num: phoneText.text!) == false{
                SVProgressHUD.showErrorMessage(ErrorMessage: "手机号格式错误", ForDuration: 1, completion: nil)
                return false
            }
            return true
        }
        return false
    }
    
     @IBAction func uploadImg(_ sender: Any) {
        let btn =  sender as! UIButton
        
                ShareModel.share().chooseUploadImg = btn.tag
        
                self.performSegue(withIdentifier: "uploadImg", sender: nil)
    }

    //MARK: --UI
    func initUI() {
      
        registBtn.dk_backgroundColorPicker = DKColorTable.shared().picker(withKey: AppConst.Color.main)
        codeBtn.dk_backgroundColorPicker = DKColorTable.shared().picker(withKey: AppConst.Color.main)
        uploadCard.dk_backgroundColorPicker = DKColorTable.shared().picker(withKey: AppConst.Color.main)
        uploadLicense.dk_backgroundColorPicker = DKColorTable.shared().picker(withKey: AppConst.Color.main)
        ShareModel.share().addObserver(self, forKeyPath: "CompanyUrl", options: .new, context: nil)
        ShareModel.share().addObserver(self, forKeyPath: "PersonUrl", options: .new, context: nil)
        
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "CompanyUrl" {
         
            
        }
        if keyPath == "PersonUrl" {
            
            
        }
    }
    
    
}
