import UIKit
import CoreBluetooth
import QuartzCore
import VerticalSlider

final class SerialViewController: UIViewController, UITextFieldDelegate, BluetoothSerialDelegate, Storyboardable {
    
    
//MARK: IBOutlets
    
    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var locationSlider: VerticalSlider!
    @IBOutlet weak var messageField: UITextField!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint! // used to move the textField up when the keyboard is present
    @IBOutlet weak var barButton: UIBarButtonItem!
    @IBOutlet weak var navItem: UINavigationItem!
    
    var locationOfTheSystem = 80
    
    func stepToCm(step: Int) -> Int{
        //4000
        //1 step 2 mm
        var singleStep = 2
        
        return singleStep * step
    }
    
    func cmToSteps(cm: Int) -> Int{
        var distanceInMillimeters = cm * 100
        
        return distanceInMillimeters / 2;
    }
    
//MARK: Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationSlider.isUserInteractionEnabled = false
        
        let defaults = UserDefaults.standard
        if  defaults.integer(forKey: "location") != 0 {
           locationOfTheSystem = defaults.integer(forKey: "location")
        }
           positionLabel.text = String (263.5 + Double(defaults.integer(forKey: "location"))) + " cm"
        
        print("location : ")
        print(locationOfTheSystem)
        
        // init serial
        serial = BluetoothSerial(delegate: self)
        
        locationSlider.value = 40
        locationSlider.minimumValue = 0
        locationSlider.maximumValue = 80
        
        reloadView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(SerialViewController.reloadView), name: NSNotification.Name(rawValue: "reloadStartViewController"), object: nil)
        
        // we want to be notified when the keyboard is shown (so we can move the textField up)
        NotificationCenter.default.addObserver(self, selector: #selector(SerialViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SerialViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // to dismiss the keyboard if the user taps outside the textField while editing
        let tap = UITapGestureRecognizer(target: self, action: #selector(SerialViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        // style the bottom UIView
        bottomView.layer.masksToBounds = false
        bottomView.layer.shadowOffset = CGSize(width: 0, height: -1)
        bottomView.layer.shadowRadius = 0
        bottomView.layer.shadowOpacity = 0.5
        bottomView.layer.shadowColor = UIColor.gray.cgColor
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let defaults = UserDefaults.standard
        positionLabel.text = String (263.5 + Double(defaults.integer(forKey: "location"))) + " cm"
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        // animate the text field to stay above the keyboard
        var info = (notification as NSNotification).userInfo!
        let value = info[UIKeyboardFrameEndUserInfoKey] as! NSValue
        let keyboardFrame = value.cgRectValue
        
        //TODO: Not animating properly
        UIView.animate(withDuration: 1, delay: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
            self.bottomConstraint.constant = keyboardFrame.size.height
            }, completion: { Bool -> Void in
        })
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        // bring the text field back down..
        UIView.animate(withDuration: 1, delay: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
            self.bottomConstraint.constant = 0
        }, completion: nil)
    }
    
    @objc func reloadView() {
        // in case we're the visible view again
        serial.delegate = self
        
        if serial.isReady {
            navItem.title = serial.connectedPeripheral!.name
            barButton.title = "Disconnect"
            barButton.tintColor = UIColor.red
            barButton.isEnabled = true
        } else if serial.centralManager.state == .poweredOn {
            navItem.title = "Smart Ceiling"
            barButton.title = "Connect"
            barButton.tintColor = view.tintColor
            barButton.isEnabled = true
        } else {
            navItem.title = "Smart Ceiling"
            barButton.title = "Connect"
            barButton.tintColor = view.tintColor
            barButton.isEnabled = false
        }
        
        locationSlider.value = Float(locationOfTheSystem)
    }
    
    

//MARK: BluetoothSerialDelegate
    
    func serialDidReceiveString(_ message: String) {
        // add the received text to the textView, optionally with a line break at the end
    
    }
    
    func serialDidDisconnect(_ peripheral: CBPeripheral, error: NSError?) {
        reloadView()
        dismissKeyboard()
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud?.mode = MBProgressHUDMode.text
        hud?.labelText = "Disconnected"
        hud?.hide(true, afterDelay: 1.0)
    }
    
    func serialDidChangeState() {
        reloadView()
        if serial.centralManager.state != .poweredOn {
            dismissKeyboard()
            let hud = MBProgressHUD.showAdded(to: view, animated: true)
            hud?.mode = MBProgressHUDMode.text
            hud?.labelText = "Bluetooth turned off"
            hud?.hide(true, afterDelay: 1.0)
        }
    }
    
    
//MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if !serial.isReady {
            let alert = UIAlertController(title: "Not connected", message: "Please connect to the smart ceiling system", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: { action -> Void in self.dismiss(animated: true, completion: nil) }))
            present(alert, animated: true, completion: nil)
            messageField.resignFirstResponder()
            return true
        }
        
        
        var msg = messageField.text!
        var msgInCm = Int(msg)
        var msgInSteps = cmToSteps(cm: msgInCm!)
        
        // send the message and clear the textfield
        
        print(locationOfTheSystem)
        
        print("message : \(msgInCm!)")
        
        
        var upLimit = locationOfTheSystem + msgInCm! <= 80
        
        if (msgInCm! < 0) {
            let downLimit = locationOfTheSystem - abs(msgInCm!) >= 0
        }
            let downLimit = locationOfTheSystem + msgInCm! >= 0
        
        
       
            if (upLimit && downLimit) {
                serial.sendMessageToDevice(String(msgInSteps))
                locationOfTheSystem += msgInCm!
            } else {
                let alert = UIAlertController(title: "Limit Reached", message: "System should be in bounds", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: { action -> Void in self.dismiss(animated: true, completion: nil) }))
                present(alert, animated: true, completion: nil)
                messageField.resignFirstResponder()
            }
        
        /*if (!((locationOfTheSystem + abs(msgInCm!)) > 80) && !((locationOfTheSystem - abs(msgInCm!)) < 0)) {
            serial.sendMessageToDevice(String(msgInSteps))
            locationOfTheSystem += msgInCm!
        } */
        
        print(locationOfTheSystem)
        
        locationSlider.value = Float(locationOfTheSystem)

        messageField.text = ""
        
        let defaults = UserDefaults.standard
        defaults.set(locationOfTheSystem, forKey: "location")
        
        positionLabel.text = String (263.5 + Double(defaults.integer(forKey: "location"))) + " cm"
        
        return true
    }
    
    @objc func dismissKeyboard() {
        messageField.resignFirstResponder()
    }
    
    
//MARK: IBActions

    @IBAction func barButtonPressed(_ sender: AnyObject) {
        if serial.connectedPeripheral == nil {
            performSegue(withIdentifier: "ShowScanner", sender: self)
        } else {
            serial.disconnect()
            reloadView()
        }
    }
}
