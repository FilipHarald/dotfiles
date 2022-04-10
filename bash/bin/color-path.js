#!/usr/bin/env node

const readline = require('readline');
const crypto = require('crypto');

const COLOR_BASE = 128;
const DELIMITER = '/';

var rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
  terminal: false
});

const getColor = (str) => {
  const buf = crypto.createHash('md5').update(str).digest();
  const red = buf.readUInt8(0) >> 1;
  const green = buf.readUInt8(1) >> 1;
  const blue = buf.readUInt8(2) >> 1;
  const paletteNbr = buf.readUInt8(0) % 3;
  switch (paletteNbr) {
    case 0:
      return [
        COLOR_BASE + red,
        COLOR_BASE + green,
        COLOR_BASE
      ];
    case 1:
      return [
        COLOR_BASE + red,
        COLOR_BASE,
        COLOR_BASE + blue
      ];
    case 2:
      return [
        COLOR_BASE,
        COLOR_BASE + green,
        COLOR_BASE + blue
      ];
  }
}

const colorize = (str, r, g, b) => {
  return `\\[\u001B[0;38;2;${r};${g};${b}m\\]${str}\\[\x1b[00m\\]`;
};

// not enough escaping
// const colorize = (str, r, g, b) => {
//   return `\u001B[0;38;2;${r};${g};${b}m${str}\x1b[00m`;
// };

rl.on('line', function(line){
  const words = line.split(DELIMITER);
  const coloredWords = words.map((word, index) => {
    if (!word) return;
    const parents = words.slice(0, index + 1);
    const color = getColor(parents.join());
    return colorize(word, ...color);
  });
  console.log(coloredWords.join('/'));
});

