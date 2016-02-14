//
//  ViewController.swift
//  Sieve
//
//  Created by Colin Biafore on 2/5/16.
//  Copyright © 2016 Colin Biafore. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate,
SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate {
    
    // View attributes
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var valueLabelView: UIScrollView!
    @IBOutlet weak var primeView: UITextView!
    
    var player: SPTAudioStreamingController?
    
    // Stores all value labels and buttons  in the valueLabelView
    var labelArray = [UILabel]()
    var buttonArray = [UIButton]()
    

    
    // Global random color attribute
    var randomColor = UIColor()
    
    // Array to keep track of which values need tending to by the timedViewUpdate
    var timerArray = [Int]()
    
    var primeArray = [Int]()
    var anotherPrimeArray = [Int]()
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Make this class a delegate for the text field
        textField.delegate = self
        goButton.enabled = false
    }
    
    
    // this function initiates the SOE visualization
    @IBAction func go(sender: UIButton) {
        textField.enabled = false
        handleNewSession()
        resetVis()
        let startInterval = initVis()
        implementSieve(startInterval, maxValue: Double(textField.text!)!)
        
        
    }
    
    func handleNewSession() {
        let auth: SPTAuth = SPTAuth.defaultInstance()
        
        let rand = arc4random_uniform(18)
        
        if player == nil {
            player = SPTAudioStreamingController(clientId: auth.clientID!)
            player!.playbackDelegate = self
            player!.diskCache = SPTDiskCache(capacity: 1024 * 1024 * 64)
        }
        
        player!.loginWithSession(auth.session, callback: {(error: NSError?) ->Void in
            if error != nil {
                NSLog("*** Enabling playback got error: %@",error!)
                return
            }
        })
        
        var playlistReq: NSURLRequest!
        
        do {
            playlistReq = try SPTPlaylistSnapshot.createRequestForPlaylistWithURI(NSURL(string: "spotify:user:129712045:playlist:03zom8Z9pRHqOMRupGMjML")!,
                accessToken: auth.session.accessToken)
        } catch _ {
            
        }

        SPTRequest.sharedHandler().performRequest(playlistReq!,
            callback: {(error: NSError?, response: NSURLResponse!, data: NSData!) -> Void in
                if error != nil {
                    NSLog("*** Failed to get playlist %@",error!)
                    return
                }
                
                var playlistSnapshot: SPTPlaylistSnapshot!
                
                do {
                    playlistSnapshot = try SPTPlaylistSnapshot(fromData: data, withResponse: response)
                } catch _ {
                    
                }
                
                self.player!.playURIs(playlistSnapshot.firstTrackPage.items, fromIndex: Int32(rand), callback: nil)
        })
        
        
        
    }
    
    // ************/ Sieve of Eratosthenes Algorithm \*****************
    // O(nlog(logn))
    func implementSieve(start: Double, maxValue: Double) {
        
        // maxValue + 1 to keep indices aligned properly with labelArray
        var A = [Bool](count: Int(maxValue + 1), repeatedValue: true)
        randomColor = getRandomColor()
        var interval = start
        
        for i in 2...Int(sqrt(maxValue)) {
            if A[i] {
                timerArray.append(i)
                primeArray.append(i)
                anotherPrimeArray.append(i)
                timedViewUpdate(interval, selector: "changeLabelColor")
                timedViewUpdate(interval, selector: "addPrime")
                interval += 1
                var j = i * i
                while j < A.count {
                    A[j] = false
                    timerArray.append(j)
                    
                    // Calls changeLabelColor() every .1 seconds to change label background color
                    timedViewUpdate(interval, selector: "changeLabelColor")
                    interval += 0.1
                    
                    j += i
                }
            }
        }
        
        // color the remaining primes
        let remaining = Int(sqrt(maxValue)) + 1
        randomColor = getRandomColor()
        for i in remaining...Int(maxValue) {
            if A[i] {
                timerArray.append(i)
                primeArray.append(i)
                anotherPrimeArray.append(i)
                timedViewUpdate(interval, selector: "changeLabelColor")
                timedViewUpdate(interval, selector: "addPrime")
                interval += 0.5
            }
        }
        
        timedViewUpdate(interval, selector: "addMusicButtons")

        
    }
    
    // Add buttons 
    func addMusicButtons() {
        
        var primeLabelArray = [UILabel]()
        
        for i in 2..<labelArray.count {
            let currentValue = Int(labelArray[i].text!)!
            if currentValue == anotherPrimeArray[0] {
                primeLabelArray.append(labelArray[i])
                anotherPrimeArray.removeFirst()
                if anotherPrimeArray.isEmpty {
                    break
                }
            }
        }
        
        for label in primeLabelArray {
            let xCenter = label.center.x
            let yCenter = label.center.y
            let labelBounds = label.bounds
            let maxX = labelBounds.maxX
            let maxY = labelBounds.maxY
            createButton(xCenter, yCenter: yCenter, xSize: maxX, ySize: maxY, value: Int(label.text!)!)
        }
        
        textField.enabled = true
    }
    
    // Adds a prime number to the primeView
    func addPrime() {
        let primeString = String(primeArray[0])
        primeArray.removeFirst()
        primeView.text! += "\(primeString)    "
        
    }
    
    // Called by NSTimer on a specified interval in implementSieve
    func changeLabelColor() {
        let currentValue = timerArray[0]
        labelArray[currentValue].backgroundColor = randomColor
        timerArray.removeFirst()
        if !timerArray.isEmpty && timerArray[0] < currentValue {
            randomColor = getRandomColor()
        }
    }
    
    // Remove everything from the valueLabelView, primeView, and reset the arrays
    func resetVis() {
        goButton.enabled = false
        labelArray.removeAll()
        timerArray.removeAll()
        primeView.text = ""
        for subview in valueLabelView.subviews {
            subview.removeFromSuperview()
        }
        
    }
    
    // Starts visualization
    func initVis() -> Double {
        
        // set label sizes for variables screen sizes
        let maxValue = Double(textField.text!)!
        let xSize = valueLabelView.bounds.maxX / CGFloat(10)
        let ySize = xSize
        var xCenter = CGFloat(xSize / 2)
        var yCenter = CGFloat(ySize / 2)
        
        // for NSTimer
        var interval = 0.05
        
        // Keep labelArray indices aligned with A 
        let dudLabel = UILabel()
        labelArray.append(dudLabel)
        labelArray.append(dudLabel)
        
        // Allows valueLabelView to scroll
        valueLabelView.contentSize = CGSize(width: xSize * 10,
            height: (CGFloat(maxValue) * ySize) / 10)
        
        // Create labels at the correct coordinates in the valueLabelView
        for i in 2...Int(maxValue) {
            timerArray.append(i)
            createLabel(xCenter, yCenter: yCenter, xSize: xSize, ySize: ySize, value: i)
            xCenter += xSize
            timedViewUpdate(interval, selector: "addLabelToView")
            interval += 0.05
            if i % 10 == 0 {
                xCenter = xSize / 2
                yCenter += ySize
            }
        }
        
        // return interval so implementSieve knows what interval to start at
        return interval
    }
    
    func createButton(xCenter: CGFloat, yCenter: CGFloat, xSize: CGFloat, ySize: CGFloat, value: Int) {
        
        let button = UIButton(frame: CGRectMake(0,0, xSize, ySize))
        button.center = CGPointMake(xCenter, yCenter)
        
        if value == 2 {
            button.addTarget(self, action: "playPause", forControlEvents: UIControlEvents.TouchUpInside)
            button.backgroundColor = UIColor.blackColor()
            button.setImage(UIImage(named: "playButton"), forState: .Normal)
        }
        else {
            button.addTarget(self, action: "pickRandom", forControlEvents: UIControlEvents.TouchUpInside)
        }

        
        buttonArray.append(button)
        valueLabelView.addSubview(button)
    }
    
    func playPause() {
        player!.setIsPlaying(!self.player!.isPlaying, callback: nil)
    }
    
    func pickRandom() {
        handleNewSession()
    }
    
    // Adds a new label to the labelArray at the correct coordinates
    func createLabel(xCenter: CGFloat, yCenter: CGFloat, xSize: CGFloat,
        ySize: CGFloat, value: Int)
    {
        let label = UILabel(frame: CGRectMake(0,0,xSize,ySize))
        label.font = UIFont(name: "DamascusBold", size:  12)
        label.opaque = true
        
        if value < 11 {
            label.center = CGPointMake(xSize + xCenter, yCenter)
        } else {
            label.center = CGPointMake(xCenter, yCenter)
        }
        label.textAlignment = NSTextAlignment.Center
        label.text = String(value)
        
        labelArray.append(label)
    }
    
    // Called by NSTimer on a specified interval in initVis
    func addLabelToView() {
        let currentValue = timerArray[0]
        timerArray.removeFirst()
        valueLabelView.addSubview(labelArray[currentValue])
    }
    
    func timedViewUpdate(interval: Double, selector: Selector) {
        NSTimer.scheduledTimerWithTimeInterval(interval, target: self, selector: selector, userInfo: nil, repeats: false)
    }
    
    // If the input is not an integer between 1 and 10,000, throw an error alert
    func invalidInputAlert() {
        let message = "Input must be an integer value between 4 and 500!"
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: {
            self.textField.text = ""
            self.goButton.enabled = false
        })
    }
    
    func getRandomColor() -> UIColor {
        
        let randomRed: CGFloat = CGFloat(drand48())
        let randomGreen: CGFloat = CGFloat(drand48())
        let randomBlue: CGFloat = CGFloat(drand48())
        
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 0.5)
    }
    
    // MARK: UITextFieldDelegate
    func textFieldDidBeginEditing(textField: UITextField) {
        goButton.enabled = false
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        checkInput()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    // Make sure the input is an integer greater than 1, otherwise throw an alert
    func checkInput() {
        let text = textField.text ?? ""
        if let inputValue = Int(text) {
            if inputValue < 4 || inputValue > 500 {
                invalidInputAlert()
            } else {
                goButton.enabled = true
            }
        } else {
            invalidInputAlert()
        }
    }
    
    
} // end ViewController class

