const fs = require('fs');
const path = require('path');

function sortPhotos(sourceDir, dryRun) {
 
  if (!fs.existsSync(sourceDir)) {
    console.log('Source directory does not exist.');
    return;
  }

  const destinationDir = './sorted';
  const allowedExtensions = ['.jpg', '.jpeg', '.png', '.heic', '.webp'];
  const files = fs.readdirSync(sourceDir);

  for (let i = 0; i < files.length; i++) {
    const file = files[i];
    const oldPath = path.join(sourceDir, file)
    if (!fs.statSync(oldPath).isFile()) {
      continue;
    }
    const ext = path.extname(file).toLowerCase();
    if (!allowedExtensions.includes(ext)) {
      continue;
    }

    const match = file.match(/(\d{4})-(\d{2})-(\d{2})/);
    if (!match) {
      console.log('Skipping (no date): ' + file);
      continue;
    }

    const year = Number(match[1]);
    const month = Number(match[2]);
    const day = Number(match[3]);
    const date = new Date(year, month - 1, day);
    if (
      date.getFullYear() !== year ||
      date.getMonth() !== month - 1 ||
      date.getDate() !== day
    ) {
      console.log('Skipping (invalid date): ' + file);
      continue;
    }
    const yearFolder = path.join(destinationDir, String(year));
    const newPath = path.join(yearFolder, file);
    if (fs.existsSync(newPath)) {
      console.log('Skipping (already exists): ' + file);
      continue;
    }
    if (dryRun) {
      console.log('Would move: ' + file + ' -> ' + newPath);
    } else {
      fs.mkdirSync(yearFolder, { recursive: true });
      fs.renameSync(oldPath, newPath);
      console.log('Moved: ' + file + ' -> ' + newPath);
    }
  }
}
const sourceDir = process.argv[2];
const dryRun = process.argv.includes('--dry-run');

if (!sourceDir) {
  console.log('Usage: node sort_photos.js <source-directory> [--dry-run]');
} else {
  sortPhotos(sourceDir, dryRun);
}
