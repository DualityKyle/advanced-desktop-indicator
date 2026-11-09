/*
    SPDX-FileCopyrightText: 2022-2026 Kyle McGrath <dualitykyle@pm.me>

    SPDX-License-Identifier: GPL-3.0-or-later
*/

.pragma library

// Per-screen lists for allScreens mode, stored as JSON text. One
// list per screen by position. The first screen (0) uses the
// normal setting so its slot stays empty.

// An empty or broken text retunrs no lists instead of an error
function parse(text) {
  try {
    const lists = JSON.parse(text || "[]");
    return Array.isArray(lists) ? lists : [];
  } catch (error) {
    return [];
  }
}

function listFor(text, screen) {
  return parse(text)[screen] ?? [];
}

// Returns new JSON text with one entry changed
function withEntry(text, screen, index, value) {
  const lists = parse(text);
  while (lists.length <= screen)
    lists.push([]);
  const list = lists[screen] ?? [];
  while (list.length <= index)
    list.push("");
  list[index] = value;
  lists[screen] = list;
  return JSON.stringify(lists);
}
