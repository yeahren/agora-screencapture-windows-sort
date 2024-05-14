#### Install
```bash
$ npm install agora-screencapture-windows-sort
```
#### Demo
```javascript
const getWindowList = require("agora-screencapture-windows-sort")
const { createAgoraRtcEngine } = require("agora-electron-sdk");

// ... init Engine
const rtcEngine = createAgoraRtcEngine();


//... sort sourcesList
const sourcesList= rtcEngine.getScreenCaptureSources(
        { width: 1920, height: 1080 },
        { width: 32, height: 32 },
        true
        )
const sortedSourcesList = getWindowList(sourceList)

```

#### FAQ
```bash
# if got issue about openssl_fips=''
npm install --openssl_fips=''
```