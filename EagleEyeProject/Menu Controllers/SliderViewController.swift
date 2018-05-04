import UIKit
import InteractiveSideMenu

class SliderViewController: UIViewController, SideMenuItemContent, Storyboardable {
    
    var location = 0
    
    @IBOutlet weak var positionLabel: UILabel!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let defaults = UserDefaults.standard
        positionLabel.text = String (263.5 + Double(defaults.integer(forKey: "location")))
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        let defaults = UserDefaults.standard
        positionLabel.text = String (263.5 + Double(defaults.integer(forKey: "location")))
    }
    
    func stepToCm(step: Int) -> Double{
        //4000
        //1 step 2.25 mm
        var singleStep = 2.25
        return singleStep * Double(step)
    }
    
    // Show side menu on menu button click
    @IBAction func openMenu(_ sender: UIButton) {
        showSideMenu()
    }
}
