import Anthropic from "@anthropic-ai/sdk";
import { zodOutputFormat } from "@anthropic-ai/sdk/helpers/zod";
import { Extraction } from "./schema";
import { SYSTEM } from "./prompt";

const client = new Anthropic();

export async function extract(model: string, text: string) {
  const res = await client.messages.parse({
    model,
    max_tokens: 1024,
    system: SYSTEM,
    messages: [{ role: "user", content: text }],
    output_config: { format: zodOutputFormat(Extraction) },
  });
  return { data: res.parsed_output, usage: res.usage, stop: res.stop_reason };
}
 