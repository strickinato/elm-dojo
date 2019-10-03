import { Elm } from './Main.elm'

const HASHED_SLACK_API_TOKEN = process.env.HASHED_SLACK_API_TOKEN

Elm.Main.init({
    node: document.getElementById("mount"),
    flags: HASHED_SLACK_API_TOKEN,
});
