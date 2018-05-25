//
//  GameViewController.swift
//  Pointers
//
//  Created by Matheus Garcia on 21/05/18.
//  Copyright © 2018 Matheus Garcia. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit
import AVFoundation

class GameViewController: UIViewController {

    var sceneView: SCNView!
    var scene: SCNScene!

    var hourPointer: SCNNode!
    var minutePointer: SCNNode!
    var secondPointer: SCNNode!
    var textNode: SCNNode!

    var doorNode: SCNNode!
    var perchNode: SCNNode!

    let maxValue = 60
    let maxHourValue = 12

    var timer = Timer()

    var currentTime = CurrentTime()

    var cucoSound: SCNAudioSource!
    var cuSound: SCNAudioSource!

    var seconds:Int = 00 {
        didSet {
            DispatchQueue.main.async {
                self.updateTime()
            }
        }
    }
    var minutes:Int = 00 {
        didSet {
            DispatchQueue.main.async {
                self.updateTime()
            }
        }
    }
    var hour:Int = 00 {
        didSet {
            DispatchQueue.main.async {
                self.updateTime()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupHour()
        setupScene()
        setupNodes()
        setupSound()
        startTimer()

        startPosition()
        rotate()

        openDoor()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(willEnterForeground(_:)),
                                               name: .UIApplicationWillEnterForeground,
                                               object: nil)
    }

    deinit {
        // make sure to remove the observer when this view controller is dismissed/deallocated

        NotificationCenter.default.removeObserver(self)
    }

    func setupHour() {

        currentTime.updateHour()

        seconds = currentTime.second
        minutes = currentTime.minute
        hour = currentTime.hour
    }

    func setupScene() {
        sceneView = self.view as! SCNView
        scene = SCNScene(named: "art.scnassets/MainScene.scn")
        sceneView.scene = scene
    }

    func setupNodes() {

        if let scene = sceneView.scene {

            let hourNodeName = "hourNode"
            hourPointer = scene.rootNode.childNode(withName: hourNodeName, recursively: true)

            let minuteNodeName = "minuteNode"
            minutePointer = scene.rootNode.childNode(withName: minuteNodeName, recursively: true)

            let secondNodeName = "secondNode"
            secondPointer = scene.rootNode.childNode(withName: secondNodeName, recursively: true)

            let textNodeName = "text"
            textNode = scene.rootNode.childNode(withName: textNodeName, recursively: true)

            let doorNodeName = "door"
            doorNode = scene.rootNode.childNode(withName: doorNodeName, recursively: true)

            let perchNodeName = "perch"
            perchNode = scene.rootNode.childNode(withName: perchNodeName, recursively: true)
        }
    }

    func setupSound() {

        cucoSound = SCNAudioSource(fileNamed: "cuco.mp3")!
        cucoSound.load()

        cuSound = SCNAudioSource(fileNamed: "cu.mp3")!
        cuSound.load()
    }

    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateCounting), userInfo: nil, repeats: true)
    }

    @objc func updateCounting() {

        updateSeconds()

        if let textTimer = textNode.geometry as? SCNText {
            textTimer.string = String(format:"%02i:%02i:%02i", hour, minutes, seconds)
        }
    }

    func updateSeconds () {
        seconds = seconds + 1

        if seconds == maxValue {
            seconds = 0
            updateMinutes()
        }
    }

    func updateMinutes() {
        minutes = minutes + 1

        let halfHour = 30

        if minutes == halfHour {
            playCuSound()
        } else if minutes == maxValue {
            minutes = 0
            updateHour()
        }
    }

    func updateHour() {
        hour = hour + 1

        playCucoSound()

        if hour == maxHourValue {
            hour = 0
        }
    }

    func updateTime() {
        if let textTimer = textNode.geometry as? SCNText {
            textTimer.string = String(format:"%02i:%02i:%02i", hour, minutes, seconds)
        }
    }

    func playCucoSound () {

        let times = hour

        let action = SCNAction.playAudio(cucoSound, waitForCompletion: true)
        hourPointer.runAction(SCNAction.repeat(action, count: times))
    }

    func playCuSound () {

        let action = SCNAction.playAudio(cuSound, waitForCompletion: true)
        minutePointer.runAction(action)
    }

    func startPosition() {

        let fullRotation: CGFloat = (2.0 * .pi) * -1

        var inicialSecond: CGFloat = fullRotation / 60
        inicialSecond = inicialSecond * CGFloat(seconds)
        secondPointer.runAction(SCNAction.rotateBy(x: 0, y: 0, z: inicialSecond, duration: 0))

        var inicialMinute: CGFloat = fullRotation / 60
        inicialMinute = inicialMinute * CGFloat(minutes)
        minutePointer.runAction(SCNAction.rotateBy(x: 0, y: 0, z: inicialMinute, duration: 0))

        var inicialHour: CGFloat = fullRotation / 12
        inicialHour = inicialHour * CGFloat(hour)
        hourPointer.runAction(SCNAction.rotateBy(x: 0, y: 0, z: inicialHour, duration: 0))
    }

    func rotate() {

        let secondDuration: Double = 60
        let minuteDuration: Double = secondDuration * 60
        let hourDuration: Double = minuteDuration * 12

        let zAngle: CGFloat = (2.0 * .pi) * -1

        hourPointer.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 0, z: zAngle , duration: hourDuration)))

        minutePointer.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 0, z: zAngle, duration: minuteDuration)))

        secondPointer.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 0, z: zAngle, duration: secondDuration)))
    }

    func openDoor() {

        let duration: Double = 1
        let angleMult: CGFloat = 3 / 4
        let yAngle: CGFloat = (.pi * -1) * angleMult

        doorNode.runAction(SCNAction.rotateBy(x: 0, y: yAngle, z: 0, duration: duration))

        let perchDuration: Double = 1.5
        let zSpace: CGFloat = 3

        perchNode.runAction(SCNAction.moveBy(x: 0, y: 0, z: zSpace, duration: perchDuration))
    }

    @objc func willEnterForeground(_ notification: NSNotification!) {

        setupHour()
        //TO-DO: Adjust position of the pointers
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
}
