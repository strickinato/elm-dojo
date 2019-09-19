import { Elm } from './src/Main.elm'

const SLACK_API_TOKEN = process.env.SLACK_API_TOKEN

Elm.Main.init({
    node: document.getElementById("mount"),
    flags: SLACK_API_TOKEN,
});
