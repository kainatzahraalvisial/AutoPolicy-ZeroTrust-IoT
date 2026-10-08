import { writeFileSync } from "node:fs";
import { S, AR, SC, TH } from "./src/narrative.js";
writeFileSync(
  "../assets/renderer/story.json",
  JSON.stringify({ explore: S, arch: AR, sec: SC, threats: TH }, null, 2),
);
