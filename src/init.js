import { Elm } from './Main.elm'
import * as CryptoJS from "crypto-js"

const ENCRYPTED_SLACK_API_TOKEN = process.env.ENCRYPTED_SLACK_API_TOKEN 



const app = Elm.Main.init({
    node: document.getElementById("mount"),
    flags: ENCRYPTED_SLACK_API_TOKEN,
});






app.ports.decrypt.subscribe(secret => {
  try {
    console.log('decrypting secret')
    const bytes     = CryptoJS.AES.decrypt(ENCRYPTED_SLACK_API_TOKEN, secret);
    const plaintext = bytes.toString(CryptoJS.enc.Utf8)
    
    if (plaintext.startsWith('xoxp'))
    {
        app.ports.getDecrypted.send(plaintext)  
    }
    
  } catch {
    console.error('decryption didnt go well. whatever ignore')
  }
});