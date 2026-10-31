import {
  appendCitations, parseSourcedReply, shortenWithCitations,
  verificationInput, verificationPassed,
} from './coach_citations.ts'

function assert(condition: unknown, message = 'Assertion failed'): asserts condition {
  if (!condition) throw new Error(message)
}

function reply(overrides: Record<string, unknown> = {}) {
  return JSON.stringify({ answer: 'Auch Gehen zählt als Bewegung [1].',
    contains_health_guidance: true, source_ids: ['who-activity'], ...overrides })
}

Deno.test('valid source ids become canonical links, preserved in history', () => {
  const parsed = parseSourcedReply(reply())!
  assert(parsed)
  for (const english of [false, true]) {
    const answer = appendCitations(parsed.answer, parsed.ids, english)
    assert(answer.includes('https://www.who.int/news-room/fact-sheets/detail/physical-activity'))
    assert(answer.includes(english ? '\n\nSources:\n' : '\n\nQuellen:\n'))
    const longAnswer = appendCitations('Text '.repeat(600), parsed.ids, english)
    const shortened = shortenWithCitations(longAnswer, 1200)
    assert(shortened.length <= 1200)
    assert(shortened.endsWith('detail/physical-activity)'))
  }
})

Deno.test('citation verification fails closed and uses selected server facts', () => {
  assert(verificationPassed('{"supported":true}'))
  for (const raw of [null, '', '{}', '{"supported":false}',
    '{"supported":"true"}', '{"supported":true,"extra":1}']) {
    assert(!verificationPassed(raw))
  }
  const input = JSON.parse(verificationInput('Kalorien sind Energie. [1]', ['nhs-calories']))
  assert(input.sources.length === 1)
  assert(input.sources[0].reference === 1)
  assert(input.sources[0].facts.includes('Kalorien'))
  assert(!JSON.stringify(input).includes('who-activity'))
})

Deno.test('missing evidence, fabricated ids, URLs and broken references are rejected', () => {
  for (const raw of [
    'Unstructured health advice', '{"answer":',
    reply({ source_ids: [] }), reply({ source_ids: ['invented'] }),
    reply({ source_ids: ['who-activity', 'who-activity'] }),
    reply({ answer: 'Bewegung [2].' }),
    reply({ answer: 'Behauptung ohne Referenz.' }),
    reply({ answer: 'Siehe https://evil.example [1].' }),
    reply({ answer: '[Quelle](file:///test) [1].' }),
    reply({ source_ids: [null] }),
    reply({ contains_health_guidance: 'false' }),
    reply({ answer: 'A'.repeat(2801) }),
  ]) assert(parseSourcedReply(raw) === null, raw)
})

Deno.test('recipes, app help and refusals do not receive unrelated references', () => {
  const parsed = parseSourcedReply(reply({ answer: 'Bitte frage eine Fachkraft.',
    contains_health_guidance: false, source_ids: [] }))!
  assert(parsed)
  assert(appendCitations(parsed.answer, parsed.ids, false) === parsed.answer)
})
