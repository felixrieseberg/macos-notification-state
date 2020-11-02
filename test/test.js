/* global describe, it */

const assert = require('assert')
const { getSessionState, getNotificationState, getDoNotDisturb } = require('../lib/index')

if (process.platform !== 'darwin') {
  console.error('You can\'t run this test on a non-mac machine. Sorry!')
}

describe('getSessionState', () => {
  it('should return unknown or error', () => {
    const res = getSessionState()
    assert.strictEqual((res !== 'UNKNOWN'), true, 'Result is not unknown')
  })

  it('should return a SESSION_ON_CONSOLE_KEY (this test is flaky, but in most test cases, this should be true)', () => {
    const res = getSessionState()
    assert.strictEqual((res === 'SESSION_ON_CONSOLE_KEY'), true, 'Result is SESSION_ON_CONSOLE_KEY (normal result)')
  })
})

describe('getDoNotDisturb', () => {
  it('should return false', () => {
    assert.strictEqual(getDoNotDisturb(), false, 'doNotDisturb returns false')
  })
})

describe('getDoNotDisturb / getNotificationState test, interactive', () => {
  it('should correctly identify do not disturb', function (done) {
    this.timeout(20000)

    let secondsLeft = 8
    const interval = setInterval(() => {
      process.stdout.clearLine()
      process.stdout.cursorTo(5)
      process.stdout.write(`Please enable do not disturb. Starting test in ${secondsLeft}s...`)

      if (secondsLeft === 0) {
        console.log('')
        clearInterval(interval)

        assert.strictEqual(getDoNotDisturb(), true)
        assert.strictEqual(getNotificationState(), 'DO_NOT_DISTURB')
        done()
      }

      secondsLeft = secondsLeft - 1
    }, 1000)
  })
})
