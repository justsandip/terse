import { readFileSync } from 'node:fs';
import { parse } from 'csv-parse/sync';
import { extract } from './extract';

type Row = Record<string, string>;
const read = (p: string): Row[] => parse(readFileSync(p), { columns: true, skip_empty_lines: true });
const entries = read('data/entries.csv').filter((e) => e.split === 'dev');
const labels = read('data/labels.csv');

const FIELDS = ['sleep_hours', 'sleep_quality', 'mood', 'energy', 'stress', 'caffeine_cups', 'exercise_type', 'exercise_minutes'] as const;

for (const e of entries) {
  const r = await extract('claude-haiku-5-5', e.text ?? '');
  console.log(`\n${e.entry_id}: ${e.text}`);
  if (!r.data) {
    console.log(`  NO DATA (stop=${r.stop})`);
    continue;
  }
  for (const f of FIELDS) {
    const truth = labels.find((l) => l.entry_id === e.entry_id && l.field === f)?.truth ?? '?';
    const got = String(r.data[f].value ?? 'NA');
    console.log(`  ${f.padEnd(17)} truth=${truth.padEnd(4)} model=${got.padEnd(4)} ${truth === got ? '' : '<-- differs'}`);
  }
  console.log(`  notes: ${r.data.notes}`);
}
