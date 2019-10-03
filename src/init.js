import { Elm } from './Main.elm'
import * as CryptoJS from "crypto-js"

const ENCRYPTED_SLACK_API_TOKEN = process.env.ENCRYPTED_SLACK_API_TOKEN 

const app = Elm.Main.init({
    node: document.getElementById("mount"),
    flags: ENCRYPTED_SLACK_API_TOKEN,
});

app.ports.decrypt.subscribe(secret => {
  const bytes  = CryptoJS.AES.decrypt(ENCRYPTED_SLACK_API_TOKEN, secret);
  try {
    const plaintext = bytes.toString(CryptoJS.enc.Utf8)
    console.log(plaintext)
    if (plaintext.startsWith('xoxp')) {
        app.ports.getDecrypted.send()  
    }
  } catch {
    console.error('decryption didnt go well. whatever ignore')
  }
});