---
name: gym-training-log
description: Use when the user pastes a plaintext gym workout, training log, exercise list, series, reps, or loads and wants it added to treningi/dziennik-treningow.md. Parses informal Polish workout notes into the existing gym training diary format.
---

# Gym Training Log

Use this skill when the user pastes a plaintext gym workout and asks to save,
add, append, log, or record it in the gym training diary.

## Target File

Default target path from the active vault or repository:

`treningi/dziennik-treningow.md`

If the active working directory is not the gym plan directory, search for that
relative path before creating any new file.

## Workflow

1. Read the existing diary file before editing.
2. Preserve the diary's existing Markdown style, headings, table columns, and
   ASCII spelling conventions.
3. Extract the workout date and title from the pasted text.
4. If the pasted text gives only day and month, infer the current year from the
   system date unless the user gave a different year.
5. Normalize obvious typos only when the intended exercise is clear.
6. Convert exercises into the existing table format:
   `Cwiczenie | Serie x powtorzenia | Obciazenie | Notatki`.
7. Preserve per-set differences in reps, load, side, bodyweight, or notes.
8. Append the new workout under `## Wpisy`; keep existing entries unchanged.
9. Run `git diff --check` when the diary is inside a Git repository.

## Parsing Rules

- Keep exercise names concise and consistent with previous entries when the
  same movement already exists in the diary.
- Put set-by-set reps in `Serie x powtorzenia`, for example `1x6, 1x6, 1x4, 1x4`.
- Put weight in `Obciazenie`, for example `20 kg hantle`, `22 kg`, or
  `masa ciala`.
- Put mixed or unclear load details in `Notatki`, for example
  `pierwsza seria masa wlasna + 15 kg, serie 2-3 masa wlasna + 5 kg`.
- Do not invent RPE, pain, tempo, rest time, or next-session recommendations.
- Leave summary bullets blank unless the user provided that information.

## Output

Summarize:

- diary file changed
- workout date and title added
- exercises logged
- validation performed
