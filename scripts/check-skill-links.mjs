/**
 * Skill link integrity — the failure mode this guards against is an index
 * link that resolves to nothing: the agent reads nothing and silently falls
 * back to inventing (Nord's design-system skill shipped ~60 of these).
 *
 * For every plugins/<plugin>/skills/<skill>/:
 *  1. every relative link in SKILL.md and references/*.md resolves to a file
 *  2. every file under references/ is linked from SKILL.md (unreachable
 *     reference = dead weight the agent will never read)
 *
 * External URLs, pure #anchors, and repo-external paths (e.g. app-repo paths,
 * which are validated by the app repo's design:migration-doc script) are out
 * of scope — only relative links are checked.
 */
import { existsSync, readFileSync, readdirSync, statSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';

const root = resolve(import.meta.dirname, '..');
const errors = [];

const skillDirs = [];
for (const plugin of readdirSync(join(root, 'plugins'))) {
  const skillsRoot = join(root, 'plugins', plugin, 'skills');
  if (!existsSync(skillsRoot)) continue;
  for (const skill of readdirSync(skillsRoot)) {
    const dir = join(skillsRoot, skill);
    if (statSync(dir).isDirectory() && existsSync(join(dir, 'SKILL.md'))) skillDirs.push(dir);
  }
}

const LINK = /\[[^\]]*\]\(([^)\s]+)\)/g;

for (const dir of skillDirs) {
  const mdFiles = [join(dir, 'SKILL.md')];
  const refsDir = join(dir, 'references');
  const refFiles = existsSync(refsDir)
    ? readdirSync(refsDir)
        .filter((f) => !f.startsWith('.'))
        .map((f) => join(refsDir, f))
    : [];
  mdFiles.push(...refFiles.filter((f) => f.endsWith('.md')));

  const linkedTargets = new Set();
  for (const file of mdFiles) {
    const text = readFileSync(file, 'utf8');
    for (const [, target] of text.matchAll(LINK)) {
      if (/^[a-z]+:/i.test(target) || target.startsWith('#')) continue;
      const path = resolve(dirname(file), target.split('#')[0]);
      if (!path.startsWith(dir)) continue; // repo-external: not ours to check
      if (!existsSync(path)) {
        errors.push(`${file}: broken link → ${target}`);
      } else if (file.endsWith('SKILL.md')) {
        linkedTargets.add(path);
      }
    }
  }

  for (const ref of refFiles) {
    if (!linkedTargets.has(ref)) {
      errors.push(`${join(dir, 'SKILL.md')}: references/${ref.split('/').pop()} is never linked`);
    }
  }
}

if (errors.length > 0) {
  console.error(`${errors.length} skill link problem(s):`);
  for (const e of errors) console.error(`  ${e}`);
  process.exit(1);
}
console.log(`checked ${skillDirs.length} skills — all links resolve, all references reachable`);
