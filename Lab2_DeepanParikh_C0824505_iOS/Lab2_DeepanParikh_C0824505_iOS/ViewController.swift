//
//  ViewController.swift
//  Lab2_DeepanParikh_C0824505_iOS
//
//  Created by Deepan Parikh on 24/01/22.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    var iS = [0,0,0,0,0,0,0,0,0]
    var isActive = true
    var user = 1
    
    @IBOutlet weak var crossScore: UILabel!
    @IBOutlet weak var circleScore: UILabel!

    var crossWinSc = 0
    var circleWinSc = 0
    var shake_state = 0
    var shake_pers = false
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let winningpatterns = [[0,1,2],[3,4,5],[6,7,8],[0,4,8],[2,4,6],[0,3,6],[1,4,7],[2,5,8]]
    var count = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        let newGame = NSEntityDescription.insertNewObject(forEntityName: "Lab2", into: context)
        
        
        
        
        let hasLaunchedKey = "HasLaunched"
        let defaults = UserDefaults.standard
        let hasLaunched = defaults.bool(forKey: hasLaunchedKey)
        
        
        if !hasLaunched {
            newGame.setValue(crossWinSc, forKey: "sX")
            newGame.setValue(circleWinSc, forKey: "sO")
            newGame.setValue(user, forKey: "prT")
            newGame.setValue("0,0,0,0,0,0,0,0", forKey: "persistance")
            
            saveCoreData()
            defaults.set(true, forKey: hasLaunchedKey)
        }
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Lab2")
        
        do {
            let results = try context.fetch(request)
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    if let persistance = result.value(forKey: "persistance") {
                        let gamePState = persistance as! String
                        print(gamePState)
                    }
    

                    if let sO = result.value(forKey: "sO") {
                        let s0 = sO as! Int
                        print(s0)
                        circleWinSc = s0
                        circleScore.text = "\(circleWinSc)";
                    }
                    if let prT = result.value(forKey: "prT") {
                        let lastPlayer = prT as! Int
                        print(lastPlayer)
                        user = lastPlayer
                    }
                    if let sX = result.value(forKey: "sX") {
                        let scorex = sX as! Int
                        print(scorex)
                        crossWinSc = scorex
                        crossScore.text = "\(crossWinSc)";
                    }

                }
            }
        } catch {
            print(error)
        }
        
        
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swiped))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        view.addGestureRecognizer(swipeRight)
        
        
        
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swiped))
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
        view.addGestureRecognizer(swipeLeft)
        
      
        
    }
    
        @objc func swiped(gesture: UISwipeGestureRecognizer) {
        let swipeGesture = gesture as UISwipeGestureRecognizer
        switch swipeGesture.direction {
        case UISwipeGestureRecognizer.Direction.left:
            resetBoard()
        case UISwipeGestureRecognizer.Direction.right:
            resetBoard()
        default:
            break
        }
    }
    
        func saveCoreData() {
        do {
            try context.save()
        } catch {
            print(error)
        }
    }
    
    
    @IBAction func btnChange(_ sender: AnyObject) {
        shake_pers = true
        shake_state = sender.tag
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Lab2")
        
       
        if iS[sender.tag-1] == 0 && isActive == true {
            iS[sender.tag-1] = user
            if user == 1 {
                sender.setImage(UIImage(named: "cross.png"), for: UIControl.State())
                user = 2
            } else {
                sender.setImage(UIImage(named: "circle.png"), for: UIControl.State())
                user = 1
            }
        }
        print(iS)
        
        for combination in winningpatterns {
            if iS[combination[0]] != 0 && iS[combination[0]] == iS[combination[1]] && iS[combination[1]] == iS[combination[2]] {
                if iS[combination[0]] == 1 {
                    crossWinSc += 1;
                    crossScore.text = "\(crossWinSc)";
                } else if iS[combination[0]] == 2{
                    circleWinSc += 1;
                    circleScore.text = "\(circleWinSc)";
                }
            
                                isActive = false
                resetBoard()
            }
            
            
            if isActive == true {
                count = 1
                for i in iS {
                    count = i*count
                }
                if count != 0 {
                    resetBoard()
                }
            }
            
            do {
                let results = try context.fetch(request)
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        result.setValue(crossWinSc, forKey: "sX")
                        result.setValue(circleWinSc, forKey: "sO")
                        result.setValue(user, forKey: "prT")
                        let currentState = (iS.map{String($0)}).joined(separator: ",")
                        result.setValue(currentState, forKey: "persistance")
                    }
                }
            } catch {
                print(error)
            }
            
            saveCoreData()
            
        }
    }
    
    
    func resetBoard() {
        iS = [0,0,0,0,0,0,0,0,0]
        isActive = true
        user = 1
        for i in 1...9 {
            let button = view.viewWithTag(i) as! UIButton
            button.setImage(nil, for: UIControl.State())
        }
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if event?.subtype == UIEvent.EventSubtype.motionShake {
            if shake_pers {
                let button = view.viewWithTag(shake_state) as! UIButton
                button.setImage(nil, for: UIControl.State())
                iS[shake_state-1] = 0
                if user == 1 {
                    user = 2
                } else {
                    user = 1
                }
                shake_pers = false
            }
        }
    }
        
   
}


