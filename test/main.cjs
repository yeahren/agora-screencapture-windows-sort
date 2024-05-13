var SortWindowsAddon = null

try {
    SortWindowsAddon = require("../build/Release/SortWindowsAddon.node")
} catch (error) {
    SortWindowsAddon = require("../build/Debug/SortWindowsAddon.node")
}


const list = SortWindowsAddon.getWindowsList()

console.log('t', list)
