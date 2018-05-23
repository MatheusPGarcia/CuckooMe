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

    var seconds: Int = 0
    var minutes: Int = 0
    var hour: Int = 0
    let maxValue = 60
    let maxHourValue = 12

    var timer = Timer()

    var cucoSound: SCNAudioSource!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupScene()
        setupNodes()
        setupSound()
        startTimer()

        rotate()
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
        }
    }

    func setupSound() {

        cucoSound = SCNAudioSource(fileNamed: "cuco.mp3")!
        cucoSound.load()

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

    func startTimer() {
        seconds = 0
        minutes = 0
        hour = 0

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

        if minutes == maxValue {
            minutes = 0
            updateHour()
        }
    }

    func updateHour() {
        hour = hour + 1

        playSound()

        if hour == maxHourValue {
            hour = 0
        }
    }

    func playSound () {

        let times = hour

        let action = SCNAction.playAudio(cucoSound, waitForCompletion: true)
        hourPointer.runAction(SCNAction.repeat(action, count: times))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

}
