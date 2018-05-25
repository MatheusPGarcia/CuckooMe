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

    var leftDoorNode: SCNNode!
    var leftCucoNode: SCNNode!
    var leftPerchNode: SCNNode!

    var rightDoorNode: SCNNode!
    var rightCucoNode: SCNNode!
    var rightPerchNode: SCNNode!

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

//            let secondNodeName = "secondNode"
//            secondPointer = scene.rootNode.childNode(withName: secondNodeName, recursively: true)

            let textNodeName = "text"
            textNode = scene.rootNode.childNode(withName: textNodeName, recursively: true)

            let leftDoorNodeName = "leftDoor"
            leftDoorNode = scene.rootNode.childNode(withName: leftDoorNodeName, recursively: true)

            let rightDoorNodeName = "rightDoor"
            rightDoorNode = scene.rootNode.childNode(withName: rightDoorNodeName, recursively: true)

            let leftCucoNodeName = "leftCuco"
            leftCucoNode = scene.rootNode.childNode(withName: leftCucoNodeName, recursively: true)

            let leftPerchNodeName = "leftPerch"
            leftPerchNode = scene.rootNode.childNode(withName: leftPerchNodeName, recursively: true)

            let rightCucoNodeName = "rightCuco"
            rightCucoNode = scene.rootNode.childNode(withName: rightCucoNodeName, recursively: true)

            let rightPerchNodeName = "rightPerch"
            rightPerchNode = scene.rootNode.childNode(withName: rightPerchNodeName, recursively: true)
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
            cucoAnimation(type: "minute")
        } else if minutes == maxValue {
            minutes = 0
            updateHour()
        }
    }

    func updateHour() {
        hour = hour + 1

        cucoAnimation(type: "hour")

        if hour == maxHourValue {
            hour = 0
        }
    }

    func updateTime() {
        if let textTimer = textNode.geometry as? SCNText {
            textTimer.string = String(format:"%02i:%02i:%02i", hour, minutes, seconds)
        }
    }

    func startPosition() {

        let fullRotation: CGFloat = (2.0 * .pi) * -1

//        var inicialSecond: CGFloat = fullRotation / 60
//        inicialSecond = inicialSecond * CGFloat(seconds)
//        secondPointer.runAction(SCNAction.rotateBy(x: 0, y: 0, z: inicialSecond, duration: 0))

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

//        secondPointer.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 0, z: zAngle, duration: secondDuration)))
    }

    func cucoAnimation(type: String) {

        let doorOpeningDuration: Double = 1
        let angleMult: CGFloat = 3 / 4
        let yAngle: CGFloat = (.pi * -1) * angleMult

        let openLeftDoorAction = SCNAction.rotateBy(x: 0, y: yAngle, z: 0, duration: doorOpeningDuration)
        leftDoorNode.runAction(openLeftDoorAction)

        let openRightDoorAction = SCNAction.rotateBy(x: 0, y: -yAngle, z: 0, duration: doorOpeningDuration)
        rightDoorNode.runAction(openRightDoorAction)

        let goingOutDuration: Double = 1.5
        let zSpace: CGFloat = 3

        let cucoAction = SCNAction.moveBy(x: 0, y: 0, z: zSpace, duration: goingOutDuration)
        let perchAction = SCNAction.moveBy(x: 0, y: 0, z: zSpace, duration: goingOutDuration)

        leftCucoNode.runAction(cucoAction)
        leftPerchNode.runAction(perchAction) {

            var timesReference = 1
            var soundReference = self.cuSound

            if type == "hour" {
                timesReference = self.hour
                soundReference = self.cucoSound
            }

            let times = timesReference
            let sound = soundReference

            let leanDuration = 0.5

            let angleMult: CGFloat = 1 / 4
            let angle: CGFloat = (.pi * -1) * angleMult

            let leanAction = SCNAction.rotateBy(x: -angle, y: 0, z: 0, duration: leanDuration)
            let cucoSound = SCNAction.playAudio(sound!, waitForCompletion: false)
            let unleanAction = SCNAction.rotateBy(x: angle, y: 0, z: 0, duration: leanDuration)

            let animationsArray = [leanAction, cucoSound, unleanAction]
            let animationsSequence = SCNAction.sequence(animationsArray)

            self.leftCucoNode.runAction(SCNAction.repeat(animationsSequence, count: times), completionHandler: {

                let uncucoAction = SCNAction.moveBy(x: 0, y: 0, z: -zSpace, duration: goingOutDuration)
                let unperchAction = SCNAction.moveBy(x: 0, y: 0, z: -zSpace, duration: goingOutDuration)

                self.leftCucoNode.runAction(uncucoAction)
                self.leftPerchNode.runAction(unperchAction)

                let waitAction = SCNAction.wait(duration: 0.5)
                let closeDoorAction = SCNAction.rotateBy(x: 0, y: -yAngle, z: 0, duration: doorOpeningDuration)

                let animationsSequence = [waitAction, closeDoorAction]
                let sequence = SCNAction.sequence(animationsSequence)

                self.leftDoorNode.runAction(sequence)
            })
        }

        rightCucoNode.runAction(cucoAction)
        rightPerchNode.runAction(perchAction) {

            var timesReference = 1
            var soundReference = self.cuSound

            if type == "hour" {
                timesReference = self.hour
                soundReference = self.cucoSound
            }

            let times = timesReference
            let sound = soundReference

            let leanDuration = 0.5

            let angleMult: CGFloat = 1 / 4
            let angle: CGFloat = (.pi * -1) * angleMult

            let leanAction = SCNAction.rotateBy(x: -angle, y: 0, z: 0, duration: leanDuration)
            let cucoSound = SCNAction.playAudio(sound!, waitForCompletion: false)
            let unleanAction = SCNAction.rotateBy(x: angle, y: 0, z: 0, duration: leanDuration)

            let animationsArray = [leanAction, cucoSound, unleanAction]
            let animationsSequence = SCNAction.sequence(animationsArray)

            self.rightCucoNode.runAction(SCNAction.repeat(animationsSequence, count: times), completionHandler: {

                let uncucoAction = SCNAction.moveBy(x: 0, y: 0, z: -zSpace, duration: goingOutDuration)
                let unperchAction = SCNAction.moveBy(x: 0, y: 0, z: -zSpace, duration: goingOutDuration)

                self.rightCucoNode.runAction(uncucoAction)
                self.rightPerchNode.runAction(unperchAction)

                let waitAction = SCNAction.wait(duration: 0.5)
                let closeDoorAction = SCNAction.rotateBy(x: 0, y: yAngle, z: 0, duration: doorOpeningDuration)

                let animationsSequence = [waitAction, closeDoorAction]
                let sequence = SCNAction.sequence(animationsSequence)

                self.rightDoorNode.runAction(sequence)
            })
        }
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
