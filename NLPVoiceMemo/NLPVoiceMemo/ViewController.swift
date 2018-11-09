//
//  ViewController.swift
//  NLPVoiceMemo
//
//  Created by Anoop tomar on 4/4/18.
//  Copyright © 2018 Devtechie. All rights reserved.
//

import UIKit
import Speech

class ViewController: UIViewController {
    
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var speakerButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var recordingButton: UIButton!
    
    @IBOutlet weak var recordingView: UIView!
    @IBOutlet weak var recordedMessage: UITextView!
    @IBOutlet weak var stopButton: UIButton!
    
    @IBOutlet weak var fadedView: UIView!
    
    var memoData: [Memo]!
    
    // speech related code
    
    lazy var speechRecognizer: SFSpeechRecognizer? = {
        if let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US")) {
            recognizer.delegate = self
            return recognizer
        }
        else {
            return nil
        }
    }()
    
    lazy var audioEngine: AVAudioEngine = {
        let audioEngine = AVAudioEngine()
        return audioEngine
    }()
    
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    
//    let taggerOptions: NSLinguisticTagger.Options = [.joinNames, .omitWhitespace]
//    lazy var linguisticTagger: NSLinguisticTagger = {
//        let tagScheme = NSLinguisticTagger.availableTagSchemes(forLanguage: "en")
//        return NSLinguisticTagger(tagSchemes: tagScheme, options: Int(self.taggerOptions.rawValue))
//    }()
    
    // end speech

    override func viewDidLoad() {
        super.viewDidLoad()
        memoData = []
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        
        // speech related
        self.recordingView.isHidden = true
        self.fadedView.isHidden = true
        
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    self.recordingButton.isEnabled = true
                case .denied:
                    self.recordingButton.isEnabled = false
                case .restricted:
                    self.recordingButton.isEnabled = false
                case .notDetermined:
                    self.recordingButton.isEnabled = false
                }
            }
        }
        // end speech
    }

    @IBAction func recordButton(sender: UIButton) {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            
        } else {
            startRecording()
            self.recordingView.isHidden = false
            self.fadedView.alpha = 0.0
            self.fadedView.isHidden = false
            UIView.animate(withDuration: 1.0) {
                self.fadedView.alpha = 1.0
            }
        }
    }
    
    @IBAction func stopRecording(sender: UIButton) {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            audioEngine.inputNode.removeTap(onBus: 0)
            self.memoData.append(Memo(memoTitle: "New Recording", memoDate: Date(), memoText: self.recordedMessage.text!))
            UIView.animate(withDuration: 0.5, animations: {
                self.fadedView.alpha = 0.0
            }) { (finished) in
                self.fadedView.isHidden = true
                self.recordingView.isHidden = true
                self.tableView.reloadData()
            }
            
        }
    }
    
    // speech related code
    func startRecording() {
        if let recognitionTask = self.recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        self.recordedMessage.text = ""
        
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(AVAudioSessionCategoryRecord)
        try? audioSession.setMode(AVAudioSessionModeMeasurement)
        try? audioSession.setActive(true, with: AVAudioSessionSetActiveOptions.notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let recognitionRequest = self.recognitionRequest else {
            fatalError("Unable to create a SFSpeechAudioBufferRecognitionRequest object.")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            
            var isFinal = false
            if let result = result {
                let sentence = result.bestTranscription.formattedString
                //self.linguisticTagger.string = sentence
                self.recordedMessage.text = sentence
//                let range = NSMakeRange(0,(sentence as NSString).length)
//                self.linguisticTagger.enumerateTags(in: range, scheme: .lexicalClass, options: self.taggerOptions, using: { (tag, tokenRange, _, _) in
//                    let token = (sentence as NSString).substring(with: tokenRange)
//                    print("\(token) -> \(range)")
//                })
                isFinal = result.isFinal
            }
            if error != nil || isFinal {
                self.audioEngine.stop()
                self.audioEngine.inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
                self.recordingButton.isEnabled = true
            }
            
        })
        
        let recordingFormat = audioEngine.inputNode.outputFormat(forBus: 0)
        audioEngine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        audioEngine.prepare()
        try? audioEngine.start()
    }
    // end speech
    
    
}
extension ViewController: SFSpeechRecognizerDelegate {}
extension ViewController: UITableViewDelegate {}
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memoData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! CustomCell
        let memo = memoData[indexPath.row]
        cell.titleLabel.text = memo.memoTitle
        cell.dateLabel.text = memo.memoDate.description
        cell.memoLabel.text = memo.memoText
        return cell
    }
}
