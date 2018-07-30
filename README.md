# Milestone 3

*Please refer to branch "latency" for the latest version.*

Samuel and Stephen
 
**Level of Achievement:**
Gemini

**Problem Motivation:**
We often found ourselves preparing and perfecting our speeches for the regular presentations we need to deliver. In the early stages of rehearsals, we naturally forgot key points and had to constantly refer to our keynote outline or script. For substantial presentations, scripts are often lengthy. It is time-consuming to locate the exact line which we forgot. This causes major disruptions the flow of our rehearsal. AutoCue was born from this need, a smart and responsive teleprompter for practising speeches. AutoCue recognises the current lines being rehearsed and automatically displays a cue card with the corresponding line of script. This allows the rehearsal to proceed smoothly with minimal hiccups. Although primarily constructed for presentation purposes, another potential application of AutoCue is for actors/actresses to rehearse lines for dramas on stage.

**Core Features:**
- Low latency Speech-to-Text recognition
- DropBox integration
- Pattern matching of recognised text to user’s script
- Automated swiping of cue cards based on pattern matching result

**Problems Encountered:**
When we initially added the ability to choose the path you wanted to download, we encountered two problems. Swift could not decipher the encoding of the file and it kept displaying the old speech. This confused us greatly as we initially thought that somehow adding a variable path to the download function was affecting the initialisation of the speech. The two errors also occurred at seemingly random  intervals, only adding to our confusion. We tried different ways of providing a variable path and scoured the web on info on the download function. In the end, we realised that the text files we were downloading actually were saved using different text encodings, ANSI and Unicode. We thus, provided a common denomination of encoding that was ASCII and if it couldn’t work, Swift would attempt to guess the encoding and decode it using it. The issue of displaying the wrong speech was because the speech took time to download. This meant that code would run and text would display before the correct speech is downloaded. As such we would have to get a response from the download function before carrying out the speech initialisation. 

Handling user action error. One particularly difficult portion was retrieving the responses in the AppDelegate file and ensuring that we sorted the responses before other code ran. This meant that if the app delegate has a successful response, we needed to somehow retrieve this response while pausing the flow of the code in the original class. And then from this original class decide what to do with the response. This troubled us somewhat because the app delegate was a class that is initialised before all else and so isn’t as easy to call. To display the error as well we needed to ensure that we were calling the right function to display the error. 

We also had to learn a whole new set of iOS classes for our implementation of the animated cue cards. The movement of the cue cards had to be perfectly in place to ensure that it was smooth and not appear to be “jumping” from the start to the end or back again as it resets. We spent many hours trying to find the correct positions for the cards to move into and getting the flow of the animation to seem smooth and natural to the speaker. 

We also encountered many unexpected problems late in our development. For example, there was no way to dismiss the keyboard after having typed in our path which blocked out the button to downloaded. We only realised there was such an issue when at the end, we decided to boot the application on a physical iPhone where previously we had always used the simulator in xCode which simply accepts the input from the hardware keyboard without bringing up the software keyboard. This prompted a rush to find a solution, some of which suggested a deep dive into the app delegate class. 

Lastly the latency involved in receiving back the transcription of what the person has said, This was an issue that had been plaguing us since the start of the project and at times it even seemed unsolvable as the time taken for the final transcription is fixed after all. Time is needed for it to recognise the audio and print the string. We eventually worked around it by making use of a less accurate transcription but increasing the amount of words it has to match, providing a balance between speed and accuracy. 


**Edge Features:**
- Animated movement of cue cards.
- Restart of speech midway for rehearsal
- Overriding of cue card display using swiping
- Pop-ups to notify user of any errors encountered 


**Bugs Squashed:**
- Starting and ending edge case
- Jumpy animations
- Cue cards failing to move or moving too fast
- Inability to dismiss software keyboard
- Subsequent downloads still loaded previous speech
- After segueing the second time to the Cue Cards, pressing back will show the previous speech Cue Cards. 

**User Testing:**
In addition to rigorous self-evaluation, we have mainly attempted Heuristic and Cognitive evaluations. We asked ourselves questions such as have we presented information that has meaningful aids to interpretation and limit data-driven tasks? This was done via animated Cue Cards view of their speech. Or have we used names that are conceptually related to function and automated unwanted workload? We have done this with buttons that simply and clearly state their purpose which would automatically transfer the user to the next part of the application. 
The user is also able to get appropriate feedback such as when he has formatted his path wrong or failed to input a speech into the text view. There is also a back button that is always visible should the user need to “escape”.

