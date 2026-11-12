import { extract } from "./extract";

const text = `Slept about six hours, two coffees, walked for twenty minutes. Stressed about the release but mood was okay.`;
const r = await extract("claude-haiku-5-5", text);

console.log(JSON.stringify(r.data, null, 2));
console.log(
  "stop:",
  r.stop,
  "| tokens in/out:",
  r.usage.input_tokens,
  r.usage.output_tokens,
);
