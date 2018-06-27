//
// Copyright 2016 Google Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
import UIKit
import AVFoundation
import googleapis
import SwiftyDropbox
import Foundation //only needed for Time API

let SAMPLE_RATE = 16000

class ViewController : UIViewController, AudioControllerDelegate {
    
    var audioData: NSMutableData!
    lazy var match = Match()
    
    @IBOutlet weak var textLabelCurrent: UILabel! {
        didSet {
            textLabelCurrent.numberOfLines = 0
        }
    }
    @IBOutlet weak var textLabelAhead: UILabel! {
        didSet {
            textLabelAhead.numberOfLines = 0
        }
    }
    
    @IBAction func login(_ sender: UIButton) {
        DropboxClientsManager.authorizeFromController(UIApplication.shared, controller: self, openURL: {(url: URL) -> Void in UIApplication.shared.openURL(url)})
    }
    
    @IBAction func download(_ sender: UIButton) {
        let client = DropboxClientsManager.authorizedClient
        let fileManager = FileManager.default
        let directoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let destURL = directoryURL.appendingPathComponent("myTestFile")//myTestFile will be the file name
        let destination: (URL, HTTPURLResponse) -> URL = { temporaryURL, response in
            return destURL
        }
        client!.files.download(path: "/test.txt", overwrite: true, destination: destination).response {response, error in
            if let response = response {
                print (response)
            } else if let error = error {
                print (error)
            }
            }
            .progress {progressData in print(progressData)
        }
        print("Success! Your speech has been imported. Press Start to start")
        print(destURL)
        do {
            match.fakeInit(document: try String(contentsOf: destURL))
        } catch {
            print(error)
        }
    }
        
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AudioController.sharedInstance.delegate = self
        
        
//        textLabelCurrent.text = match.stringForViewController(index: 0).current
//        textLabelAhead.text = match.stringForViewController(index: 0).ahead
    }
    
    @IBAction func recordAudio(_ sender: UIButton) {
        startStream()
        Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(timeController), userInfo: nil, repeats: true)
    }
    
    @objc func timeController() {
        print("called timecontroller")
        stopStream()
        startStream()
    }
    
    private func startStream() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
        } catch {
            
        }
        audioData = NSMutableData()
        _ = AudioController.sharedInstance.prepare(specifiedSampleRate: SAMPLE_RATE)
        SpeechRecognitionService.sharedInstance.sampleRate = SAMPLE_RATE
        _ = AudioController.sharedInstance.start()
    }
    
    private func stopStream(){
        _ = AudioController.sharedInstance.stop()
        SpeechRecognitionService.sharedInstance.stopStreaming()
    }
    
    @IBAction func stopAudio(_ sender: UIButton) {
        stopStream()
    }
    
    func processSampleData(_ data: Data) -> Void {
        audioData.append(data)
        
        // We recommend sending samples in 100ms chunks
        let chunkSize : Int /* bytes/chunk */ = Int(0.1 /* seconds/chunk */
            * Double(SAMPLE_RATE) /* samples/second */
            * 2 /* bytes/sample */);
        
        if (audioData.length > chunkSize) {
            SpeechRecognitionService.sharedInstance.streamAudioData(audioData,
                                                                    completion:
                { [weak self] (response, error) in
                    guard let strongSelf = self else {
                        return
                    }
                    
                    if let error = error {
                        strongSelf.textLabelCurrent.text = error.localizedDescription
                        self?.textLabelCurrent.text = error.localizedDescription
                    } else if let response = response {
                        for result in response.resultsArray! {
                            if let result = result as? StreamingRecognitionResult {
                                if result.isFinal {
                                    if let result = result.alternativesArray[0] as? SpeechRecognitionAlternative {
                                        let presentedText = self?.match.compareStringWithSentences(googleString: result.transcript!)
                                        self!.textLabelCurrent.text = presentedText?.current
                                        self!.textLabelAhead.text = presentedText?.ahead
                                    }
                                }
                            }
                        }
                    }
            })
            self.audioData = NSMutableData()
        }
    }
}
