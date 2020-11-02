// This is pretty simple and dumb.

function usingNative () {
  const { getDoNotDisturb } = require('../lib/index')
  return getDoNotDisturb()
}

function usingExec () {
  const { exec } = require('child_process')
  return new Promise((resolve, reject) => {
    exec('defaults read ~/Library/Preferences/ByHost/com.apple.notificationcenterui.plist', (error, stdout) => {
      if (error) {
        return reject(error)
      }

      resolve(stdout.trim() === '1')
    })
  })
}

async function test () {
  console.log('Checking dnd with native code (100.000 times)')
  console.time('macos-notification-state')
  for (let index = 0; index < 100000; index++) {
    usingNative()
  }
  console.timeEnd('macos-notification-state')

  console.log('Checking dnd with exec (100 times)')
  console.time('exec')
  for (let index = 0; index < 100; index++) {
    await usingExec()
  }
  console.timeEnd('exec')
}

test()
