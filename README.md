#### Install
```bash
npm install agora-screencapture-windows-sort
# or
npm install --openssl_fips=''
```
#### Demo
```javascript
const getWindowList = require("agora-screencapture-windows-sort")
const { createAgoraRtcEngine } = require("agora-electron-sdk");

// ... init Engine
const rtcEngine = createAgoraRtcEngine();
this.rtcEngine = rtcEngine

//... sort sourcesList
const sourcesList= this.rtcEngine.getScreenCaptureSources(
        { width: 1920, height: 1080 },
        { width: 32, height: 32 },
        true
        )
const sortedSourcesList = getWindowList(sourceList)

```