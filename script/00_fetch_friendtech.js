// Usage: node 00_fetch_friendtech.js <output_filename>
const https = require('https');
const fs = require('fs');

const url = 'https://friendmex.com/api/stats/leaderboard';

// Check for output filename argument
if (process.argv.length < 3) {
    console.log('Usage: node 00_fetch_friendtech.js <output_filename>');
    process.exit(1);
}

const outputFilename = process.argv[2];

https.get(url, (response) => {
    let data = '';

    // A chunk of data has been received.
    response.on('data', (chunk) => {
        data += chunk;
    });

    // The whole response has been received.
    response.on('end', () => {
        fs.writeFile(outputFilename, data, 'utf8', (err) => {
            if (err) {
                console.error('Error writing to file:', err);
                return;
            }
            console.log(`Data has been written to ${outputFilename}`);
        });
    });

}).on("error", (err) => {
    console.log("Error: " + err.message);
});
