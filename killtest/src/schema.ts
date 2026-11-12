import { z } from "zod";

const field = <T extends z.ZodTypeAny>(value: T) =>
  z.object({ value, evidence: z.string() });

export const Extraction = z.object({
  sleep_hours: field(z.number().nullable()),
  sleep_quality: field(z.number().nullable()),
  mood: field(z.number().nullable()),
  energy: field(z.number().nullable()),
  stress: field(z.number().nullable()),
  caffeine_cups: field(z.number().nullable()),
  exercise_type: field(
    z.enum(["none", "walk", "gym", "run", "yoga", "other"]).nullable(),
  ),
  exercise_minutes: field(z.number().nullable()),
  notes: z.string(),
});

export const FIELDS = Object.keys(Extraction.shape).filter(
  (k) => k !== "notes",
);
