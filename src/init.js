import { Elm } from './Main.elm'
import * as CryptoJS from "crypto-js"

const SLACK_API_TOKEN = process.env.SLACK_API_TOKEN

 
// Encrypt
const ciphertext = CryptoJS.AES.encrypt('my message', 'secret key 123');
 
// Decrypt
const bytes  = CryptoJS.AES.decrypt(ciphertext.toString(), 'secret key 123');
const plaintext = bytes.toString(CryptoJS.enc.Utf8);
 

const app = Elm.Main.init({
    node: document.getElementById("mount"),
    flags: SLACK_API_TOKEN,
});

app.ports.decrypt.subscribe(data => {
  console.log(data)
});