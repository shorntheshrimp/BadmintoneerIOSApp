//
//  AcknowledgementsViewController.swift
//  Badmintoneer_App
//
//  Created by Shawn Tham on 11/6/21.
//

import UIKit

class AcknowledgementsViewController: UIViewController {

    @IBOutlet weak var ackTV: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        ackTV.textAlignment = NSTextAlignment.left
        
        ackTV.text = """
            Copyright (c) 2021 Tham Zhi Wei Shawn

            Portions of this Apple Software may utilise the following copyrighted material, the use of which is hereby acknowledged:




            YouTube - (IFrame Player API)
            The YouTube API Services (as defined below) are provided to you by YouTube LLC located at 901 Cherry Ave., San Bruno CA 94066 (referred to as "YouTube", "we", "us", or "our"). This YouTube API Services Terms of Service ("Terms of Service") is a legal document you must comply with at all times when accessing or using the YouTube API Services. The "YouTube API Services" means (i) the YouTube API services (e.g., YouTube Data API service and YouTube Reporting API service) made available by YouTube including those YouTube API services made available on the YouTube Developer Site (as defined below), (ii) documentation, information, materials, sample code and software (including any human-readable programming instructions) relating to YouTube API services that are made available on the YouTube Developer Site or by YouTube, (iii) data, content (including audiovisual content) and information provided to API Clients (as defined below) through the YouTube API services (the "API Data"), and (iv) the credentials assigned to you and your API Client(s) by YouTube or Google. By accessing and using the YouTube API Services, and in return for receiving the benefits of the YouTube API Services provided to you by YouTube, you agree to be bound by the Agreement (https://developers.google.com/youtube/terms/api-services-terms-of-service).

            The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

            THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


            Google - (Firebase)
            Use of Firebase service is subject to the application terms(https://firebase.google.com/terms)

            The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

            THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


            Ttsmp3.com - (Free text-to-speech and text-to-mp3 for US English)
            Use of Ttsmp3 service is subject to the application terms(https://ttsmp3.com/tos)

            The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

            THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.



            Code Sources:
            https://firebase.google.com/docs/auth
            
            Login features - https://www.youtube.com/watch?v=1HN7usMROt8&list=RDCMUC2D6eRvCeMtcF5OGHf1-trw&start_radio=1&rv=1HN7usMROt8&t=5597

            https://stackoverflow.com/questions/48594536/how-to-pass-a-type-of-uiviewcontroller-to-a-function-and-type-cast-a-variable-in

            https://stackoverflow.com/questions/24380535/how-to-apply-gradient-to-background-view-of-ios-swift-app

            https://stackoverflow.com/questions/38159397/how-to-check-if-a-string-is-an-int-in-swift

            https://stackoverflow.com/questions/10316902/rounded-corners-only-on-top-of-a-uiview

            https://www.youtube.com/watch?v=3TbdoVhgQmE

            https://stackoverflow.com/questions/26261011/how-to-choose-a-random-enumeration-value

            https://stackoverflow.com/questions/30633566/how-to-reset-restart-viewcontroller-in-swift/40172257

            https://stackoverflow.com/questions/39346449/how-to-set-2-lines-of-attribute-string-in-uilabel
            https://www.hackingwithswift.com/articles/113/nsattributedstring-by-example

            https://stackoverflow.com/questions/604632/how-do-you-add-multi-line-text-to-a-uibutton

            Accelerometer setup - https://www.youtube.com/watch?v=XDuchXYiWuE

            https://www.hackingwithswift.com/example-code/media/how-to-play-sounds-using-avaudioplayer

            https://www.appcoda.com/youtube-api-ios-tutorial/
            https://stackoverflow.com/questions/30290483/how-to-use-youtube-api-v3

            https://developers.google.com/youtube/v3/guides/ios_youtube_helper

            https://medium.com/@amlcurran/improving-completion-blocks-in-swift-e270506ab48a

            https://betterprogramming.pub/completion-handler-in-swift-4-2-671f12d33178

            https://www.weheartswift.com/how-to-make-a-simple-table-view-with-ios-8-and-swift/

            https://stackoverflow.com/questions/29986957/save-custom-objects-into-nsuserdefaults

            https://stackoverflow.com/questions/51487622/unarchive-array-with-nskeyedunarchiver-unarchivedobjectofclassfrom

            https://stackoverflow.com/questions/27987048/shake-animation-for-uitextfield-uiview-in-swift/38790163
            """
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
