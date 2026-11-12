import { existsSync, readFileSync, writeFileSync } from "node:fs";
import { parse } from "csv-parse/sync";
import { FIELDS } from "./schema";

type Row = Record<string, string>;
const read = (p: string) =>
  parse(readFileSync(p), { columns: true, skip_empty_lines: true }) as Row[];
const path = "data/labels.csv";
const have = new Set(
  existsSync(path) ? read(path).map((r) => `${r.entry_id}|${r.field}`) : [],
);
let out = existsSync(path)
  ? readFileSync(path, "utf8").replace(/\n*$/, "\n")
  : "entry_id,field,truth\n";
let added = 0;
for (const e of read("data/entries.csv")) {
  for (const f of FIELDS) {
    if (have.has(`${e.entry_id}|${f}`)) continue;
    out += `${e.entry_id},${f},TODO\n`;
    added++;
  }
}
writeFileSync(path, out);
console.log(`added ${added} TODO rows to ${path}`);
