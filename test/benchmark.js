// This is pretty simple and dumb.

function usingNative() {
  const { getDoNotDisturb } = require('../lib/index')
  return getDoNotDisturb()
}

async function usingExec() {
  const { exec } = require('child_process')
  return await new Promise((resolve) => {
    exec('defaults read ~/Library/Preferences/ByHost/com.apple.notificationcenterui.plist', (error, stdout) => {
      resolve(stdout.trim() === '1')
    })
  })
}

console.time('macos-notification-state')
usingNative()
console.timeEnd('macos-notification-state')

console.time('exec')
usingExec().then(() => console.timeEnd('exec'))
